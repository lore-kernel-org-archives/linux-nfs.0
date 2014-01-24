Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:49078 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbaAXSB4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 13:01:56 -0500
Received: by mail-pa0-f46.google.com with SMTP id rd3so3531885pab.5
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 10:01:56 -0800 (PST)
Message-ID: <1390586285.2927.16.camel@leira.trondhjem.org>
Subject: Re: [PATCH] nfs: handle servers that support only ALLOW ACE type.
From: Trond Myklebust <trondmy@gmail.com>
To: Malahal Naineni <malahal@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 24 Jan 2014 10:58:05 -0700
In-Reply-To: <1390583975-8914-1-git-send-email-malahal@us.ibm.com>
References: <EDB5CCCD-0940-46F2-B102-7094AE029170@primarydata.com>
	 <1390583975-8914-1-git-send-email-malahal@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2014-01-24 at 11:19 -0600, Malahal Naineni wrote:
> Currently we support ACLs if the NFS server file system supports both
> ALLOW and DENY ACE types. This patch makes the Linux client work with
> ACLs even if the server supports only 'ALLOW' ACE type.
> 
> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> ---
>  fs/nfs/nfs4proc.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 15052b8..e3b8fa6 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4321,9 +4321,8 @@ static int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
>  
>  static inline int nfs4_server_supports_acls(struct nfs_server *server)
>  {
> -	return (server->caps & NFS_CAP_ACLS)
> -		&& (server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
> -		&& (server->acl_bitmask & ACL4_SUPPORT_DENY_ACL);
> +	return server->caps & NFS_CAP_ACLS &&
> +		server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL;
>  }
>  
>  /* Assuming that XATTR_SIZE_MAX is a multiple of PAGE_SIZE, and that

Wait... Having looked at the code a bit more carefully. Is there any
reason to set NFS_CAP_ACLS at all if we don't see server->acl_bitmask &
ACL4_SUPPORT_ALLOW_ACL?

IOW: Is there any reason why we shouldn't just move the test for
server->acl_bitmask & ACL4_SUPPORT_ALLOW_ACL into
_nfs4_server_capabilities()?
I agree that will change the output of /proc/self/mountstats for broken
servers that advertise acls, but don't set ACL4_SUPPORT_ALLOW_ACL,
however since we will never serve up getacl, setacl or listacl requests
in that case, why would we advertise the server as supporting it?

