Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759763Ab3EOSvw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 14:51:52 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r4FIpp9E011108
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 15 May 2013 14:51:51 -0400
From: Steve Dickson <steved@redhat.com>
To: Bruce Fields <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD: Don't give out read delegations on exclusive creates
Date: Wed, 15 May 2013 14:51:49 -0400
Message-Id: <1368643909-8059-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When an exclusive create is done with the mode bits
set (aka open(testfile, O_CREAT | O_EXCL, 0777)) this
causes a OPEN op followed by a SETATTR op. When a
read delegation is given in the OPEN, it causes
the SETATTR to delay with EAGAIN until the
delegation is recalled.

This patch caused exclusive creates to give out
a write delegation (which turn into no delegation)
which allows the SETATTR seamlessly succeed.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfsd/nfs4state.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 316ec84..6b45d0e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3035,8 +3035,16 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 				goto out;
 			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
 				flag = NFS4_OPEN_DELEGATE_WRITE;
-			else
-				flag = NFS4_OPEN_DELEGATE_READ;
+			else {
+				switch(open->op_createmode) {
+				case NFS4_CREATE_EXCLUSIVE:
+				case NFS4_CREATE_EXCLUSIVE4_1:
+					flag = NFS4_OPEN_DELEGATE_WRITE;
+					break;
+				default:
+					flag = NFS4_OPEN_DELEGATE_READ;
+				}
+			}
 			break;
 		default:
 			goto out;
-- 
1.8.1.4

