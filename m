Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35149 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbcD2KwH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2016 06:52:07 -0400
Received: by mail-qg0-f44.google.com with SMTP id f74so40898361qge.2
        for <linux-nfs@vger.kernel.org>; Fri, 29 Apr 2016 03:52:06 -0700 (PDT)
Message-ID: <1461927124.32715.4.camel@poochiereds.net>
Subject: Re: [PATCH] nfs: don't match flexfiles mirrors that have different
 creds
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Fri, 29 Apr 2016 06:52:04 -0400
In-Reply-To: <1460210433-20435-1-git-send-email-jeff.layton@primarydata.com>
References: <1460210433-20435-1-git-send-email-jeff.layton@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-04-09 at 10:00 -0400, Jeff Layton wrote:
> When we're comparing mirrors to avoid adding duplicates to the to the
> list, we must also consider the creds when comparing them. Otherwise,
> mirrors that differ only by the credential will be improperly merged.
> 
> This is a problem if the client does a LAYOUTGET for a READ layout
> first and then one for a RW, and the server sends a layout with a
> non-usable uid for the READ layout. The RW mirror entry will get
> dropped on the second layoutget as the client thinks the mirror is
> identical to the one from the first. Then, when it goes to do a
> WRITE, it ends up using the creds from the READ layout and the write
> fails with EACCES.
> 
> Another possibility is to allow the RW segment to supersede the READ
> one. The problem there is that the RW layout is returned, then the
> client will still end up using the creds in the RW layout, which may
> not be correct.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 0cb1abd535e3..5d0789a41bc2 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -172,6 +172,8 @@ ff_layout_add_mirror(struct pnfs_layout_hdr *lo,
>  			continue;
>  		if (!ff_mirror_match_fh(mirror, pos))
>  			continue;
> +		if (mirror->uid != pos->uid || mirror->gid != pos->gid)
> +			continue;
>  		if (atomic_inc_not_zero(&pos->ref)) {
>  			spin_unlock(&inode->i_lock);
>  			return pos;

Self-NAK on this patch. As Trond pointed out to me in a private
conversation, we rely on this merging to handle layout stats correctly.
The patchset I sent with the cover letter below should supersede this
patch.

	[PATCH v2 0/7] nfs/sunrpc: fix flexfiles credential handling

Thanks!
-- 
Jeff Layton <jlayton@poochiereds.net>
