From: Neil Brown <neilb@suse.de>
Subject: Re: Possible-Patch: unregister bdi on error path.
Date: Thu, 11 Mar 2010 11:22:31 +1100
Message-ID: <20100311112231.7db30fd5@notabene.brown>
References: <19352.6543.377883.277948@notabene.brown>
	<1268262107.3096.207.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45090 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755476Ab0CKAWj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Mar 2010 19:22:39 -0500
In-Reply-To: <1268262107.3096.207.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 10 Mar 2010 18:01:47 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> Yes. It looks as if you have indeed found a bug.
> 
> My main comment is that in order to be complete the patch should also
> address the cases of nfs_xdev_get_sb(), nfs4_remote_get_sb(),
> nfs4_xdev_get_sb(), and nfs4_remote_referral_get_sb(). They appear to
> suffer from the same problem...
> 

Good point.  Patch follows.
I have compile-tested this but nothing more.  I'm not even sure how I can
test it as it only affect error paths that are not easy to force.

Thanks,
NeilBrown

>From 8db673fbc28ea018ab0b80c3b1f53bad0d684251 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Thu, 11 Mar 2010 11:20:17 +1100
Subject: [PATCH] NFS: ensure bdi_unregister is called on mount failure.

bdi_unregister is called by nfs_put_super which is only called by
generic_shutdown_super if ->s_root is not NULL.  So if we error out
in a circumstance where we called nfs_bdi_register (i.e. server !=
NULL) but have not set s_root, then we need to call bdi_unregister
explicitly in nfs_get_sb and various other *_get_sb() functions.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f1afee4..6baf9a3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2214,7 +2214,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	} else {
 		error = nfs_bdi_register(server);
 		if (error)
-			goto error_splat_super;
+			goto error_splat_bdi;
 	}
 
 	if (!s->s_root) {
@@ -2256,6 +2256,9 @@ out_err_nosb:
 error_splat_root:
 	dput(mntroot);
 error_splat_super:
+	if (server && !s->s_root)
+		bdi_unregister(&server->backing_dev_info);
+error_splat_bdi:
 	deactivate_locked_super(s);
 	goto out;
 }
@@ -2326,7 +2329,7 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 	} else {
 		error = nfs_bdi_register(server);
 		if (error)
-			goto error_splat_super;
+			goto error_splat_bdi;
 	}
 
 	if (!s->s_root) {
@@ -2363,6 +2366,9 @@ out_err_noserver:
 	return error;
 
 error_splat_super:
+	if (server && !s->s_root)
+		bdi_unregister(&server->backing_dev_info);
+error_splat_bdi:
 	deactivate_locked_super(s);
 	dprintk("<-- nfs_xdev_get_sb() = %d [splat]\n", error);
 	return error;
@@ -2578,7 +2584,7 @@ static int nfs4_remote_get_sb(struct file_system_type *fs_type,
 	} else {
 		error = nfs_bdi_register(server);
 		if (error)
-			goto error_splat_super;
+			goto error_splat_bdi;
 	}
 
 	if (!s->s_root) {
@@ -2616,6 +2622,9 @@ out_free:
 error_splat_root:
 	dput(mntroot);
 error_splat_super:
+	if (server && !s->s_root)
+		bdi_unregister(&server->backing_dev_info);
+error_splat_bdi:
 	deactivate_locked_super(s);
 	goto out;
 }
@@ -2811,7 +2820,7 @@ static int nfs4_xdev_get_sb(struct file_system_type *fs_type, int flags,
 	} else {
 		error = nfs_bdi_register(server);
 		if (error)
-			goto error_splat_super;
+			goto error_splat_bdi;
 	}
 
 	if (!s->s_root) {
@@ -2847,6 +2856,9 @@ out_err_noserver:
 	return error;
 
 error_splat_super:
+	if (server && !s->s_root)
+		bdi_unregister(&server->backing_dev_info);
+error_splat_bdi:
 	deactivate_locked_super(s);
 	dprintk("<-- nfs4_xdev_get_sb() = %d [splat]\n", error);
 	return error;
@@ -2893,7 +2905,7 @@ static int nfs4_remote_referral_get_sb(struct file_system_type *fs_type,
 	} else {
 		error = nfs_bdi_register(server);
 		if (error)
-			goto error_splat_super;
+			goto error_splat_bdi;
 	}
 
 	if (!s->s_root) {
@@ -2929,6 +2941,9 @@ out_err_noserver:
 	return error;
 
 error_splat_super:
+	if (server && !s->s_root)
+		bdi_unregister(&server->backing_dev_info);
+error_splat_bdi:
 	deactivate_locked_super(s);
 	dprintk("<-- nfs4_referral_get_sb() = %d [splat]\n", error);
 	return error;
