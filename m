From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.23.1 regression: write() data lost after lseek()
Date: Fri, 26 Oct 2007 12:53:49 -0400
Message-ID: <1193417629.7486.11.camel@heimdal.trondhjem.org>
References: <20071026155039.GA23334@janus>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-uZa+5hovE5/nfnETopMJ"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlSQa-0003Rj-8k
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 09:52:56 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IlSQe-0004Qh-Tp
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 09:53:01 -0700
In-Reply-To: <20071026155039.GA23334@janus>
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


--=-uZa+5hovE5/nfnETopMJ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Fri, 2007-10-26 at 17:50 +0200, Frank van Maarseveen wrote:
> 2.6.23.1 client (using 2.6.22.10 and 2.6.21.7 as server), mount options
> according to /proc/mounts:
> 
> rw,nodev,vers=3,rsize=32768,wsize=32768,hard,intr,proto=udp,timeo=11,retrans=2,sec=sys
> 
> 
> The data of the last write in this program gets lost when run on 2.6.23.1 client:

Known issue. I have already submitted the attached fix to
stable@kernel.org.

Trond

--=-uZa+5hovE5/nfnETopMJ
Content-Disposition: inline; filename=linux-2.6.23-133-fix_write_race.dif
Content-Type: message/rfc822; name=linux-2.6.23-133-fix_write_race.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 18 Oct 2007 17:08:05 -0400
NFS: Fix a writeback race...
Subject: No Subject
Message-Id: <1193417629.7486.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

This patch fixes a regression that was introduced by commit
44dd151d5c21234cc534c47d7382f5c28c3143cd

We cannot zero the user page in nfs_mark_uptodate() any more, since

  a) We'd be modifying the page without holding the page lock
  b) We can race with other updates of the page, most notably
     because of the call to nfs_wb_page() in nfs_writepage_setup().

Instead, we do the zeroing in nfs_update_request() if we see that we're
creating a request that might potentially be marked as up to date.

Thanks to Olivier Paquet for reporting the bug and providing a test-case.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e2bb66c..f418f6e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -174,8 +174,6 @@ static void nfs_mark_uptodate(struct page *page, unsigned int base, unsigned int
 		return;
 	if (count != nfs_page_length(page))
 		return;
-	if (count != PAGE_CACHE_SIZE)
-		zero_user_page(page, count, PAGE_CACHE_SIZE - count, KM_USER0);
 	SetPageUptodate(page);
 }
 
@@ -626,7 +624,8 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 				return ERR_PTR(error);
 			}
 			spin_unlock(&inode->i_lock);
-			return new;
+			req = new;
+			goto zero_page;
 		}
 		spin_unlock(&inode->i_lock);
 
@@ -654,13 +653,23 @@ static struct nfs_page * nfs_update_request(struct nfs_open_context* ctx,
 	if (offset < req->wb_offset) {
 		req->wb_offset = offset;
 		req->wb_pgbase = offset;
-		req->wb_bytes = rqend - req->wb_offset;
+		req->wb_bytes = max(end, rqend) - req->wb_offset;
+		goto zero_page;
 	}
 
 	if (end > rqend)
 		req->wb_bytes = end - req->wb_offset;
 
 	return req;
+zero_page:
+	/* If this page might potentially be marked as up to date,
+	 * then we need to zero any uninitalised data. */
+	if (req->wb_pgbase == 0 && req->wb_bytes != PAGE_CACHE_SIZE
+			&& !PageUptodate(req->wb_page))
+		zero_user_page(req->wb_page, req->wb_bytes,
+				PAGE_CACHE_SIZE - req->wb_bytes,
+				KM_USER0);
+	return req;
 }
 
 int nfs_flush_incompatible(struct file *file, struct page *page)

--=-uZa+5hovE5/nfnETopMJ
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--=-uZa+5hovE5/nfnETopMJ
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-uZa+5hovE5/nfnETopMJ--
