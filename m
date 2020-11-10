Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7D0DC61DD8
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Nov 2020 23:29:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 68FE6207E8
	for <linux-nfs@archiver.kernel.org>; Tue, 10 Nov 2020 23:29:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="saJwjPV+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732052AbgKJX3W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 10 Nov 2020 18:29:22 -0500
Received: from mail.kernel.org ([198.145.29.99]:39164 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731982AbgKJX3V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Nov 2020 18:29:21 -0500
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 905352080A
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2020 23:29:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1605050961;
        bh=qf4KMfaV8KzGjVCK8mx8xTWaCJ7GabrbTSZkH8hH3HA=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=saJwjPV+yDFbcxT9nPWDHcBxJNcgUcfnFz7XtwVAng//OcewDglW7h8oU7pY7pBpf
         LzWDYe5z7m+otWgqiGFUy9Q7uB7GTtWUxx3XEywkQF1H3lv/LU8H84U6S3RCTrOSMA
         drCX7f0UAG4BRQz9yDWxyUCqx20UJUMx+0Jf7eoY=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 04/11] NFS: Switch mount code to use xprt_find_transport_ident()
Date:   Tue, 10 Nov 2020 18:18:59 -0500
Message-Id: <20201110231906.863446-5-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201110231906.863446-4-trondmy@kernel.org>
References: <20201110231906.863446-1-trondmy@kernel.org>
 <20201110231906.863446-2-trondmy@kernel.org>
 <20201110231906.863446-3-trondmy@kernel.org>
 <20201110231906.863446-4-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Switch the mount code to use xprt_find_transport_ident() and to check
the results before allowing the mount to proceed.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/fs_context.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/fs_context.c b/fs/nfs/fs_context.c
index 29ec8b09a52d..06894bcdea2d 100644
--- a/fs/nfs/fs_context.c
+++ b/fs/nfs/fs_context.c
@@ -510,13 +510,12 @@ static int nfs_fs_context_parse_param(struct fs_context *fc,
 		ctx->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 		break;
 	case Opt_tcp:
-		ctx->flags |= NFS_MOUNT_TCP;
-		ctx->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-		break;
 	case Opt_rdma:
 		ctx->flags |= NFS_MOUNT_TCP; /* for side protocols */
-		ctx->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
-		xprt_load_transport(param->key);
+		ret = xprt_find_transport_ident(param->key);
+		if (ret < 0)
+			goto out_bad_transport;
+		ctx->nfs_server.protocol = ret;
 		break;
 	case Opt_acl:
 		if (result.negated)
@@ -670,11 +669,13 @@ static int nfs_fs_context_parse_param(struct fs_context *fc,
 		case Opt_xprt_rdma:
 			/* vector side protocols to TCP */
 			ctx->flags |= NFS_MOUNT_TCP;
-			ctx->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
-			xprt_load_transport(param->string);
+			ret = xprt_find_transport_ident(param->string);
+			if (ret < 0)
+				goto out_bad_transport;
+			ctx->nfs_server.protocol = ret;
 			break;
 		default:
-			return nfs_invalf(fc, "NFS: Unrecognized transport protocol");
+			goto out_bad_transport;
 		}
 
 		ctx->protofamily = protofamily;
@@ -697,7 +698,7 @@ static int nfs_fs_context_parse_param(struct fs_context *fc,
 			break;
 		case Opt_xprt_rdma: /* not used for side protocols */
 		default:
-			return nfs_invalf(fc, "NFS: Unrecognized transport protocol");
+			goto out_bad_transport;
 		}
 		ctx->mountfamily = mountfamily;
 		break;
@@ -787,6 +788,8 @@ static int nfs_fs_context_parse_param(struct fs_context *fc,
 	return nfs_invalf(fc, "NFS: Bad IP address specified");
 out_of_bounds:
 	return nfs_invalf(fc, "NFS: Value for '%s' out of range", param->key);
+out_bad_transport:
+	return nfs_invalf(fc, "NFS: Unrecognized transport protocol");
 }
 
 /*
-- 
2.28.0

