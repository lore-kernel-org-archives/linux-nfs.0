Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28169 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755463Ab1KASSa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Nov 2011 14:18:30 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFSD: Remove unnecessary whitespace
Date: Tue,  1 Nov 2011 14:18:28 -0400
Message-Id: <1320171508-14028-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The close parenthesis was hard to find with it spaced so far over.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfsd.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 46f97ba..7763670 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -345,7 +345,7 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
 
 /* These are the only attrs allowed in CREATE/OPEN/SETATTR. */
 #define NFSD_WRITEABLE_ATTRS_WORD0                                                          \
-(FATTR4_WORD0_SIZE              | FATTR4_WORD0_ACL                                         )
+(FATTR4_WORD0_SIZE              | FATTR4_WORD0_ACL)
 #define NFSD_WRITEABLE_ATTRS_WORD1                                                          \
 (FATTR4_WORD1_MODE              | FATTR4_WORD1_OWNER         | FATTR4_WORD1_OWNER_GROUP     \
  | FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
-- 
1.7.7

