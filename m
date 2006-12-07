From: Christopher Smith <csmith@nighthawkrad.net>
Subject: Poor performance (especially writes)
Date: Fri, 08 Dec 2006 06:24:33 +1100
Message-ID: <45786A71.7080908@nighthawkrad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsOtM-0001AU-0H
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 11:26:50 -0800
Received: from mail.syd.nighthawkrad.net ([203.166.121.124])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsOtI-00028F-DC
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 11:26:46 -0800
Received: from localhost (localhost [127.0.0.1])
	by mail.syd.nighthawkrad.net (Postfix) with ESMTP id D705B108039
	for <nfs@lists.sourceforge.net>; Fri,  8 Dec 2006 06:24:19 +1100 (EST)
Received: from mail.syd.nighthawkrad.net ([127.0.0.1])
	by localhost (mail.syd.nighthawkrad.net [127.0.0.1]) (amavisd-new,
	port 10024)
	with LMTP id ntq0pfdisZNx for <nfs@lists.sourceforge.net>;
	Fri,  8 Dec 2006 06:24:18 +1100 (EST)
Received: from [192.168.0.128] (203-217-74-151.dyn.iinet.net.au
	[203.217.74.151])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.syd.nighthawkrad.net (Postfix) with ESMTP id 6E460108025
	for <nfs@lists.sourceforge.net>; Fri,  8 Dec 2006 06:24:18 +1100 (EST)
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

