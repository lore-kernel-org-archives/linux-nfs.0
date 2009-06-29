From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 29/31] mount.nfs: Fix compiler warning in stropts.c
Date: Mon, 29 Jun 2009 13:39:31 -0400
Message-ID: <20090629173931.2076.16878.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51573 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756175AbZF2RkE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:04 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Address compiler warning:

    stropts.c: In function =E2=80=98nfs_append_generic_address_option=E2=
=80=99:
    stropts.c:138: warning: comparison between signed and unsigned

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index e277b3d..9d82bb1 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -130,12 +130,14 @@ static int nfs_append_generic_address_option(cons=
t struct sockaddr *sap,
 {
 	char address[NI_MAXHOST];
 	char new_option[512];
+	int len;
=20
 	if (!nfs_present_sockaddr(sap, salen, address, sizeof(address)))
 		goto out_err;
=20
-	if (snprintf(new_option, sizeof(new_option), "%s=3D%s",
-					keyword, address) >=3D sizeof(new_option))
+	len =3D snprintf(new_option, sizeof(new_option), "%s=3D%s",
+						keyword, address);
+	if (len < 0 || (size_t)len >=3D sizeof(new_option))
 		goto out_err;
=20
 	if (po_append(options, new_option) !=3D PO_SUCCEEDED)

