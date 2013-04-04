Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:26250 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764118Ab3DDU3F convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2013 16:29:05 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH] NFSv4: Fix the fallback to AUTH_NULL if krb5i is not available
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1365106659-7880-1-git-send-email-Trond.Myklebust@netapp.com>
Date: Thu, 4 Apr 2013 13:29:08 -0700
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Message-Id: <1E8C59CD-F2C0-4C92-A06C-848F5C5AC5C0@oracle.com>
References: <1365106659-7880-1-git-send-email-Trond.Myklebust@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 4, 2013, at 1:17 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> If the rpcsec_gss_krb5 module cannot be loaded, the attempt to create
> an rpc_client in nfs4_init_client will currently fail with an EINVAL.
> Fix is to retry with AUTH_NULL.
> 
> Regression introduced by the commit "NFS: Use "krb5i" to establish NFSv4
> state whenever possible"
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Cc: Bryan Schumaker <bjschuma@netapp.com>
> ---
> fs/nfs/nfs4client.c | 2 ++
> 1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index bb9789e..a4f2100 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -200,6 +200,8 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> 
> 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
> 	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);

The parameters passed to nfs_create_rpc_client() are all valid here, so -EINVAL is not a good error value in this situation.

rpcauth_create(), I think, should return -EACCES in this case, rather than -EINVAL.


> +	if (error == -EINVAL)
> +		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_NULL);
> 	if (error < 0)
> 		goto error;
> 
> -- 
> 1.8.1.4
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



