From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: [PATCH] knfsd : Fix the BUG of exp_get_by_name when used to
 get an export entry which not be exported
Date: Thu, 08 Mar 2007 15:09:25 +0800
Message-ID: <45EFB6A5.4080200@nanjing-fnst.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1314901529=="
Cc: NeilBrown <neilb@suse.de>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPCpM-00068m-Ra
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 23:14:17 -0800
Received: from [221.6.14.228] (helo=proxy.fnst.com.cn)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HPCpN-0005Y9-E3
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 23:14:19 -0800
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

--===============1314901529==
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit

If exp_get_by_name() is used to get an export entry which not be
exported, and if export entry is added by exportfs command but not
export by kernel because of EINVAL etc., this function will add a bad
entry to svc_export_cache after call svc_export_lookup(), this let
request be revisit.

Normally, if I export /dev/null as root, mount ntf4 command will frozen.
Test by following command:
#exportfs -i -o fsid=0,no_root_squash,insecure,rw,async *:/dev/null
#mount -t nfs4 127.0.0.1:/ /tmp
mount from other client also frozen, and some client may get kernel panic.

Flollowing is my patch:

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- fs/nfsd/export.c.orig	2007-02-20 20:59:22.000000000 -0500
+++ fs/nfsd/export.c	2007-03-08 00:53:22.000000000 -0500
@@ -786,6 +786,13 @@ exp_get_by_name(svc_client *clp, struct 
 	key.ex_dentry = dentry;
 
 	exp = svc_export_lookup(&key);
+
+	/* does not known flags, so do check after lookup */
+	if(exp != NULL && check_export(exp->ex_dentry->d_inode, exp->ex_flags)) {
+		exp_put(exp);
+		exp = NULL;
+	}
+
 	if (exp != NULL)  {
 		int err;
 




--===============1314901529==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1314901529==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1314901529==--
