Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12654 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444Ab2GaS2g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 14:28:36 -0400
Message-ID: <5018103A.9070607@RedHat.com>
Date: Tue, 31 Jul 2012 13:04:58 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Karel Zak <kzak@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils: Something is wrong in is_vers4()
References: <20120731165842.08017d60@notabene.brown>
In-Reply-To: <20120731165842.08017d60@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/31/2012 02:58 AM, NeilBrown wrote:
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
> 
> so in the '0' (success, it is vers4) case we do nfs_umount23.  Odd.
> In the '1' (unknown, so presumably vers2 or 3) we don't.  Ever.  Very odd.
> 
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
> 
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
I beg to differ....

commit 76908c3f14a12e865054ea5d6e4cad201c28839a
Author: NeilBrown <neilb@suse.de>
Date:   Mon Jul 16 08:43:28 2012 -0400

    mount.nfs: restore correct error status when umount fails

Or am I missing something?

steved.
