Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44708 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935166AbeFRRZo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Jun 2018 13:25:44 -0400
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <trondmy@gmail.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Stop mounts hanging in upcalls to rpc.gssd.
Date: Mon, 18 Jun 2018 13:25:42 -0400
Message-Id: <20180618172542.45519-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To stop mounts hanging forever due to a hung
upcall to rpc.gssd, this patch adds a 5 sec
timeout to that upcall.

When the upcall does hung the mount will timeout
in about a min or so due to all the retries by the
sunrpc layer.

The mount will either fail when a krb5 flavor is
specified or roll back to a sys flavor mount.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index be8f103d22fd..407a9a571be0 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -75,6 +75,8 @@ static unsigned int gss_key_expire_timeo = GSS_KEY_EXPIRE_TIMEO;
  * using integrity (two 4-byte integers): */
 #define GSS_VERF_SLACK		100
 
+#define GSS_UPCALL_TIMEO (5 * HZ)
+
 static DEFINE_HASHTABLE(gss_auth_hash_table, 4);
 static DEFINE_SPINLOCK(gss_auth_hash_lock);
 
@@ -658,7 +660,14 @@ gss_create_upcall(struct gss_auth *gss_auth, struct gss_cred *gss_cred)
 			err = -ERESTARTSYS;
 			goto out_intr;
 		}
-		schedule();
+		if (schedule_timeout(GSS_UPCALL_TIMEO) == 0) {
+			warn_gssd();
+			if (!gssd_running(net))
+				err = -EACCES;
+			else
+				err = -ETIMEDOUT;
+			goto out_intr;
+		}
 	}
 	if (gss_msg->ctx)
 		gss_cred_set_ctx(cred, gss_msg->ctx);
-- 
2.17.1

