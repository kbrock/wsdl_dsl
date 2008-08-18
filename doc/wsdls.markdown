#  Agile, Clean Soap: A DSL to generate WSDLs

ask:
Familiarity with:
- Agile: (multiple, short iterations. incrementally adding functionality)
- soap, wsdl
- code generation
- dsl

*** this is talk is centered around WSDLs, so lets start there

# WSDL
Soap document to define a web service's interface.

Companies design by contract (WSDL first) and can communicate across many platforms.
(not tool centric)

## nature of a WSDL
- Many tools across platforms
- tool incompatibility
- Boiler plate code, redundant information
- verbose and complex - other documents/supporting material) [flow charts, and word documents to focus on domain not WSDL]
- takes time to do all this work
	- 1-2 days to produce wsdl for new service
	- 2-4 hours to make updates across all documents

go over the list of problems and talk about how we are going to solve them.

# WSDL tools and libraries
Converts the WSDL into executable code (stubs). Speak SOAP across the wire (marshal, de-marshal).

- each platform has a few libraries that implement SOAP
	ASP.NET (Microsoft CRM)
	Java backend
		Axis 1
		Axis 2, XFire/Spring,
	 	CXF, WSIT, Jaxws, (spring has native)
	Flex 2/2.5
	Salesforce.com

*** it is great that all these platforms support soap.
Unfortunately the tools support different subsets of the standard (WS-* security)
So it is tricky to produce a WSDL that works across these platforms

# 3. improving the compatibility of the WSDL
Defined a standard template for WSDLs that worked across these tools

There are multiple ways to express one interface. Trick is to find the way that works with the most tools.

- lowest common denominator
	- no groups
	- methods take primitives
	- inline (2 WSDLs)

works across platforms
simplified process (less decisions, less debugging / trial and error)

*** little tricky follow the template. (cut and paste errors). How do we improve this?

# 4. DSLn / input
Domain Specific Language allows you to focus more on the domain and less on the implementation of the interface.

- external vs internal DSLs (Martin Fowler of Thought Works terms)
- ruby and internal DSLs

person
    enum 'role', :base=>string, :values=>['MANAGER','ENGINEER']
	type 'person' do
	  describe "An Employee in a company"
	  string 'name', :description => "person's full name"
	  role :description=>'role in the team'
	  string 'company_name', :optional=>true, :description => "Employer"
	  string 'street', :description => 'home street address'
	  string 'city'
	  string 'state'
	  string 'zip'
	end


xsd picture
xsd

DSL for person, company, address

xsd picture
xsd

DSL for person, company, exploded
xsd picture
xsd

- quick
- consistent documents
- central location for documentation
- RoR

# 5. output of DSL
using html templates vs internal erb templates (includes)


picture showing the different data types
sample input, output (picture)

# 6. use the app to type in some dsl

code that understands input
code that stores/retrieves input

code that produces output

# 6. Show code to interprete the input / output

# 7. centralized management / maintanance
Application 

- defined WSDLs


summary
- time (improvement) 2 days vs 4 hours
- error
	- copy paste
	- follow the template
- consistency
	- information between documents
	- presentation
- decrease in debugging

---


# learned

2. Took many trials and errors to come up with a format that worked with all the libraries
2. would be great if all followed the standards ...
# lack of standards (IMG: square hole, round peg)

- library doesn't understand some WSDL constructs
	- flash, salesforce don't do xsds (IMG)
	- XFire doesn't do groups (IMG)
	- .net didn't do qualified attributes, next version did (IMG)
- libraries internally not consistent. (XFire client can't speak with XFire server)
- libraries can't speak with other libraries
- different versions of same library can't speak with each other (.net)
- too many java versions of libraries




2. followed same patterns as previous project
4. able to use previous knowledge.

# evolving project 2

- improving the interface: adding fields, changing methods. daily changes. [hours to redraft these changes.]
- error prone. monotonous.
- reluctance to make changes. too expensive.
2. After 1 week - became apparent 

## template changes on the horizon

- WS-* security - very complex. Change base template (expensive)
- different libraries (java in particular) change template requirements [e.g. attributeFormDefault="unqualified"]

# DSL seems like a good solution

- lots of boiler plate code (port, ...)
- lots of repeated information (field declaration repeated - because groups don't work. want to pass fields not complex type aka struct)
- very similar formula for most files (e.g.: crud methods)

# wordy

TODO: image of wsdl and code needed to alter 1 attribute

- boiler plate code
- change requires edits in many places
- need expensive editing tool (XMLSpy)

# Ph.D. in SOAP

- stay up with the times
- just like cross browser javascript
- libraries help the javascript
- (I don't want a Ph.D. in WSDL)

# DSL to the rescue

- fewer words
- concentrate on domain (structs, methods, enums)
- tool has SOAP knowledge
	- don't have to remember
	- less work
		- can tweak one and others are updated
		- don't have to document / teach all the ins and outs

# demo

- wsdl, xsd
- inline wsdl
- pictures (dot)
- picture .jpg
- html document
- java code (in .zip)
