From: "Mohit Katiyar, Noida" <mohitka@hcl.in>
Subject: NFS inconsistent behaviour
Date: Mon, 16 Oct 2006 12:35:45 +0530
Message-ID: <A93BD15112CD05479B1CD204F7F1D4730513DB@exch-04.noida.hcltech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0333664027=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZMXv-0005SO-Bx
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 00:05:59 -0700
Received: from gws02.hcl.in ([203.105.185.20] helo=nda-hclin-gws02.hcl.in)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GZMXu-0001i6-Ji
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 00:06:00 -0700
To: <nfs@lists.sourceforge.net>, <linux-kernel@vger.kernel.org>
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

--===============0333664027==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C6F0F1.805F80FA"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C6F0F1.805F80FA
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


Hi all,=20

I am currently using 2.6.16.21-0.8-smp kernel and SLES10 distribution. I=
 have two machines Machine1 and Machine2 both 4 processors SMP machines.=20

The /etc/fstab file on both machines is as follows=20

/dev/sda3 / reiserfs acl,user_xattr 1 1
/dev/sda4 /home reiserfs acl,user_xattr 1 2
/dev/sda2 swap swap defaults 0 0
proc /proc proc defaults 0 0
sysfs /sys sysfs noauto 0 0
debugfs /sys/kernel/debug debugfs noauto 0 0
usbfs /proc/bus/usb usbfs noauto 0 0
devpts /dev/pts devpts mode=3D0620,gid=3D5 0 0=20

## NFS
##
server1k:/export/server1/s25vol1 /mnt/nfs1 nfs hard,intr,tcp
server2k:/export/server2/s25vol2 /mnt/nfs2 nfs hard,intr,tcp
server2k:/export/server2/s25_2sp /mnt/nfs3 nfs hard,intr,tcp

Now on Machine1 when I try to repeatedly mount/unmount the nfs partition by=
 the following procedure=20

[Machine1:] while :; do mount -a -F -t nfs ;umount -a -t nfs ; done=20

The partitions are mounted and unmounted two or three times and after that=
 the process comes to halt and after some time the following message keeps=
 on coming=20

and mounting/unmounting stops.=20

mount: RPC: Remote system error - Connection timed out=20

mount: RPC: Remote system error - Connection timed out=20

mount: RPC: Remote system error - Connection timed out=20

.

..

.

.

On Machine2 when I try the same mounting/unmounting infinitely then after=
 30 seconds or around the following messages starts to display=20

mount: server2k:/export/server2/s25_2sp: can't read superblock
mount: server1k:/export/server1/s25vol1: can't read superblock
mount: server2k:/export/server2/s25vol2: can't read superblock
mount: server2k:/export/server2/s25_2sp: can't read superblock
mount: server1k:/export/server1/s25vol1: can't read superblock=20

.=20

.=20

.=20

Also there are several lockd daemon created=20

