Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641Ab2DXO7k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 10:59:40 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: bfields@fieldses.org
Cc: SteveD@redhat.com, linux-nfs@vger.kernel.org,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] nfsd: add IPv6 addr escaping to fs_location hosts
Date: Tue, 24 Apr 2012 10:59:37 -0400
Message-Id: <1335279577-46822-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The fs_location->hosts list is split on colons, but this doesn't work when
IPv6 addresses are used (they contain colons).
This patch adds the function nfsd4_encode_components_esc() to
allow the caller to specify escape characters when splitting on 'sep'.
In order to fix referrals, this patch must be used with the mountd patch
that similarly fixes IPv6 [] escaping.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfsd/nfs4xdr.c |   35 +++++++++++++++++++++++++++++------
 1 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 74c00bc..782be6c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1744,10 +1744,11 @@ static void encode_seqid_op_tail(struct nfsd4_compoundres *resp, __be32 *save, _
 }
 
 /* Encode as an array of strings the string given with components
- * separated @sep.
+ * separated @sep, escaped with esc_enter and esc_exit.
  */
-static __be32 nfsd4_encode_components(char sep, char *components,
-				   __be32 **pp, int *buflen)
+static __be32 nfsd4_encode_components_esc(char sep, char *components,
+				   __be32 **pp, int *buflen,
+				   char esc_enter, char esc_exit)
 {
 	__be32 *p = *pp;
 	__be32 *countp = p;
@@ -1760,8 +1761,20 @@ static __be32 nfsd4_encode_components(char sep, char *components,
 	WRITE32(0); /* We will fill this in with @count later */
 	end = str = components;
 	while (*end) {
-		for (; *end && (*end != sep); end++)
-			; /* Point to end of component */
+		bool found_esc = false;
+
+		/* try to parse as esc_start, ..., esc_end, sep */
+		if (*str == esc_enter) {
+			for (; *end && (*end != esc_exit); end++);
+			if (*end && !*(end + 1) || (end + 1) == sep) {
+				str++;
+				found_esc = true;
+			}
+		}
+
+		if (!found_esc)
+			for (; *end && (*end != sep); end++);
+
 		strlen = end - str;
 		if (strlen) {
 			if ((*buflen -= ((XDR_QUADLEN(strlen) << 2) + 4)) < 0)
@@ -1780,6 +1793,15 @@ static __be32 nfsd4_encode_components(char sep, char *components,
 	return 0;
 }
 
+/* Encode as an array of strings the string given with components
+ * separated @sep.
+ */
+static __be32 nfsd4_encode_components(char sep, char *components,
+				   __be32 **pp, int *buflen)
+{
+	return nfsd4_encode_components_esc(sep, components, pp, buflen, 0, 0);
+}
+
 /*
  * encode a location element of a fs_locations structure
  */
@@ -1789,7 +1811,8 @@ static __be32 nfsd4_encode_fs_location4(struct nfsd4_fs_location *location,
 	__be32 status;
 	__be32 *p = *pp;
 
-	status = nfsd4_encode_components(':', location->hosts, &p, buflen);
+	status = nfsd4_encode_components_esc(':', location->hosts, &p, buflen,
+						'[', ']');
 	if (status)
 		return status;
 	status = nfsd4_encode_components('/', location->path, &p, buflen);
-- 
1.7.4.4

