From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/11] NFSv4: Fix thinko in fs/nfs/super.c
Date: Thu, 19 Oct 2006 13:04:32 -0400
Message-ID: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GabLY-0001RZ-Pf
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 10:06:20 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GabLZ-0003uw-Ly
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 10:06:21 -0700
To: Linus Torvalds <torvalds@osdl.org>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Duh. addr.sin_port should be in network byte order.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 28659a9..28108c8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -834,7 +834,7 @@ static int nfs4_get_sb(struct file_syste
 	}
 	/* RFC3530: The default port for NFS is 2049 */
 	if (addr.sin_port == 0)
-		addr.sin_port = NFS_PORT;
+		addr.sin_port = htons(NFS_PORT);
 
 	/* Grab the authentication type */
 	authflavour = RPC_AUTH_UNIX;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
