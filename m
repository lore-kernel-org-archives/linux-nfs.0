Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:2060 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965028Ab3IDQel (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 12:34:41 -0400
Date: Wed, 4 Sep 2013 12:29:08 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Weston Andros Adamson <dros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Message-ID: <1816381628.87.1378312148730.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <983545972.85.1378311975965.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: [PATCH] NFSv4: use mach cred for SECINFO_NO_NAME w/ integrity
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

It honestly feels quite odd to me for sec=sys to actually connote krb5i.

Matt

----- "Weston Andros Adamson" <dros@netapp.com> wrote:

> Commit 97431204ea005ec8070ac94bc3251e836daa7ca7 introduced a
> regression
> that causes SECINFO_NO_NAME to fail without sending an RPC if:
> 
>  1) the nfs_client's rpc_client is using krb5i/p (now tried by
> default)
>  2) the current user doesn't have valid kerberos credentials
> 
> This situation is quite common - as of now a sec=sys mount would use
> krb5i for the nfs_client's rpc_client and a user would hardly be
> faulted
> for not having run kinit.
> 
> The solution is to use the machine cred when trying to use an
> integrity
> protected auth flavor for SECINFO_NO_NAME.
> 
> Older servers may not support using the machine cred or an integrity
> protected auth flavor for SECINFO_NO_NAME in every circumstance, so we
> fall
> back to using the user's cred and the filesystem's auth flavor in this
> case.
> 
> We run into another problem when running against linux nfs servers -
> they return NFS4ERR_WRONGSEC when using integrity auth flavor (unless
> the
> mount is also that flavor) even though that is not a valid error for
> SECINFO*.  Even though it's against spec, handle WRONGSEC errors on
> SECINFO_NO_NAME by falling back to using the user cred and the
> filesystem's auth flavor.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> 
> This patch goes along with yesterday's SECINFO patch
> 
>  fs/nfs/nfs4proc.c | 41 +++++++++++++++++++++++++++++++++++++----
>  1 file changed, 37 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ab1461e..74b37f5 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7291,7 +7291,8 @@ out:
>   */
>  static int
>  _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh
> *fhandle,
> -		    struct nfs_fsinfo *info, struct nfs4_secinfo_flavors *flavors)
> +		    struct nfs_fsinfo *info,
> +		    struct nfs4_secinfo_flavors *flavors, bool use_integrity)
>  {
>  	struct nfs41_secinfo_no_name_args args = {
>  		.style = SECINFO_STYLE_CURRENT_FH,
> @@ -7304,8 +7305,23 @@ _nfs41_proc_secinfo_no_name(struct nfs_server
> *server, struct nfs_fh *fhandle,
>  		.rpc_argp = &args,
>  		.rpc_resp = &res,
>  	};
> -	return nfs4_call_sync(server->nfs_client->cl_rpcclient, server,
> &msg,
> -				&args.seq_args, &res.seq_res, 0);
> +	struct rpc_clnt *clnt = server->client;
> +	int status;
> +
> +	if (use_integrity) {
> +		clnt = server->nfs_client->cl_rpcclient;
> +		msg.rpc_cred = nfs4_get_clid_cred(server->nfs_client);
> +	}
> +
> +	dprintk("--> %s\n", __func__);
> +	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args,
> +				&res.seq_res, 0);
> +	dprintk("<-- %s status=%d\n", __func__, status);
> +
> +	if (msg.rpc_cred)
> +		put_rpccred(msg.rpc_cred);
> +
> +	return status;
>  }
>  
>  static int
> @@ -7315,7 +7331,24 @@ nfs41_proc_secinfo_no_name(struct nfs_server
> *server, struct nfs_fh *fhandle,
>  	struct nfs4_exception exception = { };
>  	int err;
>  	do {
> -		err = _nfs41_proc_secinfo_no_name(server, fhandle, info, flavors);
> +		/* first try using integrity protection */
> +		err = -NFS4ERR_WRONGSEC;
> +
> +		/* try to use integrity protection with machine cred */
> +		if (_nfs4_is_integrity_protected(server->nfs_client))
> +			err = _nfs41_proc_secinfo_no_name(server, fhandle, info,
> +							  flavors, true);
> +
> +		/*
> +		 * if unable to use integrity protection, or SECINFO with
> +		 * integrity protection returns NFS4ERR_WRONGSEC (which is
> +		 * disallowed by spec, but exists in deployed servers) use
> +		 * the current filesystem's rpc_client and the user cred.
> +		 */
> +		if (err == -NFS4ERR_WRONGSEC)
> +			err = _nfs41_proc_secinfo_no_name(server, fhandle, info,
> +							  flavors, false);
> +
>  		switch (err) {
>  		case 0:
>  		case -NFS4ERR_WRONGSEC:
> -- 
> 1.7.12.4 (Apple Git-37)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
