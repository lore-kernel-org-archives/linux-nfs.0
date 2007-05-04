From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [PATCH] Fix resource leak resulting in module refcount leak
	for	rpcsec_gss_krb5.ko
Date: Fri, 04 May 2007 08:59:32 -0700
Message-ID: <1178294372.3621.13.camel@dyn9047022153>
References: <1178230502.2977.7.camel@dyn9047022153>
	<20070503224012.GK22069@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, NFS List <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hk0Bw-00068G-Ky
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 08:59:32 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.141])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hk0Bz-0007aW-1G
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 08:59:35 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l44FxRfE007858
	for <nfs@lists.sourceforge.net>; Fri, 4 May 2007 11:59:27 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l44FxRXc529168
	for <nfs@lists.sourceforge.net>; Fri, 4 May 2007 11:59:27 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l44FxRko001580
	for <nfs@lists.sourceforge.net>; Fri, 4 May 2007 11:59:27 -0400
In-Reply-To: <20070503224012.GK22069@fieldses.org>
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

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c
b/net/sunrpc/auth_gss/svcauth_gss.c
index db298b5..eb16e30 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -924,6 +924,7 @@ static inline int
 gss_write_init_verf(struct svc_rqst *rqstp, struct rsi *rsip)
 {
 	struct rsc *rsci;
+	int        rc;
 
 	if (rsip->major_status != GSS_S_COMPLETE)
 		return gss_write_null_verf(rqstp);
@@ -932,7 +933,9 @@ gss_write_init_verf(struct svc_rqst *rqstp, struct
rsi *rsip)
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
