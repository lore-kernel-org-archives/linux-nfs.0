From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 8] knfsd: Fix resource leak resulting in module
	refcount leak for	rpcsec_gss_krb5.ko
Date: Mon, 7 May 2007 10:35:27 +1000
Message-ID: <1070507003527.24108@suse.de>
References: <20070507103211.23855.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Frank Filz <ffilzlnx@us.ibm.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HkrCq-00051U-37
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:00 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HkrCs-0002oW-AH
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:02 -0700
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


From: Frank Filz <ffilzlnx@us.ibm.com>

I have been investigating a module reference count leak on the server
for rpcsec_gss_krb5.ko. It turns out the problem is a reference count
leak for the security context in net/sunrpc/auth_gss/svcauth_gss.c.

The problem is that gss_write_init_verf() calls gss_svc_searchbyctx()
which does a rsc_lookup() but never releases the reference to the
context. There is another issue that rpc.svcgssd sets an "end of time"
expiration for the context

By adding a cache_put() call in gss_svc_searchbyctx(), and setting an
expiration timeout in the downcall, cache_clean() does clean up the
context and the module reference count now goes to zero after unmount.

I also verified that if the context expires and then the client makes a
new request, a new context is established.

Here is the patch to fix the kernel, I will start a separate thread to
discuss what expiration time should be set by rpc.svcgssd.

Acked-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c
b/net/sunrpc/auth_gss/svcauth_gss.c
index db298b5..eb16e30 100644
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff .prev/net/sunrpc/auth_gss/svcauth_gss.c ./net/sunrpc/auth_gss/svcauth_gss.c
--- .prev/net/sunrpc/auth_gss/svcauth_gss.c	2007-05-07 10:30:38.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2007-05-07 10:31:03.000000000 +1000
@@ -938,6 +938,7 @@ static inline int
 gss_write_init_verf(struct svc_rqst *rqstp, struct rsi *rsip)
 {
 	struct rsc *rsci;
+	int        rc;
 
 	if (rsip->major_status != GSS_S_COMPLETE)
 		return gss_write_null_verf(rqstp);
@@ -946,7 +947,9 @@ gss_write_init_verf(struct svc_rqst *rqs
 		rsip->major_status = GSS_S_NO_CONTEXT;
 		return gss_write_null_verf(rqstp);
 	}
-	return gss_write_verf(rqstp, rsci->mechctx, GSS_SEQ_WIN);
+	rc = gss_write_verf(rqstp, rsci->mechctx, GSS_SEQ_WIN);
+	cache_put(&rsci->h, &rsc_cache);
+	return rc;
 }
 
 /*

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
