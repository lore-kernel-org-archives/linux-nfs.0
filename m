From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: [PATCH 2/2] NFS: handle IPv6 addresses in nfs ctl
Date: Tue, 23 Oct 2007 09:22:40 +0200
Message-ID: <471DA140.6060400@ext.bull.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020704010802040207090500"
To: NFS ML <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkE3v-00043A-6h
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 00:20:28 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IkE3y-0002lx-KK
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 00:20:32 -0700
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 69A2B19D98C
	for <nfs@lists.sourceforge.net>; Tue, 23 Oct 2007 09:19:46 +0200 (CEST)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
	by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 07086-05 for <nfs@lists.sourceforge.net>;
	Tue, 23 Oct 2007 09:19:40 +0200 (CEST)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 8DBC019D997
	for <nfs@lists.sourceforge.net>; Tue, 23 Oct 2007 09:19:08 +0200 (CEST)
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

This is a multi-part message in MIME format.
--------------020704010802040207090500
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed

Here is a second missing part of the IPv6 support in NFS server code 
concerning knfd syscall interface.
It updates write_getfd and write_getfd to accept IPv6 addresses.

I've updated it according to Brian's comments, and removed some unused code. 


Applies on a kernel including ip_map cache modifications

Tests: tested with only IPv4 network and basic nfs ops (mount, file 
creation and modification)

Signed-off-by: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

diff -p -u -r -N linux-2.6.23-ipmap/fs/nfsd/nfsctl.c 
linux-2.6.23-nfsctl/fs/nfsd/nfsctl.c
--- linux-2.6.23-ipmap/fs/nfsd/nfsctl.c    2007-10-22 10:32:51.000000000 
+0200
+++ linux-2.6.23-nfsctl/fs/nfsd/nfsctl.c    2007-10-22 
11:06:13.000000000 +0200
@@ -219,7 +219,7 @@ static ssize_t write_unexport(struct fil
static ssize_t write_getfs(struct file *file, char *buf, size_t size)
{
    struct nfsctl_fsparm *data;
-    struct sockaddr_in *sin;
+    struct sockaddr_in6 *sin6, sin6_storage;
    struct auth_domain *clp;
    int err = 0;
    struct knfsd_fh *res;
@@ -229,9 +229,20 @@ static ssize_t write_getfs(struct file *
        return -EINVAL;
    data = (struct nfsctl_fsparm*)buf;
    err = -EPROTONOSUPPORT;
-    if (data->gd_addr.sa_family != AF_INET)
+    switch (data->gd_addr.sa_family) {
+    case AF_INET6:
+        sin6 = &sin6_storage;
+        sin6 = (struct sockaddr_in6 *)&data->gd_addr;
+        ipv6_addr_copy(&in6, &(sin6->sin6_addr));
+        break;
+    case AF_INET:
+        /* Map v4 address into v6 structure */
+        ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct 
sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));
+        break;
+    default:
        goto out;
-    sin = (struct sockaddr_in *)&data->gd_addr;
+    }
+
    if (data->gd_maxlen > NFS3_FHSIZE)
        data->gd_maxlen = NFS3_FHSIZE;

@@ -239,10 +250,7 @@ static ssize_t write_getfs(struct file *

    exp_readlock();

-    /* IPv6 address mapping */
-        ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct 
sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));
-
-        if (!(clp = auth_unix_lookup(in6)))
+    if (!(clp = auth_unix_lookup(&in6)))
        err = -EPERM;
    else {
        err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
@@ -258,7 +266,7 @@ static ssize_t write_getfs(struct file *
static ssize_t write_getfd(struct file *file, char *buf, size_t size)
{
    struct nfsctl_fdparm *data;
-    struct sockaddr_in *sin;
+    struct sockaddr_in6 *sin6, sin6_storage;
    struct auth_domain *clp;
    int err = 0;
    struct knfsd_fh fh;
@@ -269,20 +277,30 @@ static ssize_t write_getfd(struct file *
        return -EINVAL;
    data = (struct nfsctl_fdparm*)buf;
    err = -EPROTONOSUPPORT;
-    if (data->gd_addr.sa_family != AF_INET)
+    if (data->gd_addr.sa_family != AF_INET && data->gd_addr.sa_family 
!= AF_INET6)
        goto out;
    err = -EINVAL;
    if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
        goto out;

    res = buf;
-    sin = (struct sockaddr_in *)&data->gd_addr;
    exp_readlock();
-   -    /* IPv6 address mapping */
-        ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct 
sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));

-        if (!(clp = auth_unix_lookup(in6)))
+    switch (data->gd_addr.sa_family) {
+    case AF_INET:
+        /* IPv6 address mapping */
+        ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), ((struct 
sockaddr_in *)&data->gd_addr)->sin_addr.s_addr);
+        break;
+    case AF_INET6:
+        sin6 = &sin6_storage;
+        sin6 = (struct sockaddr_in6 *)&data->gd_addr;
+        ipv6_addr_copy(&in6, &(sin6->sin6_addr));
+        break;
+    default:
+        BUG();
+    }
+
+    if (!(clp = auth_unix_lookup(&in6)))
        err = -EPERM;
    else {
        err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);

