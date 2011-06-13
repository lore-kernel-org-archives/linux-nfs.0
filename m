Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55405 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409Ab1FMV11 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 17:27:27 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH v4 2/6] nfs-utils:  Add patch to parse srcaddr= option.
Date: Mon, 13 Jun 2011 14:26:44 -0700
Message-Id: <1308000408-13690-3-git-send-email-greearb@candelatech.com>
In-Reply-To: <1308000408-13690-1-git-send-email-greearb@candelatech.com>
References: <1308000408-13690-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This will be used to parse the IP address used for
binding to a particular local IP address.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 bbe92e9... b046874... M	utils/mount/network.c
:100644 100644 4debfaa... 292ad1f... M	utils/mount/network.h
 utils/mount/network.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h |    3 ++
 2 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index bbe92e9..b046874 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -405,6 +405,57 @@ out:
 }
 
 /*
+ *  node should be an IPv4 or IPv6 address numeric notation.
+ *  The value will be parsed in placed into laddr.
+ *  Returns < 0 on failure to parse.
+ */
+int
+nfs_parse_local_bind(struct local_bind_info *laddr, const char* node,
+		     sa_family_t family) {
+	/* str is an IP address. */
+	int aiErr;
+	struct addrinfo *aiHead;
+	struct addrinfo hints;
+
+	memset(&hints, 0, sizeof(hints));
+
+	hints.ai_flags  = AI_NUMERICSERV;
+	hints.ai_socktype = SOCK_STREAM;
+	hints.ai_protocol = IPPROTO_TCP;
+	hints.ai_family = family;
+
+	aiErr = getaddrinfo(node, NULL, &hints, &aiHead);
+
+	if (aiErr != 0) {
+		char *f;
+		switch (family) {
+		case AF_INET:
+			f = "AF_INET";
+			break;
+		case AF_INET6:
+			f = "AF_INET6";
+			break;
+		default:
+			f = "UNKNOWN";
+			break;
+		}
+
+		nfs_error(_("%s: parse srcaddr failed, "
+			    "node: %s family: %s  aiErr: %i %s\n"),
+			  progname, node, f, aiErr, gai_strerror(aiErr));
+	} else {
+		if (aiHead) {
+			memcpy(&laddr->addr, aiHead->ai_addr,
+			       aiHead->ai_addrlen);
+			laddr->addrlen = aiHead->ai_addrlen;
+			freeaddrinfo(aiHead);
+			return 0;
+		}
+	}
+	return -1;
+}
+
+/*
  * Create a socket that is locally bound to a reserved or non-reserved port.
  *
  * The caller should check rpc_createerr to determine the cause of any error.
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 4debfaa..292ad1f 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -36,6 +36,9 @@ typedef struct {
 	struct pmap pmap;
 } clnt_addr_t;
 
+int nfs_parse_local_bind(struct local_bind_info *laddr, const char* str,
+			 sa_family_t family);
+
 /* RPC call timeout values */
 static const struct timeval TIMEOUT = { 20, 0 };
 static const struct timeval RETRY_TIMEOUT = { 3, 0 };
-- 
1.7.3.4

