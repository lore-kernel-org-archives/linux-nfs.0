Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49726 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016AbcHDBen convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2016 21:34:43 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 1/1] SUNRPC: allow for upcalls for same uid but different gss service
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1470269988-15806-1-git-send-email-kolga@netapp.com>
Date: Wed, 3 Aug 2016 21:34:14 -0400
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <12B6E3DD-8B61-49B1-8C9C-98D7AF5FA2DC@oracle.com>
References: <1470269988-15806-1-git-send-email-kolga@netapp.com>
To: Olga Kornievskaia <kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 3, 2016, at 8:19 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> 
> It's possible to have simultaneous upcalls for the same UIDs but
> different GSS service. In that case, we need to allow for the
> upcall to gssd to proceed so that not the same context is used
> by two different GSS services. Some servers lock the use of context
> to the GSS service.

Hi Olga-

I will get this to Helen for testing ASAP.


> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
> net/sunrpc/auth_gss/auth_gss.c | 8 +++++---
> 1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 23c8e7c..976c781 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -340,12 +340,14 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
> }
> 
> static struct gss_upcall_msg *
> -__gss_find_upcall(struct rpc_pipe *pipe, kuid_t uid)
> +__gss_find_upcall(struct rpc_pipe *pipe, kuid_t uid, const struct gss_auth *auth)
> {
> 	struct gss_upcall_msg *pos;
> 	list_for_each_entry(pos, &pipe->in_downcall, list) {
> 		if (!uid_eq(pos->uid, uid))
> 			continue;
> +		if (auth && pos->auth->service != auth->service)
> +			continue;
> 		atomic_inc(&pos->count);
> 		dprintk("RPC:       %s found msg %p\n", __func__, pos);
> 		return pos;
> @@ -365,7 +367,7 @@ gss_add_msg(struct gss_upcall_msg *gss_msg)
> 	struct gss_upcall_msg *old;
> 
> 	spin_lock(&pipe->lock);
> -	old = __gss_find_upcall(pipe, gss_msg->uid);
> +	old = __gss_find_upcall(pipe, gss_msg->uid, gss_msg->auth);
> 	if (old == NULL) {
> 		atomic_inc(&gss_msg->count);
> 		list_add(&gss_msg->list, &pipe->in_downcall);
> @@ -714,7 +716,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
> 	err = -ENOENT;
> 	/* Find a matching upcall */
> 	spin_lock(&pipe->lock);
> -	gss_msg = __gss_find_upcall(pipe, uid);
> +	gss_msg = __gss_find_upcall(pipe, uid, NULL);
> 	if (gss_msg == NULL) {
> 		spin_unlock(&pipe->lock);
> 		goto err_put_ctx;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



