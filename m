From: "Brookes, John" <john.brookes@vontu.com>
Subject: "Permission Denied" when attempting mount command - Any help appreciated
Date: Tue, 21 Mar 2006 12:18:31 -0800
Message-ID: <FB2F81A7764D9244849441E9DC12702B01E06739@teak.vontu.corp>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C64D24.9F2C9C5A"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FLnKT-00062g-2p
	for nfs@lists.sourceforge.net; Tue, 21 Mar 2006 12:19:45 -0800
Received: from dsl081-249-146.sfo1.dsl.speakeasy.net ([64.81.249.146] helo=sentinal.vontu.corp)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FLnKS-0007v2-Fa
	for nfs@lists.sourceforge.net; Tue, 21 Mar 2006 12:19:45 -0800
Received: from teak.vontu.corp (teak.vontu.corp [10.67.20.15])
	by sentinal.vontu.corp with ESMTP id k2LKIogb002314
	for <nfs@lists.sourceforge.net>; Tue, 21 Mar 2006 12:18:50 -0800 (PST)
To: <nfs@lists.sourceforge.net>
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

------_=_NextPart_001_01C64D24.9F2C9C5A
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello,
I am running redhat linux 4 enterprise version. (I'll be glad to send
more version info, but you'll have to tell me how to find it. :)

The exports file on the server machine is:

/usr/lib    *(async, all_squash)
/root/try/   *(rw)

I added the second line to exports and ran exportfs -ra afterwords.

Running rpcinfo -p on the server box produces:

   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32770  status
    100011    1   udp    641  rquotad
    100011    2   udp    641  rquotad
    100011    1   tcp    644  rquotad
    100011    2   tcp    644  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   udp  34146  nlockmgr
    100021    3   udp  34146  nlockmgr
    100021    4   udp  34146  nlockmgr
    100021    1   tcp  33275  nlockmgr
    100021    3   tcp  33275  nlockmgr
    100021    4   tcp  33275  nlockmgr
    100005    1   udp    662  mountd
    100005    1   tcp    665  mountd
    100005    2   udp    662  mountd
    100005    2   tcp    665  mountd
    100005    3   udp    662  mountd
    100005    3   tcp    665  mountd

Running rpcinfo on the client:

   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32769  status
    100011    1   udp    779  rquotad
    100011    2   udp    779  rquotad
    100011    1   tcp    782  rquotad
    100011    2   tcp    782  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   udp  32771  nlockmgr
    100021    3   udp  32771  nlockmgr
    100021    4   udp  32771  nlockmgr
    100021    1   tcp  33975  nlockmgr
    100021    3   tcp  33975  nlockmgr
    100021    4   tcp  33975  nlockmgr
    100005    1   udp    800  mountd
    100005    1   tcp    803  mountd
    100005    2   udp    800  mountd
    100005    2   tcp    803  mountd
    100005    3   udp    800  mountd
    100005    3   tcp    803  mountd


The mount command and response:

[root@redhat13 mnt]# mount -o intr,timeo=3D50 ds10.test.lab:root/try
mnt/jbrookes
mount: ds10.test.lab:root/try failed, reason given by server: Permission
denied

I am logged in as root on both machines. I have tried many different
combinations, but same negative result.
Machine A (which is the server in this example) can successfully mount
the volumes on machine B when it is functioning as client, but not the
other way around. (as illustrated by the mount command above.)

Anyone can offer me any clues into this puzzling problem?

Thanks in advance,

John Brookes



------_=_NextPart_001_01C64D24.9F2C9C5A
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7638.1">
<TITLE>&quot;Permission Denied&quot; when attempting mount command - Any =
help appreciated</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/rtf format -->

<P><FONT SIZE=3D2 FACE=3D"Arial">Hello,</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">I am running redhat linux 4 enterprise =
version. (I'll be glad to send more version info, but you'll have to =
tell me how to find it. :)</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">The exports file on the server machine =
is:</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">/usr/lib&nbsp;&nbsp;&nbsp; *(async, =
all_squash)</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">/root/try/&nbsp;&nbsp; *(rw)</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">I added the second line to exports and =
ran exportfs -ra afterwords.</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Running rpcinfo -p on the server box =
produces:</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; program vers =
proto&nbsp;&nbsp; port</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 111&nbsp; =
portmapper</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 111&nbsp; =
portmapper</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 32768&nbsp; =
status</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp; 32770&nbsp; =
status</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100011&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 641&nbsp; =
rquotad</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100011&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 641&nbsp; =
rquotad</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100011&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 644&nbsp; =
rquotad</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100011&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 644&nbsp; =
rquotad</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; tcp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 34146&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp; 34146&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; udp&nbsp; 34146&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp; 33275&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp; 33275&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; tcp&nbsp; 33275&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 662&nbsp; =
mountd</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 665&nbsp; =
mountd</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 662&nbsp; =
mountd</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 665&nbsp; =
mountd</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 662&nbsp; =
mountd</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 665&nbsp; =
mountd</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Running rpcinfo on the client:</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp; program vers =
proto&nbsp;&nbsp; port</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 111&nbsp; =
portmapper</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 111&nbsp; =
portmapper</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 32768&nbsp; =
status</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100024&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp; 32769&nbsp; =
status</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100011&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 779&nbsp; =
rquotad</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100011&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 779&nbsp; =
rquotad</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100011&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 782&nbsp; =
rquotad</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100011&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 782&nbsp; =
rquotad</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100003&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; tcp&nbsp;&nbsp; 2049&nbsp; =
nfs</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp; 32771&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp; 32771&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; udp&nbsp; 32771&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp; 33975&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp; 33975&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100021&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp; tcp&nbsp; 33975&nbsp; =
nlockmgr</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 800&nbsp; =
mountd</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 803&nbsp; =
mountd</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 800&nbsp; =
mountd</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 803&nbsp; =
mountd</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp;&nbsp;&nbsp; 800&nbsp; =
mountd</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">&nbsp;&nbsp;&nbsp; =
100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;&nbsp;&nbsp; 803&nbsp; =
mountd</FONT>
</P>
<BR>

<P><FONT SIZE=3D2 FACE=3D"Arial">The mount command and response:</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">[root@redhat13 mnt]# mount -o =
intr,timeo=3D50 ds10.test.lab:root/try&nbsp; mnt/jbrookes</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">mount: ds10.test.lab:root/try failed, =
reason given by server: Permission denied</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">I am logged in as root on both =
machines. I have tried many different combinations, but same negative =
result.</FONT>

<BR><FONT SIZE=3D2 FACE=3D"Arial">Machine A (which is the server in this =
example) can successfully mount the volumes on machine B when it is =
functioning as client, but not the other way around. (as illustrated by =
the mount command above.)</FONT></P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Anyone can offer me any clues into this =
puzzling problem?</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">Thanks in advance,</FONT>
</P>

<P><FONT SIZE=3D2 FACE=3D"Arial">John Brookes</FONT>
</P>
<BR>

</BODY>
</HTML>
------_=_NextPart_001_01C64D24.9F2C9C5A--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
