From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 8 of 9] Improve cleaning up of nfsd4 requests
Date: Thu, 24 Jun 2004 14:46:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BdM8R-0001Lw-Vv@notabene.cse.unsw.edu.au>
References: <20040624143710.5086.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8v-000261-3j
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:21 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8u-0007FF-DL
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:20 -0700
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



Currently nfs4_arg->to_free keeps a list of void ptrs on which kfree is called
when freeing the nfs4_arg.  This allows us to do cleanup on e.g. xdr decode
failures.  To allow more complicated objects to be freed (in particular, acls),
we add a "void (*release)(void *)" to allow us to request something other than
kfree be called when freeing.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c        |   15 ---------
 ./fs/nfsd/nfs4xdr.c         |   68 +++++++++++++++++++++++++++-----------------
 ./include/linux/nfsd/xdr4.h |    2 +
 3 files changed, 46 insertions(+), 39 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-06-23 14:37:39.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-06-23 14:40:28.000000000 +1000
@@ -983,20 +983,7 @@ encode_op:
 	}
 
 out:
-	if (args->ops != args->iops) {
-		kfree(args->ops);
-		args->ops = args->iops;
-	}
-	if (args->tmpp) {
-		kfree(args->tmpp);
-		args->tmpp = NULL;
-	}
-	while (args->to_free) {
-		struct tmpbuf *tb = args->to_free;
-		args->to_free = tb->next;
-		kfree(tb->buf);
-		kfree(tb);
-	}
+	nfsd4_release_compoundargs(args);
 	if (current_fh)
 		fh_put(current_fh);
 	kfree(current_fh);

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-06-23 14:37:26.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-06-23 14:40:28.000000000 +1000
@@ -287,27 +287,40 @@ u32 *read_buf(struct nfsd4_compoundargs 
 	return p;
 }
 
-char *savemem(struct nfsd4_compoundargs *argp, u32 *p, int nbytes)
+static int
+defer_free(struct nfsd4_compoundargs *argp,
+		void (*release)(const void *), void *p)
 {
 	struct tmpbuf *tb;
+
+	tb = kmalloc(sizeof(*tb), GFP_KERNEL);
+	if (!tb)
+		return -ENOMEM;
+	tb->buf = p;
+	tb->release = release;
+	tb->next = argp->to_free;
+	argp->to_free = tb;
+	return 0;
+}
+
+char *savemem(struct nfsd4_compoundargs *argp, u32 *p, int nbytes)
+{
+	void *new = NULL;
 	if (p == argp->tmp) {
-		p = kmalloc(nbytes, GFP_KERNEL);
-		if (!p) return NULL;
+		new = kmalloc(nbytes, GFP_KERNEL);
+		if (!new) return NULL;
+		p = new;
 		memcpy(p, argp->tmp, nbytes);
 	} else {
 		if (p != argp->tmpp)
 			BUG();
 		argp->tmpp = NULL;
 	}
-	tb = kmalloc(sizeof(*tb), GFP_KERNEL);
-	if (!tb) {
-		kfree(p);
+	if (defer_free(argp, kfree, p)) {
+		kfree(new);
 		return NULL;
-	}
-	tb->buf = p;
-	tb->next = argp->to_free;
-	argp->to_free = tb;
-	return (char*)p;
+	} else
+		return (char *)p;
 }
 
 
@@ -2461,6 +2474,24 @@ nfs4svc_encode_voidres(struct svc_rqst *
         return xdr_ressize_check(rqstp, p);
 }
 
+void nfsd4_release_compoundargs(struct nfsd4_compoundargs *args)
+{
+	if (args->ops != args->iops) {
+		kfree(args->ops);
+		args->ops = args->iops;
+	}
+	if (args->tmpp) {
+		kfree(args->tmpp);
+		args->tmpp = NULL;
+	}
+	while (args->to_free) {
+		struct tmpbuf *tb = args->to_free;
+		args->to_free = tb->next;
+		tb->release(tb->buf);
+		kfree(tb);
+	}
+}
+
 int
 nfs4svc_decode_compoundargs(struct svc_rqst *rqstp, u32 *p, struct nfsd4_compoundargs *args)
 {
@@ -2477,20 +2508,7 @@ nfs4svc_decode_compoundargs(struct svc_r
 
 	status = nfsd4_decode_compound(args);
 	if (status) {
-		if (args->ops != args->iops) {
-			kfree(args->ops);
-			args->ops = args->iops;
-		}
-		if (args->tmpp) {
-			kfree(args->tmpp);
-			args->tmpp = NULL;
-		}
-		while (args->to_free) {
-			struct tmpbuf *tb = args->to_free;
-			args->to_free = tb->next;
-			kfree(tb->buf);
-			kfree(tb);
-		}
+		nfsd4_release_compoundargs(args);
 	}
 	return !status;
 }

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./include/linux/nfsd/xdr4.h	2004-06-23 14:40:28.000000000 +1000
@@ -378,6 +378,7 @@ struct nfsd4_compoundargs {
 	u32 *				tmpp;
 	struct tmpbuf {
 		struct tmpbuf *next;
+		void (*release)(const void *);
 		void *buf;
 	}				*to_free;
 
@@ -449,6 +450,7 @@ extern int nfsd4_locku(struct svc_rqst *
 extern int
 nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		struct nfsd4_release_lockowner *rlockowner);
+extern void nfsd4_release_compoundargs(struct nfsd4_compoundargs *);
 #endif
 
 /*


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
