Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755984Ab2KZURM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:12 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qAQKHC49028644
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 15:17:12 -0500
Received: from smallhat.bos.devel.redhat.com (vpn-9-97.rdu.redhat.com [10.11.9.97])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id qAQKHBB1026413
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 15:17:11 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] mount.nfs: Continue to trying address when the server return ENOENT
Date: Mon, 26 Nov 2012 15:17:07 -0500
Message-Id: <1353961029-6317-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With recent changes to the /etc/hosts file, the 'localhost'
is now multiply defined as both an IPv4 address (127.0.01)
and an IPv6 address (::1). This change causes first address
returned by getaddrinfo('localhost') to be the IPv6 address
instead of the IPv4 address.

The change in the default 'localhost' address type causes
existing exports using '127.0.0.1' to fail, because the
'::1' address is tried first and fails. The problem
being not all the addresses that are returned by
getaddrinfo('localhost') are tried.

So this patch allows that address list to continue to be
process when the 'ENOENT' error is returned by the server.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 9b4197b..1119f39 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -666,6 +666,7 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
 		case EOPNOTSUPP:
 		case EHOSTUNREACH:
 		case ETIMEDOUT:
+		case ENOENT:
 			continue;
 		default:
 			goto out;
@@ -756,11 +757,11 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 		ret = nfs_do_mount_v4(mi, ai->ai_addr, ai->ai_addrlen);
 		if (ret != 0)
 			return ret;
-
 		switch (errno) {
 		case ECONNREFUSED:
 		case EHOSTUNREACH:
 		case ETIMEDOUT:
+		case ENOENT:
 			continue;
 		default:
 			goto out;
-- 
1.7.11.7

