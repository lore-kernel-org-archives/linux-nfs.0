Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15744 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751425Ab2GaJ65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 05:58:57 -0400
Date: Tue, 31 Jul 2012 11:58:53 +0200
From: Karel Zak <kzak@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils: Something is wrong in is_vers4()
Message-ID: <20120731095853.GA17896@x2.net.home>
References: <20120731165842.08017d60@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120731165842.08017d60@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 31, 2012 at 04:58:42PM +1000, NeilBrown wrote:
> 
> in nfs-utils, in utils/mount/mount_libmount.c there is a function
> 
>  is_vers4()
> 
> which
>  /* returns: error = -1, success = 0 , unknown = 1 */
> 
> which seems odd to me... I would have chosen '1' for success (it is vers 4),
> 0 for failure (not vers 4), and maybe -1 for error (something went wrong).
> 
> This is used as follows:
> 			switch (is_vers4(cxt)) {
> 			case 0:
> 				/* We ignore the error from nfs_umount23.
> 				 * If the actual umount succeeds (in del_mtab),
> 				 * we don't want to signal an error, as that
> 				 * could cause /sbin/mount to retry!
> 				 */
> 				nfs_umount23(mnt_context_get_source(cxt), opts);
> 				break;
> 			case 1:			/* unknown */
> 				break;
> 			default:		/* error */
> 				goto err;
> 			}

 The same code you can found in original non-libmount version
 in nfsumount.c *but* with correct nfs_umount_is_vers4() return codes.

> 
> so in the '0' (success, it is vers4) case we do nfs_umount23.  Odd.
> In the '1' (unknown, so presumably vers2 or 3) we don't.  Ever.  Very odd.

You're right, should be (copy & past from nfsumount.c):

   * Returns 1 if "mc" is an NFSv4 mount, zero if not, and
   * -1 if some error occurred.

...probably my bug. Sorry.

> So we don't currently send MOUNT_UMNT requests for v2 or v3.
> We don't for v4 either because nfs_umount_do_umnt contains:
> 
> 	/* Skip UMNT call for vers=4 mounts */
> 	if (nfs_pmap.pm_vers == 4)
> 		return EX_SUCCESS;
> 
> so maybe is_vers4 isn't needed?
> 
> Looks like something needs to be fixed here but I'm not entirely sure what.
> Karel??

The is_vers4() should be fixed to be compatible with the original code.

> BTW Steve, Karel's "[PATCH] umount.nfs: ignore non-nfs filesystems"
> which appears in email:
> 
> From: Karel Zak <kzak@redhat.com>
> To: NeilBrown <neilb@suse.de>
> Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
> Subject: Re: [PATCH] umount.nfs: restore correct error status when umount fails.
> Date: Thu, 12 Jul 2012 18:44:20 +0200
> 
> hasn't been applied, but probably should be.

 Yes.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