-- 

********************************
       Aurelien Charbon
       Linux NFSv4 team
           Bull SAS
     Echirolles - France
http://nfsv4.bullopensource.org/
********************************


--------------020704010802040207090500
Content-Transfer-Encoding: 7bit
Content-Type: text/x-patch;
 name="linux-2.6.23-ipmap.diff"
Content-Disposition: inline;
 filename="linux-2.6.23-ipmap.diff"

diff -p -u -r -N linux-2.6.23-haley/fs/nfsd/export.c linux-2.6.23-ipmap/fs/nfsd/export.c
--- linux-2.6.23-haley/fs/nfsd/export.c	2007-10-22 09:43:17.000000000 +0200
+++ linux-2.6.23-ipmap/fs/nfsd/export.c	2007-10-22 13:04:50.000000000 +0200
@@ -35,6 +35,7 @@
 #include <linux/lockd/bind.h>
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/gss_api.h>
+#include <net/ipv6.h>
 
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
 
@@ -1559,6 +1560,7 @@ exp_addclient(struct nfsctl_client *ncp)
 {
 	struct auth_domain	*dom;
 	int			i, err;
+	struct in6_addr addr6;
 
 	/* First, consistency check. */
 	err = -EINVAL;
@@ -1577,9 +1579,11 @@ exp_addclient(struct nfsctl_client *ncp)
 		goto out_unlock;
 
 	/* Insert client into hashtable. */
-	for (i = 0; i < ncp->cl_naddr; i++)
-		auth_unix_add_addr(ncp->cl_addrlist[i], dom);
-
+	for (i = 0; i < ncp->cl_naddr; i++) {
+		/* Mapping address */
+		ipv6_addr_set(&addr6, 0, 0, htonl(0x0000FFFF), ncp->cl_addrlist[i].s_addr);
+		auth_unix_add_addr(&addr6, dom);
+	}
 	auth_unix_forget_old(dom);
 	auth_domain_put(dom);
 
diff -p -u -r -N linux-2.6.23-haley/fs/nfsd/nfsctl.c linux-2.6.23-ipmap/fs/nfsd/nfsctl.c
--- linux-2.6.23-haley/fs/nfsd/nfsctl.c	2007-10-22 09:43:17.000000000 +0200
+++ linux-2.6.23-ipmap/fs/nfsd/nfsctl.c	2007-10-22 10:32:51.000000000 +0200
@@ -37,6 +37,7 @@
 #include <linux/nfsd/syscall.h>
 
 #include <asm/uaccess.h>
+#include <net/ipv6.h>
 
 /*
  *	We have a single directory with 9 nodes in it.
@@ -222,6 +223,7 @@ static ssize_t write_getfs(struct file *
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh *res;
+	struct in6_addr in6;
 
 	if (size < sizeof(*data))
 		return -EINVAL;
@@ -236,7 +238,11 @@ static ssize_t write_getfs(struct file *
 	res = (struct knfsd_fh*)buf;
 
 	exp_readlock();
-	if (!(clp = auth_unix_lookup(sin->sin_addr)))
+
+	/* IPv6 address mapping */
+    	ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));
+
+    	if (!(clp = auth_unix_lookup(in6))) 
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
@@ -257,6 +263,7 @@ static ssize_t write_getfd(struct file *
 	int err = 0;
 	struct knfsd_fh fh;
 	char *res;
+	struct in6_addr in6;
 
 	if (size < sizeof(*data))
 		return -EINVAL;
@@ -271,7 +278,11 @@ static ssize_t write_getfd(struct file *
 	res = buf;
 	sin = (struct sockaddr_in *)&data->gd_addr;
 	exp_readlock();
-	if (!(clp = auth_unix_lookup(sin->sin_addr)))
+	
+	/* IPv6 address mapping */
+    	ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), (((struct sockaddr_in *)&data->gd_addr)->sin_addr.s_addr));
+
+    	if (!(clp = auth_unix_lookup(in6))) 
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);
diff -p -u -r -N linux-2.6.23-haley/include/linux/sunrpc/svcauth.h linux-2.6.23-ipmap/include/linux/sunrpc/svcauth.h
--- linux-2.6.23-haley/include/linux/sunrpc/svcauth.h	2007-10-22 09:43:04.000000000 +0200
+++ linux-2.6.23-ipmap/include/linux/sunrpc/svcauth.h	2007-10-22 10:10:37.000000000 +0200
@@ -120,10 +120,10 @@ extern void	svc_auth_unregister(rpc_auth
 
 extern struct auth_domain *unix_domain_find(char *name);
 extern void auth_domain_put(struct auth_domain *item);
-extern int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom);
+extern int auth_unix_add_addr(struct in6_addr *addr, struct auth_domain *dom);
 extern struct auth_domain *auth_domain_lookup(char *name, struct auth_domain *new);
 extern struct auth_domain *auth_domain_find(char *name);
