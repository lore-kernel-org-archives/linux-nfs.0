From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Crash in dec_zone_page_state when nfs_page req is freed
Date: Mon, 18 Sep 2006 23:24:34 -0400
Message-ID: <1158636275.5896.14.camel@lade.trondhjem.org>
References: <1158623736.3376.8.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-4xh4i9HM0NhFPMY3ORRK"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GPWEC-0007bV-MB
	for nfs@lists.sourceforge.net; Mon, 18 Sep 2006 20:24:56 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GPWEC-0005l8-2n
	for nfs@lists.sourceforge.net; Mon, 18 Sep 2006 20:24:57 -0700
To: Frank Filz <ffilzlnx@us.ibm.com>
In-Reply-To: <1158623736.3376.8.camel@dyn9047022153>
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


--=-4xh4i9HM0NhFPMY3ORRK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2006-09-18 at 16:55 -0700, Frank Filz wrote:
> I am seeing a crash in dec_zone_page_state when called from 
> 
> static void nfs_cancel_commit_list(struct list_head *head)
> {
> 	struct nfs_page *req;
> 
> 	while(!list_empty(head)) {
> 		req = nfs_list_entry(head->next);
> 		nfs_list_remove_request(req);
> 		nfs_inode_remove_request(req);
> 		nfs_clear_page_writeback(req);
> 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> 	}
> }
> 
> I see this was somewhat recently added. It appears that
> nfs_clear_page_writeback has resulted in the req being freed. We are
> running with CONFIG_SLAB_DEBUG on which poisons memory with repeated
> 0x6b bytes when freed so the subsequent reference to req results in a
> bad wb_page pointer.

Does the attached patch fix it for you?

Cheers,
  Trond


--=-4xh4i9HM0NhFPMY3ORRK
Content-Disposition: inline;
	filename=linux-2.6.18-075-nfs_page_use_after_free.dif
Content-Type: message/rfc822; name=linux-2.6.18-075-nfs_page_use_after_free.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: 
NFS: Fix nfs_page use after free issues in fs/nfs/write.c
Subject: No Subject
Message-Id: <1158636275.5896.15.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index cf76f9c..38ba5c0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -591,8 +591,8 @@ static void nfs_cancel_commit_list(struc
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_inode_remove_request(req);
-		nfs_clear_page_writeback(req);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		nfs_clear_page_writeback(req);
 	}
 }
 
@@ -1387,8 +1387,8 @@ nfs_commit_list(struct inode *inode, str
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req);
-		nfs_clear_page_writeback(req);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		nfs_clear_page_writeback(req);
 	}
 	return -ENOMEM;
 }

--=-4xh4i9HM0NhFPMY3ORRK
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-4xh4i9HM0NhFPMY3ORRK
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-4xh4i9HM0NhFPMY3ORRK--
