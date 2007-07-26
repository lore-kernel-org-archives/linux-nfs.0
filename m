From: Prasad P <pvp@us.ibm.com>
Subject: Re: Status of NFS over IPv6
Date: Thu, 26 Jul 2007 02:43:58 -0500
Message-ID: <OFA53D1F49.7F74DE71-ON87257324.00289C05-86257324.002A7AAE@us.ibm.com>
References: <46A49E93.2070306@bull.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0676421891=="
Cc: NFSv4 ML <nfsv4@linux-nfs.org>, nfs@lists.sourceforge.net,
	nfsv4-bounces@linux-nfs.org
To: Le Rouzic <aime.le-rouzic@bull.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDy14-00049B-0O
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 00:44:10 -0700
Received: from e36.co.us.ibm.com ([32.97.110.154])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDy15-00015k-9h
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 00:44:14 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com
	[9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6Q7i10B004133
	for <nfs@lists.sourceforge.net>; Thu, 26 Jul 2007 03:44:01 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id
	l6Q7i1IB263466
	for <nfs@lists.sourceforge.net>; Thu, 26 Jul 2007 01:44:01 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l6Q7i1Bq021048
	for <nfs@lists.sourceforge.net>; Thu, 26 Jul 2007 01:44:01 -0600
In-Reply-To: <46A49E93.2070306@bull.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multipart message in MIME format.
--===============0676421891==
Content-Type: multipart/alternative;
	boundary="=_alternative 002A7A9286257324_="

This is a multipart message in MIME format.
--=_alternative 002A7A9286257324_=
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

Le Rouzic wrote:

>Chuck Lever a =E9crit :
>
>> Le Rouzic wrote:
>
>>>>> While there is some interest in IPv6 among some of Linux's=20
>>>>> corporate sponsors, there really isn't an overwhelming "killer"=20
>>>>> requirement for IPv6, so there isn't much motivation to get all=20
>>>>> this completed.  I have to admit I'm pretty burned out on all this=20
>>>>> because of how complicated it has all become.  I'd be happy if=20
>>>>> someone stepped forward and volunteered to help or take over the=20
>>>>> integration.
>>>>>=20
>>>>
>>> Some basic tests have been also done on the submitted Aur=E9lien's=20
patchs
>>> and we will be running the robustness tests we are regularly doing=20
>>> for ipv4.
>>> See also at http://nfsv4.bullopensource.org/doc/rpc=5Ftestsuite.php
>>> for this list of tests (cthon04, ffsb, fsx...)
>>>
>>>>
>>>> We hope the interest of community about IPv6 will grow.
>>>> Feel free to send comments on the code.
>>>>=20
>>>>
>>> Some customers are already asking it but  were waiting of its=20
>>> availibity.
>>> There are also products based on NFSV4 features which are interested=20
in.
>>
>>
>> Yeah, it's kind of unfortunate that we can't be completely specific=20
>> about the requests/requirements/use cases.
>
>
>    Hi,
>    I think you are right but nevertheless customers often require to be=20
compliant IPV6
>    in their system even they don't use IPV6. Soon, IPV6 deployed, NFS=20
will be
>    one of the first applications used. Some others UNIX systems also=20
have it,
>    so interoperabity it would be good Linux have it.
>    But that is true it will be interested to know when and who on the=20
nfs lists is interested in
>    to use it.
>
>> But here's what I know:
>>
>> 1.  Apparently there is a bureaucratic (ie non-technical) requirement=20
>> from the US Federal government for IPv6 support in new computer=20
>> software deployments.  I forget when this requirement kicks in, or=20
>> what exactly "IPv6 support" really entails.

Hi,

Back in 2005, the US Office of Management and Budget (OMB) issued a=20
mandate calling on all Federal Agencies to have an operational IPv6=20
backbone network by June, 2008.  As the date approaches, USG customers are =

increasingly asking whether individual products/applications are "IPv6=20
compliant".

The DoD has also indicated that it is developing an Approved Products List =

(APL) on which certified IPv6 compliant products will be listed.  The=20
intention is that any product purchased by the DoD must first be certified =

and added to the list.

We have some nongovernment customers (names cannot be disclosed)=20
requesting for IPv6 support in NFS, and few of them are willing to=20
participate in pilot program.  In addition to the customers, we have some=20
requests from different product owners for this support, so that their=20
products can be made "IPv6 complaint".

>>
>> 2.  The APAC market wants IPv6 because of an explosion of individual=20
>> IP network accessors, although arguably that can be addressed for a=20
>> little while with judicious application of NAT routers.
>>
>> Otherwise, the companies I've worked for recently have had no real=20
>> customer requests for IPv6 support in NFS.
>>
>> NFS community resources are focused largely on NFSv4.1 and pNFS design=20
>> and implementation.  However, here's some of what I think we need to=20
>> get IPv6 done:
>>
>> +  A coherent design for handling IPv6 address caching and export rules =

on the server side
>
>     After a first rejected solution and some new discussion on the NFSV4 =

mailing list,
>     Bull (Aur=E9lien) supplied a new document described the current=20
>     implementation. This little design document is still here:=20
>     http://nfsv4.bullopensource.org/doc/nfs=5Fipv6.php
>
>     Any new remarks are welcome.
>
>>
>> +  Help from the netdev folks with reviewing our proposed IPv6 changes
>
>     What would be the mailing lists to call them to review?
>
>>
>> +  A cunning plan to stage the integration of all the various pieces
>>
>> +  Beta testers (ie real environments that can deploy NFS over IPv6 in=20
real conditions)
>
>     May be some on this nfs mailing list have this kind of=20
environmments.
>     What  Bull can do is to run the robustness tests we are doing for=20
IPV4 on IPV6.
>
>>
>> +  A whiff of project planning to help us know what the real deadlines=20
are
>

Thanks.

Regards,
Prasad Potluri
email: pvp at-sign us dot ibm dot com
--=_alternative 002A7A9286257324_=
Content-Type: text/html; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable


<br><font size=3D2 face=3D"sans-serif">Le Rouzic wrote:</font>
<br>
<br><tt><font size=3D2>&gt;Chuck Lever a =E9crit :<br>
&gt;<br>
&gt;&gt; Le Rouzic wrote:<br>
&gt;<br>
&gt;&gt;&gt;&gt;&gt; While there is some interest in IPv6 among some of
Linux's <br>
&gt;&gt;&gt;&gt;&gt; corporate sponsors, there really isn't an overwhelming
&quot;killer&quot; <br>
&gt;&gt;&gt;&gt;&gt; requirement for IPv6, so there isn't much motivation
to get all <br>
&gt;&gt;&gt;&gt;&gt; this completed. &nbsp;I have to admit I'm pretty burned
out on all this <br>
&gt;&gt;&gt;&gt;&gt; because of how complicated it has all become. &nbsp;I'd
be happy if <br>
&gt;&gt;&gt;&gt;&gt; someone stepped forward and volunteered to help or
take over the <br>
&gt;&gt;&gt;&gt;&gt; integration.<br>
&gt;&gt;&gt;&gt;&gt; &nbsp; <br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt; Some basic tests have been also done on the submitted Aur=E9li=
en's
patchs<br>
&gt;&gt;&gt; and we will be running the robustness tests we are regularly
doing <br>
&gt;&gt;&gt; for ipv4.<br>
&gt;&gt;&gt; See also at http://nfsv4.bullopensource.org/doc/rpc=5Ftestsuit=
e.php<br>
&gt;&gt;&gt; for this list of tests (cthon04, ffsb, fsx...)<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt; We hope the interest of community about IPv6 will grow.<br>
&gt;&gt;&gt;&gt; Feel free to send comments on the code.<br>
&gt;&gt;&gt;&gt; &nbsp;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt; Some customers are already asking it but &nbsp;were waiting
of its <br>
&gt;&gt;&gt; availibity.<br>
&gt;&gt;&gt; There are also products based on NFSV4 features which are
interested in.<br>
&gt;&gt;<br>
&gt;&gt;<br>
&gt;&gt; Yeah, it's kind of unfortunate that we can't be completely specific
<br>
&gt;&gt; about the requests/requirements/use cases.<br>
&gt;<br>
&gt;<br>
&gt; &nbsp; &nbsp;Hi,<br>
&gt; &nbsp; &nbsp;I think you are right but nevertheless customers often
require to be compliant IPV6<br>
&gt; &nbsp; &nbsp;in their system even they don't use IPV6. Soon, IPV6
deployed, NFS will be<br>
&gt; &nbsp; &nbsp;one of the first applications used. Some others UNIX
systems also have it,<br>
&gt; &nbsp; &nbsp;so interoperabity it would be good Linux have it.<br>
&gt; &nbsp; &nbsp;But that is true it will be interested to know when and
who on the nfs lists is interested in<br>
&gt; &nbsp; &nbsp;to use it.<br>
&gt;<br>
&gt;&gt; But here's what I know:<br>
&gt;&gt;<br>
&gt;&gt; 1. &nbsp;Apparently there is a bureaucratic (ie non-technical)
requirement <br>
&gt;&gt; from the US Federal government for IPv6 support in new computer
<br>
&gt;&gt; software deployments. &nbsp;I forget when this requirement kicks
in, or <br>
&gt;&gt; what exactly &quot;IPv6 support&quot; really entails.</font></tt>
<br>
<br><tt><font size=3D2>Hi,</font></tt>
<br><tt><font size=3D2><br>
Back in 2005, the US Office of Management and Budget (OMB) issued a mandate
calling on all Federal Agencies to have an operational IPv6 backbone network
by June, 2008. &nbsp;As the date approaches, USG customers are increasingly
asking whether individual products/applications are &quot;IPv6 compliant&qu=
ot;.</font></tt>
<br>
<br><tt><font size=3D2>The DoD has also indicated that it is developing an
Approved Products List (APL) on which certified IPv6 compliant products
will be listed. &nbsp;The intention is that any product purchased by the
DoD must first be certified and added to the list.</font></tt>
<br>
<br><tt><font size=3D2>We have some nongovernment customers (names cannot
be disclosed) requesting for IPv6 support in NFS, and few of them are willi=
ng
to participate in pilot program. &nbsp;In addition to the customers, we
have some requests from different product owners for this support, so that
their products can be made &quot;IPv6 complaint&quot;.</font></tt>
<br>
<br><tt><font size=3D2>&gt;&gt;<br>
&gt;&gt; 2. &nbsp;The APAC market wants IPv6 because of an explosion of
individual <br>
&gt;&gt; IP network accessors, although arguably that can be addressed
for a <br>
&gt;&gt; little while with judicious application of NAT routers.<br>
&gt;&gt;<br>
&gt;&gt; Otherwise, the companies I've worked for recently have had no
real <br>
&gt;&gt; customer requests for IPv6 support in NFS.<br>
&gt;&gt;<br>
&gt;&gt; NFS community resources are focused largely on NFSv4.1 and pNFS
design <br>
&gt;&gt; and implementation. &nbsp;However, here's some of what I think
we need to <br>
&gt;&gt; get IPv6 done:<br>
&gt;&gt;<br>
&gt;&gt; + &nbsp;A coherent design for handling IPv6 address caching and
export rules on the server side<br>
&gt;<br>
&gt; &nbsp; &nbsp; After a first rejected solution and some new discussion
on the NFSV4 mailing list,<br>
&gt; &nbsp; &nbsp; Bull (Aur=E9lien) supplied a new document described the
current <br>
&gt; &nbsp; &nbsp; implementation. This little design document is still
here: <br>
&gt; &nbsp; &nbsp; http://nfsv4.bullopensource.org/doc/nfs=5Fipv6.php<br>
&gt;<br>
&gt; &nbsp; &nbsp; Any new remarks are welcome.<br>
&gt;<br>
&gt;&gt;<br>
&gt;&gt; + &nbsp;Help from the netdev folks with reviewing our proposed
IPv6 changes<br>
&gt;<br>
&gt; &nbsp; &nbsp; What would be the mailing lists to call them to review?<=
br>
&gt;<br>
&gt;&gt;<br>
&gt;&gt; + &nbsp;A cunning plan to stage the integration of all the various
pieces<br>
&gt;&gt;<br>
&gt;&gt; + &nbsp;Beta testers (ie real environments that can deploy NFS
over IPv6 in real conditions)<br>
&gt;<br>
&gt; &nbsp; &nbsp; May be some on this nfs mailing list have this kind
of environmments.<br>
&gt; &nbsp; &nbsp; What &nbsp;Bull can do is to run the robustness tests
we are doing for IPV4 on IPV6.<br>
&gt;<br>
&gt;&gt;<br>
&gt;&gt; + &nbsp;A whiff of project planning to help us know what the real
deadlines are<br>
&gt;</font></tt>
<br>
<br><font size=3D2 face=3D"sans-serif">Thanks.<br>
<br>
Regards,<br>
Prasad Potluri<br>
email: pvp at-sign us dot ibm dot com</font>
--=_alternative 002A7A9286257324_=--


--===============0676421891==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============0676421891==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0676421891==--
