From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 16 of 17 - Impletement ip_map_parse to allow filling auth.unix.ip cache
Date: Fri, 11 Oct 2002 15:28:00 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsLA-0003c8-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLd-0003j5-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:30 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By tone With Smtp ;
	Fri, 11 Oct 2002 15:28:14 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: linux-kernel@vger.kernel.org
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

a message should be:
   nfsd 10.0.1.1 {Expirydate}  domainname

if domainname is empty, then this is a NEGATIVE entry: that
IP address will be deined access.

{Expirydate} is seconds since unix epoch.
e.g.  1036105199 for midnight, halloween.


 ----------- Diffstat output ------------
 ./net/sunrpc/svcauth_unix.c |   66 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 66 insertions(+)

--- ./net/sunrpc/svcauth_unix.c	2002/10/11 03:06:58	1.5
+++ ./net/sunrpc/svcauth_unix.c	2002/10/11 04:04:45	1.6
@@ -135,12 +135,78 @@ static void ip_map_request(struct cache_
 	(*bpp)[-1] = '\n';
 }
 
+static struct ip_map *ip_map_lookup(struct ip_map *, int);
+static int ip_map_parse(struct cache_detail *cd,
+			  char *mesg, int mlen)
+{
+	/* class ipaddress [domainname] */
+	char class[50], buf[50];
+	int len;
+	int b1,b2,b3,b4;
+	char c;
+	struct ip_map ipm, *ipmp;
+	struct auth_domain *dom;
+	time_t expiry;
+
+	if (mesg[mlen-1] != '\n')
+		return -EINVAL;
+	mesg[mlen-1] = 0;
+
+	/* class */
+	len = get_word(&mesg, class, 50);
+	if (len <= 0) return -EINVAL;
+
+	/* ip address */
+	len = get_word(&mesg, buf, 50);
+	if (len <= 0) return -EINVAL;
+
+	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
+		return -EINVAL;
+	
+	expiry = get_expiry(&mesg);
+	if (expiry ==0)
+		return -EINVAL;
+
+	/* domainname, or empty for NEGATIVE */
+	len = get_word(&mesg, buf, 50);
+	if (len < 0) return -EINVAL;
+
+	if (len) {
+		dom = unix_domain_find(buf);
+		if (dom == NULL)
+			return -ENOENT;
+	} else
+		dom = NULL;
+
+	ipm.m_class = class;
+	ipm.m_addr.s_addr =
+		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
+	ipm.h.flags = 0;
+	if (dom)
+		ipm.m_client = container_of(dom, struct unix_domain, h);
+	else
+		set_bit(CACHE_NEGATIVE, &ipm.h.flags);
+	ipm.h.expiry_time = expiry;
+	ipm.m_add_change = ipm.m_client->addr_changes;
+
+	ipmp = ip_map_lookup(&ipm, 1);
+	if (ipmp)
+		ip_map_put(&ipmp->h, &ip_map_cache);
+	if (dom)
+		auth_domain_put(dom);
+	if (!ipmp)
+		return -ENOMEM;
+
+	return 0;
+}
+
 struct cache_detail ip_map_cache = {
 	.hash_size	= IP_HASHMAX,
 	.hash_table	= ip_table,
 	.name		= "auth.unix.ip",
 	.cache_put	= ip_map_put,
 	.cache_request	= ip_map_request,
+	.cache_parse	= ip_map_parse,
 };
 
 static DefineSimpleCacheLookup(ip_map)


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
