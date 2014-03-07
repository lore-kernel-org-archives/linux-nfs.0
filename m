Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11373 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751744AbaCGPCt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2014 10:02:49 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSv4: Don't retry server trunking discovery on timeouts
Date: Fri,  7 Mar 2014 10:02:43 -0500
Message-Id: <1394204563-1166-2-git-send-email-steved@redhat.com>
In-Reply-To: <1394204563-1166-1-git-send-email-steved@redhat.com>
References: <1394204563-1166-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To allow background mounts to process into background,
server trunking discovery needs to return the -ETIMEDOUT
error to the mount command instead of endless retrying in
the kernel.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e1a4721..be4b33f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2085,6 +2085,7 @@ again:
 		break;
 	case -NFS4ERR_DELAY:
 	case -ETIMEDOUT:
+		break;
 	case -EAGAIN:
 		ssleep(1);
 	case -NFS4ERR_STALE_CLIENTID:
-- 
1.7.1

