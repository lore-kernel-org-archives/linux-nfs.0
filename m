From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Crash in dec_zone_page_state when nfs_page req is freed
Date: Mon, 09 Oct 2006 16:25:10 -0400
Message-ID: <1160425510.5466.44.camel@lade.trondhjem.org>
References: <1158623736.3376.8.camel@dyn9047022153>
	<1158636275.5896.14.camel@lade.trondhjem.org>
	<1160418641.3376.103.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-pSLXWL/IGEhd5+1YSlak"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GX1gp-0005Ku-Re
	for nfs@lists.sourceforge.net; Mon, 09 Oct 2006 13:25:31 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GX1gq-0006tn-Et
	for nfs@lists.sourceforge.net; Mon, 09 Oct 2006 13:25:32 -0700
To: Frank Filz <ffilzlnx@us.ibm.com>
In-Reply-To: <1160418641.3376.103.camel@dyn9047022153>
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


--=-pSLXWL/IGEhd5+1YSlak
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2006-10-09 at 11:30 -0700, Frank Filz wrote:
> I've had a chance to do some testing of this. It turns out that
> nfs_inode_remove_request() will set wb_page to NULL, so it looks like
> the call to dec_zone_page_state needs to be moved up before
> nfs_inode_remove_request(). I'm testing that right now, but I start to
> wonder exactly what the dec_zone_page_state is doing in this case, I
> know that was a recent addition.

Yup, that makes sense. Furthermore, it looks like the call to
nfs_clear_page_writeback is redundant, since nfs_inode_remove_request
will cause the tags to be implicitly cleared.

How does the attached patch work for you?

Cheers,
  Trond

--=-pSLXWL/IGEhd5+1YSlak
Content-Disposition: inline;
	filename=linux-2.6.19-002-fix_nfs_cancel_commit_list.dif
Content-Type: message/rfc822;
	name=linux-2.6.19-002-fix_nfs_cancel_commit_list.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Mon, 9 Oct 2006 16:18:19 -0400
Subject: NFS: Fix oops in nfs_cancel_commit_list
Message-Id: <1160425510.5466.45.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Fix two bugs:
 - nfs_inode_remove_request will call nfs_clear_request, so we cannot
   reference req->wb_page after it. Move the call to dec_zone_page_state so
   that it occurs while req->wb_page is still valid.
 - Calling nfs_clear_page_writeback is unnecessary since the radix tree
   tags will have been cleared by the call to nfs_inode_remove_request.
   Replace with a simple call to nfs_unlock_request.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f6675d2..d80fa8c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -588,10 +588,10 @@ static void nfs_cancel_commit_list(struc
 
 	while(!list_empty(head)) {
 		req = nfs_list_entry(head->next);
+		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		nfs_list_remove_request(req);
 		nfs_inode_remove_request(req);
-		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		nfs_clear_page_writeback(req);
+		nfs_unlock_request(req);
 	}
 }
 

--=-pSLXWL/IGEhd5+1YSlak
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-pSLXWL/IGEhd5+1YSlak
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-pSLXWL/IGEhd5+1YSlak--
