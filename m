From: Christopher Smith <csmith@nighthawkrad.net>
Subject: (More) NFS Performance woes
Date: Fri, 15 Dec 2006 00:39:51 +1100
Message-ID: <45815427.8070805@nighthawkrad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuqpR-0002hl-FZ
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 05:40:53 -0800
Received: from mail.syd.nighthawkrad.net ([203.166.121.124])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuqpP-0003L3-Dj
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 05:40:55 -0800
Received: from localhost (localhost [127.0.0.1])
	by mail.syd.nighthawkrad.net (Postfix) with ESMTP id 7E2DC108025
	for <nfs@lists.sourceforge.net>; Fri, 15 Dec 2006 00:39:16 +1100 (EST)
Received: from mail.syd.nighthawkrad.net ([127.0.0.1])
	by localhost (mail.syd.nighthawkrad.net [127.0.0.1]) (amavisd-new,
	port 10024)
	with LMTP id TI3YW4F9wQns for <nfs@lists.sourceforge.net>;
	Fri, 15 Dec 2006 00:39:15 +1100 (EST)
Received: from [192.168.0.128] (203-217-74-151.dyn.iinet.net.au
	[203.217.74.151])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.syd.nighthawkrad.net (Postfix) with ESMTP id A5429108024
	for <nfs@lists.sourceforge.net>; Fri, 15 Dec 2006 00:39:15 +1100 (EST)
To: nfs@lists.sourceforge.net
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

While I am waiting for Red Hat to sort out the weird Dell SAS 5/i and 
NFS bug I've found, we have temporarily thrown some WD Raptor drives 
into the machines to tide us over.  Performance is as good as the 
existing boxes, but I'm having trouble making it better.

The server machine is a Dell PE860, 4G RAM, Dual-core 2.4Ghz Xeon, 2* 
150G, 10k RPM SATA hard disk.  OS is CentOS 4, kernel 
2.6.9-42.0.3.ELsmp, x86_64.
The client is a Dell PE1425, 2G RAM, 2*3.2Ghz Xeon, 160G 7200rpm SATA 
drive.  OS is CentOS 4, kernel 2.6.9-42.0.2.ELsmp, x86.

The network between them is clean gigabit.  It does go through a Cisco 
3750 switch, but there's only about 5 other machines connected and the 
"storage network" has a dedicated vlan with only the clients and server 
on it.

The first test is copying a single large file of about 700M from the 
(client) local disk to the NFS mount.
The second test is untarring a 700M tarfile from the (client) local disk 
to the NFS mount (~5000 files).

Test #1 consistently finishes in about 17 seconds, delivering about 40 
MiB/s.
Test #2 consistently finishes in about 85 seconds, delivering about 8 MiB/s

For reference, untarring the same tarfile locally on the server machine 
takes 7-8 seconds (about 80 MiB/s).

Please note that test #2 is most representative of this machine's 
real-life usage (while there will be reads as well, we expect with 4G of 
RAM the vast majority will come from the cache and not physical disk). 
Test #1 is primarily to demonstrate that there aren't any obvious or 
significant problems with the underlying network and disk IO.

I have tried various values for rsize and wsize from 2048 up to 32768, 
with both TCP and UDP mounts (TCP seems _marginally_ slower - 0.5s test 
#1, 3s test #2).  With exception of r/wsize=2048 for test #1 (which was 
about 20% slower), all combinations give basically the same performance 
+/- a couple of percent.

I'm not expecting to get the same performance for test #2 as test #1, 
but surely it can do better than ~8MiB/sec (or even 40MiB/sec for test 
#1) ?  How close can NFS get to saturating gigabit ?  Do I need to try 
FreeBSD or Solaris ;) ?

Cheers,
CS

-- 
Christopher Smith

Systems Administrator
Nighthawk Radiology Services
Level 11, Suite 1101
Grosvenor Place
225 George Street
Sydney NSW 2000
Australia

T:  612 - 8211 2300 (IP: x8163)
F:  612 - 8211 2333
M:  61  - 407 397 563
USA Toll free:  866 241 6635
E: csmith@nighthawkrad.net
I: www.nighthawkrad.net

CONFIDENTIALITY NOTICE:   This email, including any attachments, 
contains information from NightHawk Radiology Services, which may be 
confidential or privileged. The information is intended to be for the 
use of the individual or entity named above. If you are not the intended 
recipient, be aware that any disclosure, copying, distribution or use of 
the contents of this information is prohibited. If you have received 
this email in error, please notify NightHawk Radiology Services 
immediately by forwarding message to postmaster@nighthawkrad.net and 
destroy all electronic and hard copies of the communication, including 
attachments.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
