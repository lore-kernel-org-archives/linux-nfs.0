From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] text-based mount: Set addr= option in nfs_try_mount_foo()
Date: Fri, 22 Jan 2010 16:06:38 -0500
Message-ID: <20100122210638.10598.91302.stgit@localhost.localdomain>
References: <20100122210221.10598.84522.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:27690 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401Ab0AVVHd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2010 16:07:33 -0500
In-Reply-To: <20100122210221.10598.84522.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When retrying a mount request with a different server address, the
addr= option may change each time through the fg/bg loop.

Instead of setting the addr= option in nfs_validate_options(), set it
in nfs_try_mount_v2v3() and nfs_try_mount_v4().  This is much the
same thing we did recently with the version-specific mount options
which might change each time through the fg/bg retry loop.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 4ffee48..fc1b0da 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -563,10 +563,6 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
 		return 0;
 	}
 
-	if (verbose)
-		printf(_("%s: trying text-based options '%s'\n"),
-			progname, options);
-
 	if (mi->fake)
 		return 1;
 
@@ -585,6 +581,7 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
  */
 static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
 {
+	struct addrinfo *ai = mi->address;
 	struct mount_options *options = po_dup(mi->options);
 	int result = 0;
 
@@ -593,6 +590,11 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
 		return result;
 	}
 
+	if (!nfs_append_addr_option(ai->ai_addr, ai->ai_addrlen, options)) {
+		errno = EINVAL;
+		goto out_fail;
+	}
+
 	if (!nfs_fix_mounthost_option(options, mi->hostname)) {
 		errno = EINVAL;
 		goto out_fail;
@@ -613,6 +615,10 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
 		goto out_fail;
 	}
 
+	if (verbose)
+		printf(_("%s: trying text-based options '%s'\n"),
+			progname, *mi->extra_opts);
+
 	if (!nfs_rewrite_pmap_mount_options(options))
 		goto out_fail;
 
@@ -656,6 +662,11 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 		}
 	}
 
+	if (!nfs_append_addr_option(ai->ai_addr, ai->ai_addrlen, options)) {
+		errno = EINVAL;
+		goto out_fail;
+	}
+
 	if (!nfs_append_clientaddr_option(ai->ai_addr, ai->ai_addrlen, options)) {
 		errno = EINVAL;
 		goto out_fail;
@@ -669,6 +680,10 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 		goto out_fail;
 	}
 
+	if (verbose)
+		printf(_("%s: trying text-based options '%s'\n"),
+			progname, *mi->extra_opts);
+
 	result = nfs_sys_mount(mi, options);
 
 out_fail:

