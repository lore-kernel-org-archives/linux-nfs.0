From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 14 of 15 - Use hash_long from hash.h for hashing in rpc/svc caches.
Date: Mon, 06 Jan 2003 11:05:05 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlN-0002YA-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKli-0002Xf-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:26 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:14 +1100
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

It works much better than my little toy hash functions.


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c               |   27 ++++++++++-----------------
 ./include/linux/sunrpc/svcauth.h |    6 +++++-
 ./net/sunrpc/svcauth.c           |   21 +++++++++++++++------
 ./net/sunrpc/svcauth_unix.c      |    4 +++-
 4 files changed, 33 insertions(+), 25 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-01-06 10:56:30.000000000 +1100
+++ ./fs/nfsd/export.c	2003-01-06 10:36:22.000000000 +1100
@@ -24,6 +24,7 @@
 #include <linux/dcache.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
+#include <linux/hash.h>
 
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
@@ -59,12 +60,9 @@ static inline int svc_expkey_hash(struct
 	int hash = item->ek_fsidtype;
 	char * cp = (char*)item->ek_fsid;
 	int len = (item->ek_fsidtype==0)?8:4;
-	while (len--)
-		hash += *cp++;
-	cp = (char*)&item->ek_client;
-	len = sizeof(item->ek_client);
-	while (len--)
-		hash += *cp++;
+
+	hash ^= hash_mem(cp, len, EXPKEY_HASHBITS);
+	hash ^= hash_ptr(item->ek_client, EXPKEY_HASHBITS);
 	return hash & EXPKEY_HASHMASK;
 }
 
@@ -239,17 +237,12 @@ static struct cache_head *export_table[E
 
 static inline int svc_export_hash(struct svc_export *item)
 {
-	void *k[2];
-	unsigned char *cp;
-	int rv, i;
-	k[0] = item->ex_client;
-	k[1] = item->ex_dentry;
-
-	cp = (char*)k;
-	rv = 0;
-	for (i=0; i<sizeof(k); i++)
-		rv ^= cp[i];
-	return rv & EXPORT_HASHMASK;
+	int rv;
+
+	rv = hash_ptr(item->ex_client, EXPORT_HASHBITS);
+	rv ^= hash_ptr(item->ex_dentry, EXPORT_HASHBITS);
+	rv ^= hash_ptr(item->ex_mnt, EXPORT_HASHBITS);
+	return rv;
 }
 
 void svc_export_put(struct cache_head *item, struct cache_detail *cd)

diff ./include/linux/sunrpc/svcauth.h~current~ ./include/linux/sunrpc/svcauth.h
--- ./include/linux/sunrpc/svcauth.h~current~	2003-01-06 10:56:30.000000000 +1100
+++ ./include/linux/sunrpc/svcauth.h	2003-01-06 10:36:22.000000000 +1100
@@ -111,7 +111,11 @@ extern struct auth_domain *auth_unix_loo
 extern int auth_unix_forget_old(struct auth_domain *dom);
 extern void svcauth_unix_purge(void);
 
-extern int name_hash(char *name, int size);
+extern int hash_mem(char *buf, int len, int bits);
+static inline int hash_str(char *name, int bits)
+{
+	return hash_mem(name, strlen(name), bits);
+}
 
 extern struct cache_detail auth_domain_cache, ip_map_cache;
 

diff ./net/sunrpc/svcauth.c~current~ ./net/sunrpc/svcauth.c
--- ./net/sunrpc/svcauth.c~current~	2003-01-06 10:56:30.000000000 +1100
+++ ./net/sunrpc/svcauth.c	2003-01-06 10:36:22.000000000 +1100
@@ -16,6 +16,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/svcauth.h>
 #include <linux/err.h>
+#include <linux/hash.h>
 
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
@@ -111,14 +112,22 @@ svc_auth_unregister(rpc_authflavor_t fla
  * it will complain.
  */
 
-int name_hash(char *name, int size)
+int hash_mem(char *buf, int len, int bits)
 {
 	int hash = 0;
-	while (*name) {
-		hash += *name;
-		name++;
+	unsigned long l;
+	while (len >= BITS_PER_LONG/8) {
+		l = *(unsigned long *)buf;
+		buf += BITS_PER_LONG/8;
+		len -= BITS_PER_LONG/8;
+		hash ^= hash_long(l, bits);
 	}
-	return hash % size;
+	if (len) {
+		l=0;
+		memcpy((char*)&l, buf, len);
+		hash ^= hash_long(l, bits);
+	}
+	return hash;
 }
 
 
@@ -161,7 +170,7 @@ void auth_domain_put(struct auth_domain 
 
 static inline int auth_domain_hash(struct auth_domain *item)
 {
-	return name_hash(item->name, DN_HASHMAX);
+	return hash_str(item->name, DN_HASHBITS);
 }
 static inline int auth_domain_match(struct auth_domain *tmp, struct auth_domain *item)
 {

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2003-01-06 10:56:30.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2003-01-06 10:56:41.000000000 +1100
@@ -6,6 +6,7 @@
 #include <linux/sunrpc/svcauth.h>
 #include <linux/err.h>
 #include <linux/seq_file.h>
+#include <linux/hash.h>
 
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
@@ -108,7 +109,8 @@ void ip_map_put(struct cache_head *item,
 
 static inline int ip_map_hash(struct ip_map *item)
 {
-	return (name_hash(item->m_class, IP_HASHMAX) ^ item->m_addr.s_addr) & IP_HASHMASK;
+	return hash_str(item->m_class, IP_HASHBITS) ^ 
+		hash_long((unsigned long)item->m_addr.s_addr, IP_HASHBITS);
 }
 static inline int ip_map_match(struct ip_map *item, struct ip_map *tmp)
 {


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
