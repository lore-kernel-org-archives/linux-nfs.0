Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:51566 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754329AbaCDSmS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 13:42:18 -0500
Received: by mail-ig0-f176.google.com with SMTP id uy17so11163697igb.3
        for <linux-nfs@vger.kernel.org>; Tue, 04 Mar 2014 10:42:18 -0800 (PST)
Message-ID: <1393958535.7035.1.camel@leira.trondhjem.org>
Subject: Re: [PATCH 3/4] NFSv4 _nfs4_do_setattr use zero stateid on lost lock
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 04 Mar 2014 13:42:15 -0500
In-Reply-To: <1393954269-3974-4-git-send-email-andros@netapp.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com>
	 <1393954269-3974-4-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-03-04 at 12:31 -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Use the zero stateid if nfs4_select_rw_stateid indicates a lost lock (-EIO)
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index de8e7f5..efe940c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2458,18 +2458,22 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>  	truncate = (sattr->ia_valid & ATTR_SIZE) ? true : false;
>  	fmode = truncate ? FMODE_WRITE : FMODE_READ;
>  
> -	if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode)) {
> -		/* Use that stateid */
> -	} else if (truncate && state != NULL && nfs4_valid_open_stateid(state)) {
> +	if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode))
> +		/* Use delegation stateid */
> +		goto do_call;
> +	if (truncate && state != NULL && nfs4_valid_open_stateid(state)) {
>  		struct nfs_lockowner lockowner = {
>  			.l_owner = current->files,
>  			.l_pid = current->tgid,
>  		};
> -		nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
> -				&lockowner);
> -	} else
> -		nfs4_stateid_copy(&arg.stateid, &zero_stateid);
> +		/* Use zero stateid if lock is lost (-EIO fall through) */
> +		if (nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
> +						&lockowner) != -EIO)

Shouldn't we fail with EBADF instead?

> +			goto do_call;
> +	}
> +	nfs4_stateid_copy(&arg.stateid, &zero_stateid);
>  
> +do_call:
>  	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
>  	if (status == 0 && state != NULL)
>  		renew_lease(server, timestamp);

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


