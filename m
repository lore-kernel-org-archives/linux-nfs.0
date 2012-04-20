Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28266 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119Ab2DTTWC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 15:22:02 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS4: fix referrals with IPv6 mounts
Date: Fri, 20 Apr 2012 15:21:45 -0400
Message-Id: <1334949705-33393-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_path() was parsing the path component by splitting on the first colon.
This is wrong when an IPv6 address is used to mount a server.

For example, having mounted 'fc00::10:/export', nfs4_path() returned
':10:/export'.  This causes referrals (using IPv4 or IPv6 addresses) to fail
in nfs4_validate_fspath().

Parsing the path component by using the *last* colon works with
IPv6 as well as IPv4 addrs.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4namespace.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 9c8eca3..dd3dd30 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -59,7 +59,7 @@ static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t buflen)
 	char *limit;
 	char *path = nfs_path(&limit, dentry, buffer, buflen);
 	if (!IS_ERR(path)) {
-		char *colon = strchr(path, ':');
+		char *colon = strrchr(path, ':');
 		if (colon && colon < limit)
 			path = colon + 1;
 	}
-- 
1.7.4.4

