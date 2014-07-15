Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990AbaGOPJs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:48 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 08/15] print_rpc_gss_sec: Make sure logging to stderr is enabled.
Date: Tue, 15 Jul 2014 11:09:27 -0400
Message-Id: <1405436974-4161-9-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It does not make sense to try an covert this routine to
used the new debugging macro. So just insure the correct
debugging level and logging to stderr is enabled.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/auth_gss.c     | 3 +++
 src/authgss_prot.c | 2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/src/auth_gss.c b/src/auth_gss.c
index e636e7e..d8d5a72 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -88,6 +88,9 @@ print_rpc_gss_sec(struct rpc_gss_sec *ptr)
 int i;
 char *p;
 
+	if (libtirpc_debug_level < 4 || log_stderr == 0)
+		return;
+
 	gss_log_debug("rpc_gss_sec:");
 	if(ptr->mech == NULL)
 		gss_log_debug("NULL gss_OID mech");
diff --git a/src/authgss_prot.c b/src/authgss_prot.c
index 6dc4af6..669eab7 100644
--- a/src/authgss_prot.c
+++ b/src/authgss_prot.c
@@ -338,7 +338,7 @@ gss_log_hexdump(const u_char *buf, int len, int offset)
 	u_int i, j, jm;
 	int c;
 
-	if (libtirpc_debug_level < 3 || log_stderr == 0)
+	if (libtirpc_debug_level < 4 || log_stderr == 0)
 		return;
 
 	fprintf(stderr, "\n");
-- 
1.9.3

