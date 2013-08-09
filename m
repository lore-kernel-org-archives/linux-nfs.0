Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f176.google.com ([209.85.213.176]:45130 "EHLO
	mail-ye0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968218Ab3HIQwW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:52:22 -0400
Received: by mail-ye0-f176.google.com with SMTP id q3so1302996yen.21
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:52:22 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id m64sm20682680yho.25.2013.08.09.09.52.21
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:52:21 -0700 (PDT)
Subject: [PATCH v2 30/33] NFS: Implement support for NFS4ERR_LEASE_MOVED
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:52:20 -0400
Message-ID: <20130809165220.5362.25921.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trigger lease-moved recovery when a request returns
NFS4ERR_LEASE_MOVED.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 36cd989..11283da 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -386,6 +386,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			if (ret < 0)
 				break;
 			goto wait_on_recovery;
+		case -NFS4ERR_LEASE_MOVED:
+			nfs4_schedule_lease_moved_recovery(clp);
+			goto wait_on_recovery;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
@@ -4686,6 +4689,9 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			if (nfs4_schedule_migration_recovery(server) < 0)
 				goto recovery_failed;
 			goto wait_on_recovery;
+		case -NFS4ERR_LEASE_MOVED:
+			nfs4_schedule_lease_moved_recovery(clp);
+			goto wait_on_recovery;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:

