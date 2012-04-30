Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:30542 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506Ab2D3QRn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Apr 2012 12:17:43 -0400
Subject: Re: [PATCH 2/2] NFSv4.1: Use the correct hostname in the client identifier string
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1335802428-8132-2-git-send-email-Trond.Myklebust@netapp.com>
Date: Mon, 30 Apr 2012 12:17:36 -0400
Cc: linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Andy Adamson <andros@netapp.com>
Message-Id: <A56E8B66-1B33-4CFB-BD6D-B45B8F57E806@oracle.com>
References: <1335802428-8132-1-git-send-email-Trond.Myklebust@netapp.com> <1335802428-8132-2-git-send-email-Trond.Myklebust@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On Apr 30, 2012, at 12:13 PM, Trond Myklebust wrote:

> We need to use the hostname of the process that created the nfs_client.
> That hostname is now stored in the rpc_client->cl_nodename.

This looks like exactly what I outlined in my UCS patch series, thanks.  Will you be pushing this into 3.4-rc?

> Also remove the utsname()->domainname component. There is no reason
> to include the NIS/YP domainname in a client identifier string.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/nfs4proc.c |    5 ++---
> 1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 75eb883..99650aa 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5122,10 +5122,9 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
> 	nfs4_construct_boot_verifier(clp, &verifier);
> 
> 	args.id_len = scnprintf(args.id, sizeof(args.id),
> -				"%s/%s.%s/%u",
> +				"%s/%s/%u",
> 				clp->cl_ipaddr,
> -				init_utsname()->nodename,
> -				init_utsname()->domainname,
> +				clp->cl_rpcclient->cl_nodename,
> 				clp->cl_rpcclient->cl_auth->au_flavor);
> 
> 	res.server_scope = kzalloc(sizeof(struct server_scope), GFP_KERNEL);
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




