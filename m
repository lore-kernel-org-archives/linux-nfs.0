Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35805 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756486AbcIQFNv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 01:13:51 -0400
Received: by mail-it0-f67.google.com with SMTP id e20so1839482itc.2
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 22:13:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v5 16/25] NFSv4: nfs4_do_handle_exception() handle revoke/expiry of a single stateid
Date: Sat, 17 Sep 2016 01:13:24 -0400
Message-Id: <1474089213-104014-17-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474089213-104014-16-git-send-email-trond.myklebust@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-2-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-3-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-4-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-5-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-6-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-7-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-8-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-9-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-10-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-11-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-12-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-13-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-14-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-15-git-send-email-trond.myklebust@primarydata.com>
 <1474089213-104014-16-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're not yet sure that all state has expired or been revoked, we
should try to do a minimal recovery on just the one stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f79d4f55d83f..84ee836a976c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -400,10 +400,16 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
 	switch(errorcode) {
 		case 0:
 			return 0;
-		case -NFS4ERR_OPENMODE:
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_EXPIRED:
 		case -NFS4ERR_BAD_STATEID:
+			if (inode != NULL && stateid != NULL) {
+				nfs_inode_find_delegation_state_and_recover(inode,
+						stateid);
+				goto wait_on_recovery;
+			}
+		case -NFS4ERR_OPENMODE:
 			if (inode) {
 				int err;
 
@@ -422,12 +428,6 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
 			if (ret < 0)
 				break;
 			goto wait_on_recovery;
-		case -NFS4ERR_EXPIRED:
-			if (state != NULL) {
-				ret = nfs4_schedule_stateid_recovery(server, state);
-				if (ret < 0)
-					break;
-			}
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_STALE_CLIENTID:
 			nfs4_schedule_lease_recovery(clp);
-- 
2.7.4

