From: Greg Banks <gnb@sgi.com>
Subject: Re: df and "Value too large for defined data type"
Date: Thu, 26 Feb 2004 09:40:16 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040225224016.GC24990@sgi.com>
References: <403B512C.66BF37BB@moving-picture.com> <403D2217.9040405@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aw7j4-00011B-V0
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 14:41:58 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aw7UK-00019S-DL
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 14:26:44 -0800
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <403D2217.9040405@moving-picture.com>
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

On Wed, Feb 25, 2004 at 10:30:47PM +0000, James Pearson wrote:
> The underlying remote file system is XFS - which in this case appears to 
> be saying that it has 2^64 - 1 inodes - which doesn't seem correct...

XFS supports 64 bit inodes, so this can be correct if it's either

1.  on Linux, and very recent, and mounted with the right options, or

2.  on IRIX

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
