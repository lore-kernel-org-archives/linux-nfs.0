From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/27] SUNRPC: Fix xdr_decode_string_inplace()
	argument signage
Date: Fri, 26 Oct 2007 13:31:10 -0400
Message-ID: <20071026173110.31475.94749.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT2G-0007EB-RC
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:53 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2M-0005ru-7P
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:58 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xdr.h |    3 ++-
 net/sunrpc/xdr.c           |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 0751c94..9ddae63 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -112,7 +112,8 @@ struct xdr_buf {
 __be32 *xdr_encode_opaque_fixed(__be32 *p, const void *ptr, unsigned int len);
 __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int len);
 __be32 *xdr_encode_string(__be32 *p, const char *s);
-__be32 *xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen);
+__be32 *xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp,
+				  unsigned int maxlen);
 __be32 *xdr_encode_netobj(__be32 *p, const struct xdr_netobj *);
 __be32 *xdr_decode_netobj(__be32 *p, struct xdr_netobj *);
 
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 3d1f7cd..ff16bab 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -93,7 +93,7 @@ xdr_encode_string(__be32 *p, const char *string)
 }
 
 __be32 *
-xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
+xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, unsigned int maxlen)
 {
 	unsigned int	len;
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
