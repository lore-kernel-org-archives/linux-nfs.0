Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60605 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755548Ab2JVQHE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:07:04 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3828544iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:07:04 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/10] rpc.gssd: Squelch compiler warning
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:07:01 -0400
Message-ID: <20121022160701.4552.16847.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gssd_proc.c: At top level:
gssd_proc.c:782:5: warning: no previous prototype for
‘create_auth_rpc_client’ [-Wmissing-prototypes]

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/gssd_proc.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index b9a898e..1bc3942 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -802,11 +802,12 @@ set_port:
  * Create an RPC connection and establish an authenticated
  * gss context with a server.
  */
-int create_auth_rpc_client(struct clnt_info *clp,
-			   CLIENT **clnt_return,
-			   AUTH **auth_return,
-			   uid_t uid,
-			   int authtype)
+static int
+create_auth_rpc_client(struct clnt_info *clp,
+		       CLIENT **clnt_return,
+		       AUTH **auth_return,
+		       uid_t uid,
+		       int authtype)
 {
 	CLIENT			*rpc_clnt = NULL;
 	struct rpc_gss_sec	sec;

