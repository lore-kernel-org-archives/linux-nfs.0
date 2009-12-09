From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] rpc: remove unneeded function parameter in
	gss_add_msg()
Date: Wed, 9 Dec 2009 13:57:33 -0500
Message-ID: <20091209185733.GC23234@fieldses.org>
References: <1260380722-7599-1-git-send-email-sjayaraman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32773 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757101AbZLIS5U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Dec 2009 13:57:20 -0500
In-Reply-To: <1260380722-7599-1-git-send-email-sjayaraman@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 09, 2009 at 11:15:22PM +0530, Suresh Jayaraman wrote:
> The pointer to struct gss_auth parameter in gss_add_msg is not really needed
> after commit 5b7ddd4a. Zap it.

Looks straightforward to me, thanks.  (Assuming Trond will take it.)

--b.

> 
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index fc6a43c..85ee2ca 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -304,7 +304,7 @@ __gss_find_upcall(struct rpc_inode *rpci, uid_t uid)
>   * to that upcall instead of adding the new upcall.
>   */
>  static inline struct gss_upcall_msg *
> -gss_add_msg(struct gss_auth *gss_auth, struct gss_upcall_msg *gss_msg)
> +gss_add_msg(struct gss_upcall_msg *gss_msg)
>  {
>  	struct rpc_inode *rpci = gss_msg->inode;
>  	struct inode *inode = &rpci->vfs_inode;
> @@ -445,7 +445,7 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
>  	gss_new = gss_alloc_msg(gss_auth, uid, clnt, gss_cred->gc_machine_cred);
>  	if (IS_ERR(gss_new))
>  		return gss_new;
> -	gss_msg = gss_add_msg(gss_auth, gss_new);
> +	gss_msg = gss_add_msg(gss_new);
>  	if (gss_msg == gss_new) {
>  		struct inode *inode = &gss_new->inode->vfs_inode;
>  		int res = rpc_queue_upcall(inode, &gss_new->msg);
> -- 
> 1.6.4.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
