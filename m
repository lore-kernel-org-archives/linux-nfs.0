Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:53424 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbdKHMI2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 07:08:28 -0500
Received: by mail-qk0-f178.google.com with SMTP id y23so2949686qkb.10
        for <linux-nfs@vger.kernel.org>; Wed, 08 Nov 2017 04:08:27 -0800 (PST)
Message-ID: <1510142905.8401.6.camel@redhat.com>
Subject: Re: NFS Force Unmounting
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>, Joshua Watt <jpewhacker@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>
Date: Wed, 08 Nov 2017 07:08:25 -0500
In-Reply-To: <87fu9ph2g7.fsf@notabene.neil.brown.name>
References: <1508951506.2542.51.camel@gmail.com>
         <20171030202045.GA6168@fieldses.org>
         <87h8ugwdev.fsf@notabene.neil.brown.name>
         <1509557061.4755.27.camel@redhat.com>
         <87efphvbhy.fsf@notabene.neil.brown.name>
         <1509624549.4569.28.camel@redhat.com>
         <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
         <87fu9ph2g7.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-11-08 at 14:30 +1100, NeilBrown wrote:
> What to people think of the following as an approach
> to Joshua's need?
> 
> It isn't complete by itself: it needs a couple of changes to
> nfs-utils so that it doesn't stat the mountpoint on remount,
> and it might need another kernel change so that the "mount" system
> call performs the same sort of careful lookup for remount as  the umount
> system call does, but those are relatively small details.
> 

Yeah, that'd be good.

> This is the patch that you will either love of hate.
> 
> With this patch, Joshua (or any other sysadmin) could:
> 
>   mount -o remount,retrans=0,timeo=1 /path
> 
> and then new requests on any mountpoint from that server will timeout
> quickly.
> Then
>   umount -f /path
>   umount -f /path
> 
> should kill off any existing requests that use the old timeout. (I just
> tested and I did need this twice to kill of an "ls -l".
> The first was an 'open' systemcall, then next as 'newfstat'. I wonder
> why the getattr for fstat didn't use the new timeout...)
> 
> Thoughts?
> NeilBrown
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index c9d24bae3025..ced12fcec349 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2210,27 +2210,39 @@ static int nfs_validate_text_mount_data(void *options,
>  		~(NFS_MOUNT_UNSHARED | NFS_MOUNT_NORESVPORT))
>  
>  static int
> -nfs_compare_remount_data(struct nfs_server *nfss,
> -			 struct nfs_parsed_mount_data *data)
> +nfs_compare_and_set_remount_data(struct nfs_server *nfss,
> +				 struct nfs_parsed_mount_data *data)
>  {
>  	if ((data->flags ^ nfss->flags) & NFS_REMOUNT_CMP_FLAGMASK ||
>  	    data->rsize != nfss->rsize ||
>  	    data->wsize != nfss->wsize ||
>  	    data->version != nfss->nfs_client->rpc_ops->version ||
>  	    data->minorversion != nfss->nfs_client->cl_minorversion ||
> -	    data->retrans != nfss->client->cl_timeout->to_retries ||
>  	    !nfs_auth_info_match(&data->auth_info, nfss->client->cl_auth->au_flavor) ||
>  	    data->acregmin != nfss->acregmin / HZ ||
>  	    data->acregmax != nfss->acregmax / HZ ||
>  	    data->acdirmin != nfss->acdirmin / HZ ||
>  	    data->acdirmax != nfss->acdirmax / HZ ||
> -	    data->timeo != (10U * nfss->client->cl_timeout->to_initval / HZ) ||
>  	    data->nfs_server.port != nfss->port ||
>  	    data->nfs_server.addrlen != nfss->nfs_client->cl_addrlen ||
>  	    !rpc_cmp_addr((struct sockaddr *)&data->nfs_server.address,
>  			  (struct sockaddr *)&nfss->nfs_client->cl_addr))
>  		return -EINVAL;
>  
> +	if (data->retrans != nfss->client->cl_timeout->to_retries ||
> +	    data->timeo != (10U * nfss->client->cl_timeout->to_initval / HZ)) {
> +		/* Note that this will affect all mounts from the same server,
> +		 * that use the same protocol.  The timeouts are always forced
> +		 * to be the same.
> +		 */
> +		struct rpc_clnt *cl = nfss->client;
> +		if (cl->cl_timeout != &cl->cl_timeout_default)
> +			memcpy(&cl->cl_timeout_default, cl->cl_timeout,
> +			       sizeof(struct rpc_timeout));
> +		cl->cl_timeout_default.to_retries = data->retrans;
> +		cl->cl_timeout_default.to_initval = data->timeo * HZ / 10U;
> +	}
> +

No objection to allowing more mount options to be changed on remount, we
really ought to allow a lot more options to be changed on remount if we
can reasonably pull it off.

>  	return 0;
>  }
>  
> @@ -2244,7 +2256,8 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
>  	struct nfs4_mount_data *options4 = (struct nfs4_mount_data *)raw_data;
>  	u32 nfsvers = nfss->nfs_client->rpc_ops->version;
>  
> -	sync_filesystem(sb);
> +	if (sb->s_readonly_remount)
> +		sync_filesystem(sb);
>  
>  	/*
>  	 * Userspace mount programs that send binary options generally send
> @@ -2295,7 +2308,7 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
>  		*flags |= MS_SYNCHRONOUS;
>  
>  	/* compare new mount options with old ones */
> -	error = nfs_compare_remount_data(nfss, data);
> +	error = nfs_compare_and_set_remount_data(nfss, data);
>  out:
>  	kfree(data);
>  	return error;

Looks like a reasonable approach overall to preventing new RPCs from
being dispatched once the "force" umount runs.

I do wonder if this ought to be more automatic when you specify -f on
the umount. Having to manually do a remount first doesn't seem very
admin-friendly.
-- 
Jeff Layton <jlayton@redhat.com>
