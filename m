From: Nick Barkas <snb-nfs@airfire.org>
Subject: slow rewrites over nfs with bonnie++
Date: Wed, 15 Jun 2005 23:50:46 -0700
Message-ID: <20050616065046.GA25904@strait>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DioDH-0005Mb-UF
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 23:50:55 -0700
Received: from strait.cfr.washington.edu ([128.208.123.108])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DioDF-00054h-8a
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 23:50:55 -0700
To: nfs@lists.sourceforge.net
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

A few months ago I ran bonnie++ on some of our systems and noted that
the rewrite speeds reported over nfs were dramtically (ten times or
more) slower than when run locally, while regular block and character
reading/writing was not slowed down as much. I was busy at the time so
didn't look into it to much, but have the chance to now with some new
hardware (an Xserve RAID and the file server it is plugged into) that
isn't in use yet. 

Here are the bonnie++ results I get on a local xfs filesystem mounted
from the RAID on the nfs server:

Version  1.03       ------Sequential Output------ --Sequential Input- --Random-
                    -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
polyp            4G 34241  99 170337  51 71959  24 32832  92 176194  26 521.9   1
                    ------Sequential Create------ --------Random Create--------
                    -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
                 16  5844  58 +++++ +++ 16551  99  4383  68 +++++ +++ 11753  86
polyp,4G,34241,99,170337,51,71959,24,32832,92,176194,26,521.9,1,16,5844,58,+++++,+++
,16551,99,4383,68,+++++,+++,11753,86

Running bonnie++ on a client system mounting the same filesystem over 
nfs gets the following:

xraid1, xfs over nfs, tcp, 32768 rsize & wsize, two stripes (128k), 100GB FS
Version  1.03       ------Sequential Output------ --Sequential Input- --Random-
                    -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
orca1            4G 35429  97 87102  28  2339  98 37079  96 100430  16 558.6   1
                    ------Sequential Create------ --------Random Create--------
                    -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
                 16   834   3  3762   9  1363   5   824   3  3881   8  1510   5
orca1,4G,35429,97,87102,28,2339,98,37079,96,100430,16,558.6,1,16,834,3,3762,9,1363,5
,824,3,3881,8,1510,5

The block reads and writes are slowed down substantially, but that is to
be expected since for one thing I'm only running over gigabit ethernet.
However, the rewrite speed is 2339 KiB/s over nfs, while it was 71959
KiB/s locally. This is a substantial slowdown. Over nfs, the rewriting
uses up a ton of cpu, too. I've noticed that while bonnie++ is doing the
rewrite tests the server's cpu is fairly idle, while the (otherwise
idle) client sits with a load average of about 2. I am not sure if I
need to really be concerned with this, but it bothers me because other
peoples' bonnie++ output I've seen doesn't show this enormous slowdown
with rewrites over nfs. File creation/deletion over nfs seems to be
quite a bit slower over nfs, too, but I am not quite as worried about
this at the moment.

For more background, both the client (orca1) and server (polyp) machines
are running Debian Sarge with an unpatched 2.6.11.11 kernel from
kernel.org. Both machines have two gigs of ram. The server is a dual 2.4
GHz xeon with hyperthreading enabled, and the client is a dual 1.8
opteron. The Xserve RAID has two 1.8TB RAID 5 arrays with 128k
stripe sizes, and each array is connected via 2 Gbps fibre channel to a
dual port Apple (LSI) card in the server. The arrays are shared by an
LVM volume which stripes across the two (again with 128k stripe size),
and the xfs filesystem sits on this. The filesystem was created with
default settings for mkfs.xfs, and is mounted locally with default
options plus nosuid, nodev. Using ext3 instead of xfs does not improve
anything; it is slower than xfs in pretty much all cases both locally
and over nfs for me.

Both client and server are using nfsv3. The client is mounting with
rsize and wsize set to 32768, and is using tcp. I tried with smaller
rsizes/wsizes, and things are just slower.  udp performs comparably to
tcp, but I figured tcp is probably a better idea with rsize and wsize
this large, and with how much network traffic these machines may see
when in production use. For this test, the server exports the filesystem
async, but I will probably mount it sync for production use (I tested it
with sync and it was only a little bit slower on writes, as expected).
The server has 32 nfsd processes (should I have more than this?). The
network is gigabit ethernet, with an e1000 card on the server and a
broadcom card using the tigon3 driver on the client. I am running
bonnie++ in both cases with no options, so it is just doing whatever it
does by default. 

My need is primarily to serve large files which will be both read and
written to by a 20 node cluster running computationally intensive
meteorological models. I want it to be fast to move big files across the
network over nfs. At the same time, I don't want to kill performance
entirely for small files since the server will likely be serving home
directories to a few other machines and files for some low traffic web
sites.

Thanks

-- 
Nick Barkas
USDA Forest Service AirFire Team



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
