From: Marek Kowal <marek.kowal@portal.onet.pl>
Subject: 2.4.22 NFS client vs. 2.2.19 - bigger nfs lookup rate, worse perf
 ormance
Date: Sun, 14 Dec 2003 23:24:14 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3B372C82CD4B084D9B2B7BF2283FC6FD10E356@foxtrot.onet>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C3C291.011FB02A"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVeeh-0004Lx-10
	for nfs@lists.sourceforge.net; Sun, 14 Dec 2003 14:24:03 -0800
Received: from ex.onet.pl ([217.97.201.23] helo=foxtrot.onet.pl)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVeeg-0007S0-65
	for nfs@lists.sourceforge.net; Sun, 14 Dec 2003 14:24:02 -0800
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C3C291.011FB02A
Content-Type: text/plain

Dear all,
 
I have a strange problem with my NFS client on 2.4.22 - when compared to the
2.2.19 kernel installed on the other machines, I can see about 4 times more
NFS RPC lookup calls. All the other NFS RPCs (read, write, getattr, retrans)
are the same. Also, I can see that the 2.2.22 kernel keeps on waiting for
"something", thus not only intorduces bigger load on my NetApp server (more
RPCs!), but also - it ends up with smaller performance. I did my homework
and looked up through archives, but to no avail ;-(
 
Since this might be the setup related problem, here goes the full
description of the environment:
 
NFS server: NetApp F740, ONTAP 6.0.3
 
The "fast" client: Dell 2x1.3GHz, 1GB RAM, 2.2.19, eth0/eth1: 100Mbps
 
The "slow" client: IBM Blade Center, 2x2.8GHz, 1GB RAM, 2.4.22, eth0/eth1:
1Gbps. The only network setup difference is that the IBM Blades are
interconnected to the internal switch, and then communicate with the main
switch over VLANs, while the "slow" clients are connected directly to the
main switch. But the network problems do not appear, at least I do not see
them with the tools avaliable.
 
Both slow and fast clients run apache.
 
/etc/fstab is the same everywhere:
netapp.internal.domain:/vol/data/vol3 /mnt/nas1-vol3 nfs
rsize=8192,wsize=8192,acregmin=15,acregmax=90,acdirmin=15,acdirmax=90,timeo=
14,intr 0 0
 
Please, can you help me with this misterious behaviour? ;-) I've convinced
my boss to invest into "better" equipment and now it turns out to be slower
than the older stuff. Downgrading to 2.2.x series on IBM is out of question
- half of the hardware is not supported.
 
Cheers,
Marek

------_=_NextPart_001_01C3C291.011FB02A
Content-Type: text/html

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=us-ascii">


<META content="MSHTML 6.00.2800.1276" name=GENERATOR></HEAD>
<BODY>
<DIV><SPAN class=065045821-14122003><FONT face=Arial size=2>Dear 
all,</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial size=2>I have a strange 
problem with my NFS client on 2.4.22 - when compared to the 2.2.19 kernel 
installed on the other machines, I can see about 4 times more NFS RPC lookup 
calls. All the other NFS RPCs (read, write, getattr, retrans) are the same. 
Also, I can see that the 2.2.22 kernel keeps on waiting for "something", thus 
not only intorduces bigger load on my NetApp server (more RPCs!), but also - it 
ends up with smaller performance. I did my homework and looked up through 
archives, but to no avail ;-(</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial size=2>Since this might be 
the setup related problem, here goes the full description of the 
environment:</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial size=2>NFS server: NetApp 
F740, ONTAP 6.0.3</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial size=2>The "fast" client: 
Dell 2x1.3GHz, 1GB RAM, 2.2.19, eth0/eth1: 100Mbps</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial size=2>The "slow" client: 
IBM Blade Center, 2x2.8GHz, 1GB RAM, 2.4.22, eth0/eth1: 1Gbps. The only network 
setup difference is that the IBM Blades are interconnected to the internal 
switch, and then communicate with the main switch over VLANs, while the "slow" 
clients are connected directly to the main switch. But the network problems do 
not appear, at least I do not see them with the tools 
avaliable.</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial size=2>Both slow and fast 
clients run apache.</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial size=2>/etc/fstab is the 
same everywhere:</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2>netapp.internal.domain:/vol/data/vol3 /mnt/nas1-vol3 nfs 
rsize=8192,wsize=8192,acregmin=15,acregmax=90,acdirmin=15,acdirmax=90,timeo=14,intr 
0 0</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial size=2>Please, can&nbsp;you 
help me with this misterious behaviour? ;-) I've convinced my boss to invest 
into "better" equipment and now it turns out to be slower than the older stuff. 
Downgrading to 2.2.x series on IBM is out of question - half of the hardware is 
not supported.</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2>Cheers,</FONT></SPAN></DIV>
<DIV><SPAN class=065045821-14122003><FONT face=Arial 
size=2>Marek</FONT></SPAN></DIV></BODY></HTML>

------_=_NextPart_001_01C3C291.011FB02A--


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
