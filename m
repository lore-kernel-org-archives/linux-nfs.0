From: Greg Banks <gnb@sgi.com>
Subject: Re: nfsd write throughput
Date: Tue, 3 Aug 2004 12:10:18 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040803021018.GG5581@sgi.com>
References: <20040802162448.GB21365@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BrolI-0004YZ-Fn
	for nfs@lists.sourceforge.net; Mon, 02 Aug 2004 19:10:44 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BrolI-0004P9-0w
	for nfs@lists.sourceforge.net; Mon, 02 Aug 2004 19:10:44 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040802162448.GB21365@suse.de>
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

On Mon, Aug 02, 2004 at 06:24:49PM +0200, Olaf Kirch wrote:
> @@ -810,6 +811,22 @@
>  		}
>  		last_ino = inode->i_ino;
>  		last_dev = inode->i_sb->s_dev;
> +	} else if (err >= 0 && !stable) {
> +		/* If we've been writing several pages, schedule them
> +		 * for the disk immediately. The client may be streaming
> +		 * and we don't want to hang on a huge journal sync when the
> +		 * commit comes in
> +		 */
> +		struct address_space	*mapping;
> +
> +		/* This assumes a minimum page size of 1K, and will issue
> +		 * a filemap_flushfast call every 64 pages written by the
> +		 * client. */
> +		if ((cnt & 1023) == 0
> +		 && ((offset / cnt) & 63) == 0
> +		 && (mapping = inode->i_mapping) != NULL
> +		 && !bdi_write_congested(mapping->backing_dev_info))
> +			filemap_flushfast(mapping);
>  	}
>  
>  	dprintk("nfsd: write complete err=%d\n", err);

Olaf, I think this patch has problems.

First, the way the v3 server is supposed to work is that normal page
cache pressure pushes pages from unstable writes to disk before the
COMMIT call arrives from the client.  The best way to achieve this
for a dedicated NFS server box is tuning the pdflush parameters
to be more aggressive about writing back dirty pages, e.g. bumping
down the following in /proc/vm: dirty_background_ratio, dirty_ratio,
dirty_writeback_centisecs, and dirty_expire_centisecs.  I have to
admit I've not tried this yet on 2.6 but the equivalent on 2.4 has
been generally useful.

I think another useful approach would be to writeback pages which
have been written by NFS unstable writes at a faster rate than pages
written by local applications, i.e. add a new /proc/vm/ sysctl like
nfs_dirty_writeback_centisecs and a per-page flag.  With a separate
sysctl the default value can be smaller so that you get the desired
behaviour for NFS pages without the syadmin having to do page cache
tuning or perturbing the behaviour of local IO.

The justification for this approach is that data in such pages is
most likely also stored in clients' page caches too.  Recent IRIX
releases do this, and I have an open bug to implement something like
that in Linux.

Second, I have several problems with the heuristics for choosing when
to call filemap_flushfast().

For example, imagine the disk backend is a hardware RAID5 with a
stripe size of 128K or greater and the client is doing streaming
32K WRITE calls.  With your patch, every second WRITE call will now
try to write half a RAID stripe unit, requiring the RAID controller
to read the other half to update parity, which will significantly
hurt performance.  Similar bad things happen if the server is doing
strided or random writes of 1024 B at offsets which are multiples
of 64 KB.

If the disk writes are being pushed by the normal page cache
mechanisms, then the normal page cache and filesystem write clustering
has at least some chance (and the state, e.g. XFS is aware of the
hardware RAID stripe parameters) to construct writes of an appropriate
size.  Whether the page cache and fs actually do the right thing is
another matter, but that's where the responsibility lies.


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
