From: Norman Weathers <norman.r.weathers@conocophillips.com>
Subject: Some strange weirdness
Date: Tue, 10 Aug 2004 14:48:13 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200408101448.13279.norman.r.weathers@conocophillips.com>
Reply-To: norman.r.weathers@conocophillips.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Buccs-000285-UV
	for nfs@lists.sourceforge.net; Tue, 10 Aug 2004 12:49:38 -0700
Received: from mailman2.ppco.com ([138.32.33.140])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Buccs-0008NN-Hi
	for nfs@lists.sourceforge.net; Tue, 10 Aug 2004 12:49:38 -0700
Received: from bvlextrd02.conoco.net (trend2.ppco.com [138.32.33.145])
	by mailman2.ppco.com (8.12.8/8.12.8) with ESMTP id i7AJnaJF017172
	for <nfs@lists.sourceforge.net>; Tue, 10 Aug 2004 14:49:37 -0500
Received: from bvlexbh3.conoco.net (bvlexbh3.conoco.net [138.32.45.44])
	by mail1.ppco.com (8.11.6+Sun/8.11.6) with ESMTP id i7AJnao15654
	for <nfs@lists.sourceforge.net>; Tue, 10 Aug 2004 14:49:36 -0500 (CDT)
To: nfs@lists.sourceforge.net
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


Hello, Everyone.

In that pursuit for the perfect NFS server, I have been trying to work on the 
newer kernels (2.6.7 currently), and have noticed a couple of things, and was 
wondering if it was noticed elsewhere as well...

My test is with an in house set of programs.  We are currently testing XFS and 
JFS as the underlying filesystems.  The filesystem that we will serve out has 
~ 3 TB of space.  Now, here comes the strange part.  If I am using XFS, I get 
"respectable" numbers.  For instance, the server is Fedora Core 2, kernel 
2.6.7 with Trond patches, e1000 NIC interface running at 1Gbit.  We also 
upped the buffers on the e1000 card driver.  With XFS and 40 clients running 
against it (each reading and writing a separate 2 G file), aggregate we can 
get about 50 MB/s write and 91 MB/s reads (sequential reads and writes).  
Like I said, pretty good.  When I start to use JFS, however, things go to pot 
quickly.  I start off fairly well (say, with 20 clients), but within a short 
time (30 seconds to 1 minute), where before I would see all of my nfsd 
threads being utilized in Disk wait on the server, they just disappear.  
pdflush comes up for awhile, and so does jfsCommit thread, and then they 
disappear, and then the nfsd's will come back.  During this kind of thrashing 
activity, write speeds drop from 40 or 50 MB/s writes to less than 10 MB/s 
writes.  We have done similiar tests in the past (2.6.5 kernel), and have had 
good results (in house application, mulitple parallel reads and writes, final 
output is multiple parallel writes to a single file).  Has anyone seen this?

Some things we have tried:

1)  JFS parameters , increase number of threads from 2 to 4, increase 
nTxblocks to 64K.
2)  Changed pdflush down to 1500 in /proc/sys/vm/dirty_expire_centisecs.
3)  Changed swappiness down to 10.
4)  Increased number of nfs threads to 32 (both JFS and XFS.  Works well with 
XFS).

I just can't help but wonder if it is an NFS thing, because when we run 
locally, we get very good numbers.  I can have multiple writes going locally, 
and still get very good performance.

Other information:

Clients:  Redhat 7.3, kernel - 2.4.26 + Trond patches.  Mounted tcp, 32k block 
read and write.
Server:  Fedora Core 2, kernel - 2.6.7 + Trond patches.  Dual 2.4 GHz Intel, 4 
GB ram.  Dual 3Ware controllers and 14 disks (2 spares)(IDE).

Thanks in advance.
-- 

Norman Weathers
SIP Linux Cluster
TCE UNIX
ConocoPhillips
Houston, TX

Office:  LO2003
Phone:   ETN  639-2727
	 or (281) 293-2727


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
