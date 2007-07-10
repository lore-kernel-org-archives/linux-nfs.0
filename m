From: NeilBrown <neilb@suse.de>
Subject: [PATCH 020 of 20] knfsd: nfsd: enforce per-flavor id squashing
Date: Tue, 10 Jul 2007 12:28:22 +1000
Message-ID: <1070710022822.13650@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J . Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85Sj-0005Dw-FH
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:28:25 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85Sm-0004sx-8f
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:28:29 -0700
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


From: J. Bruce Fields <bfields@citi.umich.edu>

Allow root squashing to vary per-pseudoflavor, so that you can (for
example) allow root access only when sufficiently strong security is in
use.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/auth.c              |   18 ++++++++++++++++--
 ./include/linux/nfsd/export.h |    3 ++-
 2 files changed, 18 insertions(+), 3 deletions(-)

diff .prev/fs/nfsd/auth.c ./fs/nfsd/auth.c
--- .prev/fs/nfsd/auth.c	2007-07-10 12:18:33.000000000 +1000
+++ ./fs/nfsd/auth.c	2007-07-10 12:19:40.000000000 +1000
@@ -12,17 +12,31 @@
 
 #define	CAP_NFSD_MASK (CAP_FS_MASK|CAP_TO_MASK(CAP_SYS_RESOURCE))
 
+static int nfsexp_flags(struct svc_rqst *rqstp, struct svc_export *exp)
+{
+	struct exp_flavor_info *f;
+	struct exp_flavor_info *end = exp->ex_flavors + exp->ex_nflavors;
+
+	for (f = exp->ex_flavors; f < end; f++) {
+		if (f->pseudoflavor == rqstp->rq_flavor)
+			return f->flags;
+	}
+	return exp->ex_flags;
+
+}
+
 int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 {
 	struct svc_cred	cred = rqstp->rq_cred;
 	int i;
+	int flags = nfsexp_flags(rqstp, exp);
 	int ret;
 
-	if (exp->ex_flags & NFSEXP_ALLSQUASH) {
+	if (flags & NFSEXP_ALLSQUASH) {
 		cred.cr_uid = exp->ex_anon_uid;
 		cred.cr_gid = exp->ex_anon_gid;
 		cred.cr_group_info = groups_alloc(0);
-	} else if (exp->ex_flags & NFSEXP_ROOTSQUASH) {
+	} else if (flags & NFSEXP_ROOTSQUASH) {
 		struct group_info *gi;
 		if (!cred.cr_uid)
 			cred.cr_uid = exp->ex_anon_uid;

diff .prev/include/linux/nfsd/export.h ./include/linux/nfsd/export.h
--- .prev/include/linux/nfsd/export.h	2007-07-10 12:18:33.000000000 +1000
+++ ./include/linux/nfsd/export.h	2007-07-10 12:19:40.000000000 +1000
@@ -43,7 +43,8 @@
 #define NFSEXP_ALLFLAGS		0xFE3F
 
 /* The flags that may vary depending on security flavor: */
-#define NFSEXP_SECINFO_FLAGS	NFSEXP_READONLY
+#define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
+					| NFSEXP_ALLSQUASH)
 
 #ifdef __KERNEL__
 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
