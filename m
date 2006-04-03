From: NeilBrown <neilb@suse.de>
Subject: [PATCH 006 of 16] knfsd: nfsd: nfsd_setuser doesn't really need to modify rqstp->rq_cred.
Date: Mon, 3 Apr 2006 15:18:33 +1000
Message-ID: <1060403051833.1797@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQHUI-0005Tb-CG
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:26 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FQHUG-0008Jl-HR
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:26 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


In addition to setting the processes filesystem id's, nfsd_setuser also
modifies the value of the rq_cred which stores the id's that originally
came from the rpc call, for example to reflect root squashing.

There's no real reason to do that--the only case where rqstp->rq_cred 
is actually used later on is in the NFSv4 SETCLIENTID/SETCLIENTID_CONFIRM
operations, and there the results are the opposite of what we want--those
two operations don't deal with the filesystem at all, they only record the
credentials used with the rpc call for later reference (so that we may
require the same credentials be used on later operations), and the
credentials shouldn't vary just because there was or wasn't a previous
operation in the compound that referred to some export  

This fixes a bug which caused mounts from Solaris clients to fail.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/auth.c |   46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff ./fs/nfsd/auth.c~current~ ./fs/nfsd/auth.c
--- ./fs/nfsd/auth.c~current~	2006-04-03 15:12:09.000000000 +1000
+++ ./fs/nfsd/auth.c	2006-04-03 15:12:09.000000000 +1000
@@ -14,46 +14,46 @@
 
 int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 {
-	struct svc_cred	*cred = &rqstp->rq_cred;
+	struct svc_cred	cred = rqstp->rq_cred;
 	int i;
 	int ret;
 
 	if (exp->ex_flags & NFSEXP_ALLSQUASH) {
-		cred->cr_uid = exp->ex_anon_uid;
-		cred->cr_gid = exp->ex_anon_gid;
-		put_group_info(cred->cr_group_info);
-		cred->cr_group_info = groups_alloc(0);
+		cred.cr_uid = exp->ex_anon_uid;
+		cred.cr_gid = exp->ex_anon_gid;
+		cred.cr_group_info = groups_alloc(0);
 	} else if (exp->ex_flags & NFSEXP_ROOTSQUASH) {
 		struct group_info *gi;
-		if (!cred->cr_uid)
-			cred->cr_uid = exp->ex_anon_uid;
-		if (!cred->cr_gid)
-			cred->cr_gid = exp->ex_anon_gid;
-		gi = groups_alloc(cred->cr_group_info->ngroups);
+		if (!cred.cr_uid)
+			cred.cr_uid = exp->ex_anon_uid;
+		if (!cred.cr_gid)
+			cred.cr_gid = exp->ex_anon_gid;
+		gi = groups_alloc(cred.cr_group_info->ngroups);
 		if (gi)
-			for (i = 0; i < cred->cr_group_info->ngroups; i++) {
-				if (!GROUP_AT(cred->cr_group_info, i))
+			for (i = 0; i < cred.cr_group_info->ngroups; i++) {
+				if (!GROUP_AT(cred.cr_group_info, i))
 					GROUP_AT(gi, i) = exp->ex_anon_gid;
 				else
-					GROUP_AT(gi, i) = GROUP_AT(cred->cr_group_info, i);
+					GROUP_AT(gi, i) = GROUP_AT(cred.cr_group_info, i);
 			}
-		put_group_info(cred->cr_group_info);
-		cred->cr_group_info = gi;
-	}
+		cred.cr_group_info = gi;
+	} else
+		get_group_info(cred.cr_group_info);
 
-	if (cred->cr_uid != (uid_t) -1)
-		current->fsuid = cred->cr_uid;
+	if (cred.cr_uid != (uid_t) -1)
+		current->fsuid = cred.cr_uid;
 	else
 		current->fsuid = exp->ex_anon_uid;
-	if (cred->cr_gid != (gid_t) -1)
-		current->fsgid = cred->cr_gid;
+	if (cred.cr_gid != (gid_t) -1)
+		current->fsgid = cred.cr_gid;
 	else
 		current->fsgid = exp->ex_anon_gid;
 
-	if (!cred->cr_group_info)
+	if (!cred.cr_group_info)
 		return -ENOMEM;
-	ret = set_current_groups(cred->cr_group_info);
-	if ((cred->cr_uid)) {
+	ret = set_current_groups(cred.cr_group_info);
+	put_group_info(cred.cr_group_info);
+	if ((cred.cr_uid)) {
 		cap_t(current->cap_effective) &= ~CAP_NFSD_MASK;
 	} else {
 		cap_t(current->cap_effective) |= (CAP_NFSD_MASK &


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
