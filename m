Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43990 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752173Ab2H3Ucf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Aug 2012 16:32:35 -0400
Date: Thu, 30 Aug 2012 16:32:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Vivek Trivedi <vtrivedi018@gmail.com>
Subject: Re: [PATCH] nfsd: remove duplicate init in nfsd4_cb_recall
Message-ID: <20120830203234.GB23478@fieldses.org>
References: <1346249453-3549-1-git-send-email-linkinjeon@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1346249453-3549-1-git-send-email-linkinjeon@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 29, 2012 at 10:10:53AM -0400, Namjae Jeon wrote:
> remove duplicate init in nfsd4_cb_recall

Thanks, applying for 3.7.--b.

> 
> Signed-off-by: Namjae Jeon <linkinjeon@gmail.com>
> Signed-off-by: Vivek Trivedi <vtrivedi018@gmail.com>
> ---
>  fs/nfsd/nfs4callback.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 4c7bd35..bdf29c9 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -1028,7 +1028,6 @@ void nfsd4_cb_recall(struct nfs4_delegation *dp)
>  	cb->cb_msg.rpc_cred = callback_cred;
>  
>  	cb->cb_ops = &nfsd4_cb_recall_ops;
> -	dp->dl_retries = 1;
>  
>  	INIT_LIST_HEAD(&cb->cb_per_client);
>  	cb->cb_done = true;
> -- 
> 1.7.9.5
> 
