From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 003 of 3] knfsd: Remove an unused variable
	from	auth_unix_lookup()
Date: Thu, 06 Jul 2006 15:19:26 +1000
Message-ID: <1152163165.18333.367.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyMGy-0007ts-2j
	for nfs@lists.sourceforge.net; Wed, 05 Jul 2006 22:19:32 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FyMGy-0007qa-6C
	for nfs@lists.sourceforge.net; Wed, 05 Jul 2006 22:19:32 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

knfsd: Remove an unused variable from auth_unix_lookup()

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 net/sunrpc/svcauth_unix.c |    5 +----
 1 files changed, 1 insertion(+), 4 deletions(-)

Index: linus-git/net/sunrpc/svcauth_unix.c
===================================================================
--- linus-git.orig/net/sunrpc/svcauth_unix.c	2006-07-05 15:55:57.889034008 +1000
+++ linus-git/net/sunrpc/svcauth_unix.c	2006-07-06 12:56:03.790962262 +1000
@@ -348,12 +348,9 @@ int auth_unix_forget_old(struct auth_dom
 
 struct auth_domain *auth_unix_lookup(struct in_addr addr)
 {
-	struct ip_map key, *ipm;
+	struct ip_map *ipm;
 	struct auth_domain *rv;
 
-	strcpy(key.m_class, "nfsd");
-	key.m_addr = addr;
-
 	ipm = ip_map_lookup("nfsd", addr);
 
 	if (!ipm)


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
