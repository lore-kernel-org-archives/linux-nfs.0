From: "Don Allingham" <Don.Allingham@dothill.com>
Subject: Re: NFS randomly denying permission to files
Date: Thu, 1 Feb 2007 17:25:48 -0700
Message-ID: <9DDB513B94253445879B44C250C9BD9A07360F37@venusex1.power.com>
References: <1170369756.1221.8.camel@allingham.power.com>
	<17858.28322.401622.364015@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1142537282=="
Cc: nfs@lists.sourceforge.net
To: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCmFY-0008JW-5W
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 16:25:56 -0800
Received: from artecon.dothill.com ([155.254.128.254] helo=dothill.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCmFY-0005k1-Qn
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 16:25:58 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.

--===============1142537282==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C74660.B001618B"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C74660.B001618B
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


Kernel version for the server and clients are (uname -a):

Linux vlsi-fs0 2.6.17-10-generic #2 SMP Tue Dec 5 21:16:35 UTC 2006 =
x86_64 GNU/Linux

The no_subtree_check option seems to have made a big difference.=20

I'm not familar with tcpdump. However, the new system is on a 1G =
ethernet link, and the old was on a 10/100 link. However, I will =
investigate this if I start seeing the problem again.

Thanks for the help.

Don


-----Original Message-----
From: Neil Brown [mailto:neilb@suse.de]
Sent: Thu 2/1/2007 3:50 PM
To: Don Allingham
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] NFS randomly denying permission to files
=20
On Thursday February 1, don.allingham@dothill.com wrote:
>=20
> Any ideas on how to debug this problem?
>=20

Kernel version?

tcpdump -s 0  trace?

no_subtree_check export option?

NeilBrown


------_=_NextPart_001_01C74660.B001618B
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7650.28">
<TITLE>RE: [NFS] NFS randomly denying permission to files</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->
<BR>

<P><FONT SIZE=3D2>Kernel version for the server and clients are (uname =
-a):<BR>
<BR>
Linux vlsi-fs0 2.6.17-10-generic #2 SMP Tue Dec 5 21:16:35 UTC 2006 =
x86_64 GNU/Linux<BR>
<BR>
The no_subtree_check option seems to have made a big difference.<BR>
<BR>
I'm not familar with tcpdump. However, the new system is on a 1G =
ethernet link, and the old was on a 10/100 link. However, I will =
investigate this if I start seeing the problem again.<BR>
<BR>
Thanks for the help.<BR>
<BR>
Don<BR>
<BR>
<BR>
-----Original Message-----<BR>
From: Neil Brown [<A =
HREF=3D"mailto:neilb@suse.de">mailto:neilb@suse.de</A>]<BR>
Sent: Thu 2/1/2007 3:50 PM<BR>
To: Don Allingham<BR>
Cc: nfs@lists.sourceforge.net<BR>
Subject: Re: [NFS] NFS randomly denying permission to files<BR>
<BR>
On Thursday February 1, don.allingham@dothill.com wrote:<BR>
&gt;<BR>
&gt; Any ideas on how to debug this problem?<BR>
&gt;<BR>
<BR>
Kernel version?<BR>
<BR>
tcpdump -s 0&nbsp; trace?<BR>
<BR>
no_subtree_check export option?<BR>
<BR>
NeilBrown<BR>
<BR>
</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C74660.B001618B--


--===============1142537282==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1142537282==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1142537282==--
