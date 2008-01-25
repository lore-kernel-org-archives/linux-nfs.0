From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 006/100] SUNRPC: Use unsigned string lengths in xdr_decode_string_inplace
Date: Fri, 25 Jan 2008 18:15:46 -0500
Message-ID: <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47312 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759612AbYAYXRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:23 -0500
In-Reply-To: <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

XDR strings, opaques, and net objects should all use unsigned lengths.
To wit, RFC 4506 says:

4.2.  Unsigned Integer

   An XDR unsigned integer is a 32-bit datum that encodes a non-negative
   integer in the range [0,4294967295].

 ...

4.11.  String

   The standard defines a string of n (numbered 0 through n-1) ASCII
   bytes to be the number n encoded as an unsigned integer (as described
   above), and followed by the n bytes of the string.

After this patch, xdr_decode_string_inplace now matches the other XDR
string and array helpers that take a string length argument.  See:

xdr_encode_opaque_fixed, xdr_encode_opaque, xdr_encode_array

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-By: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/xdr.h |    3 ++-
 net/sunrpc/xdr.c           |    8 +++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 0751c94..e4057d7 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -112,7 +112,8 @@ struct xdr_buf {
 __be32 *xdr_encode_opaque_fixed(__be32 *p, const void *ptr, unsigned int len);
 __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int len);
 __be32 *xdr_encode_string(__be32 *p, const char *s);
-__be32 *xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen);
+__be32 *xdr_decode_string_inplace(__be32 *p, char **sp, unsigned int *lenp,
+			unsigned int maxlen);
 __be32 *xdr_encode_netobj(__be32 *p, const struct xdr_netobj *);
 __be32 *xdr_decode_netobj(__be32 *p, struct xdr_netobj *);
 
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index fdc5e6d..31bd346 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -93,11 +93,13 @@ xdr_encode_string(__be32 *p, const char *string)
 }
 
 __be32 *
-xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
+xdr_decode_string_inplace(__be32 *p, char **sp,
+			  unsigned int *lenp, unsigned int maxlen)
 {
-	unsigned int	len;
+	u32 len;
 
-	if ((len = ntohl(*p++)) > maxlen)
+	len = ntohl(*p++);
+	if (len > maxlen)
 		return NULL;
 	*lenp = len;
 	*sp = (char *) p;
-- 
1.5.4.rc2.60.gb2e62

