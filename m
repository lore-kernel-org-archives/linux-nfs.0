From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 2 of 18] svcrpc: fqdn length fix
Date: Tue, 16 Nov 2004 15:50:49 +1100
Message-ID: <E1CTvIn-0004pO-Jr@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvEy-0005r3-JY
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:52 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvEx-0007Gr-I3
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:52 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
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



Problem identified by Jan Kasprzak.

Limit on domainname_max (currently 50) is too small.

Just use the beginning of input buffer as scratch space for it, and
save a little stack space while we're at it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./net/sunrpc/svcauth_unix.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2004-11-16 14:41:06.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2004-11-16 14:41:06.000000000 +1100
@@ -150,11 +150,14 @@ static void ip_map_request(struct cache_
 }
 
 static struct ip_map *ip_map_lookup(struct ip_map *, int);
+
 static int ip_map_parse(struct cache_detail *cd,
 			  char *mesg, int mlen)
 {
 	/* class ipaddress [domainname] */
-	char class[50], buf[50];
+	/* should be safe just to use the start of the input buffer
+	 * for scratch: */
+	char *buf = mesg;
 	int len;
 	int b1,b2,b3,b4;
 	char c;
@@ -167,13 +170,11 @@ static int ip_map_parse(struct cache_det
 	mesg[mlen-1] = 0;
 
 	/* class */
-	len = qword_get(&mesg, class, 50);
+	len = qword_get(&mesg, ipm.m_class, sizeof(ipm.m_class));
 	if (len <= 0) return -EINVAL;
-	if (len >= sizeof(ipm.m_class))
-		return -EINVAL;
 
 	/* ip address */
-	len = qword_get(&mesg, buf, 50);
+	len = qword_get(&mesg, buf, mlen);
 	if (len <= 0) return -EINVAL;
 
 	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
@@ -184,7 +185,7 @@ static int ip_map_parse(struct cache_det
 		return -EINVAL;
 
 	/* domainname, or empty for NEGATIVE */
-	len = qword_get(&mesg, buf, 50);
+	len = qword_get(&mesg, buf, mlen);
 	if (len < 0) return -EINVAL;
 
 	if (len) {
@@ -194,7 +195,6 @@ static int ip_map_parse(struct cache_det
 	} else
 		dom = NULL;
 
-	strcpy(ipm.m_class, class);
 	ipm.m_addr.s_addr =
 		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
 	ipm.h.flags = 0;


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
