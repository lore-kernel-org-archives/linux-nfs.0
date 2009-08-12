From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/7] nfsd: convert gen_callback to use rpc_uaddr2sockaddr
Date: Wed, 12 Aug 2009 07:57:04 -0400
Message-ID: <1250078226-10511-6-git-send-email-jlayton@redhat.com>
References: <1250078226-10511-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35942 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177AbZHLL7L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2009 07:59:11 -0400
In-Reply-To: <1250078226-10511-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need for a separate routine here. Use the standard one provided in
sunrpc module.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   82 ++++----------------------------------------------
 1 files changed, 7 insertions(+), 75 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7658070..96a7423 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -897,78 +897,6 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval,
 	return NULL;
 }
 
-/* a helper function for parse_callback */
-static int
-parse_octet(unsigned int *lenp, char **addrp)
-{
-	unsigned int len = *lenp;
-	char *p = *addrp;
-	int n = -1;
-	char c;
-
-	for (;;) {
-		if (!len)
-			break;
-		len--;
-		c = *p++;
-		if (c == '.')
-			break;
-		if ((c < '0') || (c > '9')) {
-			n = -1;
-			break;
-		}
-		if (n < 0)
-			n = 0;
-		n = (n * 10) + (c - '0');
-		if (n > 255) {
-			n = -1;
-			break;
-		}
-	}
-	*lenp = len;
-	*addrp = p;
-	return n;
-}
-
-/* parse and set the setclientid ipv4 callback address */
-static int
-parse_ipv4(unsigned int addr_len, char *addr_val, struct sockaddr_in *s4)
-{
-	int temp = 0;
-	u32 cbaddr = 0;
-	u16 cbport = 0;
-	u32 addrlen = addr_len;
-	char *addr = addr_val;
-	int i, shift;
-
-	s4->sin_family = AF_INET;
-
-	/* ipaddress */
-	shift = 24;
-	for(i = 4; i > 0  ; i--) {
-		if ((temp = parse_octet(&addrlen, &addr)) < 0) {
-			return 0;
-		}
-		cbaddr |= (temp << shift);
-		if (shift > 0)
-		shift -= 8;
-	}
-	s4->sin_addr.s_addr = htonl(cbaddr);
-
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
-}
-
 static void
 gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 {
@@ -978,10 +906,14 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 	if ((se->se_callback_netid_len != 3) || memcmp((char *)se->se_callback_netid_val, "tcp", 3))
 		goto out_err;
 
-	if ( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
-			  (struct sockaddr_in *) &cb->cb_addr)))
+	cb->cb_addrlen = rpc_uaddr2sockaddr(se->se_callback_addr_val,
+					    se->se_callback_addr_len,
+					    (struct sockaddr *) &cb->cb_addr,
+					    sizeof(cb->cb_addr));
+
+	if (!cb->cb_addrlen || cb->cb_addr.ss_family != AF_INET)
 		goto out_err;
-	cb->cb_addrlen = sizeof(struct sockaddr_in);
+
 	cb->cb_minorversion = 0;
 	cb->cb_prog = se->se_callback_prog;
 	cb->cb_ident = se->se_callback_ident;
-- 
1.6.0.6

