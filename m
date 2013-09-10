Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14399 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243Ab3IJS4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 14:56:09 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/2] NFSv4.1: sp4_mach_cred: ask for WRITE and COMMIT
Date: Tue, 10 Sep 2013 14:55:58 -0400
Message-ID: <1378839358-10389-3-git-send-email-dros@netapp.com>
In-Reply-To: <1378839358-10389-1-git-send-email-dros@netapp.com>
References: <1378839358-10389-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Request SP4_MACH_CRED WRITE and COMMIT support in spo_must_allow list --
they're already supported by the client.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ee0d1eb..10feb7b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6162,11 +6162,13 @@ static const struct nfs41_state_protection nfs4_sp4_mach_cred_request = {
 	},
 	.allow.u.words = {
 		[0] = 1 << (OP_CLOSE) |
-		      1 << (OP_LOCKU),
+		      1 << (OP_LOCKU) |
+		      1 << (OP_COMMIT),
 		[1] = 1 << (OP_SECINFO - 32) |
 		      1 << (OP_SECINFO_NO_NAME - 32) |
 		      1 << (OP_TEST_STATEID - 32) |
-		      1 << (OP_FREE_STATEID - 32)
+		      1 << (OP_FREE_STATEID - 32) |
+		      1 << (OP_WRITE - 32)
 	}
 };
 
-- 
1.7.12.4 (Apple Git-37)

