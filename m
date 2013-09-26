Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102Ab3IZOSM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 10:18:12 -0400
Date: Thu, 26 Sep 2013 10:19:41 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, andros@netapp.com
Subject: Re: [PATCH] nfs: fix NULL pointer dereference in nfs4_fl_prepare_ds
Message-ID: <20130926101941.3487b3a6@corrin.poochiereds.net>
In-Reply-To: <1380140457-27408-1-git-send-email-jlayton@redhat.com>
References: <1380140457-27408-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 25 Sep 2013 16:20:57 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> In the event that there is an error connecting to a DS, we currently
> zero out the ds pointer and then try to dereference it to clear the
> NFS4DS_CONNECTING bit.
> 
> Fix this by clearing the bit unconditionally before zeroing out the
> pointer.
> 
> Cc: Andy Adamson <andros@netapp.com>
> Cc: <stable@vger.kernel.org> # v3.10+
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/nfs4filelayoutdev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 95604f6..816cda8 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -819,11 +819,11 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
>  		int err;
>  
>  		err = nfs4_ds_connect(s, ds);
> +		nfs4_clear_ds_conn_bit(ds);
>  		if (err) {
>  			nfs4_mark_deviceid_unavailable(devid);
>  			ds = NULL;
>  		}
> -		nfs4_clear_ds_conn_bit(ds);
>  	} else {
>  		/* Either ds is connected, or ds is NULL */
>  		nfs4_wait_ds_connect(ds);

Trond,

Please disregard this patch. There's another problem in here that we'll
need to fix too. Andy will be sending along a replacement patch later
that should fix this bug and the other problems too.

-- 
Jeff Layton <jlayton@redhat.com>
