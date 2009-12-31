From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] sunrpc: fix build-time warning
Date: Wed, 30 Dec 2009 21:23:15 -0500
Message-ID: <1262226195-27733-1-git-send-email-jlayton@redhat.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:40479 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735AbZLaCXS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Dec 2009 21:23:18 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 486bad2e40e938cd68fd853b7a9fa3115a9d3a4a introduced this warning
at build time on some 32-bit architectures:

net/sunrpc/auth_gss/auth_gss.c: In function 'gss_pipe_downcall':
net/sunrpc/auth_gss/auth_gss.c:660: warning: format '%ld' expects type 'long int', but argument 3 has type 'ssize_t

...fix it by changing the length modifier in the printk.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 66cb89c..6de4f91 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -657,7 +657,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 			break;
 		default:
 			printk(KERN_CRIT "%s: bad return from "
-				"gss_fill_context: %ld\n", __func__, err);
+				"gss_fill_context: %Zd\n", __func__, err);
 			BUG();
 		}
 		goto err_release_msg;
-- 
1.6.5.2

