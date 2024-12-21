
-- Q1

create or replace view AllRatings(taster,beer,brewer,rating)
as
select t.given,b.name,br.name,r.score
from   Taster t, Beer b, Brewer br, Ratings r
where  r.taster = t.id and r.beer = b.id and b.brewer = br.id
order  by t.given, r.score desc;
;

-- Q2

create or replace view JohnsFavouriteBeer(brewer,beer)
as
select brewer,beer
from   AllRatings
where  taster = 'John' and
       rating = (select max(rating) from AllRatings
       		 where  taster = 'John')
;

-- alternative solution

create or replace view JohnsRatedBeers(beer,brewer,rating)
as
select beer,brewer,rating
from   AllRatings
where  taster = 'John'
;

create or replace view JohnsFavouriteBeer1(brewer,beer)
as
select brewer,beer
from   JohnsRatedBeers
where  rating = (select max(rating) from JohnsRatedBeers)
;

-- Q3

create type BeerInfo as (brewer text, beer text);

create or replace function FavouriteBeer(text) returns setof BeerInfo
as $$
select brewer,beer
from   AllRatings
where  taster = $1 and
       rating = (select max(rating) from AllRatings
       		 where  taster = $1)
$$ language sql
;

-- Q4

create or replace function BeerStyle(brewer text, beer text) returns text
as $$
select s.name
from   Beer b, Brewer br, BeerStyle s
where  lower(br.name) = lower($1) and lower(b.name) = lower($2)
	 and b.brewer = br.id and b.style = s.id
$$ language sql
;

-- Q5a

create or replace function TasterAddress(text) returns text
as $$
      select case
             when loc.state is null then loc.country
             when loc.country is null then loc.state
             else loc.state||', '||loc.country
             end
      from   Taster t, Location loc
      where  t.given = $1 and t.livesIn = loc.id
$$ language sql
;

-- BeerSummary function

-- when we call BeerDisplay, we have a string of tasters that looks like
-- ', John, Sarah' because of the way we built the string in BeerSummary
-- substr(_tasters,3,...) simply trims off the leading ', '

create or replace function
	BeerDisplay(_beer text, _rating float, _tasters text) returns text
as $$
begin
	return E'\n' ||
	       'Beer:    ' || _beer || E'\n' ||
	       'Rating: ' || to_char(_rating,'9.9') || E'\n' ||
	       'Tasters: ' || substr(_tasters,3,length(_tasters)) || E'\n';
end;
$$ language plpgsql;

create or replace function
	BeerSummary() returns text
as $$
declare
	r       record;
	out     text := '';
	curbeer text := '';
	tasters text;
	sum     integer;
	count   integer;
begin
	for r in select * from AllRatings order by beer,taster
	loop
		if (r.beer <> curbeer) then
			if (curbeer <> '') then
				out := out || BeerDisplay(curbeer,sum::numeric/count,tasters);
			end if;
			curbeer := r.beer;
			sum := 0; count := 0; tasters := '';
		end if;
		sum := sum + r.rating;
		count := count + 1;
		tasters := tasters || ', ' || r.taster;
	end loop;
	-- finish off the last beer
	out := out || beerDisplay(curbeer,sum::numeric/count,tasters);
	return out;
end;
$$ language plpgsql;


-- Concat aggregate

create or replace function
	appendNext(_state text, _next text) returns text
as $$
begin
	return _state||','||_next;
end;
$$ language plpgsql;

create or replace function
	finalText(_final text) returns text
as $$
begin
	return substr(_final,2,length(_final));
end;
$$ language plpgsql;

create aggregate concat (text)
(
	stype     = text,
	initcond  = '',
	sfunc     = appendNext,
	finalfunc = finalText
);

-- for pre-8.2 versions of PostgreSQL
-- create aggregate concat (
-- 	basetype  = text,
-- 	stype     = text,
-- 	initcond  = '',
-- 	sfunc     = appendNext,
-- 	finalfunc = finalText
-- );


-- BeerSummary view

create or replace view BeerSummary(beer,rating,tasters)
as
select beer, to_char(avg(rating),'9.9'), concat(taster)
from   AllRatings
group  by beer
;
