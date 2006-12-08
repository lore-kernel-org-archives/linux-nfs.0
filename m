From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 18] knfsd: nfsd: make exp_rootfh handle
	exp_parent errors
Date: Fri, 8 Dec 2006 12:13:41 +1100
Message-ID: <1061208011341.30603@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUIt-00037M-3H
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:31 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUIs-0004rl-WC
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:32 -0800
To: Andrew Morton <akpm@osdl.org>
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


From: J.Bruce Fields <bfields@fieldses.org>

Since exp_parent can fail by returning an error (-EAGAIN) in addition 
to by returning NULL, we should check for that case in exp_rootfh.

(TODO: we should check that userland handles these errors too.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c |    4 ++++
 1 file changed, 4 insertions(+)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2006-12-08 12:07:28.000000000 +1100
+++ ./fs/nfsd/export.c	2006-12-08 12:08:20.000000000 +1100
@@ -1104,6 +1104,10 @@ exp_rootfh(svc_client *clp, char *path, 
 		 path, nd.dentry, clp->name,
 		 inode->i_sb->s_id, inode->i_ino);
 	exp = exp_parent(clp, nd.mnt, nd.dentry, NULL);
+	if (IS_ERR(exp)) {
+		err = PTR_ERR(exp);
+		goto out;
+	}
 	if (!exp) {
 		dprintk("nfsd: exp_rootfh export not found.\n");
 		goto out;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
