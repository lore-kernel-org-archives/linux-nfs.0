Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:62628 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbaBRQdp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Feb 2014 11:33:45 -0500
Received: by mail-ie0-f177.google.com with SMTP id rp18so4990863iec.8
        for <linux-nfs@vger.kernel.org>; Tue, 18 Feb 2014 08:33:44 -0800 (PST)
Message-ID: <1392741222.4923.4.camel@leira.trondhjem.org>
Subject: Re: [PATCH 01/12] NFS fix error return in nfs4_select_rw_stateid
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: andros@netapp.com, Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 18 Feb 2014 11:33:42 -0500
In-Reply-To: <1392737765-41942-1-git-send-email-andros@netapp.com>
References: <1392737765-41942-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-02-18 at 10:36 -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Do not return an error when nfs4_copy_delegation_stateid succeeds.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4state.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index ba18958..1cfde97 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1120,8 +1120,11 @@ int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
>  	if (ret == -EIO)
>  		/* A lost lock - don't even consider delegations */
>  		goto out;
> -	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
> +	/* returns true if delegation stateid found and copied */
> +	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode)) {
> +		ret = 0;
>  		goto out;
> +	}
>  	if (ret != -ENOENT)
>  		/* nfs4_copy_delegation_stateid() didn't over-write
>  		 * dst, so it still has the lock stateid which we now

Ouch! That looks like it would trigger looping in both the read and
write code when we're holding a delegation. Is that what you end up
seeing?

It looks like it was introduced by commit ef1820f9be27b...

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


