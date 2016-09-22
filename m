Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35705 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965911AbcIVRkH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:40:07 -0400
Received: by mail-it0-f67.google.com with SMTP id e20so5326537itc.2
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:40:06 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 25/31] NFSv4: nfs4_do_handle_exception() handle revoke/expiry of a single stateid
Date: Thu, 22 Sep 2016 13:39:15 -0400
Message-Id: <1474565961-21303-26-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-25-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-15-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-16-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-17-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-18-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-19-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-20-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-21-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-22-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-23-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-24-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-25-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're not yet sure that all state has expired or been revoked, we
should try to do a minimal recovery on just the one stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 338684195e95..552bea2af811 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -397,13 +397,23 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
 	exception->delay = 0;
 	exception->recovering = 0;
 	exception->retry = 0;
+
+	if (stateid == NULL && state != NULL)
+		stateid = &state->stateid;
+
 	switch(errorcode) {
 		case 0:
 			return 0;
-		case -NFS4ERR_OPENMODE:
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_EXPIRED:
 		case -NFS4ERR_BAD_STATEID:
+			if (inode != NULL && stateid != NULL) {
+				nfs_inode_find_state_and_recover(inode,
+						stateid);
+				goto wait_on_recovery;
+			}
+		case -NFS4ERR_OPENMODE:
 			if (inode) {
 				int err;
 
@@ -422,12 +432,6 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
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