-extern struct auth_domain *auth_unix_lookup(struct in_addr addr);
+extern struct auth_domain *auth_unix_lookup(struct in6_addr *addr);
 extern int auth_unix_forget_old(struct auth_domain *dom);
 extern void svcauth_unix_purge(void);
 extern void svcauth_unix_info_release(void *);
diff -p -u -r -N linux-2.6.23-haley/include/net/ipv6.h linux-2.6.23-ipmap/include/net/ipv6.h
--- linux-2.6.23-haley/include/net/ipv6.h	2007-10-22 09:42:58.000000000 +0200
+++ linux-2.6.23-ipmap/include/net/ipv6.h	2007-10-22 10:10:59.000000000 +0200
@@ -21,6 +21,7 @@
 #include <net/ndisc.h>
 #include <net/flow.h>
 #include <net/snmp.h>
+#include <linux/in.h>
 
 #define SIN6_LEN_RFC2133	24
 
@@ -167,6 +168,12 @@ DECLARE_SNMP_STAT(struct udp_mib, udplit
 	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);         \
 	else		SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
 
+#define IS_ADDR_MAPPED(a) \
+	(((uint32_t *) (a))[0] == 0			\
+	&& ((uint32_t *) (a))[1] == 0			\
+	&& (((uint32_t *) (a))[2] == 0			\
+	|| ((uint32_t *) (a))[2] == htonl(0xffff)))
+
 struct ip6_ra_chain
 {
 	struct ip6_ra_chain	*next;
@@ -380,7 +387,7 @@ static inline int ipv6_addr_any(const st
 static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
 {
 	return ((a->s6_addr32[0] | a->s6_addr32[1]) == 0 && 
-		 a->s6_addr32[2] == htonl(0x0000ffff)); 
+		a->s6_addr32[2] == htonl(0x0000ffff)); 
 }
 
 /*
diff -p -u -r -N linux-2.6.23-haley/net/sunrpc/svcauth_unix.c linux-2.6.23-ipmap/net/sunrpc/svcauth_unix.c
--- linux-2.6.23-haley/net/sunrpc/svcauth_unix.c	2007-10-22 09:43:05.000000000 +0200
+++ linux-2.6.23-ipmap/net/sunrpc/svcauth_unix.c	2007-10-22 10:12:03.000000000 +0200
@@ -11,7 +11,8 @@
 #include <linux/hash.h>
 #include <linux/string.h>
 #include <net/sock.h>
-
+#include <net/ipv6.h>
+#include <linux/kernel.h>
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
 
@@ -84,7 +85,7 @@ static void svcauth_unix_domain_release(
 struct ip_map {
 	struct cache_head	h;
 	char			m_class[8]; /* e.g. "nfsd" */
-	struct in_addr		m_addr;
+	struct in6_addr		m_addr;
 	struct unix_domain	*m_client;
 	int			m_add_change;
 };
@@ -112,12 +113,19 @@ static inline int hash_ip(__be32 ip)
 	return (hash ^ (hash>>8)) & 0xff;
 }
 #endif
