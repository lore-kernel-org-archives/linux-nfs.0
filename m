From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH]: nfsd: Added dprintks to kernel export code
Date: Fri, 24 Oct 2008 13:34:38 -0400
Message-ID: <4902072E.6070106@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59693 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754848AbYJXRgT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Oct 2008 13:36:19 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[As requested, here is the debugging portion broken out of
the 6th patch in the "Dynamic Pseudo Root" patch series.]

Added dprintk to the top and bottom of both expkey_parse() and
svc_export_parse(). The top dprintks shows what rpc.mountd gave
to the routines to parse. These match up well with the current
debugging statements in the rpc.mount routines nfsd_export()
and nfsd_fh(). 

The bottom two dprintks show when either routine error out. This
was very useful in debugging why exports failed or hang.

I also added a number dprintks to the sunrpc caching code. Being
there was exactly one debugging statement through out the entire
chuck of code, it was literally impossible to tell whats going
on. This dprintks will show if and when upcalls are made and
(more importantly) when they are not.

All of these dprintks are not very busy code paths. They only 
pop when an exported is created or modified.

Signed-off-by: Steve Dickson <steved@redhat.com>

diff -up linux/fs/nfsd/export.c.org linux/fs/nfsd/export.c
--- linux/fs/nfsd/export.c.org	2008-10-24 13:00:36.000000000 -0400
+++ linux/fs/nfsd/export.c	2008-10-24 12:59:46.000000000 -0400
@@ -104,6 +104,7 @@ static int expkey_parse(struct cache_det
 	if (mesg[mlen-1] != '\n')
 		return -EINVAL;
 	mesg[mlen-1] = 0;
+	dprintk("expkey_parse: '%s'\n", mesg);
 
 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	err = -ENOMEM;
@@ -182,6 +183,8 @@ static int expkey_parse(struct cache_det
 	if (dom)
 		auth_domain_put(dom);
 	kfree(buf);
+	if (err)
+		dprintk("expkey_parse: err %d\n", err);
 	return err;
 }
 
@@ -353,6 +356,8 @@ static void svc_export_request(struct ca
 		return;
 	}
 	qword_add(bpp, blen, pth);
+	dprintk("svc_export_request: pth %s\n", pth);
+
 	(*bpp)[-1] = '\n';
 }
 
@@ -520,6 +525,7 @@ static int svc_export_parse(struct cache
 	if (mesg[mlen-1] != '\n')
 		return -EINVAL;
 	mesg[mlen-1] = 0;
+	dprintk("svc_export_parse: '%s'\n", mesg);
 
 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	err = -ENOMEM;
@@ -632,6 +638,8 @@ static int svc_export_parse(struct cache
 	if (dom)
 		auth_domain_put(dom);
 	kfree(buf);
+	if (err)
+		dprintk("svc_export_parse: err %d\n", err);
 	return err;
 }
 
diff -up linux/net/sunrpc/cache.c.org linux/net/sunrpc/cache.c
--- linux/net/sunrpc/cache.c.org	2008-10-24 13:00:46.000000000 -0400
+++ linux/net/sunrpc/cache.c	2008-10-14 07:54:01.000000000 -0400
@@ -215,11 +215,13 @@ int cache_check(struct cache_detail *det
 		if (rv == -EAGAIN)
 			rv = -ENOENT;
 	} else if (rv == -EAGAIN || age > refresh_age/2) {
-		dprintk("RPC:       Want update, refage=%ld, age=%ld\n",
-				refresh_age, age);
+		dprintk("check_check: upcall: h 0x%p pending %d rv %d\n", 
+			h, test_bit(CACHE_PENDING, &h->flags), rv);
 		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
 			switch (cache_make_upcall(detail, h)) {
 			case -EINVAL:
+				dprintk("check_check: upcall(-EINVAL): h 0x%p rv %d\n",
+					h, rv);
 				clear_bit(CACHE_PENDING, &h->flags);
 				if (rv == -EAGAIN) {
 					set_bit(CACHE_NEGATIVE, &h->flags);
@@ -231,6 +233,8 @@ int cache_check(struct cache_detail *det
 
 			case -EAGAIN:
 				clear_bit(CACHE_PENDING, &h->flags);
+				dprintk("check_check: upcall(-EAGAIN): h 0x%p flags 0x%lx\n",
+					h, h->flags);
 				cache_revisit_request(h);
 				break;
 			}
@@ -560,13 +564,16 @@ static int cache_defer_req(struct cache_
 		/* too much in the cache, randomly drop this one,
 		 * or continue and drop the oldest below
 		 */
-		if (net_random()&1)
+		if (net_random()&1) {
+			dprintk("cache_defer_req:  0x%p: dropping request\n", item);
 			return -ETIMEDOUT;
+		}
 	}
 	dreq = req->defer(req);
-	if (dreq == NULL)
+	if (dreq == NULL) {
+		dprintk("cache_defer_req: 0x%p: request timedout\n", item);
 		return -ETIMEDOUT;
-
+	}
 	dreq->item = item;
 
 	spin_lock(&cache_defer_lock);
@@ -596,6 +603,7 @@ static int cache_defer_req(struct cache_
 		/* must have just been validated... */
 		cache_revisit_request(item);
 	}
+	dprintk("cache_defer_req:  0x%p: request deferred\n", item);
 	return 0;
 }
 

