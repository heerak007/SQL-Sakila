use sakila;

-- 1a. Display the first and last names of all actors from the table actor
select first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name, ' ', last_name) as 'Actor Name' 
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
select actor.actor_id, actor.first_name, actor.last_name 
from actor 
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
select actor.actor_id, actor.first_name, actor.last_name 
from actor 
where last_name like "%gen%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor.actor_id, actor.last_name, actor.first_name 
from actor 
where last_name like "%li%";

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
select country.country_id, country.country 
from country 
where country.country in("Afghanistan", "Bangladesh", "China");

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
-- Hint: you will need to specify the data type.
alter table actor
add middle_name varchar(15) after first_name;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.
alter table actor
modify column middle_name blob;

-- 3c. Now delete the middle_name column.
alter table actor
drop column middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select actor.last_name, count(last_name)
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select actor.last_name, count(last_name) as LastCount
from actor
group by last_name
having LastCount > 1
;

-- 4c, 4d:  Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
select actor.actor_id, actor.first_name, actor.last_name 
from actor 
where last_name = "Williams"
;
-- actor_id = 172

update actor set first_name='HARPO' 
where first_name='groucho' and last_name="williams"
;

-- one way to do 4d
	update actor a2 set a2.first_name=case
		when a2.first_name = "harpo" then "GROUCHO"
		else "MUCHO GROUCHO"
		end
	where a2.actor_id = (
	
		select actor_id
		from (
    
			select a1.actor_id 
			from actor a1
			where a1.last_name="Williams" and (a1.first_name="Harpo" or a1.first_name="Groucho" or a1.first_name="Mucho Groucho")
    
		) s
		);

-- second way to do 4d   
	update actor as a2 , (	select actor_id 
										from actor  
										where last_name="Williams" and (first_name="Harpo" or first_name="Groucho" or first_name="Mucho Groucho")
                                        ) as a1

	set a2.first_name=case
		when a2.first_name = "harpo" then "GROUCHO"
		else "MUCHO GROUCHO"
		end
	where a2.actor_id = a1.actor_id;


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
select s.first_name, s.last_name, a.address, c.city, ctry.country
from staff s
left join address a
on s.address_id=a.address_id
left join city c
on a.city_id=c.city_id
left join country ctry
on c.country_id=ctry.country_id
;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, s.last_name, sum(p.amount) as `Total Rung Up`
from payment p
join staff s on p.staff_id=s.staff_id
group by s.staff_id
;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(a.actor_id)
from film_actor a
inner join film f on a.film_id=f.film_id
group by a.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(i.film_id) 
from inventory i
where film_id = (select film_id from film where title like "hunchba%")
;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
select c.first_name, c.last_name, sum(p.amount) as `Total Paid`
from payment p
join customer c on p.customer_id=c.customer_id
group by p.customer_id
ORDER BY c.last_name asc
;

-- 7a. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title, language_id from film
where (title like "k%" or title like "q%") and language_id = (
		select language_id
        from language
        where name = "english"
)
;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select actor.first_name, actor.last_name from actor
where actor_id in 
	(
		select actor_id from film_actor
		where film_id = 
			(
				select film_id from film where title = 'Alone Trip'
			)
	)
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
-- and email addresses of all Canadian customers. Use joins to retrieve this information.
select s.first_name, s.last_name, s.email, c.city, ctry.country
from customer s
left join address a
on s.address_id=a.address_id
left join city c
on a.city_id=c.city_id
left join country ctry
on c.country_id=ctry.country_id
where ctry.country = 'Canada'
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select f.title
from film_category fc inner join film f on f.film_id=fc.film_id
where fc.category_id = (select category_id from category where name = "Family")
;
-- same as above, different way
select f.title
from film f
inner join film_category fc on f.film_id=fc.film_id
inner join category c on fc.category_id=c.category_id
where c.name = 'Family'
;

-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(r.rental_id)
from rental r 
inner join inventory i on r.inventory_id=i.inventory_id
inner join film f on i.film_id=f.film_id
group by f.title
ORDER BY count(r.rental_id) desc
;
-- way to check output of above query
select count(*)
from inventory i 
inner join rental r on r.inventory_id=i.inventory_id
where i.film_id = (select film_id from film where title like "grit c%")
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount)
from payment p
inner join rental r on p.rental_id=r.rental_id
inner join inventory i on r.inventory_id=i.inventory_id
inner join store s on i.store_id=s.store_id
group by s.store_id
;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, ctry.country
from store s
left join address a
on s.address_id=a.address_id
left join city c
on a.city_id=c.city_id
left join country ctry
on c.country_id=ctry.country_id
;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount)
from payment p inner join rental r on p.rental_id=r.rental_id
inner join inventory i on r.inventory_id=i.inventory_id
inner join film_category fc on i.film_id=fc.film_id
inner join category c on fc.category_id=c.category_id
group by c.name
ORDER BY sum(p.amount) desc
;

-- 8 a,b,c. 
-- a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- b. How would you display the view that you created in a?
-- c. Write a query to delete it.

drop view if exists TopGenres;

create view TopGenres as 
(
	select c.name, sum(p.amount)
	from payment p inner join rental r on p.rental_id=r.rental_id
	inner join inventory i on r.inventory_id=i.inventory_id
	inner join film_category fc on i.film_id=fc.film_id
	inner join category c on fc.category_id=c.category_id
	group by c.name
	ORDER BY sum(p.amount) desc
    limit 5
)
;

select * from TopGenres;





