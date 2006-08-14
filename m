From: Wendy Cheng <wcheng@redhat.com>
Subject: [Reference PATCH 5/5] NLM failover - deadlock
Date: Mon, 14 Aug 2006 02:07:17 -0400
Message-ID: <1155535637.3416.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-mWvJ1rxdN3RLyHLQIDOP"
Cc: cluster-devel@redhat.com, lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCVQ4-0006p8-Vt
	for nfs@lists.sourceforge.net; Sun, 13 Aug 2006 22:55:25 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GCVQ4-00038L-B5
	for nfs@lists.sourceforge.net; Sun, 13 Aug 2006 22:55:25 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k7E5tNWZ022762
	for <nfs@lists.sourceforge.net>; Mon, 14 Aug 2006 01:55:23 -0400
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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


--=-mWvJ1rxdN3RLyHLQIDOP
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

There is an existing NLM deadlock bug that can be easily triggered by
patch 5-1 (but the bug exists with and without this patch set). We
include the temporary workaround here for reference purpose. The real
fix has been worked on:

http://sourceforge.net/mailarchive/forum.php?
thread_id=30052343&forum_id=4930





--=-mWvJ1rxdN3RLyHLQIDOP
Content-Disposition: attachment; filename=gfs_nlm_misc.patch
Content-Type: text/x-patch; name=gfs_nlm_misc.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-2/fs/lockd/svclock.c	2006-08-08 10:20:16.000000000 -0400
+++ linux/fs/lockd/svclock.c	2006-08-09 10:28:35.000000000 -0400
@@ -264,7 +264,9 @@ static void nlmsvc_free_block(struct kre
 
 	nlmsvc_freegrantargs(block->b_call);
 	nlm_release_call(block->b_call);
-	nlm_release_file(block->b_file);
+	down(&file->f_sema);
+	file->f_count--;
+	up(&file->f_sema);
 	kfree(block);
 }
 

--=-mWvJ1rxdN3RLyHLQIDOP
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--=-mWvJ1rxdN3RLyHLQIDOP
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-mWvJ1rxdN3RLyHLQIDOP--
