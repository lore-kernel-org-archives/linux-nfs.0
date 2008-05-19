From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs2/3 ESTALE bug (libblkid uses stale cache/uuid
	values)
Date: Mon, 19 May 2008 12:04:08 -0400
Message-ID: <20080519160408.GG7622@fieldses.org>
References: <200805172204.m4HM424o003970@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Kevin Coffman <kwc@umich.edu>, Theodore Ts'o <tytso@mit.edu>,
	nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	Himanshu Kanda <hkanda-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53233 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758144AbYESQEg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 12:04:36 -0400
In-Reply-To: <200805172204.m4HM424o003970-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 17, 2008 at 06:04:02PM -0400, Erez Zadok wrote:
> 
> Several months ago we reported an ESTALE bug when mounting NFS2/3
> partitions.  The tests which trigger this bug perform lots of small mkfs's
> on small /dev/loop partitions, after which destroying the loop device and
> creating a new f/s.  This bug was reported in a message subject "nfs2/3
> ESTALE bug on mount point (v2.6.24-rc8)" here:
> 
> 	http://www.mail-archive.com/linux-nfs@vger.kernel.org/msg00877.html

So, just to make sure I understand, you:

	- Create a new ext2 filesystem image and loopback mount it.
	- Export the new mount.
	- Mount it from a client, do something with it.
	- unmount from client, unexport, unmount, and destroy the image.
	- Repeat.

And eventually get a stale filehandle error?

