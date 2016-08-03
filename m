Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:48221 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755167AbcHCWTJ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2016 18:19:09 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Kornievskaia Olga <kolga@netapp.com>
CC: Trond Myklebust <trondmy@primarydata.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] SUNRPC: allow for upcalls for same uid but different
 gss service
Date: Wed, 3 Aug 2016 22:19:02 +0000
Message-ID: <D13C7BE9-5431-46F0-B0A7-CE731E00DB5F@primarydata.com>
References: <1470260832-15662-1-git-send-email-kolga@netapp.com>
In-Reply-To: <1470260832-15662-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 3, 2016, at 17:47, Olga Kornievskaia <kolga@netapp.com> wrote:
> 
> It's possible to have simultaneous upcalls for the same UIDs but
> different GSS service. In that case, we need to allow for the
> upcall to gssd to proceed so that not the same context is used
> by two different GSS services. Some servers lock the use of context
> to the GSS service.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
> net/sunrpc/auth_gss/auth_gss.c | 8 +++++---
> 1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 23c8e7c..5b60112 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -340,12 +340,14 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
> }
> 
> static struct gss_upcall_msg *
> -__gss_find_upcall(struct rpc_pipe *pipe, kuid_t uid)
> +__gss_find_upcall(struct rpc_pipe *pipe, kuid_t uid, int service)

Can you please make that a pointer to a const struct gss_auth *?

> {
> 	struct gss_upcall_msg *pos;
> 	list_for_each_entry(pos, &pipe->in_downcall, list) {
> 		if (!uid_eq(pos->uid, uid))
> 			continue;
> +		if (service != -1 && pos->auth->service != service)

…so that we don’t need a “magic” value for “service” here. Just test for auth == NULL.

> +			continue;
> 		atomic_inc(&pos->count);
> 		dprintk("RPC:       %s found msg %p\n", __func__, pos);
> 		return pos;
> @@ -365,7 +367,7 @@ gss_add_msg(struct gss_upcall_msg *gss_msg)
> 	struct gss_upcall_msg *old;
> 
> 	spin_lock(&pipe->lock);
> -	old = __gss_find_upcall(pipe, gss_msg->uid);
> +	old = __gss_find_upcall(pipe, gss_msg->uid, gss_msg->auth->service);
> 	if (old == NULL) {
> 		atomic_inc(&gss_msg->count);
> 		list_add(&gss_msg->list, &pipe->in_downcall);
> @@ -714,7 +716,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
> 	err = -ENOENT;
> 	/* Find a matching upcall */
> 	spin_lock(&pipe->lock);
> -	gss_msg = __gss_find_upcall(pipe, uid);
> +	gss_msg = __gss_find_upcall(pipe, uid, -1);
> 	if (gss_msg == NULL) {
> 		spin_unlock(&pipe->lock);
> 		goto err_put_ctx;
> -- 
> 1.8.3.1
> 

Otherwise ACK, this is what we need.

