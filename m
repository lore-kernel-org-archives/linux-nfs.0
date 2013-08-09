Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f181.google.com ([209.85.213.181]:54624 "EHLO
	mail-ye0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968214Ab3HIQvh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:51:37 -0400
Received: by mail-ye0-f181.google.com with SMTP id q2so1315525yen.12
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:51:36 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id f67sm20693750yhh.9.2013.08.09.09.51.35
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:51:36 -0700 (PDT)
Subject: [PATCH v2 26/33] NFS: Rename "stateid_invalid" label
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:51:34 -0400
Message-ID: <20130809165134.5362.92998.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm going to use this exit label also for migration recovery
failures.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4cc5181..93eeac3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4653,12 +4653,12 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			if (state == NULL)
 				break;
 			if (nfs4_schedule_stateid_recovery(server, state) < 0)
-				goto stateid_invalid;
+				goto recovery_failed;
 			goto wait_on_recovery;
 		case -NFS4ERR_EXPIRED:
 			if (state != NULL) {
 				if (nfs4_schedule_stateid_recovery(server, state) < 0)
-					goto stateid_invalid;
+					goto recovery_failed;
 			}
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_STALE_CLIENTID:
@@ -4687,7 +4687,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	}
 	task->tk_status = nfs4_map_errors(task->tk_status);
 	return 0;
-stateid_invalid:
+recovery_failed:
 	task->tk_status = -EIO;
 	return 0;
 wait_on_recovery:

