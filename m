Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48835 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757800Ab3APV5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2013 16:57:23 -0500
Date: Wed, 16 Jan 2013 16:57:19 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mika Westerberg <mika.westerberg@linux.intel.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: fix compile warning about unused variable 'nn'
Message-ID: <20130116215719.GC6598@fieldses.org>
References: <1358235787-17292-1-git-send-email-mika.westerberg@linux.intel.com>
 <1358235787-17292-2-git-send-email-mika.westerberg@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1358235787-17292-2-git-send-email-mika.westerberg@linux.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 15, 2013 at 09:43:07AM +0200, Mika Westerberg wrote:
> Commit c9a4962881 (nfsd: make client_lock per net) added
> lockdep_assert_held() call to function free_client(). However, if lockdep
> is disabled we get following compiler warning:
> 
> fs/nfsd/nfs4state.c: In function ‘free_client’:
> fs/nfsd/nfs4state.c:1051:19: warning: unused variable ‘nn’ [-Wunused-variable]
> 
> Fix this by marking the 'nn' with __maybe_unused.

I queued up fixes for these for 3.9 on the assumption it's better to
live with the compile errors a little longer than to submit unimportant
stuff for post-merge-window 3.8.

But if it means more people are going to waste time tripping over these,
then maybe they should just go in now--I don't know.

--b.

> 
> Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
> ---
>  fs/nfsd/nfs4state.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index ac8ed96..2d3011c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1048,7 +1048,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
>  static inline void
>  free_client(struct nfs4_client *clp)
>  {
> -	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +	struct nfsd_net *nn __maybe_unused = net_generic(clp->net, nfsd_net_id);
>  
>  	lockdep_assert_held(&nn->client_lock);
>  	while (!list_empty(&clp->cl_sessions)) {
> -- 
> 1.7.10.4
> 