> The message we posted also provides a simple shell script which triggers the
> bug quite consistently on a variety of systems.  The problem started for us
> when we began using a newer version of nfs-utils, and until now we couldn't
> use newer versions of nfs-utils.  After some testing, we tracked it down to
> a bug in libblkid (part of e2fsprogs), which newer versions of nfs-utils
> began using: ALL versions of nfs-utils using libblkid have this bug.
> 
> Here's what happens.
> 
> 1. Mountd calls get_uuid() (which is #ifdef'ed USE_BLKID).  There, it
>    initializes a static blkid_cache variable as follows:
> 
> 		static blkid_cache cache = NULL;
> 
> 		if (cache == NULL)
> 			blkid_get_cache(&cache, NULL);
> 
>    get_uuid then calls
> 
> 		dev = blkid_get_dev(cache, devname, BLKID_DEV_NORMAL);
> 
>    to find the specific device out of the cache, and if found, it extracts
>    the UUID from the device structure returned (using the appropriate tag).
>    It should be noted that getting the uuid is a filesystems-specific
>    procedure, and libblkid knows how to handle ext2/3/4, reiserfs, xfs, and
>    more.
> 
> 2. Each time mountd needs to get the uuid of a device, after the first time,
>    it then calls blkid_get_dev with the BLKID_DEV_NORMAL flag (which is
>    defined as
> 
> 	#define BLKID_DEV_NORMAL	(BLKID_DEV_CREATE | BLKID_DEV_VERIFY)
> 
>    The code in blkid_get_dev (libblkid has three parts):
> 
>    (a) check if the device is in the known cached list;, if so, return it.
> 
>    (b) if not found, then create a new blkid device structure, store it in
>        the cache, and mark the cache as having changed
>        (BLKID_BIC_FL_CHANGED).
> 
>    (c) finally, since flags includes BLKID_DEV_VERIFY (which is part of
>        BLKID_DEV_NORMAL), then blkid_get_dev also calls blkid_verify() to
>        check that the existing device about to be returned to the caller
>        (get_uuid) is valid.
> 
> 3. blkid_verify can verify that a device is valid.  To do so, it open(2)'s
>    the device, reads some filesystem-specific info from it (e.g., the ext2
>    superblock header, which includes the uuid), and caches all that
>    filesystem-specific information for later reuse.  Of course, reading the
>    f/s superblock each time is expensive,

How expensive is it actually?

> so blkid_verify has some code
>    which is intended to prevent excessive verifications as follows:
> 
> 	now = time(0);
> 	diff = now - dev->bid_time;
> 
> 	if ((now > dev->bid_time) && (diff > 0) && 
> 	    ((diff < BLKID_PROBE_MIN) || 
> 	     (dev->bid_flags & BLKID_BID_FL_VERIFIED &&
> 	      diff < BLKID_PROBE_INTERVAL)))
> 		return dev;
> 
>    It should be noted that when a blkid device structure is created/probed,
>    the time it was last probed is saved in dev->bid_time.  IOW, this
>    bid_time is the last time it was probed, *not* the mtime of the /dev
>    itself.
> 
>    Therefore, the above "if" wants to ensure that a device won't be
>    re-probed unless enough time had passed since the last time it was
>    probed: BLKID_PROBE_INTERVAL is 200 seconds.  That check alone is wrong.
>    A device could have changed numerous times within 200 seconds, and the
>    result is that libblkid happily returns the old dev structure, with the
>    old UUID, *until* 200 seconds have passed.  We verified it by sticking
>    printf's in nfs-utils and libblkid, and also using tcpdumps b/t an nfs
>    client and server.
> 
>    If the above "if" condition is false, blkid_verify falls through and
>    re-probes the device: call open(2), get the new superblock info, and
>    return a new UUID.  This is the point at which our script aborted with
>    ESTALE, because the on disk /dev's UUID (which NFS uses in the fhandle)
>    and the cached one did not match.  In other words, although our scripts
>    mkfs's ext2 file systems many many times within 200 seconds, it takes
>    that long for mountd to detect the changed UUID (I have to think that
>    this can be a security problem, esp. if UUIDs are used for such
>    purposes).
> 
>    Therefore, the above "if" test in blkid_verify must also check to see if
>    the on-disk device itself has changed, by checking to see if its *mtime*
>    of the device is older than the last probe time: if the mtime is older,
>    then it's safe to return the existing cached device; otherwise, we must
>    reprobe and update the cached info

I should know this, but I don't: when exactly do the ctime, mtime, and
atime of a block device get updated?

> 
>    (BTW, I think that the check for "diff > 0" is redundant in the above
>    "if" b/c if "now > dev->bid_time" is true, then "diff > 0" is also true.)

I don't understand that check either.

--b.

> 
> 
> The following patch (against e2fsprogs v1.40.8-215-g9817a2b) fixes the bug.
> It's a small patch, but perhaps not the cleanest one: it has to goto the
> middle of another if statement; a better patch would perhaps consolidate the
> stat() and fstat() calls into one, and rewrite the code so the second 'if'
> doesn't need the fstat().  We've tested this patch with our script and we
> cannot reproduce the ESTALE bug even after thousands of iterations.
> 
> Enjoy,
> Erez and Himanshu.
> 
> --cut-here----cut-here----cut-here----cut-here----cut-here----cut-here--
> 
> BLKID: don't uses stale cache/uuid values for recreated devices
> 
> Signed-off-by: Himanshu Kanda <hkanda@fsl.cs.sunysb.edu>
> Signed-off-by: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
> 
> diff --git a/lib/blkid/probe.c b/lib/blkid/probe.c
> index d8457a8..838c54b 100644
> --- a/lib/blkid/probe.c
> +++ b/lib/blkid/probe.c
> @@ -1220,7 +1220,11 @@ blkid_dev blkid_verify(blkid_cache cache, blkid_dev dev)
>  	now = time(0);
>  	diff = now - dev->bid_time;
>  
> +	if (stat(dev->bid_name, &st) < 0)
> +		goto out_err;
> +
>  	if ((now > dev->bid_time) && (diff > 0) && 
> +	    (st.st_mtime <= dev->bid_time) &&
>  	    ((diff < BLKID_PROBE_MIN) || 
>  	     (dev->bid_flags & BLKID_BID_FL_VERIFIED &&
>  	      diff < BLKID_PROBE_INTERVAL)))
> @@ -1233,6 +1237,7 @@ blkid_dev blkid_verify(blkid_cache cache, blkid_dev dev)
>  	if (((probe.fd = open(dev->bid_name, O_RDONLY)) < 0) ||
>  	    (fstat(probe.fd, &st) < 0)) {
>  		if (probe.fd >= 0) close(probe.fd);
> +out_err:
>  		if ((errno != EPERM) && (errno != EACCES) &&
>  		    (errno != ENOENT)) {
>  			DBG(DEBUG_PROBE, 
> 
> --cut-here----cut-here----cut-here----cut-here----cut-here----cut-here--
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
