From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: Re: Some strange weirdness
Date: Wed, 11 Aug 2004 08:44:29 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040811134429.GC31199@rx8.austin.ibm.com>
References: <200408101448.13279.norman.r.weathers@conocophillips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ButQB-0004zB-SE
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 06:45:39 -0700
Received: from e4.ny.us.ibm.com ([32.97.182.104])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1ButQB-0002n6-7L
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 06:45:39 -0700
To: norman.r.weathers@conocophillips.com
In-Reply-To: <200408101448.13279.norman.r.weathers@conocophillips.com> (from norman.r.weathers@conocophillips.com on Tue, Aug 10, 2004 at 14:48:13 -0500)
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

On 08/10/04 14:48:13, Norman Weathers wrote:
> My test is with an in house set of programs.  We are currently testing XFS and 
> JFS as the underlying filesystems.  The filesystem that we will serve out has 
> ~ 3 TB of space.  Now, here comes the strange part.  If I am using XFS, I get 
> "respectable" numbers.  For instance, the server is Fedora Core 2, kernel 
> 2.6.7 with Trond patches, e1000 NIC interface running at 1Gbit.  We also 
> upped the buffers on the e1000 card driver.  With XFS and 40 clients running 
> against it (each reading and writing a separate 2 G file), aggregate we can 
> get about 50 MB/s write and 91 MB/s reads (sequential reads and writes).  
> Like I said, pretty good.  When I start to use JFS, however, things go to pot 
> quickly.  I start off fairly well (say, with 20 clients), but within a short 
> time (30 seconds to 1 minute), where before I would see all of my nfsd 
> threads being utilized in Disk wait on the server, they just disappear.  
> pdflush comes up for awhile, and so does jfsCommit thread, and then they 
> disappear, and then the nfsd's will come back.  During this kind of thrashing 
> activity, write speeds drop from 40 or 50 MB/s writes to less than 10 MB/s 
> writes.  We have done similiar tests in the past (2.6.5 kernel), and have had 
> good results (in house application, mulitple parallel reads and writes, final 
> output is multiple parallel writes to a single file).  Has anyone seen this?

I've been running SpecSFS on JFS for a while and have never seen this type of 
behavior (although my hardware config is a lot different than yous).  From
you description, it seems that you were doing writes just fine until you reach
memory limitations and then the system goes crazy for a while writing dirty 
pages to disk and then stabilize.  I've seen this behavior on other file
systems when running on systems with large amounts of memory.


> Some things we have tried:
> 
> 1)  JFS parameters , increase number of threads from 2 to 4, increase 
> nTxblocks to 64K.
Adding jfsCommit threads only helps if you have multiple JFS filesystems
mounted.

> 2)  Changed pdflush down to 1500 in /proc/sys/vm/dirty_expire_centisecs.
You could also play with the dirty_background_ratio to lower the amount
of memory that's allow to be dirty.

> 3)  Changed swappiness down to 10.
Seen no improvement on changing this for SpecSFS.

> 4)  Increased number of nfs threads to 32 (both JFS and XFS.  Works well with 
> XFS).
If all of your processes are stuck in Disk wait, it wont help.
 
> I just can't help but wonder if it is an NFS thing, because when we run 
> locally, we get very good numbers.  I can have multiple writes going locally, 
> and still get very good performance.

Why XFS seems to do well while JFS sees this behavior as soon as you
hit memory pressure is harder to answer without know both filesystems in 
detail.  It seem to be a filesystem issue and nothing to do with the NFS
server.  Try running sysrq to get the stack of all the NFS processes when 
they are in disk wait state (its probably going to be stuck in JFS code). 

On SpecSFS, JFS is a the fastest of all the journaling filesystems available 
in Linux.  The workloads are very different though and I'm running with very
different hardware.

-JRS


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