> $ ps -ef | grep lockd
> root 21 15 0 13:51 ? 00:00:00 [kblockd/0]
> root 22 15 0 13:51 ? 00:00:00 [kblockd/1]
> root 23 15 0 13:51 ? 00:00:00 [kblockd/2]
> root 24 15 0 13:51 ? 00:00:00 [kblockd/3]
> root 11715 1 0 13:58 ? 00:00:00 [lockd]
> root 11762 1 0 13:58 ? 00:00:00 [lockd]
> root 11765 1 0 13:58 ? 00:00:00 [lockd]
> root 11800 1 0 13:58 ? 00:00:00 [lockd]
> root 11801 1 0 13:58 ? 00:00:00 [lockd]
> root 11811 1 0 13:58 ? 00:00:00 [lockd]
> root 11823 1 0 13:58 ? 00:00:00 [lockd]
> root 11825 1 0 13:58 ? 00:00:00 [lockd]
> root 11834 1 0 13:58 ? 00:00:00 [lockd]
> root 11835 1 0 13:58 ? 00:00:00 [lockd]
> root 11839 1 0 13:58 ? 00:00:00 [lockd]
> root 11859 1 0 13:58 ? 00:00:00 [lockd]
> root 11860 1 0 13:58 ? 00:00:00 [lockd]
> root 11870 1 0 13:58 ? 00:00:00 [lockd]
> root 11879 1 0 13:58 ? 00:00:00 [lockd]
> root 11883 1 0 13:58 ? 00:00:00 [lockd]
> root 11884 1 0 13:58 ? 00:00:00 [lockd]
> root 11894 1 0 13:59 ? 00:00:00 [lockd]
> root 11913 1 0 13:59 ? 00:00:00 [lockd]
> root 11915 1 0 13:59 ? 00:00:00 [lockd]
> root 11927 1 0 13:59 ? 00:00:00 [lockd]
> root 11928 1 0 13:59 ? 00:00:00 [lockd]
> root 11929 1 0 13:59 ? 00:00:00 [lockd]
> root 11940 1 0 13:59 ? 00:00:00 [lockd]
> root 11953 1 0 13:59 ? 00:00:00 [lockd]
> root 11963 1 0 13:59 ? 00:00:00 [lockd]
> root 11964 1 0 13:59 ? 00:00:00 [lockd]
> root 11965 1 0 13:59 ? 00:00:00 [lockd]
> root 11974 1 0 13:59 ? 00:00:00 [lockd]
> root 11978 1 0 13:59 ? 00:00:00 [lockd]
> root 11979 1 0 13:59 ? 00:00:00 [lockd]
> root 11988 1 0 13:59 ? 00:00:00 [lockd]
> root 11989 1 0 13:59 ? 00:00:00 [lockd]
> root 12264 1 0 13:59 ? 00:00:00 [lockd]
> root 12268 1 0 13:59 ? 00:00:00 [lockd]
> root 12488 1 0 13:59 ? 00:00:00 [lockd]
> root 12489 1 0 13:59 ? 00:00:00 [lockd]
> root 12490 1 0 13:59 ? 00:00:00 [lockd]
> root 12500 1 0 13:59 ? 00:00:00 [lockd]
> nfs 12905 10345 0 13:59 pts/1 00:00:00 grep lockd

There are no messages in the /var/log/messages.

If I try to mount/unmount the partitions manually without in a loop they=
 completely work fine. I am able to mount and unmount them without any=
 problem. But whenever this is put in a infinite loop it goes to=
 inconsistent state.

Is it a some kind of bug?

Does anyone faced the same problem or anyone can help me in the case what=
 is going wrong and where?=20

TIA

Mohit Katiyar

HCL Technologies Ltd.

=20

=20
=20
=20


DISCLAIMER:
---------------------------------------------------------------------------=
--------------------------------------------
The contents of this e-mail and any attachment(s) are confidential and=
 intended for the named recipient(s) only.=20
It shall not attach any liability on the originator or HCL or its=
 affiliates. Any views or opinions presented in=20
this email are solely those of the author and may not necessarily reflect=
 the opinions of HCL or its affiliates.=20
Any form of reproduction, dissemination, copying, disclosure, modification,=
 distribution and / or publication of=20
this message without the prior written consent of the author of this e-mail=
 is strictly prohibited. If you have=20
received this email in error please delete it and notify the sender=
 immediately. Before opening any mail and=20
attachments please check them for viruses and defect.
---------------------------------------------------------------------------=
--------------------------------------------
------_=_NextPart_001_01C6F0F1.805F80FA
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"><HTML DIR=
=3Dltr><HEAD><META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html;=
 charset=3Diso-8859-1"></HEAD><BODY><DIV><FONT face=3DArial size=3D2><FONT=
 size=3D2>
<P>Hi all, </P>
<P>I am currently using 2.6.16.21-0.8-smp kernel and SLES10 distribution. I=
 have=20
two machines Machine1 and Machine2 both 4 processors SMP machines. </P>
<P>The /etc/fstab file on both machines is as follows </P>
<P>/dev/sda3 / reiserfs acl,user_xattr 1 1<BR>/dev/sda4 /home reiserfs=20
acl,user_xattr 1 2<BR>/dev/sda2 swap swap defaults 0 0<BR>proc /proc proc=20
defaults 0 0<BR>sysfs /sys sysfs noauto 0 0<BR>debugfs /sys/kernel/debug=
 debugfs=20
