From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 24/24] Remove warnings from nfsctl.c
Date: Wed,  4 Aug 2010 11:12:20 -0400
Message-ID: <1280934740-11366-25-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:45178 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755484Ab0HDPvQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:51:16 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdo-0002SZ-To
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:25 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsctl.c: In function 'expsetup':
nfsctl.c:112: warning: signed and unsigned type in conditional expression

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/export/nfsctl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/export/nfsctl.c b/support/export/nfsctl.c
index 3b9876a..f89c644 100644
--- a/support/export/nfsctl.c
+++ b/support/export/nfsctl.c
@@ -109,7 +109,7 @@ expsetup(struct nfsctl_export *exparg, nfs_export *exp, int unexport)
 	str_tolower(exparg->ex_client);
 	exparg->ex_flags    = exp->m_export.e_flags;
 	exparg->ex_dev      = (!unexport && (exp->m_export.e_flags & NFSEXP_FSID)) ?
-				exp->m_export.e_fsid : stb.st_dev;
+			(__nfsd_dev_t)exp->m_export.e_fsid : stb.st_dev;
 	exparg->ex_ino      = stb.st_ino;
 	exparg->ex_anon_uid = exp->m_export.e_anonuid;
 	exparg->ex_anon_gid = exp->m_export.e_anongid;
-- 
1.7.2

