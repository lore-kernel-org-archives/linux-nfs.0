From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: [PATCH 4/4] Rename add_mtab2() to del_mtab()
Date: Wed, 14 Mar 2007 14:46:59 +0800
Message-ID: <45F79A63.7030609@nanjing-fnst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRNKv-0002Ka-Es
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 23:51:49 -0700
Received: from [221.6.14.228] (helo=proxy.fnst.com.cn)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HRNKw-0000IW-1l
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 23:51:51 -0700
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

add_mtab2 is used to remove an entry from mtab, rename it to del_mtab.

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- utils/mount/nfsumount.c.orig	2007-03-05 03:11:48.000000000 -0500
+++ utils/mount/nfsumount.c	2007-03-04 03:15:18.000000000 -0500
@@ -156,7 +156,7 @@
   }
 }
 
-int add_mtab2(const char *spec, const char *node, const char *type,
+int del_mtab(const char *spec, const char *node, const char *type,
 		const char *opts, struct mntentchn *mc)
 {
 	int umnt_err, umnt_err2, res;
@@ -378,13 +378,13 @@
 	if(mc) {
 		ret = _nfsumount(mc->m.mnt_fsname, mc->m.mnt_opts);
 		if(ret)
-			ret = add_mtab2(mc->m.mnt_fsname, mc->m.mnt_dir,
+			ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir,
 				mc->m.mnt_type, mc->m.mnt_opts, mc);
 	}
 	else {
 		ret = _nfsumount(spec, NULL);
 		if(ret)
-			ret = add_mtab2(spec, spec, spec, spec, NULL);
+			ret = del_mtab(spec, spec, spec, spec, NULL);
 	}
 
 	return(ret);




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