(Apologies if this is a reposts, but I haven't seen it appear four hours 
later and there's no indication the list is moderated...)

Hello, all,

I am having some trouble extracting good (or even average) performance
out of my NFS server, particular for writes, and was hoping to get some
suggestions as to how to improve it.

The situation:

We have an in house app that receives, processes and resends image
files.  Larger (512k - 1M) images come into two "indexing nodes", which
extract some header data from them and write them to an NFS share
("store").  They then re-read these "large" images back from the share,
compress and resize them, and write these smaller (150k - 400k) files to
another NFS share ("images").  Finally, a "sender" program running from
a third machine displays the smaller images in a viewer to end users
(serving them up via apache reading from "images") and, on demand, sends
the corresponding set of larger images (from "store") to a number of
destination machines (using scp I believe).  Apparently the read
patterns on the smaller images from the viewer are quite pathological,
with lots of random, very small (10k - 50k) read from the actual image file.

Currently the NFS server is a Dell PE750 with 4G RAM, 2*400G 7200 RPM
SATA drives and a ~3Ghz P4.  It has an identical twin in a failover
configuration via heartbeat and DRBD.  The "images" and "store" shares
are on different spindles.  Both are running Fedora Core 4, kernel
2.6.13-1.1526_FC4smp.

We are hitting a wall with the current config due, I believe, to IO
contention on poor little SATA drives.  While we do have medium term
plans to move to something SAN-ish with GFS (or similar) and the
development team has big promises of removing the need for any sort of
commonly-shared-storage completely, in the interim we need to make do
with NFS.

We have two newer servers which I have started to configure.  They are
Dell PE860s with 4G RAM, 1*2.4Ghz dual-core Xeon, 1*146G 15k SAS disk
(for "images") and 1* 300G 10k RPM SAS disk (for "store").  After
completing a functionally identical setup (albeit using using CentOS 4
x86-64 instead of Fedora) and attaching it to our indexing and viewer
nodes, we discovered it was actually _slower_ than the existing servers
by a significant margin (~10 images/sec vs 17 - 19 images/sec).  "17 -19
images/sec" translates roughly to a combined (store and images) speed of
20 - 25MiB/sec incoming data.  Unfortunately our app isn't easily able
to atuomatically simulate the "reading and sending" load, so we can't
easily produce benchmarks taking into account the additional disk
contention this introduces - but for the purposes of this tuning that's
not really relevant.

(We have tried these tests with and without DRBD active - the DRBD
overhead is essentially zero, so it is not a factor).


There appears to be some bottleneck in the newer servers that is making
them slower.  I don't believe it's hardware, which means that the
CentOS+NFS combo needs some tuning.  I'm not married to CentOS, although
it is our preferred platform.  I'm willing to try newer kernels and/or
Fedora if that will improve performance.  I'd rather not stray from
redhat-derived distros, however, as we have a significant administrative
and skills investment with them.

For the purposes of benchmarking, in light of an inability to use our
production systems outside of a very small window which is extremely
inconvenient to the timezone I'm in, I have captured a set of sample
data from the "images" and "store" shares.  I am testing by copying this
data around for some semblence of relevance to the real-life usage
patterns.  It consists of:

images.tar
4889 files
684MiB

store.tar
4954 files
2103MiB

I have also temporarily limited the amount of memory on the NFS server
to 512M, so the physical disks do actually see some action.  The only
"optimisations" I have made is bumping up the number of NFSDs to 96
(mirroring our current productions environments), so config and mount
options are defaults (I believe this will result in TCP mounts, which
wouldn't work well with our failover server config, but we're willing to
accept that tradeoff for better performance).  The machines are all
connected to a Cisco 3750 gigabit switch which is otherwise empty.  The
only slightly abnormal thing is they are using dot1q trunks, ie:

eth0      Link encap:Ethernet  HWaddr 00:15:C5:F5:B1:0D
           inet6 addr: fe80::215:c5ff:fef5:b10d/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:11990734 errors:0 dropped:0 overruns:0 frame:0
           TX packets:20114864 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:1427499066 (1.3 GiB)  TX bytes:29822008141 (27.7 GiB)
           Interrupt:169

eth0.180  Link encap:Ethernet  HWaddr 00:15:C5:F5:B1:0D
           inet addr:10.184.2.160  Bcast:10.184.2.255  Mask:255.255.255.0
           inet6 addr: fe80::215:c5ff:fef5:b10d/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:11947553 errors:0 dropped:0 overruns:0 frame:0
           TX packets:20114877 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:1161282256 (1.0 GiB)  TX bytes:29661082251 (27.6 GiB)

I have also tried raising the MTU, but that doesn't seem to work:

[root@justinstalled ~]# ifconfig eth0 mtu 9000
SIOCSIFMTU: Invalid argument
[root@justinstalled ~]#

Maybe the tg3 driver doesn't support jumbo frames ?  In any event, I
wouldn't expect it to make the order-of-magnitude type of improvement
I'm looking for.

As you'll see, the performance for big, sequential writes is quite
respectable, but as soon as lots of smaller files are involved, it all
goes to pot.  I'd very much appreciate any advice people can offer on
making this faster.


The numbers:
Baseline performance (local disk -> local disk on NFS server).  I don't
expect to get this performance over NFS, but it'd be nice to get closer
- especially the untarring stuff...

Copy images.tar from /export/store to /export/images
684M
13s
52M/s

Copy store.tar from /export/images to /export/store
2103M
33s
64M/s

Untar images.tar from /export/store to /export/images
time tar -C /export/images -xf /export/store/images.tar
4889 files
684M
15s
46M/s

Untar store.tar from /export/images to /export/store
time tar -C /export/store -xf /export/images/store.tar
4954 files
2103M
51s
41M/s


Remote performance #1 (NFS client -> NFS server).  Single client, single
action, default NFS options:
Copy images.tar
time cp /data/images.tar /mnt/images
684M
18s
38M/s

Copy store.tar
time cp /data/store.tar /mnt/store
2103M
60s
35M/s

Untar images.tar
time tar -C /mnt/images -xf /data/images.tar
4889 files
684M
372s
1.8M/s

Untar store.tar
time tar -C /mnt/store -xf /data/store.tar
4954 files
2103M
578
3.6M/s


Remote performance #2 (NFS client -> NFS server).  Single client,
combined action, default NFS options:
Copy images.tar and store.tar simultaneously
date; time cp /data/images.tar /mnt/images &
time cp /data/store.tar /mnt/store && date
2787MiB
63s
44M/s

Untar images.tar and store.tar simultaneously
date; time tar -C /mnt/images -xf /data/images.tar &
time tar -C /mnt/store -xf /data/store.tar && date
9843 files
2787MiB
576s
4.8M/s


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
