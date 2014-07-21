Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f65.google.com ([209.85.216.65]:63990 "EHLO
	mail-qa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbaGUTyo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 15:54:44 -0400
Received: by mail-qa0-f65.google.com with SMTP id k15so2024265qaq.0
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 12:54:44 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 21 Jul 2014 15:54:42 -0400
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v5 11/10] nfsd: set fl->fl_file properly in
 nfs4_setlease
Message-ID: <20140721155442.14946ce9@tlielax.poochiereds.net>
In-Reply-To: <1405971973-10029-1-git-send-email-jlayton@primarydata.com>
References: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
	<1405971973-10029-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 21 Jul 2014 15:46:13 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> We must set the fl->fl_file properly for the lease, or there will be
> trouble when the lease gets removed.
> 
> Longer term, it would probably make sense to set fl_file during the
> setlease call, since we pass it in, but this should work around the
> immediate oops that I've been seeing.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3946a5a9459c..b21319816b89 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3514,6 +3514,7 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
>  		WARN_ON_ONCE(1);
>  		return -EBADF;
>  	}
> +	fl->fl_file = filp;
>  	status = vfs_setlease(filp, fl->fl_type, &fl);
>  	if (status) {
>  		locks_free_lock(fl);

Obviously, this should ideally be squashed into patch #1 in the series
I sent this morning to prevent regressions. Bruce, can you fix that up
or do I need to resend?

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
