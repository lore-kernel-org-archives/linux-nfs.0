From: "Nelson, Allan" <anelson@midf.com>
Subject: NFS over TCP and NFS bindresrvport: Already in use
Date: Tue, 24 Jun 2003 14:48:19 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <7E0DB3A126BA9146AC30744E2B7E4245111845@midhouhqxch01.net.smith.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="----_=_NextPart_001_01C33A89.8FFD004A"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from igate1.smith-intl.com ([206.229.216.5] ident=firewall-user)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Utoi-0000QL-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 12:51:00 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C33A89.8FFD004A
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable

Hello listers,

I have a dual CPU 2GB box with 16 ide drives running on 2 8 port
Escalade controllers.  This is the NFS server.  It is running Redhat 9.0
patched up for the latest errata through up2date with kernel
2.4.20-18.9custom because I recompiled to turn on NFS over TCP. =20

The NFS client is a Dell Poweredge 1600 SC.  It is running Redhat AS 2.1
also patched up2date with kernel 2.4.9e16smp  I have updated nfs-utils
to 1.0.3-1.

I was using ./iozone -a -R -c -g 4G -b 4gb_tcp.xls -U /data0 -f
/data0/testfile and what I saw was the first run of the test sequences
and then an error as given in the subject line and then iozone aborts.

My /etc/exports for /data0 is

/data0	oracle(rw,sync,no_root_squash,insecure)

My mount line from fstab is=20

Gate.midf.com:/data0	data0	nfs
rw,soft.intr,suid.nfsvers=3D3,proto=3Dtcp,rsize=3D32768,wsize=3D32768	0 0

I did this on UDP with no problems.  I had to add the insecure option
when I went to TCP because the nfsd would not allow iozone to make mount
requrests from ports above 1023.  I have the iozone command without -U
/data0 running now.  Any thoughts because I don't know which way to go
at this point.

Thanks

> Allan L. Nelson
> Oracle DBA
> M-I L.L.C.=20
> (832) 295-2238 office=20
> (832) 351-4180 fax=20
> anelson@midf.com <mailto:anelson@midf.com>
>=20
>=20
>=20

______________________________________________________________________________
This email is intended solely for the person or entity to which it is =
addressed and may contain confidential and/or privileged information.  =
Copying, forwarding or distributing this message by persons or entities other=
 =
than the addressee is prohibited. If you have received this email in error, =
please contact the sender immediately and delete the material from any =
computer.  This email may have been monitored for policy compliance.  [021216]

------_=_NextPart_001_01C33A89.8FFD004A
Content-Type: text/html;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version 6.0.6389.0">
<TITLE>NFS over TCP and NFS bindresrvport: Already in use</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT SIZE=3D2 FACE=3D"Arial">Hello listers,</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">I have a dual CPU 2GB box with 16 ide drives=
 =
running on 2 8 port Escalade controllers.&nbsp; This is the NFS server.&nbsp;=
 =
It is running Redhat 9.0 patched up for the latest errata through up2date wit=
h=
 kernel 2.4.20-18.9custom because I recompiled to turn on NFS over TCP.&nbsp;=
 =
</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">The NFS client is a Dell Poweredge 1600 =
SC.&nbsp; It is running Redhat AS 2.1 also patched up2date with kernel =
2.4.9e16smp&nbsp; I have updated nfs-utils to 1.0.3-1.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">I was using ./iozone -a -R -c -g 4G -b =
4gb_tcp.xls -U /data0 -f /data0/testfile and what I saw was the first run of =
the test sequences and then an error as given in the subject line and then =
iozone aborts.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">My /etc/exports for /data0 is</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">/data0&nbsp; =
oracle(rw,sync,no_root_squash,insecure)</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">My mount line from fstab is </FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Gate.midf.com:/data0&nbsp;&nbsp;&nbsp; =
data0&nbsp;&nbsp; nfs&nbsp;&nbsp;&nbsp;&nbsp; =
rw,soft.intr,suid.nfsvers=3D3,proto=3Dtcp,rsize=3D32768,wsize=3D32768&nbsp;&n=
bsp;=
 0 0</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">I did this on UDP with no problems.&nbsp; I =
had to add the insecure option when I went to TCP because the nfsd would not =
allow iozone to make mount requrests from ports above 1023.&nbsp; I have the =
iozone command without -U /data0 running now.&nbsp; Any thoughts because I =
don't know which way to go at this point.</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Thanks</FONT>
</P>
<UL>
<P><B><FONT COLOR=3D"#808080" SIZE=3D2 FACE=3D"Tahoma">Allan L. =
Nelson</FONT></B><BR>
<B></B><B></B><B><FONT COLOR=3D"#808080" SIZE=3D2 FACE=3D"Tahoma">Oracle =
DBA</FONT></B>

<BR><B><FONT COLOR=3D"#808080" SIZE=3D2 =
=46ACE=3D"Tahoma">M-I</FONT></B><I></I><I> <FONT COLOR=3D"#808080" SIZE=3D1 =
=46ACE=3D"Tahoma">L.L.C.</FONT></I><BR>
<B></B><B><FONT COLOR=3D"#808080" SIZE=3D2 FACE=3D"Tahoma">(832) =
295-22</FONT><FONT COLOR=3D"#808080" SIZE=3D2 FACE=3D"Tahoma">38</FONT><FONT =
COLOR=3D"#808080" SIZE=3D2 FACE=3D"Tahoma"> office</FONT></B><FONT =
COLOR=3D"#808080" FACE=3D"Tahoma"><BR>
</FONT><B><FONT COLOR=3D"#808080" SIZE=3D2 FACE=3D"Tahoma">(832) 351-4180 =
=66ax</FONT></B><FONT FACE=3D"Tahoma"><BR>
</FONT><FONT FACE=3D"Tahoma">anelson@midf.com &lt;</FONT><A =
HREF=3D"mailto:anelson@midf.com"><U><FONT COLOR=3D"#0000FF" =
=46ACE=3D"Tahoma">mailto:anelson@midf.com</FONT></U></A><FONT =
=46ACE=3D"Tahoma">&gt;</FONT>
</P>
<BR>
<BR>
</UL>
</BODY>
</HTML>
<P>__________________________________________________________________________=
____<br>
This email is intended solely for the person or entity to which it is =
addressed and may contain confidential and/or privileged information.  =
Copying, forwarding or distributing this message by persons or entities other=
 =
than the addressee is prohibited. If you have received this email in error, =
please contact the sender immediately and delete the material from any =
computer.  This email may have been monitored for policy compliance.  =
[021216]<br>
</P>
------_=_NextPart_001_01C33A89.8FFD004A--



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
