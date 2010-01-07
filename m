Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48734 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751706Ab0AGUau convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2010 15:30:50 -0500
Subject: [GIT PULL] Please pull NFS client bugfixes....
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Marvin <marvin24@gmx.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Randy Dunlap <randy.dunlap@oracle.com>,
        Jeff Layton <jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 07 Jan 2010 15:29:34 -0500
Message-ID: <1262896174.2659.3.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/dir.c                          |    1 +
 net/sunrpc/auth_gss/auth_gss.c        |   17 ++++++++++++++++-
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    4 +++-
 net/sunrpc/auth_gss/gss_mech_switch.c |    2 +-
 4 files changed, 21 insertions(+), 3 deletions(-)

commit 56335936de1a41c8978fde62b2158af77ddc7258
Author: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date:   Wed Jan 6 18:48:26 2010 -0500

    nfs: fix oops in nfs_rename()
    
    Recent change is missing to update "rehash".  With that change, it will
    become the cause of adding dentry to hash twice.
    
    This explains the reason of Oops (dereference the freed dentry in
    __d_lookup()) on my machine.
    
    Signed-off-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
    Reported-by: Marvin <marvin24@gmx.de>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6c8530993e1fdf1d6af0403e796fe14d80b4b097
Author: Randy Dunlap <randy.dunlap@oracle.com>
Date:   Wed Jan 6 17:26:27 2010 -0500

    sunrpc: fix build-time warning
    
    Fix auth_gss printk format warning:
    
    net/sunrpc/auth_gss/auth_gss.c:660: warning: format '%ld' expects type 'long int', but argument 3 has type 'ssize_t'
    
    Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
    Acked-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 486bad2e40e938cd68fd853b7a9fa3115a9d3a4a
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Dec 18 16:28:20 2009 -0500

    sunrpc: on successful gss error pipe write, don't return error
    
    When handling the gssd downcall, the kernel should distinguish between a
    successful downcall that contains an error code and a failed downcall
    (i.e. where the parsing failed or some other sort of problem occurred).
    
    In the former case, gss_pipe_downcall should be returning the number of
    bytes written to the pipe instead of an error. In the event of other
    errors, we generally want the initiating task to retry the upcall so
    we set msg.errno to -EAGAIN. An unexpected error code here is a bug
    however, so BUG() in that case.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b891e4a05ef6beac85465295a032431577c66b16
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Dec 18 16:28:12 2009 -0500

    SUNRPC: Fix the return value in gss_import_sec_context()
    
    If the context allocation fails, it will return GSS_S_FAILURE, which is
    neither a valid error code, nor is it even negative.
    
    Return ENOMEM instead...
    
    Reported-by: Jeff Layton <jlayton@redhat.com>
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 14ace024b1e16d2bb9445c8387494fbbd820a738
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Dec 18 16:28:05 2009 -0500

    SUNRPC: Fix up an error return value in gss_import_sec_context_kerberos()
    
    If the context allocation fails, the function currently returns a random
    error code, since the variable 'p' still points to a valid memory location.
    
    Ensure that it returns ENOMEM...
    
    Cc: stable@kernel.org
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2c5ace4..3c7f03b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1615,6 +1615,7 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 				goto out;
 
 			new_dentry = dentry;
+			rehash = NULL;
 			new_inode = NULL;
 		}
 	}
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 3c3c50f..f7a7f83 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -644,7 +644,22 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech);
 	if (IS_ERR(p)) {
 		err = PTR_ERR(p);
-		gss_msg->msg.errno = (err == -EAGAIN) ? -EAGAIN : -EACCES;
+		switch (err) {
+		case -EACCES:
+			gss_msg->msg.errno = err;
+			err = mlen;
+			break;
+		case -EFAULT:
+		case -ENOMEM:
+		case -EINVAL:
+		case -ENOSYS:
+			gss_msg->msg.errno = -EAGAIN;
+			break;
+		default:
+			printk(KERN_CRIT "%s: bad return from "
+				"gss_fill_context: %zd\n", __func__, err);
+			BUG();
+		}
 		goto err_release_msg;
 	}
 	gss_msg->ctx = gss_get_ctx(ctx);
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index ef45eba..2deb0ed 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -131,8 +131,10 @@ gss_import_sec_context_kerberos(const void *p,
 	struct	krb5_ctx *ctx;
 	int tmp;
 
-	if (!(ctx = kzalloc(sizeof(*ctx), GFP_NOFS)))
+	if (!(ctx = kzalloc(sizeof(*ctx), GFP_NOFS))) {
+		p = ERR_PTR(-ENOMEM);
 		goto out_err;
+	}
 
 	p = simple_get_bytes(p, end, &ctx->initiate, sizeof(ctx->initiate));
 	if (IS_ERR(p))
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 6efbb0c..76e4c6f 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -252,7 +252,7 @@ gss_import_sec_context(const void *input_token, size_t bufsize,
 		       struct gss_ctx		**ctx_id)
 {
 	if (!(*ctx_id = kzalloc(sizeof(**ctx_id), GFP_KERNEL)))
-		return GSS_S_FAILURE;
+		return -ENOMEM;
 	(*ctx_id)->mech_type = gss_mech_get(mech);
 
 	return mech->gm_ops

