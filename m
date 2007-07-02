From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of NFS over IPv6
Date: Mon, 02 Jul 2007 12:23:06 -0400
Message-ID: <4689266A.1000607@oracle.com>
References: <20070629123747.GA1034@uio.no> <46858153.8060109@oracle.com>
	<4688C70C.2050801@ext.bull.net> <4688E296.2040101@bull.net>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090708060600010709040606"
Cc: Le Rouzic <aime.le-rouzic@bull.net>,
	=?ISO-8859-1?Q?bon?= <aurelien.charbon@ext.bull.net>,
	=?ISO-8859-1?Q?Aur=E9lien_Char?=@sc8-sf-spam2.sourceforge.net
To: NFSv4 ML <nfsv4@linux-nfs.org>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5Phl-00016S-Pl
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 10:28:54 -0700
Received: from agminet02.oracle.com ([141.146.126.229])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5Phn-0005FX-AN
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 10:28:56 -0700
Received: from agminet01.oracle.com (agminet01.oracle.com [141.146.126.228])
	by agminet02.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l62GPZPj010989
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 2 Jul 2007 11:26:09 -0500
In-Reply-To: <4688E296.2040101@bull.net>
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

This is a multi-part message in MIME format.
--------------090708060600010709040606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Le Rouzic wrote:
>>> While there is some interest in IPv6 among some of Linux's corporate=20
>>> sponsors, there really isn't an overwhelming "killer" requirement for=
=20
>>> IPv6, so there isn't much motivation to get all this completed.  I=20
>>> have to admit I'm pretty burned out on all this because of how=20
>>> complicated it has all become.  I'd be happy if someone stepped=20
>>> forward and volunteered to help or take over the integration.
>>>  =20
> Some basic tests have been also done on the submitted Aur=E9lien's patc=
hs
> and we will be running the robustness tests we are regularly doing for=20
> ipv4.
> See also at http://nfsv4.bullopensource.org/doc/rpc_testsuite.php
> for this list of tests (cthon04, ffsb, fsx...)
>=20
>>
>> We hope the interest of community about IPv6 will grow.
>> Feel free to send comments on the code.
>> =20
>>
> Some customers are already asking it but  were waiting of its availibit=
y.
> There are also products based on NFSV4 features which are interested in=
.

Yeah, it's kind of unfortunate that we can't be completely specific=20
about the requests/requirements/use cases.  But here's what I know:

1.  Apparently there is a bureaucratic (ie non-technical) requirement=20
from the US Federal government for IPv6 support in new computer software=20
deployments.  I forget when this requirement kicks in, or what exactly=20
"IPv6 support" really entails.

2.  The APAC market wants IPv6 because of an explosion of individual IP=20
network accessors, although arguably that can be addressed for a little=20
while with judicious application of NAT routers.

Otherwise, the companies I've worked for recently have had no real=20
customer requests for IPv6 support in NFS.

NFS community resources are focused largely on NFSv4.1 and pNFS design=20
and implementation.  However, here's some of what I think we need to get=20
IPv6 done:

+  A coherent design for handling IPv6 address caching and export rules=20
on the server side

+  Help from the netdev folks with reviewing our proposed IPv6 changes

+  A cunning plan to stage the integration of all the various pieces

+  Beta testers (ie real environments that can deploy NFS over IPv6 in=20
real conditions)

+  A whiff of project planning to help us know what the real deadlines ar=
e

--------------090708060600010709040606
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------090708060600010709040606
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------090708060600010709040606
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090708060600010709040606--
