From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: How to know whether a given directory in in NFS
Date: Thu, 2 Dec 2004 19:09:06 -0600
Message-ID: <344E0C583ED04F49A874F1E8FE26873301B486@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C4D8D4.EECE76B0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ca2Zc-0005ZQ-Iy
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 17:49:28 -0800
Received: from host27-44.discord.birch.net ([65.16.27.44] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ca2Zb-0008J3-Rs
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 17:49:28 -0800
To: "Raghu Ram Murthy" <me_rams@yahoo.com>,
	<nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C4D8D4.EECE76B0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


"df <directory-name>" or the equivalent call the df command
uses (vfstat I think or something similar) works nicely.

                    Roger


-----Original Message-----
From: nfs-admin@lists.sourceforge.net on behalf of Raghu Ram Murthy
Sent: Thu 12/2/2004 4:45 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] How to know whether a given directory in in NFS
=20
Hi,

I want to know (from perl), whether a given directory
is in part of NFS. Are there any Unix commands to find
it out or any indirect methods?

Thanks in advance
-Raghuram

=3D=3D=3D=3D=3D
----------------------------------------------
P.Raghu Ram Murthy, M-tech (Computer Science),
Member, Information Technology,
D E Shaw India Software Private Limited,
6-3-879 & 879/B
Begumpet, Hyderabad 500 016
Andhra Pradesh
India

Mobile: (+91) 98852 17928
----------------------------------------------

If it doesn't work, you're not hitting it with a big enough hammer


	=09
__________________________________=20
Do you Yahoo!?=20
Yahoo! Mail - Helps protect you from nasty viruses.=20
http://promotions.yahoo.com/new_mail


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.=20
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


------_=_NextPart_001_01C4D8D4.EECE76B0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3DISO-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7226.0">
<TITLE>RE: [NFS] How to know whether a given directory in in NFS</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->
<BR>

<P><FONT SIZE=3D2>&quot;df &lt;directory-name&gt;&quot; or the =
equivalent call the df command<BR>
uses (vfstat I think or something similar) works nicely.<BR>
<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Roger<BR>
<BR>
<BR>
-----Original Message-----<BR>
From: nfs-admin@lists.sourceforge.net on behalf of Raghu Ram Murthy<BR>
Sent: Thu 12/2/2004 4:45 AM<BR>
To: nfs@lists.sourceforge.net<BR>
Subject: [NFS] How to know whether a given directory in in NFS<BR>
<BR>
Hi,<BR>
<BR>
I want to know (from perl), whether a given directory<BR>
is in part of NFS. Are there any Unix commands to find<BR>
it out or any indirect methods?<BR>
<BR>
Thanks in advance<BR>
-Raghuram<BR>
<BR>
=3D=3D=3D=3D=3D<BR>
----------------------------------------------<BR>
P.Raghu Ram Murthy, M-tech (Computer Science),<BR>
Member, Information Technology,<BR>
D E Shaw India Software Private Limited,<BR>
6-3-879 &amp; 879/B<BR>
Begumpet, Hyderabad 500 016<BR>
Andhra Pradesh<BR>
India<BR>
<BR>
Mobile: (+91) 98852 17928<BR>
----------------------------------------------<BR>
<BR>
If it doesn't work, you're not hitting it with a big enough hammer<BR>
<BR>
<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR>
__________________________________<BR>
Do you Yahoo!?<BR>
Yahoo! Mail - Helps protect you from nasty viruses.<BR>
<A =
HREF=3D"http://promotions.yahoo.com/new_mail">http://promotions.yahoo.com=
/new_mail</A><BR>
<BR>
<BR>
-------------------------------------------------------<BR>
SF email is sponsored by - The IT Product Guide<BR>
Read honest &amp; candid reviews on hundreds of IT Products from real =
users.<BR>
Discover which products truly live up to the hype. Start reading =
now.<BR>
<A =
HREF=3D"http://productguide.itmanagersjournal.com/">http://productguide.i=
tmanagersjournal.com/</A><BR>
_______________________________________________<BR>
NFS maillist&nbsp; -&nbsp; NFS@lists.sourceforge.net<BR>
<A =
HREF=3D"https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.s=
ourceforge.net/lists/listinfo/nfs</A><BR>
<BR>
</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C4D8D4.EECE76B0--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
