From: James Pearson <james-p@moving-picture.com>
Subject: Re: df and "Value too large for defined data type"
Date: Thu, 26 Feb 2004 10:16:19 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403DC773.409BE2BB@moving-picture.com>
References: <403B512C.66BF37BB@moving-picture.com> <403D2217.9040405@moving-picture.com> <20040225224016.GC24990@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwIaw-000770-Ry
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 02:18:18 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwILU-0006Hr-68
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 02:02:20 -0800
To: Greg Banks <gnb@sgi.com>
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

I'll probally send an email to the XFS list about this - the problem is
that we've done nothing different with the file system set up on this
server compared with the many others we have - i.e. the file systems
were set up with:

mkfs -t xfs /dev/sdb1

etc.

It's just that the file systems in question seem to be saying that the
number of inodes on the file system is 2^64  - whereas all the other XFS
file systems we have (of a similar size) have nowhere near 2^32 inodes
...

However, the one big difference is that the RAID array in question is
3.5TB - which is partioned on the RAID into 4 (i.e. Linux sees 4 devices
on different LUNs) - therefore the overall size of the RAID array is a
lot bigger than anything else we've used before (we don't have anything
else over 2TB) - and the version of xfsprogs used was very old
(1.3.17-0) ...

I'm going to remake one of the partitions with a newer version of
mkfs.xfs to see if that makes a difference ...

James Pearson

Greg Banks wrote:
> 
> On Wed, Feb 25, 2004 at 10:30:47PM +0000, James Pearson wrote:
> > The underlying remote file system is XFS - which in this case appears to
> > be saying that it has 2^64 - 1 inodes - which doesn't seem correct...
> 
> XFS supports 64 bit inodes, so this can be correct if it's either
> 
> 1.  on Linux, and very recent, and mounted with the right options, or
> 
> 2.  on IRIX
> 
> Greg.
> --
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
