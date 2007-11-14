From: Joe Perches <joe@perches.com>
Subject: [PATCH] - [7/15] - remove defconfig ptr comparisons to 0 -
	fs/lockd
Date: Tue, 13 Nov 2007 18:05:18 -0800
Message-ID: <1195005918.5163.93.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is7dS-0003vY-Sc
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 18:05:47 -0800
Received: from dsl022.labridge.com ([206.117.136.22] helo=perches.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is7dY-0004HK-A3
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 18:05:52 -0800
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

Remove defconfig ptr comparison to 0

Remove sparse warning: Using plain integer as NULL pointer

Signed-off-by: Joe Perches <joe@perches.com>

---

diff --git a/fs/lockd/svcshare.c b/fs/lockd/svcshare.c
index 068886d..98548ad 100644
--- a/fs/lockd/svcshare.c
+++ b/fs/lockd/svcshare.c
@@ -71,7 +71,7 @@ nlmsvc_unshare_file(struct nlm_host *host, struct nlm_file *file,
 	struct nlm_share	*share, **shpp;
 	struct xdr_netobj	*oh = &argp->lock.oh;
 
-	for (shpp = &file->f_shares; (share = *shpp) != 0; shpp = &share->s_next) {
+	for (shpp = &file->f_shares; (share = *shpp); shpp = &share->s_next) {
 		if (share->s_host == host && nlm_cmp_owner(share, oh)) {
 			*shpp = share->s_next;
 			kfree(share);



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
