From: "Roger Heflin" <rheflin@atipa.com>
Subject: NFS crash on Suse, any ideas on which normal nfs patch could be a cause/fix?
Date: Thu, 9 Jun 2005 13:50:13 -0500
Message-ID: <EXCHG2003FbN4TZyabY000003d9@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_02B4_01C56CFA.28F006D0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DgS5b-00010D-Cg
	for nfs@lists.sourceforge.net; Thu, 09 Jun 2005 11:49:15 -0700
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DgS5X-0007Dv-IW
	for nfs@lists.sourceforge.net; Thu, 09 Jun 2005 11:49:15 -0700
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

------=_NextPart_000_02B4_01C56CFA.28F006D0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,
 
I have a NFS related crash on Suse, I do have a support call in with Suse,
I really only want to know if there is any patch add/deletes that was to fix
a similar issue to this.   We are using 2.6.5-7.139 which is of course
a Suse patched kernel, that I don't not know exactly what it was patched
with.   We are running nfsv3, with udp, 32k block size.
 
NFS did survive several large bonnie runs to the same nfs servers, with
no signs similar to these.     Also the server seems fine when the event
happens it seems to be a client only problem, other clients can get
to the server being used just fine.
 
Below is the description, I have been looking through the recent nfs
patches and have came up with the following that look possible, but
I have looked at the code that it patches, and don't see signs of the 
code it deletes being in the Suse kernel, so I don't think that is it.
  

 
<http://client.linux-nfs.org/Linux-2.6.x/2.6.7-rc3/linux-2.6.7-01-write_hang
.dif> linux-2.6.7-01-write_hang.dif: 


NFS: remove the WRITEPAGE_ACTIVATE hack. It causes crashes.

 
 
 
		
	Customer untars a 8GB file located on a NFS share back onto the same

NFS share,  They have done this on at least 4 separate (slightly different
configurations) machines, with slightly different results on each machine.
On 1 of the 4 machines it succeeded, on the other 3 it failed.  Customer
has also experienced similar issues doing nfs read/writes with applications
other than tar.  On the other 3 machines, 1 machine locked up and required
power removal, 1 machine gave us a kernel panic, and 1 machine put the
tar process into a permanent unkillable "D" state.   Similar results were
obtained with a user test program, and a 3rd party application software.

The kernel crash message was:

CPU 0: Machine Check Exception:          4 Bank 4: f60da00100000813
  RIP !INEXACT!  10:<ffffffff8022fae2> {copy_user_generic_c0x8/0x26}
  TSC 3d101af6bf756 ADDR 4304010
  Kernel panic: Machine check

We have only so far got this on one of the machines.

Any ideas on what is happening?   All machines are Opteron machines, some
are dual processor machines with one motherboard, and the other machines
are quad processer models with a different motherboard, so it does look
like a software issues since there is some variation of hardware, it also
does
not look like a broken hardware issue, as the machine don't fail on anything
but
these nfs tests.
 
The same commands appear to work on local filesystems.
 
                                     