noauto 0 0<BR>usbfs /proc/bus/usb usbfs noauto 0 0<BR>devpts /dev/pts=
 devpts=20
mode=3D0620,gid=3D5 0 0 </P>
<P>## NFS<BR>##<BR>server1k:/export/server1/s25vol1 /mnt/nfs1 nfs=20
hard,intr,tcp<BR>server2k:/export/server2/s25vol2 /mnt/nfs2 nfs=20
hard,intr,tcp<BR>server2k:/export/server2/s25_2sp /mnt/nfs3 nfs=20
hard,intr,tcp</P>
<P>Now on Machine1 when I try to repeatedly mount/unmount the nfs partition=
 by=20
the following procedure </P>
<P>[Machine1:] while :; do mount -a -F -t nfs ;umount -a -t nfs ; done </P>
<P>The partitions are mounted and unmounted two or three times and after=
 that=20
the process comes to halt and after some time the following message keeps=
 on=20
coming </P>
<P>and mounting/unmounting stops. </P>
<P>mount: RPC: Remote system error - Connection timed out </P>
<P>mount: RPC: Remote system error - Connection timed out </P>
<P>mount: RPC: Remote system error - Connection timed out </P>
<P>.</P>
<P>..</P>
<P>.</P>
<P>.</P>
<P>On Machine2 when I try the same mounting/unmounting infinitely then=
 after 30=20
seconds or around the following messages starts to display </P>
<P>mount: server2k:/export/server2/s25_2sp: can't read superblock<BR>mount:=
=20
server1k:/export/server1/s25vol1: can't read superblock<BR>mount:=20
server2k:/export/server2/s25vol2: can't read superblock<BR>mount:=20
server2k:/export/server2/s25_2sp: can't read superblock<BR>mount:=20
server1k:/export/server1/s25vol1: can't read superblock </P>
<P>. </P>
<P>. </P>
<P>. </P>
<P>Also there are several lockd daemon created </P>
<P>&gt; $ ps -ef | grep lockd<BR>&gt; root 21 15 0 13:51 ? 00:00:00=20
[kblockd/0]<BR>&gt; root 22 15 0 13:51 ? 00:00:00 [kblockd/1]<BR>&gt; root=
 23 15=20
0 13:51 ? 00:00:00 [kblockd/2]<BR>&gt; root 24 15 0 13:51 ? 00:00:00=20
[kblockd/3]<BR>&gt; root 11715 1 0 13:58 ? 00:00:00 [lockd]<BR>&gt; root=
 11762 1=20
0 13:58 ? 00:00:00 [lockd]<BR>&gt; root 11765 1 0 13:58 ? 00:00:00=20
[lockd]<BR>&gt; root 11800 1 0 13:58 ? 00:00:00 [lockd]<BR>&gt; root 11801=
 1 0=20
13:58 ? 00:00:00 [lockd]<BR>&gt; root 11811 1 0 13:58 ? 00:00:00=
 [lockd]<BR>&gt;=20
root 11823 1 0 13:58 ? 00:00:00 [lockd]<BR>&gt; root 11825 1 0 13:58 ?=
 00:00:00=20
[lockd]<BR>&gt; root 11834 1 0 13:58 ? 00:00:00 [lockd]<BR>&gt; root 11835=
 1 0=20
13:58 ? 00:00:00 [lockd]<BR>&gt; root 11839 1 0 13:58 ? 00:00:00=
 [lockd]<BR>&gt;=20
root 11859 1 0 13:58 ? 00:00:00 [lockd]<BR>&gt; root 11860 1 0 13:58 ?=
 00:00:00=20
[lockd]<BR>&gt; root 11870 1 0 13:58 ? 00:00:00 [lockd]<BR>&gt; root 11879=
 1 0=20
13:58 ? 00:00:00 [lockd]<BR>&gt; root 11883 1 0 13:58 ? 00:00:00=
 [lockd]<BR>&gt;=20
