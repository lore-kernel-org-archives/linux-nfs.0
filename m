From: Juan Gomez  <gomez@cs.sjsu.edu>
Subject: PATCH(nfs-utils) Fix bug in statd notify mode
Date: Wed, 9 Oct 2002 15:50:07 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.05.10210091536420.17500-100000@eniac>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, juang@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailhub.cs.sjsu.edu ([130.65.86.58])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zPfa-0008Bd-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 15:51:10 -0700
To: neilb@cse.unsw.edu.au
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


Neil,

While further testing the statd mode I introduced previously (-N opt) I
found that
I forgot to skip pmap_unset() while in the notify mode.

If we do not do that a statd running in notify mode will disable
any other local statd running in the non-notify mode which is undesirable.

Would you please apply the current patch to the HEAD of the cvs repository
for nfs-utils?

Regards, Juan

diff -ur nfs-utils/utils/statd/statd.c nfs-utils-new/utils/statd/statd.c
--- nfs-utils/utils/statd/statd.c	Sun Sep  1 19:31:23 2002
+++ nfs-utils-new/utils/statd/statd.c	Wed Oct  9 22:28:26 2002
@@ -307,7 +307,14 @@
 	statd_get_socket(out_port);
 
 	for (;;) {
-		pmap_unset (SM_PROG, SM_VERS);
+                /* Do not do pmap_unset() when running in notify mode.
+                 * We may clear the portmapper record for a statd not
+                 * running in notify mode disabling it.
+                 * Juan C. Gomez j_carlos_gomez@yahoo.com
+                 */
+		if (!(run_mode & MODE_NOTIFY_ONLY)) {
+                        pmap_unset (SM_PROG, SM_VERS);
+                }
 		change_state ();
 		shuffle_dirs ();	/* Move directory names around */
 		notify_hosts ();	/* Send out notify requests */



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