------=_NextPart_000_02B4_01C56CFA.28F006D0
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2800.1400" name=3DGENERATOR></HEAD>
<BODY>
<DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial=20
size=3D2>Hello,</FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial size=3D2>I have =
a NFS related=20
crash on Suse, I do have a support call in with =
Suse,</FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial size=3D2>I =
really only want=20
to know if there is any patch add/deletes that was to =
fix</FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial size=3D2>a =
similar issue to=20
this.&nbsp;&nbsp; We are using 2.6.5-7.139 which&nbsp;is of=20
course</FONT></SPAN></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D106312614-09062005>a Suse =
patched=20
kernel,&nbsp;that I don't&nbsp;not know exactly what it was=20
patched</SPAN></FONT></DIV>
<DIV><FONT face=3DArial><FONT size=3D2><SPAN =
class=3D106312614-09062005>with.=20
</SPAN><SPAN class=3D106312614-09062005>&nbsp; We are running nfsv3, =
with udp, 32k=20
block size.</SPAN></FONT></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D106312614-09062005></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D106312614-09062005>NFS =
did survive=20
several large bonnie runs to the same nfs servers, =
with</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D106312614-09062005>no =
signs similar to=20
these.&nbsp;&nbsp;&nbsp;&nbsp; Also the server seems fine when the=20
event</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN =
class=3D106312614-09062005>happens it seems to=20
be a client only problem, other clients can get</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D106312614-09062005>to the =
server being=20
used just fine.</SPAN></FONT></DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial size=3D2>Below =
is the=20
description, I have been looking through the recent =
nfs</FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial =
size=3D2>patches and have=20
came up with the following that look possible, but</FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005></SPAN><SPAN =
class=3D106312614-09062005><FONT=20
face=3DArial size=3D2>I have looked at the code that it patches, and =
don't see signs=20
of the </FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial size=3D2>code =
it deletes=20
being in the Suse kernel, so I don't think that is =
it.</FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><!--StartFragment --><FONT =
face=3DArial=20
size=3D2>&nbsp; </FONT>
<DT><FONT face=3DArial size=3D2> </FONT>
<DT><A=20
title=3Dhttp://client.linux-nfs.org/Linux-2.6.x/2.6.7-rc3/linux-2.6.7-01-=
write_hang.dif=20
href=3D"http://client.linux-nfs.org/Linux-2.6.x/2.6.7-rc3/linux-2.6.7-01-=
write_hang.dif"><FONT=20
face=3DArial size=3D2>linux-2.6.7-01-write_hang.dif</FONT></A><FONT =
face=3DArial=20
size=3D2>: </FONT>
<DD>
<P><FONT face=3DArial size=3D2>NFS: remove the WRITEPAGE_ACTIVATE hack. =
It causes=20
crashes.</FONT></P></SPAN></DD></DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D106312614-09062005><!--StartFragment --><FONT =
face=3DArial><FONT=20
size=3D2>&nbsp;<SPAN class=3DAppletStyle1><TR><TD =
class=3DdCCItemLabel></TD><TD=20
class=3DdCCItemValue valign=3D"bottom"></TD></TR><TR><TD =
class=3DdCCItemLabel></TD><TD=20
class=3DdCCItemValue valign=3D"bottom"><SPAN id=3Ds_3_1_46_0>Customer =
untars a 8GB=20
file located on a NFS share back onto the=20
same</SPAN></SPAN></FONT></FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>NFS share, &nbsp;They have done this on at least 4 =
separate=20
(slightly different</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>configurations) machines, with slightly different =
results on=20
each machine.</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>On 1 of the 4 machines it succeeded, on the other =
3 it failed.=20
&nbsp;Customer</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>has also experienced similar issues doing nfs =
read/writes with=20
applications</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>other than tar. &nbsp;On the other 3 machines, 1 =
machine=20
locked up and required</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>power removal, 1 machine gave us a kernel panic, =
and 1 machine=20
put the</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>tar process into a permanent unkillable "D" state. =

&nbsp;&nbsp;Similar results were</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>obtained with a user test program, and a 3rd party =
application=20
software.<BR><BR>The kernel crash message was:<BR><BR>CPU 0: Machine =
Check=20
Exception: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4 Bank =
4:=20
f60da00100000813<BR>&nbsp;&nbsp;RIP !INEXACT! =
&nbsp;10:&lt;ffffffff8022fae2&gt;=20
{copy_user_generic_c0x8/0x26}<BR>&nbsp;&nbsp;TSC 3d101af6bf756 ADDR=20
4304010<BR>&nbsp;&nbsp;Kernel panic: Machine check<BR><BR>We have only =
so far=20
got this on one of the machines.<BR><BR>Any ideas on what is happening?=20
&nbsp;&nbsp;All machines are Opteron machines,=20
some</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>are dual processor machines with one motherboard, =
and the=20
other machines</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>are quad processer models with a different =
motherboard, so it=20
does look</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN =
class=3DAppletStyle1><SPAN><FONT=20
face=3DArial size=3D2>like a software issues since there is some =
variation of=20
hardware, it also does</FONT></SPAN></SPAN></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><SPAN=20
class=3DAppletStyle1><SPAN></SPAN></TD></TR></SPAN></SPAN><SPAN=20
class=3D106312614-09062005><FONT face=3DArial size=3D2>not look like a =
broken hardware=20
issue, as the machine don't fail on anything but</FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial size=3D2>these =
nfs=20
tests.</FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial size=3D2>The =
same commands=20
appear to work on local filesystems.</FONT></SPAN></DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D106312614-09062005><FONT face=3DArial><FONT=20
size=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;</FONT></FONT></SPAN></DIV></DIV></BODY></HTML>

------=_NextPart_000_02B4_01C56CFA.28F006D0--



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
