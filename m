From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH] Fix lockd oops caused by f_count
Date: Wed, 18 Apr 2007 11:09:53 -0400
Message-ID: <1176908994.8837.11.camel@wendyc-t.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeC70-0002Ed-H6
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 08:30:26 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeC71-0002FJ-Oe
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 08:30:29 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3IFUK4x026066
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 11:30:20 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3IFUKO5002971
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 11:30:20 -0400
Received: from [172.16.59.29] (wendyc-t.rdu.redhat.com [172.16.59.29])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3IFUJjn012120
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 11:30:20 -0400
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

Code segment breaks out of the original NLM failover patch set since it
is a bug fix for current lockd (server) code. 

When posix locks are still held by NLM clients, lockd server side could
oops if nlm_traverse_files() is invoked. The code falsely relies on
f_count to identify whether the file lock is in-use. The f_count can be
zero as soon as NLM server RPC call is returned while client is having
the lock.

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>

 svcsubs.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- gfs2-nmw/fs/lockd/svcsubs.c	2007-04-10 11:59:09.000000000 -0400
+++ linux/fs/lockd/svcsubs.c	2007-04-18 10:01:23.000000000 -0400
@@ -250,8 +250,7 @@ nlm_traverse_files(struct nlm_host *host
 			mutex_lock(&nlm_file_mutex);
 			file->f_count--;
 			/* No more references to this file. Let go of it. */
-			if (list_empty(&file->f_blocks) && !file->f_locks
-			 && !file->f_shares && !file->f_count) {
+			if (!nlm_file_inuse(file)) {
 				hlist_del(&file->f_list);
 				nlmsvc_ops->fclose(file->f_file);
 				kfree(file);



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
