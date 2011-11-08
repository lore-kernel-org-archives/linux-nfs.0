Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:60565 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823Ab1KHDO4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 22:14:56 -0500
MIME-Version: 1.0
From: Hamo <hamo.by@gmail.com>
Date: Tue, 8 Nov 2011 11:14:36 +0800
Message-ID: <CAO_0yfP8XRH0+Gdn43QSncUFFPPmwbsxx2ZFdPpFTjKAQeuyAw@mail.gmail.com>
Subject: [PATCH] mount.nfs: ensure AF priority when mounting
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        steved@redhat.com, chuck.lever@oracle.com, jlayton@redhat.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On different architectures, getaddrinfo() may return different
orders of address families. This may confuse the users.
This patch fixes this problem by ensuring that we first try
through IPv6(if present), then through IPv4.
Bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=750729

Signed-off-by: Yang Bai <hamo.by@gmail.com>
---
 utils/mount/stropts.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 4032bf3..aa5ee86 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -654,7 +654,28 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
 	struct addrinfo *ai;
 	int ret = 0;

+	/* first, try IPv6 */
 	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
+		if (ai->ai_family != AF_INET6)
+			continue;
+		ret = nfs_do_mount_v3v2(mi, ai->ai_addr, ai->ai_addrlen);
+		if (ret != 0)
+			return ret;
+
+		switch (errno) {
+		case ECONNREFUSED:
+		case EOPNOTSUPP:
+		case EHOSTUNREACH:
+			continue;
+		default:
+			goto out;
+		}
+	}
+
+	/* then, try IPv4 */
+	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
+		if (ai->ai_family != AF_INET)
+			continue;
 		ret = nfs_do_mount_v3v2(mi, ai->ai_addr, ai->ai_addrlen);
 		if (ret != 0)
 			return ret;
@@ -742,7 +763,27 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 	struct addrinfo *ai;
 	int ret = 0;

+	/* first, try IPv6 */
 	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
+		if (ai->ai_family != AF_INET6)
+			continue;
+		ret = nfs_do_mount_v4(mi, ai->ai_addr, ai->ai_addrlen);
+		if (ret != 0)
+			return ret;
+
+		switch (errno) {
+		case ECONNREFUSED:
+		case EHOSTUNREACH:
+			continue;
+		default:
+			goto out;
+		}
+	}
+
+	/* then, try IPv4 */
+	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
+		if (ai->ai_family != AF_INET)
+			continue;
 		ret = nfs_do_mount_v4(mi, ai->ai_addr, ai->ai_addrlen);
 		if (ret != 0)
 			return ret;
-- 
1.7.1
