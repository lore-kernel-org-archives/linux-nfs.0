From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: Fix xdr_decode_string_inplace() mixed sign
	comparison
Date: Wed, 31 Oct 2007 12:50:45 -0400
Message-ID: <20071031165045.5861.52308.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InGnF-0005WN-LH
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 09:51:49 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1InGnJ-0003an-TW
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 09:51:55 -0700
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

xdr_decode_string_inplace() compares an incoming length to a maximum length
allowed by the protocol.  Make sure both sides of the comparison have the
same sign.

A better fix for this would be always to use unsigned 32-bit integers for
string lengths.  To wit, RFC 4506 says:

4.2.  Unsigned Integer

   An XDR unsigned integer is a 32-bit datum that encodes a non-negative
   integer in the range [0,4294967295].

 ...

4.11.  String

   The standard defines a string of n (numbered 0 through n-1) ASCII
   bytes to be the number n encoded as an unsigned integer (as described
   above), and followed by the n bytes of the string.

This would mean fixing up the callers of xdr_decode_string_inplace, which
include the NFS server's filename handling functions (including
decode_filename, decode_pathname, and nfsd_lookup), and lockd's nlm_lock
structure.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 3d1f7cd..db80a77 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -95,7 +95,7 @@ xdr_encode_string(__be32 *p, const char *string)
 __be32 *
 xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
 {
-	unsigned int	len;
+	int len;
 
 	if ((len = ntohl(*p++)) > maxlen)
 		return NULL;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
