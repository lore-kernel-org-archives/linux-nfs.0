From: Jeff Layton <jlayton@redhat.com>
Subject: CVE-2006-5158 -- is a NULL nfs_lockowner->owner field legal?
Date: Wed, 17 Jan 2007 11:39:59 -0500
Message-ID: <200701171639.l0HGdxwg025600@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: staubach@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7Dpy-0008Jg-OA
	for nfs@lists.sourceforge.net; Wed, 17 Jan 2007 08:40:34 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H7Dpo-0007gz-N5
	for nfs@lists.sourceforge.net; Wed, 17 Jan 2007 08:40:36 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	l0HGe16s011068
	for <nfs@lists.sourceforge.net>; Wed, 17 Jan 2007 11:40:01 -0500
To: nfs@lists.sourceforge.net
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

I've been looking over an issue that related to CVE-2006-5158 (which is a
NULL pointer dereference in nlmclnt_mark_reclaim). It looks like the only
way it's possible to get in this situation is when the kmalloc in
nlm_find_lockowner returns NULL. If this occurs, it seems like that should
be an error condition and we should abort whatever operation is occurring.

So my question is -- should a NULL "owner" field in an nfs_lockowner struct
even be considered legal? If not, would something like the patch below be
reasonable?

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 0b4acc1..aa52990 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -179,6 +179,11 @@ nlmclnt_proc(struct inode *inode, int cmd, struct file_lock *fl)
 		return -ENOMEM;
 
 	nlmclnt_locks_init_private(fl, host);
+	if (fl->fl_u.nfs_fl.owner == NULL) {
+		nlm_release_call(call);
+		return -ENOMEM;
+	}
+
 	/* Set up the argument struct */
 	nlmclnt_setlockargs(call, fl);
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
