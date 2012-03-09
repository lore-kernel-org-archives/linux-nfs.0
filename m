Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759363Ab2CIUtr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 15:49:47 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q29KnkOS017319
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 15:49:47 -0500
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 1/1] Kill SPKM3: Remove also the dependent lipkey mechanism
Date: Fri,  9 Mar 2012 15:49:32 -0500
Message-Id: <1331326172-13296-2-git-send-email-simo@redhat.com>
In-Reply-To: <1331326172-13296-1-git-send-email-simo@redhat.com>
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
 <1331326172-13296-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 support/nfs/exports.c          |    3 ---
 utils/gssd/svcgssd_mech2file.c |    1 -
 utils/mount/nfs.man            |    7 ++-----
 utils/mount/nfsmount.c         |    6 ------
 4 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 6e7ed699dfda6863e1bb1c0ef7894d473232f834..84a2b08b1f3c69e1b9765e1e42a7aa90c9b3d082 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -39,9 +39,6 @@ struct flav_info flav_map[] = {
 	{ "krb5",	RPC_AUTH_GSS_KRB5	},
 	{ "krb5i",	RPC_AUTH_GSS_KRB5I	},
 	{ "krb5p",	RPC_AUTH_GSS_KRB5P	},
-	{ "lipkey",	RPC_AUTH_GSS_LKEY	},
-	{ "lipkey-i",	RPC_AUTH_GSS_LKEYI	},
-	{ "lipkey-p",	RPC_AUTH_GSS_LKEYP	},
 	{ "unix",	AUTH_UNIX		},
 	{ "sys",	AUTH_SYS		},
 	{ "null",	AUTH_NULL		},
diff --git a/utils/gssd/svcgssd_mech2file.c b/utils/gssd/svcgssd_mech2file.c
index a3177f6ff8ab7e0ee5eef7c830ce2c2042553c3c..ecd908bc24b827b9553f6394b5bab6213359a711 100644
--- a/utils/gssd/svcgssd_mech2file.c
+++ b/utils/gssd/svcgssd_mech2file.c
@@ -53,7 +53,6 @@ struct mech2file {
 
 struct mech2file m2f[] = {
 	{{9, "\052\206\110\206\367\022\001\002\002"}, "krb5"},
-	{{7, "\053\006\001\005\005\001\009"}, "lipkey"},
 	{{0,0},""},
 };
 
diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 810bfc075cb2629beedb8738f60e3f5fdf771f1e..0d20cf0d190665178c28b9efa45f22680397f73b 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -372,11 +372,8 @@ Valid security flavors are
 .BR sys ,
 .BR krb5 ,
 .BR krb5i ,
+and
 .BR krb5p ,
-.BR lkey ,
-.BR lkeyi ,
-and
-.BR lkeyp ,
 Refer to the SECURITY CONSIDERATIONS section for details.
 .TP 1.5i
 .BR sharecache " / " nosharecache
@@ -1413,7 +1410,7 @@ security flavor encrypts every RPC request
 to prevent data exposure during network transit; however,
 expect some performance impact
 when using integrity checking or encryption.
-Similar support for other forms of cryptographic security (such as lipkey)
+Similar support for other forms of cryptographic security
 is also available.
 .P
 The NFS version 4 protocol allows
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 7bd1c97b291eb585221452ba865036d25e7fa8ff..930622d94b57f6e4dd12497fb99277dc76580ecf 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -294,12 +294,6 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 					data->pseudoflavor = AUTH_GSS_KRB5I;
 				else if (!strcmp(secflavor, "krb5p"))
 					data->pseudoflavor = AUTH_GSS_KRB5P;
-				else if (!strcmp(secflavor, "lipkey"))
-					data->pseudoflavor = AUTH_GSS_LKEY;
-				else if (!strcmp(secflavor, "lipkey-i"))
-					data->pseudoflavor = AUTH_GSS_LKEYI;
-				else if (!strcmp(secflavor, "lipkey-p"))
-					data->pseudoflavor = AUTH_GSS_LKEYP;
 				else if (sloppy)
 					continue;
 				else {
-- 
1.7.7.6

