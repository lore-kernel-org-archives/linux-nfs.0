Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43061 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753655AbaJBTxj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Oct 2014 15:53:39 -0400
Date: Thu, 2 Oct 2014 15:53:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] NFSD: Always initialize cl_cb_addr
Message-ID: <20141002195338.GA13925@fieldses.org>
References: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
 <20140822191059.3883.7753.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140822191059.3883.7753.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 22, 2014 at 03:10:59PM -0400, Chuck Lever wrote:
> A client may not want to use the back channel on a transport it sent
> CREATE_SESSION on, in which case it clears SESSION4_BACK_CHAN.
> 
> However, cl_cb_addr should be populated anyway, to be used if the
> client binds other connections to this session. If cl_cb_addr is
> not initialized, rpc_create() fails when the server attempts to
> set up a back channel on such secondary transports.

OK, applying.--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfsd/nfs4state.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2e80a59..a45f244 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1429,7 +1429,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
>  	list_add(&new->se_perclnt, &clp->cl_sessions);
>  	spin_unlock(&clp->cl_lock);
>  
> -	if (cses->flags & SESSION4_BACK_CHAN) {
> +	{
>  		struct sockaddr *sa = svc_addr(rqstp);
>  		/*
>  		 * This is a little silly; with sessions there's no real
> 
