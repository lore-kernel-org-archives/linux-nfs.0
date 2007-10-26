From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 24/27] NFS: Clean up address comparison in
	__nfs_find_client()
Date: Fri, 26 Oct 2007 13:32:45 -0400
Message-ID: <20071026173245.31475.49916.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT3J-0007LZ-Lg
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:33:09 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT3O-0006fy-2D
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:33:03 -0700
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

The address comparison in the __nfs_find_client() function is deceptive.
It uses a memcmp() to check a pair of u32 fields for equality.  Not only is
this inefficient, but usually memcmp() is used for comparing two *whole*
sockaddr_in's (which includes comparisons of the address family and port
number), so it's easy to mistake the comparison here for a whole sockaddr
comparison, which it isn't.

So for clarity and efficiency, we replace the memcmp() with a simple test
for equality between the two s_addr fields.  This should have no
behavioral effect.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 70587f3..4081197 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -220,8 +220,7 @@ static struct nfs_client *__nfs_find_client(const struct sockaddr_in *addr, int
 		if (clp->cl_nfsversion != nfsversion)
 			continue;
 
-		if (memcmp(&clp->cl_addr.sin_addr, &addr->sin_addr,
-			   sizeof(clp->cl_addr.sin_addr)) != 0)
+		if (clp->cl_addr.sin_addr.s_addr != addr->sin_addr.s_addr)
 			continue;
 
 		if (!match_port || clp->cl_addr.sin_port == addr->sin_port)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
