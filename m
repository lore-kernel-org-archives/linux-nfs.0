Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44592 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757627Ab1FJVIr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 17:08:47 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH v3 2/6] nfs-utils:  Add patch to parse srcaddr= option.
Date: Fri, 10 Jun 2011 14:08:12 -0700
Message-Id: <1307740096-19933-3-git-send-email-greearb@candelatech.com>
In-Reply-To: <1307740096-19933-1-git-send-email-greearb@candelatech.com>
References: <1307740096-19933-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This will be used to parse the IP address used for
binding to a particular local IP address.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 5ba6967... 65c2145... M	utils/mount/network.c
:100644 100644 a832e76... 6f66822... M	utils/mount/network.h
 utils/mount/network.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h |    2 ++
 2 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 5ba6967..65c2145 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -405,6 +405,51 @@ out:
 }
 
 /*
+ *  node should be an IPv4 or IPv6 address numeric notation.
+ *  The value will be parsed in placed into laddr.
+ */
+void
+parse_local_bind(struct local_bind_info *laddr, const char* node) {
+	/* str is an IP address. */
+	int aiErr;
+	struct addrinfo *aiHead;
+	struct addrinfo hints;
+
+	laddr->is_set = 0;
+
+	memset(&hints, 0, sizeof(hints));
+
+	hints.ai_flags  = AI_NUMERICSERV;
+	hints.ai_socktype = SOCK_STREAM;
+	hints.ai_protocol = IPPROTO_TCP;
+	hints.ai_family = PF_INET;
+
+	aiErr = getaddrinfo(node, NULL, &hints, &aiHead);
+
+	/* If we tried PF_INET and it failed, try IPv6 instead
+	 * to see if it resolves properly.
+	 */
+	if (aiErr != 0) {
+		hints.ai_family = PF_INET6;
+		aiErr = getaddrinfo(node, NULL, &hints, &aiHead);
+	}
+
+	if (aiErr != 0) {
+		nfs_error(_("%s: parse srcaddr failed, "
+			    "node: %s  aiErr: %i %s\n"),
+			  progname, node, aiErr, gai_strerror(aiErr));
+	} else {
+		if (aiHead) {
+			memcpy(&laddr->addr, aiHead->ai_addr,
+			       aiHead->ai_addrlen);
+			laddr->addrlen = aiHead->ai_addrlen;
+			laddr->is_set = true;
+			freeaddrinfo(aiHead);
+		}
+	}
+}
+
+/*
  * Create a socket that is locally bound to a reserved or non-reserved port.
  *
  * The caller should check rpc_createerr to determine the cause of any error.
diff --git a/utils/mount/network.h b/utils/mount/network.h
index a832e76..6f66822 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -36,6 +36,8 @@ typedef struct {
 	struct pmap pmap;
 } clnt_addr_t;
 
+void parse_local_bind(struct local_bind_info *laddr, const char* str);
+
 /* RPC call timeout values */
 static const struct timeval TIMEOUT = { 20, 0 };
 static const struct timeval RETRY_TIMEOUT = { 3, 0 };
-- 
1.7.3.4