root 11884 1 0 13:58 ? 00:00:00 [lockd]<BR>&gt; root 11894 1 0 13:59 ?=
 00:00:00=20
[lockd]<BR>&gt; root 11913 1 0 13:59 ? 00:00:00 [lockd]<BR>&gt; root 11915=
 1 0=20
13:59 ? 00:00:00 [lockd]<BR>&gt; root 11927 1 0 13:59 ? 00:00:00=
 [lockd]<BR>&gt;=20
root 11928 1 0 13:59 ? 00:00:00 [lockd]<BR>&gt; root 11929 1 0 13:59 ?=
 00:00:00=20
[lockd]<BR>&gt; root 11940 1 0 13:59 ? 00:00:00 [lockd]<BR>&gt; root 11953=
 1 0=20
13:59 ? 00:00:00 [lockd]<BR>&gt; root 11963 1 0 13:59 ? 00:00:00=
 [lockd]<BR>&gt;=20
root 11964 1 0 13:59 ? 00:00:00 [lockd]<BR>&gt; root 11965 1 0 13:59 ?=
 00:00:00=20
[lockd]<BR>&gt; root 11974 1 0 13:59 ? 00:00:00 [lockd]<BR>&gt; root 11978=
 1 0=20
13:59 ? 00:00:00 [lockd]<BR>&gt; root 11979 1 0 13:59 ? 00:00:00=
 [lockd]<BR>&gt;=20
root 11988 1 0 13:59 ? 00:00:00 [lockd]<BR>&gt; root 11989 1 0 13:59 ?=
 00:00:00=20
[lockd]<BR>&gt; root 12264 1 0 13:59 ? 00:00:00 [lockd]<BR>&gt; root 12268=
 1 0=20
13:59 ? 00:00:00 [lockd]<BR>&gt; root 12488 1 0 13:59 ? 00:00:00=
 [lockd]<BR>&gt;=20
root 12489 1 0 13:59 ? 00:00:00 [lockd]<BR>&gt; root 12490 1 0 13:59 ?=
 00:00:00=20
[lockd]<BR>&gt; root 12500 1 0 13:59 ? 00:00:00 [lockd]<BR>&gt; nfs 12905=
 10345=20
0 13:59 pts/1 00:00:00 grep lockd</P>
<P>There are no messages in the /var/log/messages.</P>
<P>If I try to mount/unmount the partitions manually without in a loop they=
=20
completely work fine. I am able to mount and unmount them without=20
any&nbsp;problem. But whenever this is put in&nbsp;a&nbsp;infinite loop it=
 goes=20
to inconsistent state.</P>
<P>Is it a some kind of bug?</P>
<P>Does anyone faced the same&nbsp;problem or anyone&nbsp;can&nbsp;help me=
 in=20
the case what is going wrong&nbsp;and where?&nbsp;</P>
<P>TIA</P>
<P>Mohit Katiyar</P>
<P>HCL Technologies Ltd.</P>
<P>&nbsp;</P></FONT></FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;</DIV></FONT></BODY></HTML>
<table><tr><td bgcolor=3D#ffffff><font color=3D#000000>DISCLAIMER:<br>
---------------------------------------------------------------------------=
--------------------------------------------<br>
The contents of this e-mail and any attachment(s) are confidential and=
 intended for the named recipient(s) only. <br>
It shall not attach any liability on the originator or HCL or its=
 affiliates. Any views or opinions presented in <br>
this email are solely those of the author and may not necessarily reflect=
 the opinions of HCL or its affiliates. <br>
Any form of reproduction, dissemination, copying, disclosure, modification,=
 distribution and / or publication of <br>
this message without the prior written consent of the author of this e-mail=
 is strictly prohibited. If you have <br>
received this email in error please delete it and notify the sender=
 immediately. Before opening any mail and <br>
attachments please check them for viruses and defect.<br>
---------------------------------------------------------------------------=
--------------------------------------------<br>
</font></td></tr></table>
------_=_NextPart_001_01C6F0F1.805F80FA--


--===============0333664027==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============0333664027==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0333664027==--
