From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/23] umount.nfs: make _nfsumount() static
Date: Sat, 28 Jul 2007 17:49:59 -0400
Message-ID: <20070728214959.21871.24342.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAf-0007Rd-7Y
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:57 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAi-0003Cn-TR
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:50:01 -0700
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

_nfsumount() is never called outside of nfsumount.c.  Also give it a more
conventional name.

Note that it's return code is ignored.  That will be addressed in a
subsequent patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index db22c11..a6fec31 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -124,7 +124,7 @@ static int del_mtab(const char *spec, const char *node)
 /*
  * Returns 1 if everything went well, else 0.
  */
-int _nfsumount(const char *spec, char *opts)
+static int do_nfs_umount(const char *spec, char *opts)
 {
 	char *hostname;
 	char *dirname;
@@ -312,11 +312,11 @@ int nfsumount(int argc, char *argv[])
 	ret = 0;
 	if (mc) {
 		if (!lazy)
-			_nfsumount(mc->m.mnt_fsname, mc->m.mnt_opts);
+			do_nfs_umount(mc->m.mnt_fsname, mc->m.mnt_opts);
 		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
 	} else if (*spec != '/') {
 		if (!lazy)
-			_nfsumount(spec, "tcp,v3");
+			do_nfs_umount(spec, "tcp,v3");
 	} else
 		ret = del_mtab(NULL, spec);
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
