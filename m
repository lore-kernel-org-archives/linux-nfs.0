From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH][nfs-utils] configuration: Fix a typo in configure.ac
Date: Sat, 20 Feb 2010 15:45:10 -0800
Message-ID: <1266709510.3507.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "Mr. Steve Dickson" <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34657 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756955Ab0BTXpS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Feb 2010 18:45:18 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Fix a typo in commit 6d5ac3fa (nfsd: Disble NFS 4.1 functionality by default).

We did not really intend to make NFSv4.0 support conditional on NFSv4.1
being enabled.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 configure.ac |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/configure.ac b/configure.ac
index b7520d8..518b6d8 100644
--- a/configure.ac
+++ b/configure.ac
@@ -81,7 +81,7 @@ AC_ARG_ENABLE(nfsv41,
 	if test "$enable_nfsv41" = yes; then
 		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv41 support compiled in])
 	else
-		enable_nfsv4=
+		enable_nfsv41=
 	fi
 	AC_SUBST(enable_nfsv41)
 	AM_CONDITIONAL(CONFIG_NFSV41, [test "$enable_nfsv41" = "yes"])

