From: Neil Brown <neilb@suse.de>
Subject: [PATCH]  bug in old-cache handling in mountd.
Date: Fri, 29 May 2009 11:49:19 +1000
Message-ID: <18975.16159.264056.854413@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:52431 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbZE2Bs4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 May 2009 21:48:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,
 there is a bug in the old-cache behaviour of mountd.
 Hopefully no-one is using this but you never know....

 The bug was reported to redhat
    https://bugzilla.redhat.com/show_bug.cgi?id=164186

 It was fixed incorrectly and never (that I recall) reported
 upstream. :-(

 A SLES customer thinks they have hit the same problem, which is why
 I'm looking at it.  (They shouldn't really hit it because that
 version of sles uses 'new_cache' but maybe nfsdfs was disabled
 somehow - don't know yet).

 Anyway, when mountd gets a mount request, it tells the kernel about it
 and remembers that it told the kernel so it doesn't have to tell the
 kernel again.
 It is possible that "exportfs -r" will tell the kernel to forget that
 information if the client has since unmounted.
 So mountd really needs to tell the kernel even if it thinks the
 kernel should already know.

 The following patch does this if the kernel refuses to provide a
 valid filehandle.

 Does RHEL3 use old-cache or new-cache ??

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.de>
Subject: retry export if getfh fails.

mountd tries to avoid telling the kernel to export something
when the kernel already knows to do that.
However sometimes (exportfs -r) the kernel can be told
to forget something without mountd realising.
So if mountd finds that it cannot get a  valid filehandle,
make sure it really has been exported to the kernel.

This only applies if the nfsd filesystem is not mounted.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 25d292b..b59f939 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -467,8 +467,12 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 			return NULL;
 		}
 	} else {
-		if (exp->m_exported<1)
+		int did_export = 0;
+	retry:
+		if (exp->m_exported<1) {
 			export_export(exp);
+			did_export = 1;
+		}
 		if (!exp->m_xtabent)
 			xtab_append(exp);
 
@@ -482,6 +486,11 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 				fh = getfh_old ((struct sockaddr *) sin,
 						stb.st_dev, stb.st_ino);
 		}
+		if (fh == NULL && !did_export) {
+			exp->m_exported = 0;
+			goto retry;
+		}
+
 		if (fh == NULL) {
 			xlog(L_WARNING, "getfh failed: %s", strerror(errno));
 			*error = NFSERR_ACCES;
