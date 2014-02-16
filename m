Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f169.google.com ([209.85.214.169]:51293 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbaBPR1h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Feb 2014 12:27:37 -0500
Received: by mail-ob0-f169.google.com with SMTP id wo20so16132253obc.28
        for <linux-nfs@vger.kernel.org>; Sun, 16 Feb 2014 09:27:36 -0800 (PST)
Message-ID: <1392571653.44773.4.camel@leira.trondhjem.org>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Borislav Petkov <bp@alien8.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: John <da_audiophile@yahoo.com>, lkml <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "mlindner@marvell.com" <mlindner@marvell.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Date: Sun, 16 Feb 2014 12:27:33 -0500
In-Reply-To: <20140215232508.GB4508@pd.tnic>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>
	 <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com>
	 <20140215203015.GA4528@pd.tnic>
	 <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>
	 <20140215232508.GB4508@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please ensure that you post to the linux-nfs@vger.kernel.org when
reporting NFS and RPC related bugs.

On Sun, 2014-02-16 at 00:25 +0100, Borislav Petkov wrote:
> On Sat, Feb 15, 2014 at 01:04:22PM -0800, John wrote:
> > Thanks for the reply, Boris.  The .config is unmodified
> > from the Arch Distro default for 3.13.3-1 which can be found
> > here: http://pastebin.com/LPGZ8ZqA
> 
> Yep, it is that struct net *net argument to put_pipe_version() which is NULL:
> 
>   12:   55                      push   %ebp
>   13:   89 e5                   mov    %esp,%ebp
>   15:   56                      push   %esi
>   16:   53                      push   %ebx
>   17:   3e 8d 74 26 00          lea    %ds:0x0(%esi,%eiz,1),%esi
>   1c:   8b 1d 28 e9 a3 f8       mov    0xf8a3e928,%ebx
>   22:   89 c6                   mov    %eax,%esi
>   24:   e8 59 64 5f c8          call   0xc85f6482
>   29:   85 db                   test   %ebx,%ebx
>   2b:*  8b 86 58 08 00 00       mov    0x858(%esi),%eax         <-- trapping instruction
> 
> put_pipe_version:
> 	pushl	%ebp	#
> 	movl	%esp, %ebp	#,
> 	pushl	%esi	#
> 	pushl	%ebx	#
> 	call	mcount
> 	movl	sunrpc_net_id, %ebx	# sunrpc_net_id, sunrpc_net_id.130
> 	movl	%eax, %esi	# net, net
> 	call	__rcu_read_lock	#
> 	testl	%ebx, %ebx	# sunrpc_net_id.130
> 	movl	2136(%esi), %eax	# MEM[(struct net_generic * const *)net_4(D) + 2136B], ng <-- trapping insn
> 
> 
> 	[ 137.689996] ESI: 00000000 EDI: f56efc00 EBP: f568fee8 ESP: f568fee0
> 			   ^^^^^^^^
> 
> Here's the c/asm interleaved version:
> 
> static void put_pipe_version(struct net *net)
> {
>      d80:       55                      push   %ebp
>      d81:       89 e5                   mov    %esp,%ebp
>      d83:       56                      push   %esi
>      d84:       53                      push   %ebx
>      d85:       e8 fc ff ff ff          call   d86 <put_pipe_version+0x6>
>                         d86: R_386_PC32 mcount
>         struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
>      d8a:       8b 1d 00 00 00 00       mov    0x0,%ebx
>                         d8c: R_386_32   sunrpc_net_id
>         spin_unlock(&pipe_version_lock);
>         return ret;
> }
> 
> static void put_pipe_version(struct net *net)
> {
>      d90:       89 c6                   mov    %eax,%esi
>  * block, but only when acquiring spinlocks that are subject to priority
>  * inheritance.
>  */
> static inline void rcu_read_lock(void)
> {
>         __rcu_read_lock();
>      d92:       e8 fc ff ff ff          call   d93 <put_pipe_version+0x13>
>                         d93: R_386_PC32 __rcu_read_lock
>         struct net_generic *ng;
>         void *ptr;
> 
>         rcu_read_lock();
>         ng = rcu_dereference(net->gen);
>         BUG_ON(id == 0 || id > ng->len);
>      d97:       85 db                   test   %ebx,%ebx
> {
>         struct net_generic *ng;
>         void *ptr;
> 
>         rcu_read_lock();
>         ng = rcu_dereference(net->gen);
>      d99:       8b 86 58 08 00 00       mov    0x858(%esi),%eax			<-- trapping insn
> 
> 
> I guess you could avoid the crash if you did
> 
> 	if (!net)
> 		return;
> 
> in put_pipe_version() but this hardly is the right solution. Someone
> else has to make sense of this thing, not me. :-)

Does the following patch help?

8<-------------------------------------------------------------------
>From 0e57b109cd7b17d6e6f16c3454427372a583b18a Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Sun, 16 Feb 2014 12:14:13 -0500
Subject: [PATCH] SUNRPC: Ensure that gss_auth isn't freed before its upcall
 messages

Fix a race in which the RPC client is shutting down while the
gss daemon is processing a downcall. If the RPC client manages to
shut down before the gss daemon is done, then the struct gss_auth
used in gss_release_msg() may have already been freed.

Link: http://lkml.kernel.org/r/1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com
Reported-by: John <da_audiophile@yahoo.com>
Reported-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 44a61e8fda6f..1ba1fd114912 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -108,6 +108,7 @@ struct gss_auth {
 static DEFINE_SPINLOCK(pipe_version_lock);
 static struct rpc_wait_queue pipe_version_rpc_waitqueue;
 static DECLARE_WAIT_QUEUE_HEAD(pipe_version_waitqueue);
+static void gss_put_auth(struct gss_auth *gss_auth);
 
 static void gss_free_ctx(struct gss_cl_ctx *);
 static const struct rpc_pipe_ops gss_upcall_ops_v0;
@@ -320,6 +321,7 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
 	if (gss_msg->ctx != NULL)
 		gss_put_ctx(gss_msg->ctx);
 	rpc_destroy_wait_queue(&gss_msg->rpc_waitqueue);
+	gss_put_auth(gss_msg->auth);
 	kfree(gss_msg);
 }
 
@@ -500,6 +502,7 @@ gss_alloc_msg(struct gss_auth *gss_auth,
 		if (err)
 			goto err_free_msg;
 	};
+	kref_get(&gss_auth->kref);
 	return gss_msg;
 err_free_msg:
 	kfree(gss_msg);
@@ -1064,6 +1067,12 @@ gss_free_callback(struct kref *kref)
 }
 
 static void
+gss_put_auth(struct gss_auth *gss_auth)
+{
+	kref_put(&gss_auth->kref, gss_free_callback);
+}
+
+static void
 gss_destroy(struct rpc_auth *auth)
 {
 	struct gss_auth *gss_auth = container_of(auth,
@@ -1084,7 +1093,7 @@ gss_destroy(struct rpc_auth *auth)
 	gss_auth->gss_pipe[1] = NULL;
 	rpcauth_destroy_credcache(auth);
 
-	kref_put(&gss_auth->kref, gss_free_callback);
+	gss_put_auth(gss_auth);
 }
 
 /*
@@ -1255,7 +1264,7 @@ gss_destroy_nullcred(struct rpc_cred *cred)
 	call_rcu(&cred->cr_rcu, gss_free_cred_callback);
 	if (ctx)
 		gss_put_ctx(ctx);
-	kref_put(&gss_auth->kref, gss_free_callback);
+	gss_put_auth(gss_auth);
 }
 
 static void
-- 
1.8.5.3


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


