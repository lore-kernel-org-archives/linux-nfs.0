From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 8 - Always flush rpc caches after an update
Date: Tue, 24 Jun 2003 16:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19Uhhd-0001q6-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Uhhy-0007S7-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 23:55:14 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 24 Jun 2003 16:54:58 +1000
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

..as the update might have set an expiry date in the past
and we want it to be removed instantly.


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c          |    4 ++--
 ./net/sunrpc/svcauth_unix.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-06-24 12:37:38.000000000 +1000
+++ ./fs/nfsd/export.c	2003-06-24 13:25:59.000000000 +1000
@@ -184,7 +184,7 @@ int expkey_parse(struct cache_detail *cd
 	out_nd:
 		path_release(&nd);
 	}
-
+	cache_flush();
  out:
 	if (dom)
 		auth_domain_put(dom);
@@ -396,7 +396,7 @@ int svc_export_parse(struct cache_detail
 	if (expp)
 		exp_put(expp);
 	err = 0;
-
+	cache_flush();
  out:
 	if (nd.dentry)
 		path_release(&nd);

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2003-06-24 12:37:38.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2003-06-24 13:26:24.000000000 +1000
@@ -209,7 +209,7 @@ static int ip_map_parse(struct cache_det
 		auth_domain_put(dom);
 	if (!ipmp)
 		return -ENOMEM;
-
+	cache_flush();
 	return 0;
 }
 


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
