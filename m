From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 4 - Change names of some exported functions
Date: Sun, 13 Oct 2002 21:42:24 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E180h8a-0000jd-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 180h8n-0007Ds-00
	for <nfs@lists.sourceforge.net>; Sun, 13 Oct 2002 04:42:37 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Sun, 13 Oct 2002 21:42:29 +1000
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

... as generic names probably aren't such a good idea.
Also sort the related EXPORT_SYMBOLS.

A 'qword' is a 'quoted word' and can be added, added as hex,
or got (getted??).


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c             |   22 +++++++++++-----------
 ./include/linux/sunrpc/cache.h |    8 ++++----
 ./net/sunrpc/cache.c           |    6 +++---
 ./net/sunrpc/sunrpc_syms.c     |   24 ++++++++++++------------
 ./net/sunrpc/svcauth_unix.c    |   10 +++++-----
 5 files changed, 35 insertions(+), 35 deletions(-)

--- ./include/linux/sunrpc/cache.h	2002/10/13 05:17:20	1.1
+++ ./include/linux/sunrpc/cache.h	2002/10/13 09:12:14	1.2
@@ -271,16 +271,16 @@ extern int cache_unregister(struct cache
 extern struct cache_detail *cache_find(char *name);
 extern void cache_drop(struct cache_detail *detail);
 
-extern void add_word(char **bpp, int *lp, char *str);
-extern void add_hex(char **bpp, int *lp, char *buf, int blen);
-extern int get_word(char **bpp, char *dest, int bufsize);
+extern void qword_add(char **bpp, int *lp, char *str);
+extern void qword_addhex(char **bpp, int *lp, char *buf, int blen);
+extern int qword_get(char **bpp, char *dest, int bufsize);
 
 static inline int get_int(char **bpp, int *anint)
 {
 	char buf[50];
 	char *ep;
 	int rv;
-	int len = get_word(bpp, buf, 50);
+	int len = qword_get(bpp, buf, 50);
 	if (len < 0) return -EINVAL;
 	if (len ==0) return -ENOENT;
 	rv = simple_strtol(buf, &ep, 0);
--- ./fs/nfsd/export.c	2002/10/12 12:15:40	1.2
+++ ./fs/nfsd/export.c	2002/10/13 09:12:14	1.3
@@ -86,10 +86,10 @@ void expkey_request(struct cache_detail 
 	struct svc_expkey *ek = container_of(h, struct svc_expkey, h);
 	char type[5];
 
-	add_word(bpp, blen, ek->ek_client->name);
+	qword_add(bpp, blen, ek->ek_client->name);
 	snprintf(type, 5, "%d", ek->ek_fsidtype);
-	add_word(bpp, blen, type);
-	add_hex(bpp, blen, (char*)ek->ek_fsid, ek->ek_fsidtype==0?8:4);
+	qword_add(bpp, blen, type);
+	qword_addhex(bpp, blen, (char*)ek->ek_fsid, ek->ek_fsidtype==0?8:4);
 	(*bpp)[-1] = '\n';
 }
 
@@ -114,7 +114,7 @@ int expkey_parse(struct cache_detail *cd
 	if (!buf) goto out;
 
 	err = -EINVAL;
-	if ((len=get_word(&mesg, buf, PAGE_SIZE)) <= 0)
+	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
 		goto out;
 
 	err = -ENOENT;
@@ -124,7 +124,7 @@ int expkey_parse(struct cache_detail *cd
 	dprintk("found domain %s\n", buf);
 
 	err = -EINVAL;
-	if ((len=get_word(&mesg, buf, PAGE_SIZE)) <= 0)
+	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
 		goto out;
 	fsidtype = simple_strtoul(buf, &ep, 10);
 	if (*ep)
@@ -132,7 +132,7 @@ int expkey_parse(struct cache_detail *cd
 	dprintk("found fsidtype %d\n", fsidtype);
 	if (fsidtype > 1)
 		goto out;
-	if ((len=get_word(&mesg, buf, PAGE_SIZE)) <= 0)
+	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
 		goto out;
 	dprintk("found fsid length %d\n", len);
 	if (len != ((fsidtype==0)?8:4))
@@ -149,7 +149,7 @@ int expkey_parse(struct cache_detail *cd
 	memcpy(key.ek_fsid, buf, len);
 
 	/* now we want a pathname, or empty meaning NEGATIVE  */
-	if ((len=get_word(&mesg, buf, PAGE_SIZE)) < 0)
+	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) < 0)
 		goto out;
 	dprintk("Path seems to be <%s>\n", buf);
 	err = 0;
@@ -269,9 +269,9 @@ void svc_export_request(struct cache_det
 	struct svc_export *exp = container_of(h, struct svc_export, h);
 	char *pth;
 
-	add_word(bpp, blen, exp->ex_client->name);
+	qword_add(bpp, blen, exp->ex_client->name);
 	pth = d_path(exp->ex_dentry, exp->ex_mnt, *bpp, *blen);
-	add_word(bpp, blen, pth);
+	qword_add(bpp, blen, pth);
 	(*bpp)[-1] = '\n';
 }
 
@@ -298,7 +298,7 @@ int svc_export_parse(struct cache_detail
 	if (!buf) goto out;
 
 	/* client */
-	len = get_word(&mesg, buf, PAGE_SIZE);
+	len = qword_get(&mesg, buf, PAGE_SIZE);
 	if (len <= 0) return -EINVAL;
 	err = -ENOENT;
 	dom = auth_domain_find(buf);
@@ -307,7 +307,7 @@ int svc_export_parse(struct cache_detail
 
 	/* path */
 	err = -EINVAL;
-	if ((len=get_word(&mesg, buf, PAGE_SIZE)) <= 0)
+	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
 		goto out;
 	err = path_lookup(buf, 0, &nd);
 	if (err) goto out;
--- ./net/sunrpc/sunrpc_syms.c	2002/10/12 11:42:07	1.2
+++ ./net/sunrpc/sunrpc_syms.c	2002/10/13 09:12:14	1.3
@@ -94,22 +94,22 @@ EXPORT_SYMBOL(svc_proc_read);
 
 /* caching... */
 EXPORT_SYMBOL(auth_domain_find);
-EXPORT_SYMBOL(cache_fresh);
-EXPORT_SYMBOL(unix_domain_find);
 EXPORT_SYMBOL(auth_domain_put);
-EXPORT_SYMBOL(cache_flush);
-EXPORT_SYMBOL(cache_unregister);
-EXPORT_SYMBOL(add_hex);
+EXPORT_SYMBOL(auth_unix_add_addr);
+EXPORT_SYMBOL(auth_unix_forget_old);
+EXPORT_SYMBOL(auth_unix_lookup);
 EXPORT_SYMBOL(cache_check);
-EXPORT_SYMBOL(svcauth_unix_purge);
-EXPORT_SYMBOL(get_word);
 EXPORT_SYMBOL(cache_clean);
-EXPORT_SYMBOL(cache_register);
-EXPORT_SYMBOL(auth_unix_lookup);
-EXPORT_SYMBOL(auth_unix_add_addr);
+EXPORT_SYMBOL(cache_flush);
+EXPORT_SYMBOL(cache_fresh);
 EXPORT_SYMBOL(cache_init);
-EXPORT_SYMBOL(auth_unix_forget_old);
-EXPORT_SYMBOL(add_word);
+EXPORT_SYMBOL(cache_register);
+EXPORT_SYMBOL(cache_unregister);
+EXPORT_SYMBOL(qword_add);
+EXPORT_SYMBOL(qword_addhex);
+EXPORT_SYMBOL(qword_get);
+EXPORT_SYMBOL(svcauth_unix_purge);
+EXPORT_SYMBOL(unix_domain_find);
 
 /* Generic XDR */
 EXPORT_SYMBOL(xdr_encode_array);
--- ./net/sunrpc/svcauth_unix.c	2002/10/12 12:15:40	1.2
+++ ./net/sunrpc/svcauth_unix.c	2002/10/13 09:12:14	1.3
@@ -132,8 +132,8 @@ static void ip_map_request(struct cache_
 		 ntohl(addr) >>  8 & 0xff,
 		 ntohl(addr) >>  0 & 0xff);
 
-	add_word(bpp, blen, im->m_class);
-	add_word(bpp, blen, text_addr);
+	qword_add(bpp, blen, im->m_class);
+	qword_add(bpp, blen, text_addr);
 	(*bpp)[-1] = '\n';
 }
 
@@ -155,11 +155,11 @@ static int ip_map_parse(struct cache_det
 	mesg[mlen-1] = 0;
 
 	/* class */
-	len = get_word(&mesg, class, 50);
+	len = qword_get(&mesg, class, 50);
 	if (len <= 0) return -EINVAL;
 
 	/* ip address */
-	len = get_word(&mesg, buf, 50);
+	len = qword_get(&mesg, buf, 50);
 	if (len <= 0) return -EINVAL;
 
 	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
@@ -170,7 +170,7 @@ static int ip_map_parse(struct cache_det
 		return -EINVAL;
 
 	/* domainname, or empty for NEGATIVE */
-	len = get_word(&mesg, buf, 50);
+	len = qword_get(&mesg, buf, 50);
 	if (len < 0) return -EINVAL;
 
 	if (len) {
--- ./net/sunrpc/cache.c	2002/10/13 05:17:31	1.1
+++ ./net/sunrpc/cache.c	2002/10/13 09:12:14	1.2
@@ -750,7 +750,7 @@ static void queue_loose(struct cache_det
  *
  */
 
-void add_word(char **bpp, int *lp, char *str)
+void qword_add(char **bpp, int *lp, char *str)
 {
 	char *bp = *bpp;
 	int len = *lp;
@@ -785,7 +785,7 @@ void add_word(char **bpp, int *lp, char 
 	*lp = len;
 }
 
-void add_hex(char **bpp, int *lp, char *buf, int blen)
+void qword_addhex(char **bpp, int *lp, char *buf, int blen)
 {
 	char *bp = *bpp;
 	int len = *lp;
@@ -879,7 +879,7 @@ static int cache_make_upcall(struct cach
  */
 
 #define isodigit(c) (isdigit(c) && c <= '7')
-int get_word(char **bpp, char *dest, int bufsize)
+int qword_get(char **bpp, char *dest, int bufsize)
 {
 	/* return bytes copied, or -1 on error */
 	char *bp = *bpp;


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
