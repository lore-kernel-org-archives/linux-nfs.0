Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932136Ab2K0RE6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 12:04:58 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qARH4wDK009270
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 27 Nov 2012 12:04:58 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id qARH4vVj031093
	for <linux-nfs@vger.kernel.org>; Tue, 27 Nov 2012 12:04:57 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2 V2] mount.nfs: Continue to trying address when the server return EACCES
Date: Tue, 27 Nov 2012 12:01:23 -0500
Message-Id: <1354035684-15802-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With recent changes to the /etc/hosts file, the 'localhost'
host name is now multiply defined as both an IPv4 address (127.0.01)
and an IPv6 address (::1). This causes first address returned
by getaddrinfo('localhost') to be the IPv6 address instead of
the IPv4 address.

The change in the default 'localhost' address type causes
existing exports using '127.0.0.1' to fail, because the
'::1' address is tried first and fails. The problem is
not all the addresses in the address list are being tried.

So this patch allows that address list to continue to be
process when a 'EACCES' error is returned by the server.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/stropts.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 9b4197b..8ee3024 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -666,6 +666,7 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
 		case EOPNOTSUPP:
 		case EHOSTUNREACH:
 		case ETIMEDOUT:
+		case EACCES:
 			continue;
 		default:
 			goto out;
@@ -761,6 +762,7 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 		case ECONNREFUSED:
 		case EHOSTUNREACH:
 		case ETIMEDOUT:
+		case EACCES:
 			continue;
 		default:
 			goto out;
-- 
1.7.11.7

