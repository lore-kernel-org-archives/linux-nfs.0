From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] SUNRPC: Use unsigned string lengths
	in	xdr_decode_string_inplace
Date: Thu, 01 Nov 2007 16:56:47 -0400
Message-ID: <20071101205647.5503.42569.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no, neilb@suse.de, bfields@fieldses.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Inh7Q-0007od-RQ
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:58:24 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Inh7W-0005bs-En
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:58:30 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

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


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
