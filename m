Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758536Ab3GZKwe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jul 2013 06:52:34 -0400
Date: Fri, 26 Jul 2013 06:53:08 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 13/16] nfsd4: minor nfs4_setlease cleanup
Message-ID: <20130726065308.0f3fe2ef@corrin.poochiereds.net>
In-Reply-To: <1374094217-31493-15-git-send-email-bfields@redhat.com>
References: <1374094217-31493-1-git-send-email-bfields@redhat.com>
	<1374094217-31493-15-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Jul 2013 16:50:14 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> As far as I can tell, this list is used only under the state lock, so we
> may as well do this in the simpler order.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4state.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 1698816..7c91b6c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3028,18 +3028,18 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
>  	if (!fl)
>  		return -ENOMEM;
>  	fl->fl_file = find_readable_file(fp);
> -	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
>  	status = vfs_setlease(fl->fl_file, fl->fl_type, &fl);
> -	if (status) {
> -		list_del_init(&dp->dl_perclnt);
> -		locks_free_lock(fl);
> -		return -ENOMEM;
> -	}
> +	if (status)
> +		goto out_free;
> +	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
>  	fp->fi_lease = fl;
>  	fp->fi_deleg_file = get_file(fl->fl_file);
>  	atomic_set(&fp->fi_delegees, 1);
>  	list_add(&dp->dl_perfile, &fp->fi_delegations);
>  	return 0;
> +out_free:
> +	locks_free_lock(fl);
> +	return -ENOMEM;
>  }
>  
>  static int nfs4_set_delegation(struct nfs4_delegation *dp)

Acked-by: Jeff Layton <jlayton@redhat.com>
