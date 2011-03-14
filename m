Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:50788 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092Ab1CNM4y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 08:56:54 -0400
Received: by mail-iw0-f174.google.com with SMTP id 34so4886177iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2011 05:56:54 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/12] NFS: Add NFS4CLNT_UPDATE_CLIENTID
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Mar 2011 08:56:52 -0400
Message-ID: <20110314125652.2413.10405.stgit@matisse.1015granger.net>
In-Reply-To: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
References: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Introduce a mechanism for updating our client's callback endpoint
information on a server when handling NFS4ERR_CB_PATH_DOWN or during
migration recovery.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4_fs.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 7a74740..e266e2d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -47,6 +47,7 @@ enum nfs4_client_state {
 	NFS4CLNT_LAYOUTRECALL,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
+	NFS4CLNT_UPDATE_CLIENTID,
 };
 
 enum nfs4_session_state {

