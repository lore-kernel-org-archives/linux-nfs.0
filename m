From: Jos van Wezel <jvw@iwr.fzk.de>
Subject: NFS servers stop answering
Date: Thu, 06 Jan 2005 00:03:56 +0100
Message-ID: <41DC725C.7050203@iwr.fzk.de>
References: <FZKMSX4Gxd3gWicigQk00050a35@FZKMSX4.ka.fzk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CmKCK-0006bB-GR
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 15:04:12 -0800
Received: from fzkmail2.fzk.de ([141.52.27.52])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1CmKCF-0007nG-6b
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 15:04:12 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <FZKMSX4Gxd3gWicigQk00050a35@FZKMSX4.ka.fzk.de>
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

We run a couple of NFS servers (RedHat 3.0, 2.4.21-15.0.3, nfs-utils 
1.0.6) that have access to the same underlying file system (GPFS). 
Sometimes the servers stop responding to mount requests. Clients give up 
with 'RPC: Timed out messages'. A second later all is green again and 
mount requests go through without a hitch.

I have included a server side tcpdump trace of a client trying to mount 
an export which gives up with a 'RPC: Timed out' response. What could be 
the reason for the momentary failure? The servers handle 5 to 10 mounts 
and unmounts per minute. /var/lib/nfs/rmtab has some 1000 - 1300 
entries. Is there something to look for? Can you help? Thanks.

[root@f01-010-103 root]# tcpdump host l01-001-118
tcpdump: listening on eth0
23:35:26.742161 l01-001-118.784 > f01-010-103.sunrpc: S 
682592854:682592854(0) win 5840 <mss 1460,sackOK,timestamp 36812367 
0,nop,wscale 0> (DF)
23:35:26.742186 f01-010-103.sunrpc > l01-001-118.784: S 
3720816568:3720816568(0) ack 682592855 win 5792 <mss 
1460,sackOK,timestamp 2711116 36812367,nop,wscale 0> (DF)
23:35:26.742270 l01-001-118.784 > f01-010-103.sunrpc: . ack 1 win 5840 
<nop,nop,timestamp 36812367 2711116> (DF)
23:35:26.742323 l01-001-118.784 > f01-010-103.sunrpc: P 1:45(44) ack 1 
win 5840 <nop,nop,timestamp 36812367 2711116> (DF)
23:35:26.742330 f01-010-103.sunrpc > l01-001-118.784: . ack 45 win 5792 
<nop,nop,timestamp 2711116 36812367> (DF)
23:35:26.742466 f01-010-103.sunrpc > l01-001-118.784: P 1:401(400) ack 
45 win 5792 <nop,nop,timestamp 2711116 36812367> (DF)
23:35:26.742554 l01-001-118.784 > f01-010-103.sunrpc: . ack 401 win 6432 
<nop,nop,timestamp 36812367 2711116> (DF)
23:35:26.742561 f01-010-103.sunrpc > l01-001-118.784: P 401:597(196) ack 
45 win 5792 <nop,nop,timestamp 2711116 36812367> (DF)
23:35:26.742638 l01-001-118.784 > f01-010-103.sunrpc: . ack 597 win 7504 
<nop,nop,timestamp 36812367 2711116> (DF)
23:35:26.742660 l01-001-118.784 > f01-010-103.sunrpc: F 45:45(0) ack 597 
win 7504 <nop,nop,timestamp 36812367 2711116> (DF)
23:35:26.742681 f01-010-103.sunrpc > l01-001-118.784: F 597:597(0) ack 
46 win 5792 <nop,nop,timestamp 2711116 36812367> (DF)
23:35:26.742756 l01-001-118.784 > f01-010-103.sunrpc: . ack 598 win 7504 
<nop,nop,timestamp 36812367 2711116> (DF)
23:35:26.742779 l01-001-118.785 > f01-010-103.859: udp 124 (DF)
23:35:29.743481 l01-001-118.785 > f01-010-103.859: udp 124 (DF)
23:35:32.753998 l01-001-118.785 > f01-010-103.859: udp 124 (DF)
23:35:35.764540 l01-001-118.785 > f01-010-103.859: udp 124 (DF)
23:35:38.775053 l01-001-118.785 > f01-010-103.859: udp 124 (DF)
23:35:41.785575 l01-001-118.785 > f01-010-103.859: udp 124 (DF)
23:35:44.796101 l01-001-118.785 > f01-010-103.859: udp 124 (DF)

19 packets received by filter
0 packets dropped by kernel
[root@f01-010-103 root]#


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