+static inline int hash_ip6(struct in6_addr ip)
+{
+	return (hash_ip(ip.s6_addr32[0]) ^
+		hash_ip(ip.s6_addr32[1]) ^
+		hash_ip(ip.s6_addr32[2]) ^
+		hash_ip(ip.s6_addr32[3]));
+}
 static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
 {
 	struct ip_map *orig = container_of(corig, struct ip_map, h);
 	struct ip_map *new = container_of(cnew, struct ip_map, h);
 	return strcmp(orig->m_class, new->m_class) == 0
-		&& orig->m_addr.s_addr == new->m_addr.s_addr;
+		&& ipv6_addr_equal(&orig->m_addr, &new->m_addr);
 }
 static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -125,7 +133,7 @@ static void ip_map_init(struct cache_hea
 	struct ip_map *item = container_of(citem, struct ip_map, h);
 
 	strcpy(new->m_class, item->m_class);
-	new->m_addr.s_addr = item->m_addr.s_addr;
+	ipv6_addr_copy(&(new->m_addr), &(item->m_addr));
 }
 static void update(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -149,22 +157,24 @@ static void ip_map_request(struct cache_
 				  struct cache_head *h,
 				  char **bpp, int *blen)
 {
-	char text_addr[20];
+	char text_addr[40];
 	struct ip_map *im = container_of(h, struct ip_map, h);
-	__be32 addr = im->m_addr.s_addr;
-
-	snprintf(text_addr, 20, "%u.%u.%u.%u",
-		 ntohl(addr) >> 24 & 0xff,
-		 ntohl(addr) >> 16 & 0xff,
-		 ntohl(addr) >>  8 & 0xff,
-		 ntohl(addr) >>  0 & 0xff);
 
+	if (ipv6_addr_v4mapped(&(im->m_addr))) {
+		snprintf(text_addr, 20, NIPQUAD_FMT,
+				ntohl(im->m_addr.s6_addr32[3]) >> 24 & 0xff,
+				ntohl(im->m_addr.s6_addr32[3]) >> 16 & 0xff,
+				ntohl(im->m_addr.s6_addr32[3]) >>  8 & 0xff,
+				ntohl(im->m_addr.s6_addr32[3]) >>  0 & 0xff);
+	} else {
+		snprintf(text_addr, 40, NIP6_FMT, NIP6(im->m_addr));
+	}
 	qword_add(bpp, blen, im->m_class);
 	qword_add(bpp, blen, text_addr);
 	(*bpp)[-1] = '\n';
 }
 
-static struct ip_map *ip_map_lookup(char *class, struct in_addr addr);
+static struct ip_map *ip_map_lookup(char *class, struct in6_addr *addr);
 static int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
 
 static int ip_map_parse(struct cache_detail *cd,
@@ -175,10 +185,10 @@ static int ip_map_parse(struct cache_det
 	 * for scratch: */
 	char *buf = mesg;
 	int len;
-	int b1,b2,b3,b4;
+	int b1, b2, b3, b4, b5, b6, b7, b8;
 	char c;
 	char class[8];
-	struct in_addr addr;
+	struct in6_addr addr;
 	int err;
 
 	struct ip_map *ipmp;
@@ -197,9 +207,26 @@ static int ip_map_parse(struct cache_det
 	len = qword_get(&mesg, buf, mlen);
 	if (len <= 0) return -EINVAL;
 
-	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
+	if (sscanf(buf, NIPQUAD_FMT "%c", &b1, &b2, &b3, &b4, &c) == 4) {
+		addr.s6_addr32[0] = 0;
+		addr.s6_addr32[1] = 0;
+		addr.s6_addr32[2] = htonl(0xffff);
+		addr.s6_addr32[3] =
+			htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
+       } else if (sscanf(buf, NIP6_FMT "%c",
+			&b1, &b2, &b3, &b4, &b5, &b6, &b7, &b8, &c) == 8) {
+		addr.s6_addr16[0] = htons(b1);
+		addr.s6_addr16[1] = htons(b2);
+		addr.s6_addr16[2] = htons(b3);
+		addr.s6_addr16[3] = htons(b4);
+		addr.s6_addr16[4] = htons(b5);
+		addr.s6_addr16[5] = htons(b6);
+		addr.s6_addr16[6] = htons(b7);
+		addr.s6_addr16[7] = htons(b8);
+       } else
 		return -EINVAL;
 
+
 	expiry = get_expiry(&mesg);
 	if (expiry ==0)
 		return -EINVAL;
@@ -215,10 +242,7 @@ static int ip_map_parse(struct cache_det
 	} else
 		dom = NULL;
 
-	addr.s_addr =
-		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
-
-	ipmp = ip_map_lookup(class,addr);
+	ipmp = ip_map_lookup(class, &addr);
 	if (ipmp) {
 		err = ip_map_update(ipmp,
 			     container_of(dom, struct unix_domain, h),
@@ -238,7 +262,7 @@ static int ip_map_show(struct seq_file *
 		       struct cache_head *h)
 {
 	struct ip_map *im;
-	struct in_addr addr;
+	struct in6_addr addr;
 	char *dom = "-no-domain-";
 
 	if (h == NULL) {
@@ -247,20 +271,24 @@ static int ip_map_show(struct seq_file *
 	}
 	im = container_of(h, struct ip_map, h);
 	/* class addr domain */
-	addr = im->m_addr;
+	ipv6_addr_copy(&addr, &im->m_addr);
 
 	if (test_bit(CACHE_VALID, &h->flags) &&
 	    !test_bit(CACHE_NEGATIVE, &h->flags))
 		dom = im->m_client->h.name;
 
-	seq_printf(m, "%s %d.%d.%d.%d %s\n",
-		   im->m_class,
-		   ntohl(addr.s_addr) >> 24 & 0xff,
-		   ntohl(addr.s_addr) >> 16 & 0xff,
-		   ntohl(addr.s_addr) >>  8 & 0xff,
-		   ntohl(addr.s_addr) >>  0 & 0xff,
-		   dom
-		   );
+	if (ipv6_addr_v4mapped(&addr)) {
+		seq_printf(m, "%s" NIPQUAD_FMT "%s\n",
+			im->m_class,
+			ntohl(addr.s6_addr32[3]) >> 24 & 0xff,
+			ntohl(addr.s6_addr32[3]) >> 16 & 0xff,
+			ntohl(addr.s6_addr32[3]) >>  8 & 0xff,
+			ntohl(addr.s6_addr32[3]) >>  0 & 0xff,
+			dom);
+	} else {
+		seq_printf(m, "%s" NIP6_FMT "%s\n",
+			im->m_class, NIP6(addr), dom);
+	}
 	return 0;
 }
 
@@ -280,16 +308,16 @@ struct cache_detail ip_map_cache = {
 	.alloc		= ip_map_alloc,
 };
 
-static struct ip_map *ip_map_lookup(char *class, struct in_addr addr)
+static struct ip_map *ip_map_lookup(char *class, struct in6_addr *addr)
 {
 	struct ip_map ip;
 	struct cache_head *ch;
 
 	strcpy(ip.m_class, class);
-	ip.m_addr = addr;
+	ipv6_addr_copy(&ip.m_addr, addr);
 	ch = sunrpc_cache_lookup(&ip_map_cache, &ip.h,
 				 hash_str(class, IP_HASHBITS) ^
-				 hash_ip(addr.s_addr));
+				 hash_ip6(*addr));
 
 	if (ch)
 		return container_of(ch, struct ip_map, h);
@@ -318,14 +346,14 @@ static int ip_map_update(struct ip_map *
 	ch = sunrpc_cache_update(&ip_map_cache,
 				 &ip.h, &ipm->h,
 				 hash_str(ipm->m_class, IP_HASHBITS) ^
-				 hash_ip(ipm->m_addr.s_addr));
+				 hash_ip6(ipm->m_addr));
 	if (!ch)
 		return -ENOMEM;
 	cache_put(ch, &ip_map_cache);
 	return 0;
 }
 
-int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom)
+int auth_unix_add_addr(struct in6_addr *addr, struct auth_domain *dom)
 {
 	struct unix_domain *udom;
 	struct ip_map *ipmp;
@@ -352,7 +380,7 @@ int auth_unix_forget_old(struct auth_dom
 	return 0;
 }
 
-struct auth_domain *auth_unix_lookup(struct in_addr addr)
+struct auth_domain *auth_unix_lookup(struct in6_addr *addr)
 {
 	struct ip_map *ipm;
 	struct auth_domain *rv;
@@ -641,9 +669,24 @@ static int unix_gid_find(uid_t uid, stru
 int
 svcauth_unix_set_client(struct svc_rqst *rqstp)
 {
-	struct sockaddr_in *sin = svc_addr_in(rqstp);
+	struct sockaddr_in *sin;
+	struct sockaddr_in6 *sin6, sin6_storage;
 	struct ip_map *ipm;
 
+	switch (rqstp->rq_addr.ss_family) {
+	case AF_INET:
+		sin = svc_addr_in(rqstp);
+		sin6 = &sin6_storage;
+		ipv6_addr_set(&sin6->sin6_addr, 0, 0, 
+				htonl(0x0000FFFF), sin->sin_addr.s_addr); 
+		break;
+	case AF_INET6:
+		sin6 = svc_addr_in6(rqstp);
+		break;
+	default:
+		BUG();
+	}
+
 	rqstp->rq_client = NULL;
 	if (rqstp->rq_proc == 0)
 		return SVC_OK;
@@ -651,7 +694,7 @@ svcauth_unix_set_client(struct svc_rqst 
 	ipm = ip_map_cached_get(rqstp);
 	if (ipm == NULL)
 		ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
-				    sin->sin_addr);
+				    &(sin6->sin6_addr));
 
 	if (ipm == NULL)
 		return SVC_DENIED;

--------------020704010802040207090500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------020704010802040207090500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020704010802040207090500--
