From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] PNFS: filelayout_commit corrupts RPC all_tasks
Date: Wed, 05 Sep 2007 13:03:18 -0500
Message-ID: <1189015398.22424.54.camel@trinity.ogc.int>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISzF3-0001qB-KM
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 11:04:41 -0700
Received: from ms-smtp-06.texas.rr.com ([24.93.47.45])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ISzF5-0001CR-UT
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 11:04:46 -0700
Received: from trinity.ogc.int (smtp.opengridcomputing.com [71.42.183.126])
	by ms-smtp-06.texas.rr.com (8.13.6/8.13.6) with ESMTP id l85I4b9P014636
	for <nfs@lists.sourceforge.net>; Wed, 5 Sep 2007 13:04:37 -0500 (CDT)
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


The filelayout_commit function incorrectly releases the nfs_write_data 
pointed to by 'data'. Basically, the task contained in the nfs_write_data 
structure has already been initialized (rpc_init_task) up in the generic NFS
commit logic. Calling nfs4_commit_free frees the memory, but doesn't remove 
the task from the RPC all_tasks list. With debug turned on, the task list 
is corrupted immediately by poison_obj; without debug, a freed task is 
sitting on the all_tasks list and will eventually be corrupted when the 
memory is reused.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfs/nfs4filelayout.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 86ced63..1a32925 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -583,7 +583,7 @@ filelayout_commit(struct pnfs_layout_typ
 	}
 
 	/* Release original commit data since it is not used */
-	nfs4_commit_free(data);
+	rpc_release_task(&data->task);
 	return 0;
 
 out_bad:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
