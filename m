From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/5] nfsd: break out setclientid port parsing into separate routine
Date: Fri, 19 Jun 2009 14:42:58 -0400
Message-ID: <1245436981-11806-3-git-send-email-jlayton@redhat.com>
References: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
Cc: bfields@fieldses.org, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:48386 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbZFSSnA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2009 14:43:00 -0400
In-Reply-To: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and change the parse_ipv4 routine to be a little more efficient with
the stack.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   46 ++++++++++++++++++++++++++++++----------------
 1 files changed, 30 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d9ef1ea..92512de 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -935,15 +935,40 @@ parse_octet(unsigned int *lenp, char **addrp)
 	return n;
 }
 
+/*
+ * Parse port out of setclientid callback address
+ *
+ * @addrlen: remaining length of address string
+ * @addr: pointer to first port octet in address string
+ * @sa: pointer to port field in sockaddr
+ *
+ * Parse the port portion of a setclientid callback address. Returns true on
+ * success and false on failure.
+ */
+static bool
+parse_port(unsigned int addrlen, char *addr, __be16 *port)
+{
+	int temp = 0, i, shift = 8;
+	u16 cbport = 0;
+
+	for (i = 2; i > 0; i--) {
+		temp = parse_octet(&addrlen, &addr);
+		if (temp < 0)
+			return 0;
+		cbport |= (temp << shift);
+		if (shift > 0)
+			shift -= 8;
+	}
+	*port = htons(cbport);
+	return 1;
+}
+
 /* parse and set the setclientid ipv4 callback address */
 static int
-parse_ipv4(unsigned int addr_len, char *addr_val, struct sockaddr_in *s4)
+parse_ipv4(unsigned int addrlen, char *addr, struct sockaddr_in *s4)
 {
 	int temp = 0;
 	u32 cbaddr = 0;
-	u16 cbport = 0;
-	u32 addrlen = addr_len;
-	char *addr = addr_val;
 	int i, shift;
 
 	s4->sin_family = AF_INET;
@@ -960,18 +985,7 @@ parse_ipv4(unsigned int addr_len, char *addr_val, struct sockaddr_in *s4)
 	}
 	s4->sin_addr.s_addr = htonl(cbaddr);
 
-	/* port */
-	shift = 8;
-	for(i = 2; i > 0  ; i--) {
-		if ((temp = parse_octet(&addrlen, &addr)) < 0) {
-			return 0;
-		}
-		cbport |= (temp << shift);
-		if (shift > 0)
-			shift -= 8;
-	}
-	s4->sin_port = htons(cbport);
-	return 1;
+	return parse_port(addrlen, addr, &s4->sin_port);
 }
 
 static void
-- 
1.6.0.6

