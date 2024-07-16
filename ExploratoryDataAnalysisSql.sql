-- Exploratory data analysis

Select *
from layoffs_staging1;

-- Max Layoffs in a day

Select MAX(total_laid_off), max(percentage_laid_off)
from layoffs_staging1
;

-- Companies that went bankrupt

Select *
from layoffs_staging1
where percentage_laid_off=1
order by funds_raised_millions desc
;

-- Companies order by total layoffs

Select company, sum(total_laid_off)
from layoffs_staging1
group by company
order by 2 desc;

-- Period of analysis

Select min(`date`),max(`date`)
from layoffs_staging1;

-- Industries order by total layoffs with percentage of total and accumulated percentage

SELECT 
    industry,
    SUM(total_laid_off) AS total_laid_off,
    ROUND(SUM(total_laid_off) * 100.0 / (SELECT SUM(total_laid_off) FROM layoffs_staging1), 2) AS percentage_of_total,
    ROUND(SUM(SUM(total_laid_off)) OVER (ORDER BY SUM(total_laid_off) DESC) * 100.0 / (SELECT SUM(total_laid_off) FROM layoffs_staging1), 2) AS accumulated_percentage
FROM 
    layoffs_staging1
GROUP BY 
    industry
ORDER BY 
    total_laid_off DESC;

-- Countries order by total layoffs

Select country, sum(total_laid_off)
from layoffs_staging1
where total_laid_off is not null
group by country
order by 2 desc
;

-- Layoffs per year

Select year(`date`), sum(total_laid_off)
from layoffs_staging1
group by year(`date`)
order by 1 desc
;

-- Layoffs per stage of the company

Select stage, sum(total_laid_off)
from layoffs_staging1
group by stage
order by 2 desc
;

-- Layoffs per month

Select substring(`date`,1,7) as month, sum(total_laid_off) as layoffs
from layoffs_staging1
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
;

-- Layoffs per month and rolling total

with Rolling_total_laid_off as
(Select substring(`date`,1,7) as month, sum(total_laid_off) as total_off	
from layoffs_staging1
group by `month`
order by 1 asc
)
Select `month`, total_off, sum(total_off) over(order by `month`) as rolling_total
from Rolling_total_laid_off;

-- Layoffs per year and rolling total

with Rolling_total_laid_off as
(Select substring(`date`,1,4) as year, sum(total_laid_off) as total_off	
from layoffs_staging1
group by `year`
order by 1 asc
)
Select `year`, total_off, sum(total_off) over(order by `year`) as rolling_total
from Rolling_total_laid_off
where year is not null;

-- Total Layoffs

Select format(sum(total_laid_off),0)
from layoffs_staging1;

-- Total Layoffs per company and year

Select company, year(`date`), sum(total_laid_off)
from layoffs_staging1
group by company, year(`date`)
order by 3 desc;

-- Top five of total layoffs per company per year

with company_year (company,year,total_laid_off) as
(Select company, year(`date`), sum(total_laid_off)
from layoffs_staging1
group by company, year(`date`)
), company_year_rank as
(Select *, dense_rank() over (partition by year order by total_laid_off desc) as ranking
From company_year
where year is not null)
Select *
from company_year_rank
where ranking<=5
;