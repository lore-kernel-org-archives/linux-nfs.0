From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 8 - Assorted fixed for NFS export cache
Date: Wed, 18 Jun 2003 09:51:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQEj-00083L-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQBS-0002WF-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 16:48:14 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 09:47:01 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

Most significant fix is cleaning up properly when
nfs service is stopped.
Also fix some refcounting problems and other little bits.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c             |    8 ++++++--
 ./fs/nfsd/nfsproc.c            |    1 +
 ./fs/nfsd/vfs.c                |    2 +-
 ./include/linux/sunrpc/cache.h |    9 +++++++--
 ./include/linux/sunrpc/svc.h   |    1 -
 ./net/sunrpc/cache.c           |   40 ++++++++++++++++++++++++++++++++++------
 ./net/sunrpc/svc.c             |    2 ++
 ./net/sunrpc/svcauth_unix.c    |    6 +++---
 ./net/sunrpc/svcsock.c         |    4 ++--
 9 files changed, 56 insertions(+), 17 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-06-18 09:18:16.000000000 +1000
+++ ./fs/nfsd/export.c	2003-06-18 09:18:16.000000000 +1000
@@ -153,9 +153,13 @@ int expkey_parse(struct cache_detail *cd
 		goto out;
 	dprintk("Path seems to be <%s>\n", buf);
 	err = 0;
-	if (len == 0)
+	if (len == 0) {
+		struct svc_expkey *ek;
 		set_bit(CACHE_NEGATIVE, &key.h.flags);
-	else {
+		ek = svc_expkey_lookup(&key, 2);
+		if (ek)
+			expkey_put(&ek->h, &svc_expkey_cache);
+	} else {
 		struct nameidata nd;
 		struct svc_expkey *ek;
 		struct svc_export *exp;

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2003-06-18 09:18:16.000000000 +1000
+++ ./fs/nfsd/nfsproc.c	2003-06-18 09:18:16.000000000 +1000
@@ -591,6 +591,7 @@ nfserrno (int errno)
 		{ nfserr_dquot, -EDQUOT },
 #endif
 		{ nfserr_stale, -ESTALE },
+		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },
 		{ -1, -EIO }
 	};

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-06-18 09:18:16.000000000 +1000
+++ ./fs/nfsd/vfs.c	2003-06-18 09:18:16.000000000 +1000
@@ -167,7 +167,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 				dput(mounts);
 				dput(dentry);
 				mntput(mnt);
-				goto out;
+				goto out_nfserr;
 			}
 			if (exp2 &&
 			    ((exp->ex_flags & NFSEXP_CROSSMNT)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2003-06-18 09:18:16.000000000 +1000
+++ ./include/linux/sunrpc/cache.h	2003-06-18 09:18:16.000000000 +1000
@@ -115,6 +115,8 @@ struct cache_deferred_req {
 	struct list_head	recent; /* on fifo */
 	struct cache_head	*item;  /* cache item we wait on */
 	time_t			recv_time;
+	void			*owner; /* we might need to discard all defered requests
+					 * owned by someone */
 	void			(*revisit)(struct cache_deferred_req *req,
 					   int too_many);
 };
@@ -168,12 +170,14 @@ RTN *FNAME ARGS										\
 		tmp = container_of(*hp, RTN, MEMBER);					\
 		if (TEST) { /* found a match */						\
 											\
+			if (set == 1 && test_bit(CACHE_VALID, &tmp->MEMBER.flags) && !new) \
+				break;							\
+											\
 			atomic_inc(&tmp->MEMBER.refcnt);				\
 			if (set) {							\
-				if (set!= 2 && test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
+				if (set == 1 && test_bit(CACHE_VALID, &tmp->MEMBER.flags))\
 				{ /* need to swap in new */				\
 					RTN *t2;					\
-					if (!new) break;				\
 											\
 					new->MEMBER.next = tmp->MEMBER.next;		\
 					*hp = &new->MEMBER;				\
@@ -242,6 +246,7 @@ RTN *FNAME ARGS										\
 
 extern void cache_defer_req(struct cache_req *req, struct cache_head *item);
 extern void cache_revisit_request(struct cache_head *item);
+extern void cache_clean_deferred(void *owner);
 
 static inline struct cache_head  *cache_get(struct cache_head *h)
 {

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2003-06-18 09:17:34.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2003-06-18 09:18:16.000000000 +1000
@@ -218,7 +218,6 @@ static inline void svc_free_allpages(str
 }
 
 struct svc_deferred_req {
-	struct svc_serv		*serv;
 	u32			prot;	/* protocol (UDP or TCP) */
 	struct sockaddr_in	addr;
 	struct svc_sock		*svsk;	/* where reply must go */

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2003-06-18 09:18:16.000000000 +1000
+++ ./net/sunrpc/cache.c	2003-06-18 09:18:16.000000000 +1000
@@ -310,14 +310,17 @@ int cache_clean(void)
 		cp = & current_detail->hash_table[current_index];
 		ch = *cp;
 		for (; ch; cp= & ch->next, ch= *cp) {
-			if (atomic_read(&ch->refcnt))
-				continue;
-			if (ch->expiry_time < get_seconds()
-			    || ch->last_refresh < current_detail->flush_time
-				)
-				break;
 			if (current_detail->nextcheck > ch->expiry_time)
 				current_detail->nextcheck = ch->expiry_time+1;
+			if (ch->expiry_time >= get_seconds()
+			    && ch->last_refresh >= current_detail->flush_time
+				)
+				continue;
+			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
+				queue_loose(current_detail, ch);
+
+			if (atomic_read(&ch->refcnt))
+				continue;
 		}
 		if (ch) {
 			cache_get(ch);
@@ -467,6 +470,31 @@ void cache_revisit_request(struct cache_
 	}
 }
 
+void cache_clean_deferred(void *owner)
+{
+	struct cache_deferred_req *dreq, *tmp;
+	struct list_head pending;
+
+
+	INIT_LIST_HEAD(&pending);
+	spin_lock(&cache_defer_lock);
+	
+	list_for_each_entry_safe(dreq, tmp, &cache_defer_list, recent) {
+		if (dreq->owner == owner) {
+			list_del(&dreq->hash);
+			list_move(&dreq->recent, &pending);
+			cache_defer_cnt--;
+		}
+	}
+	spin_unlock(&cache_defer_lock);
+
+	while (!list_empty(&pending)) {
+		dreq = list_entry(pending.next, struct cache_deferred_req, recent);
+		list_del_init(&dreq->recent);
+		dreq->revisit(dreq, 1);
+	}
+}
+
 /*
  * communicate with user-space
  *

diff ./net/sunrpc/svc.c~current~ ./net/sunrpc/svc.c
--- ./net/sunrpc/svc.c~current~	2003-06-18 09:18:16.000000000 +1000
+++ ./net/sunrpc/svc.c	2003-06-18 09:18:16.000000000 +1000
@@ -98,6 +98,8 @@ svc_destroy(struct svc_serv *serv)
 				  sk_list);
 		svc_delete_socket(svsk);
 	}
+	
+	cache_clean_deferred(serv);
 
 	/* Unregister service with the portmapper */
 	svc_register(serv, 0, 0);

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2003-06-18 09:18:16.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2003-06-18 09:18:16.000000000 +1000
@@ -195,12 +195,12 @@ static int ip_map_parse(struct cache_det
 	ipm.m_addr.s_addr =
 		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
 	ipm.h.flags = 0;
-	if (dom)
+	if (dom) {
 		ipm.m_client = container_of(dom, struct unix_domain, h);
-	else
+		ipm.m_add_change = ipm.m_client->addr_changes;
+	} else
 		set_bit(CACHE_NEGATIVE, &ipm.h.flags);
 	ipm.h.expiry_time = expiry;
-	ipm.m_add_change = ipm.m_client->addr_changes;
 
 	ipmp = ip_map_lookup(&ipm, 1);
 	if (ipmp)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-06-18 09:18:16.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-06-18 09:18:16.000000000 +1000
@@ -1443,7 +1443,7 @@ svc_makesock(struct svc_serv *serv, int 
 static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 {
 	struct svc_deferred_req *dr = container_of(dreq, struct svc_deferred_req, handle);
-	struct svc_serv *serv = dr->serv;
+	struct svc_serv *serv = dreq->owner;
 	struct svc_sock *svsk;
 
 	if (too_many) {
@@ -1481,7 +1481,7 @@ svc_defer(struct cache_req *req)
 		if (dr == NULL)
 			return NULL;
 
-		dr->serv = rqstp->rq_server;
+		dr->handle.owner = rqstp->rq_server;
 		dr->prot = rqstp->rq_prot;
 		dr->addr = rqstp->rq_addr;
 		dr->argslen = rqstp->rq_arg.len >> 2;


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
