From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] knfsd : export : Fix bug of svc_export_parse()
Date: Tue, 20 Mar 2007 17:26:58 +0800
Message-ID: <45FFA8E2.5000902@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTahb-0000LF-1k
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 02:32:24 -0700
Received: from [222.73.24.84] (helo=song.cn.fujitsu.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTaha-0005Mt-G4
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 02:32:25 -0700
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

When I export /dev/null as root, and mount it from client, mount ntf4 command will frozen.

You can test it by following command:
#exportfs -i -o fsid=0,no_root_squash,insecure,rw,async *:/dev/null
#mount -t nfs4 127.0.0.1:/ /tmp

This is because in svc_export_parse() function, if check_export return 
false, after we reject the file handle, we must do cleanup the cache, 
which is not a format error of file handle.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- fs/nfsd/export.c.orig	2007-02-20 20:59:22.000000000 -0500
+++ fs/nfsd/export.c	2007-03-16 01:04:16.000000000 -0400
@@ -543,12 +543,13 @@ static int svc_export_parse(struct cache
 		if (err) goto out;
 		exp.ex_fsid = an_int;
 
-		err = check_export(nd.dentry->d_inode, exp.ex_flags);
-		if (err) goto out;
-
 		err = fsloc_parse(&mesg, buf, &exp.ex_fslocs);
 		if (err)
 			goto out;
+
+		err = check_export(nd.dentry->d_inode, exp.ex_flags);
+		if (err)
+			set_bit(CACHE_NEGATIVE, &exp.h.flags);
 	}
 
 	expp = svc_export_lookup(&exp);



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
