From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 9] knfsd: knfsd: Add some missing newlines in
	printks
Date: Tue, 25 Jul 2006 11:54:27 +1000
Message-ID: <1060725015427.21909@suse.de>
References: <20060725114207.21779.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5C8b-0004a9-AE
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:09 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5C8a-0003xa-88
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:09 -0700
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


From: Greg Banks <gnb@melbourne.sgi.com>

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c       |    2 +-
 ./fs/nfsd/nfs4callback.c |    2 +-
 ./fs/nfsd/nfs4proc.c     |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2006-07-24 14:33:06.000000000 +1000
+++ ./fs/nfsd/export.c	2006-07-24 14:33:06.000000000 +1000
@@ -370,7 +370,7 @@ static int check_export(struct inode *in
 	 */
 	if (!(inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV) &&
 	    !(flags & NFSEXP_FSID)) {
-		dprintk("exp_export: export of non-dev fs without fsid");
+		dprintk("exp_export: export of non-dev fs without fsid\n");
 		return -EINVAL;
 	}
 	if (!inode->i_sb->s_export_op) {

diff .prev/fs/nfsd/nfs4callback.c ./fs/nfsd/nfs4callback.c
--- .prev/fs/nfsd/nfs4callback.c	2006-07-24 14:33:06.000000000 +1000
+++ ./fs/nfsd/nfs4callback.c	2006-07-24 14:33:06.000000000 +1000
@@ -131,7 +131,7 @@ xdr_error:                              
 #define READ_BUF(nbytes)  do { \
 	p = xdr_inline_decode(xdr, nbytes); \
 	if (!p) { \
-		dprintk("NFSD: %s: reply buffer overflowed in line %d.", \
+		dprintk("NFSD: %s: reply buffer overflowed in line %d.\n", \
 			__FUNCTION__, __LINE__); \
 		return -EIO; \
 	} \

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2006-07-24 14:33:06.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2006-07-24 14:33:06.000000000 +1000
@@ -600,7 +600,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 			&setattr->sa_stateid, CHECK_FH | WR_STATE, NULL);
 		nfs4_unlock_state();
 		if (status) {
-			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!");
+			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			return status;
 		}
 	}

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
