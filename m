Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755212Ab2FFS1u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jun 2012 14:27:50 -0400
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Map minor mismatch error to protocol not support error.
Date: Wed,  6 Jun 2012 14:12:07 -0400
Message-Id: <1339006327-27815-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sservers that only have NFSv4.1 support the
NFS4ERR_MINOR_VERS_MISMATCH error is return on
v4.0 mounts. Mapping that error to EPROTONOSUPPORT
will cause the mount to back off to v3 instead of
failing.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/nfs4proc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d48dbef..eda028b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -105,6 +105,8 @@ static int nfs4_map_errors(int err)
 		return -EINVAL;
 	case -NFS4ERR_SHARE_DENIED:
 		return -EACCES;
+	case -NFS4ERR_MINOR_VERS_MISMATCH:
+		return -EPROTONOSUPPORT;
 	default:
 		dprintk("%s could not handle NFSv4 error %d\n",
 				__func__, -err);
-- 
1.7.1

