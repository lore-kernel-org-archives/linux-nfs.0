Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7933AC282CA
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 15:15:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3AB8F2075C
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 15:15:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549984523;
	bh=s5OlnlLvROAU/0q6bcWo6o5MB0Mr6LM8OgL4RnjSDC4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=NOedMlgXDSc275V009g5LPsk2mTQV6AWa1iguc81M9C0Cz2w1Emf4oxt1hpyDmkfM
	 qkMinnDeOYoG24yfCgedy8ut/n3NlHQ5Bi1y/vnWUalc6tfdNwzA7/40ENe8A1rrvq
	 +yWfjqhitX223Xq0ycNDSveyjMrO9SwAoD3XUnzk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729406AbfBLPOC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 10:14:02 -0500
Received: from mail.kernel.org ([198.145.29.99]:60934 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726238AbfBLPOA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 10:14:00 -0500
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 6FE1D2075C;
        Tue, 12 Feb 2019 15:13:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1549984439;
        bh=s5OlnlLvROAU/0q6bcWo6o5MB0Mr6LM8OgL4RnjSDC4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=nTjIJ74k/CFqEDzfzhm5akpVkGzwqqten1odRBXrZ3tFGNw7Uv8D5ZG7MFfn5RTfF
         N9nIyHUnI89YSCvZj8UY/RsX07/2yJQU6QiWn4msEj1M/nGMEy6N1B9fH5f5ZaJURd
         0RCNy0UPyOvZE1pe+v0V/2PTZe6kLLlwSnYyKFqM=
Date:   Tue, 12 Feb 2019 16:13:57 +0100
From:   Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To:     David Howells <dhowells@redhat.com>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mhiramat@kernel.org, bigeasy@linutronix.de
Subject: Re: Oops in rpc_clnt_debugfs_register() from debugfs change
Message-ID: <20190212151357.GA24831@kroah.com>
References: <20190212144214.GA17111@kroah.com>
 <19914.1549970944@warthog.procyon.org.uk>
 <14223.1549981874@warthog.procyon.org.uk>
 <20190212143720.GA16380@kroah.com>
 <21212.1549983454@warthog.procyon.org.uk>
 <20190212150459.GA19188@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212150459.GA19188@kroah.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 12, 2019 at 04:04:59PM +0100, Greg Kroah-Hartman wrote:
> On Tue, Feb 12, 2019 at 02:57:34PM +0000, David Howells wrote:
> > Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> > 
> > > -	if (!xprt->debugfs) {
> > > +	if (IS_ERR_OR_NULL(xprt->debugfs)) {
> > 
> > That works, though I don't much like the idea of there being an error there.
> > 
> > Looking in rpc_xprt_debugfs_register() there are two now-dodgy looking checks
> > on the result of debugfs calls.
> 
> now-dodgy checks are fine.  Well, they shouldn't matter, I've sent a
> patch that just gets rid of those checks.
> 
> Ideally no one should need to check of debugfs is ok or not, the fact
> that these functions keep getting called is a bit odd, I can look into
> that some more, it shouldn't be needed...

And here's a "final" version of this, that removes all of the "dodgy"
checks, with the exception of the "is this actually a dentry" check that
my first patch had, which is still required.

Overall it makes the code smaller and simpler, but for 5.0-final, I
think my original patch should be all that is needed.

thanks,

greg k-h

-------------------------

From e6114e66bb7921b1e83e5ca0083893afa7816b45 Mon Sep 17 00:00:00 2001
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 4 Jan 2019 13:40:56 +0100
Subject: [PATCH] sunrpc: no need to check return value of debugfs_create functions

When calling debugfs functions, there is no need to ever check the
return value.  The function can work or not, but the code logic should
never do something different based on this.

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 net/sunrpc/debugfs.c | 68 ++++++++------------------------------------
 1 file changed, 12 insertions(+), 56 deletions(-)

diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index 45a033329cd4..c7ad5772f5d9 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -11,7 +11,6 @@
 #include "netns.h"
 
 static struct dentry *topdir;
-static struct dentry *rpc_fault_dir;
 static struct dentry *rpc_clnt_dir;
 static struct dentry *rpc_xprt_dir;
 
@@ -125,28 +124,21 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 	char name[24]; /* enough for "../../rpc_xprt/ + 8 hex digits + NULL */
 	struct rpc_xprt *xprt;
 
-	/* Already registered? */
-	if (clnt->cl_debugfs || !rpc_clnt_dir)
-		return;
-
 	len = snprintf(name, sizeof(name), "%x", clnt->cl_clid);
 	if (len >= sizeof(name))
 		return;
 
 	/* make the per-client dir */
 	clnt->cl_debugfs = debugfs_create_dir(name, rpc_clnt_dir);
-	if (!clnt->cl_debugfs)
-		return;
 
 	/* make tasks file */
-	if (!debugfs_create_file("tasks", S_IFREG | 0400, clnt->cl_debugfs,
-				 clnt, &tasks_fops))
-		goto out_err;
+	debugfs_create_file("tasks", S_IFREG | 0400, clnt->cl_debugfs, clnt,
+			    &tasks_fops);
 
 	rcu_read_lock();
 	xprt = rcu_dereference(clnt->cl_xprt);
 	/* no "debugfs" dentry? Don't bother with the symlink. */
-	if (!xprt->debugfs) {
+	if (IS_ERR_OR_NULL(xprt->debugfs)) {
 		rcu_read_unlock();
 		return;
 	}
@@ -157,8 +149,7 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 	if (len >= sizeof(name))
 		goto out_err;
 
-	if (!debugfs_create_symlink("xprt", clnt->cl_debugfs, name))
-		goto out_err;
+	debugfs_create_symlink("xprt", clnt->cl_debugfs, name);
 
 	return;
 out_err:
@@ -226,9 +217,6 @@ rpc_xprt_debugfs_register(struct rpc_xprt *xprt)
 	static atomic_t	cur_id;
 	char		name[9]; /* 8 hex digits + NULL term */
 
-	if (!rpc_xprt_dir)
-		return;
-
 	id = (unsigned int)atomic_inc_return(&cur_id);
 
 	len = snprintf(name, sizeof(name), "%x", id);
@@ -237,15 +225,10 @@ rpc_xprt_debugfs_register(struct rpc_xprt *xprt)
 
 	/* make the per-client dir */
 	xprt->debugfs = debugfs_create_dir(name, rpc_xprt_dir);
-	if (!xprt->debugfs)
-		return;
 
 	/* make tasks file */
-	if (!debugfs_create_file("info", S_IFREG | 0400, xprt->debugfs,
-				 xprt, &xprt_info_fops)) {
-		debugfs_remove_recursive(xprt->debugfs);
-		xprt->debugfs = NULL;
-	}
+	debugfs_create_file("info", S_IFREG | 0400, xprt->debugfs, xprt,
+			    &xprt_info_fops);
 
 	atomic_set(&xprt->inject_disconnect, rpc_inject_disconnect);
 }
@@ -308,28 +291,11 @@ static const struct file_operations fault_disconnect_fops = {
 	.release	= fault_release,
 };
 
-static struct dentry *
-inject_fault_dir(struct dentry *topdir)
-{
-	struct dentry *faultdir;
-
-	faultdir = debugfs_create_dir("inject_fault", topdir);
-	if (!faultdir)
-		return NULL;
-
-	if (!debugfs_create_file("disconnect", S_IFREG | 0400, faultdir,
-				 NULL, &fault_disconnect_fops))
-		return NULL;
-
-	return faultdir;
-}
-
 void __exit
 sunrpc_debugfs_exit(void)
 {
 	debugfs_remove_recursive(topdir);
 	topdir = NULL;
-	rpc_fault_dir = NULL;
 	rpc_clnt_dir = NULL;
 	rpc_xprt_dir = NULL;
 }
@@ -337,26 +303,16 @@ sunrpc_debugfs_exit(void)
 void __init
 sunrpc_debugfs_init(void)
 {
-	topdir = debugfs_create_dir("sunrpc", NULL);
-	if (!topdir)
-		return;
+	struct dentry *rpc_fault_dir;
 
-	rpc_fault_dir = inject_fault_dir(topdir);
-	if (!rpc_fault_dir)
-		goto out_remove;
+	topdir = debugfs_create_dir("sunrpc", NULL);
 
 	rpc_clnt_dir = debugfs_create_dir("rpc_clnt", topdir);
-	if (!rpc_clnt_dir)
-		goto out_remove;
 
 	rpc_xprt_dir = debugfs_create_dir("rpc_xprt", topdir);
-	if (!rpc_xprt_dir)
-		goto out_remove;
 
-	return;
-out_remove:
-	debugfs_remove_recursive(topdir);
-	topdir = NULL;
-	rpc_fault_dir = NULL;
-	rpc_clnt_dir = NULL;
+	rpc_fault_dir = debugfs_create_dir("inject_fault", topdir);
+
+	debugfs_create_file("disconnect", S_IFREG | 0400, rpc_fault_dir, NULL,
+			    &fault_disconnect_fops);
 }
-- 
2.20.1

