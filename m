From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 9] knfsd: svcrpc: gss: factor out some common
	wrapping code
Date: Tue, 5 Sep 2006 09:15:27 +1000
Message-ID: <1060904231527.23059@suse.de>
References: <20060905090617.21303.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKNfG-0000KH-Or
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:15:38 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKNfK-00041O-H2
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:15:43 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: J.Bruce Fields <bfields@fieldses.org>

Factor out some common code from the integrity and privacy cases.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |   43 +++++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 20 deletions(-)

diff .prev/net/sunrpc/auth_gss/svcauth_gss.c ./net/sunrpc/auth_gss/svcauth_gss.c
--- .prev/net/sunrpc/auth_gss/svcauth_gss.c	2006-09-04 17:09:50.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-09-04 17:12:31.000000000 +1000
@@ -1147,6 +1147,25 @@ out:
 	return ret;
 }
 
+u32 *
+svcauth_gss_prepare_to_wrap(struct xdr_buf *resbuf, struct gss_svc_data *gsd)
+{
+	u32 *p;
+
+	p = gsd->body_start;
+	gsd->body_start = NULL;
+	/* move accept_stat to right place: */
+	memcpy(p, p + 2, 4);
+	/* Don't wrap in failure case: */
+	/* Counting on not getting here if call was not even accepted! */
+	if (*p != rpc_success) {
+		resbuf->head[0].iov_len -= 2 * 4;
+		return NULL;
+	}
+	p++;
+	return p;
+}
+
 static inline int
 svcauth_gss_wrap_resp_integ(struct svc_rqst *rqstp)
 {
@@ -1160,17 +1179,9 @@ svcauth_gss_wrap_resp_integ(struct svc_r
 	int integ_offset, integ_len;
 	int stat = -EINVAL;
 
-	p = gsd->body_start;
-	gsd->body_start = NULL;
-	/* move accept_stat to right place: */
-	memcpy(p, p + 2, 4);
-	/* Don't wrap in failure case: */
-	/* Counting on not getting here if call was not even accepted! */
-	if (*p != rpc_success) {
-		resbuf->head[0].iov_len -= 2 * 4;
+	p = svcauth_gss_prepare_to_wrap(resbuf, gsd);
+	if (p == NULL)
 		goto out;
-	}
-	p++;
 	integ_offset = (u8 *)(p + 1) - (u8 *)resbuf->head[0].iov_base;
 	integ_len = resbuf->len - integ_offset;
 	BUG_ON(integ_len % 4);
@@ -1222,17 +1233,9 @@ svcauth_gss_wrap_resp_priv(struct svc_rq
 	int offset, *len;
 	int pad;
 
-	p = gsd->body_start;
-	gsd->body_start = NULL;
-	/* move accept_stat to right place: */
-	memcpy(p, p + 2, 4);
-	/* Don't wrap in failure case: */
-	/* Counting on not getting here if call was not even accepted! */
-	if (*p != rpc_success) {
-		resbuf->head[0].iov_len -= 2 * 4;
+	p = svcauth_gss_prepare_to_wrap(resbuf, gsd);
+	if (p == NULL)
 		return 0;
-	}
-	p++;
 	len = p++;
 	offset = (u8 *)p - (u8 *)resbuf->head[0].iov_base;
 	*p++ = htonl(gc->gc_seq);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
