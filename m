From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/4] NFS: Don't fail an O_DIRECT read/write if
	get_user_pages() returns pages
Date: Tue, 22 May 2007 10:29:18 -0400
Message-ID: <20070522142918.22559.74840.stgit@heimdal.trondhjem.org>
References: <20070522142908.22559.91696.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqVMY-00049A-0B
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 07:29:22 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqVMa-0006Fp-Ma
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 07:29:24 -0700
In-Reply-To: <20070522142908.22559.91696.stgit@heimdal.trondhjem.org>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

There is no need to fail the entire O_DIRECT read/write just because
get_user_pages() returned fewer pages than we requested.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c |   22 ++++++++++++++++------
 1 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 49e4823..ef0ce2c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -284,9 +284,14 @@ static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq, unsigned lo
 			break;
 		}
 		if ((unsigned)result < data->npages) {
-			nfs_direct_release_pages(data->pagevec, result);
-			nfs_readdata_release(data);
-			break;
+			bytes = result * PAGE_SIZE;
+			if (bytes <= pgbase) {
+				nfs_direct_release_pages(data->pagevec, result);
+				nfs_readdata_release(data);
+				break;
+			}
+			bytes -= pgbase;
+			data->npages = result;
 		}
 
 		get_dreq(dreq);
@@ -618,9 +623,14 @@ static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq, unsigned l
 			break;
 		}
 		if ((unsigned)result < data->npages) {
-			nfs_direct_release_pages(data->pagevec, result);
-			nfs_writedata_release(data);
-			break;
+			bytes = result * PAGE_SIZE;
+			if (bytes <= pgbase) {
+				nfs_direct_release_pages(data->pagevec, result);
+				nfs_writedata_release(data);
+				break;
+			}
+			bytes -= pgbase;
+			data->npages = result;
 		}
 
 		get_dreq(dreq);

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
