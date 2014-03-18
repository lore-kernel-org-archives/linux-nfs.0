Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:45263 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757114AbaCRUDc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Mar 2014 16:03:32 -0400
Received: by mail-ie0-f175.google.com with SMTP id to1so7506180ieb.6
        for <linux-nfs@vger.kernel.org>; Tue, 18 Mar 2014 13:03:31 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Schedule recovery if nfs40_walk_client_list() is interrupted
Date: Tue, 18 Mar 2014 16:03:25 -0400
Message-Id: <1395173006-14871-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a timeout or a signal interrupts the NFSv4 trunking discovery
SETCLIENTID_CONFIRM call, then we don't know whether or not the
server has changed the callback identifier on us.
Assume that it did, and schedule a 'path down' recovery...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4client.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 0e46d3d1b6cc..aa9ef4876046 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -531,6 +531,13 @@ int nfs40_walk_client_list(struct nfs_client *new,
 			*result = pos;
 			dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
 				__func__, pos, atomic_read(&pos->cl_count));
+			goto out;
+		case -ERESTARTSYS:
+		case -ETIMEDOUT:
+			/* The callback path may have been inadvertently
+			 * changed. Schedule recovery!
+			 */
+			nfs4_schedule_path_down_recovery(pos);
 		default:
 			goto out;
 		}
-- 
1.8.5.3

