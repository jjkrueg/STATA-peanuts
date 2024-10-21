{smcl}
{* 20oct2024}{...}
{cmd:help wmc}
{hline}

{title:Title}
{p 10}{bf:wmc} -- Displays the number and proportion of missing values for each variable in {varlist} as well as the proportion weighted by another weighting variable.{p_end}


{title:Syntax}
{p 10}
{cmd:wmc}
{varlist}
{ifin}
[,
{cmdab:ab:breviate(#)}
{cmd:wv({varlist})}
{cmd:graph}
{cmd:groups({varname})
{cmd:mvals(values)
]
{p_end}

{opt by} may be used with {cmd:wmc}; see {helpb by}.


{title:Description}

{p}Produces a table with the number of missing values, total number 
of cases, percent missing and weighted share of missing values for each variable in {varlist}. 
{cmd:wmc} works with both numeric and string variables. This command is based on the the {cmd:mdesc} command but expands it to allow subgroup analysis as well as weighting and some other small features. {p_end}

{title:Options}

{p 4 8 2}{opt ab:breviate(#)} abbreviate variable names to {it:#} of characters; default is {bf:ab(12)}.{p_end}

{p 4 8 2}{opt wv(string)} specify the variable by which we want to weigh the variables whose missingness we want to analyse; the default is none.{p_end}

{p 4 8 2}{opt graph} allows the user to automatically create formatted pie charts of the missingness of a variable by weighting variable for all specified variables.{p_end}

{p 4 8 2}{opt groups(varname)} specify the subgroups by which we want to investigate the missingness of the variables; the default is none.{p_end}

{p 4 8 2}{opt mvals(values)} specify the values which in addition to the traditional . You want to consider as missing; the default is none.{p_end}

{title:Saved Results}

{p 4 4 2}The {cmd:wmc} command saves scalars and macros as the {cmd:mdesc} command:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(percent)}}percent missing for last variable specified in {cmd:wmc}{p_end}
{synopt:{cmd:r(total)}}total number of observations submitted to {cmd:wmc}{p_end}
{synopt:{cmd:r(miss)}}number of missing values for last variable specified in {cmd:wmc}{p_end}

{title:Authors}

{pstd}
Jan Jakob Krüger {break}
info@jjkrueger.de {p_end}

{p 4 4 2}The {cmd:mdesc} command, on which this is based was developped by:{p_end}

{pstd}
Rose Anne Medeiros {break}
Department of Sociology {break}
Rice University {break}
rose.a.medeiros@rice.edu {p_end}

{pstd}
Dan Blanchette {break}
The Carolina Population Center {break}
University of North Carolina - Chapel Hill, USA {break}
dan_blanchette@unc.edu {p_end}


{title:Also see}

{psee}
Online: {helpb missing()}, {helpb misstable}, {stata ssc describe nmissing: ssc describe nmissing}
{p_end}
