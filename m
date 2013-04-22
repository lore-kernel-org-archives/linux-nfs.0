Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:3989 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754895Ab3DVUVn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Apr 2013 16:21:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Retry SETCLIENTID with AUTH_SYS instead of
 AUTH_NONE
Date: Mon, 22 Apr 2013 20:21:42 +0000
Message-ID: <1366662101.12400.0.camel@leira.trondhjem.org>
References: <20130422194240.25157.85632.stgit@seurat.1015granger.net>
In-Reply-To: <20130422194240.25157.85632.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-04-22 at 15:42 -0400, Chuck Lever wrote:
> Recently I changed the SETCLIENTID code to use AUTH_GSS(krb5i), and
> then retry with AUTH_NONE if that didn't work.  This was to enable
> Kerberos NFS mounts to work without forcing Linux NFS clients to
> have a keytab on hand.
> 
> Rick Macklem reports that the FreeBSD server accepts AUTH_NONE only
> for NULL operations (thus certainly not for SETCLIENTID).  Falling
> back to AUTH_NONE means our proposed 3.10 NFS client will not
> interoperate with FreeBSD servers over NFSv4 unless Kerberos is
> fully configured on both ends.
> 
> If the Linux client falls back to using AUTH_SYS instead for
> SETCLIENTID, all should work fine as long as the NFS server is
> configured to allow AUTH_SYS for SETCLIENTID.
> 
> This may still prevent access to Kerberos-only FreeBSD servers by
> Linux clients with no keytab.  Rick is of the opinion that the
> security settings the server applies to its pseudo-fs should also
> apply to the SETCLIENTID operation.
> 
> Linux and Solaris NFS servers do not place that limitation on
> SETCLIENTID.  The security settings for the server's pseudo-fs are
> determined automatically as the union of security flavors allowed on
> real exports, as recommended by RFC 3530bis; and the flavors allowed
> for SETCLIENTID are all flavors supported by the respective server
> implementation.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Build-tested only.
> 
>  fs/nfs/nfs4state.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index d684a57f..87ac12b 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1857,7 +1857,7 @@ again:
>  			break;
>  	case -NFS4ERR_CLID_INUSE:
>  	case -NFS4ERR_WRONGSEC:
> -		clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_NULL);
> +		clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
>  		if (IS_ERR(clnt)) {
>  			status = PTR_ERR(clnt);
>  			break;
> 

Thanks! Applied...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
