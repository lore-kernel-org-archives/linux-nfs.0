From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 7 - Create a mountpoint for the nfsd filesystem.
Date: Tue, 05 Aug 2003 13:59:23 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19jsyp-0000nP-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jsz0-0001hf-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 20:59:34 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 5 Aug 2003 13:59:28 +1000
To: Linus Torvalds <torvalds@osdl.org>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

Though the nfsd module can create this, having it always
there makes auto-loading-on-mount work better.

Note: it was previously recommended that the nfsd filesystem be mounted
on /proc/fs/nfs, which I was never comfortable with.
Henceforth the recommended location will be /proc/fs/nfsd.
nfs-utils 1.0.6 and later will support both.

 ----------- Diffstat output ------------
 ./fs/proc/root.c |    1 +
 1 files changed, 1 insertion(+)

diff ./fs/proc/root.c~current~ ./fs/proc/root.c
--- ./fs/proc/root.c~current~	2003-08-04 11:37:38.000000000 +1000
+++ ./fs/proc/root.c	2003-08-04 11:37:48.000000000 +1000
@@ -65,6 +65,7 @@ void __init proc_root_init(void)
 #endif
 	proc_root_fs = proc_mkdir("fs", 0);
 	proc_root_driver = proc_mkdir("driver", 0);
+	proc_mkdir("fs/nfsd", 0); /* somewhere for the nfsd filesystem to be mounted */
 #if defined(CONFIG_SUN_OPENPROMFS) || defined(CONFIG_SUN_OPENPROMFS_MODULE)
 	/* just give it a mountpoint */
 	proc_mkdir("openprom", 0);


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
