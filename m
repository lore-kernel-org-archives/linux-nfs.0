Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:45107 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaHVTLR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2014 15:11:17 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so158227igb.8
        for <linux-nfs@vger.kernel.org>; Fri, 22 Aug 2014 12:11:17 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] nfsd: Assert SEQ4_STATUS_CB_PATH_DOWN_SESSION
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Fri, 22 Aug 2014 15:11:16 -0400
Message-ID: <20140822191116.3883.65056.stgit@klimt.1015granger.net>
In-Reply-To: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
References: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS server should assert both CB_PATH_DOWN and CB_PATH_DOWN_SESSION
when there is no backchannel.

RFC 5661 section 18.46.3:

   SEQ4_STATUS_CB_PATH_DOWN
      When set, indicates that the client has no operational backchannel
      path for any session associated with the client ID, making it
      necessary for the client to re-establish one.  This bit remains
      set on all SEQUENCE responses on all sessions associated with the
      client ID until at least one backchannel is available on any
      session associated with the client ID.


   SEQ4_STATUS_CB_PATH_DOWN_SESSION
      When set, indicates that the session has no operational
      backchannel. . .
                . . . The SEQ4_STATUS_CB_PATH_DOWN_SESSION bit is the
      indication to the client that it needs to associate a connection
      to the session’s backchannel.  This bit remains set on all
      SEQUENCE responses of the session until a connection is associated
      with the session’s a backchannel.

The Linux server doesn't currently make a distinction between these
cases, so both flags should be asserted unconditionally.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfs4state.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d7cfd8b..ea50ac0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2805,7 +2805,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 out:
 	switch (clp->cl_cb_state) {
 	case NFSD4_CB_DOWN:
-		seq->status_flags = SEQ4_STATUS_CB_PATH_DOWN;
+		seq->status_flags = SEQ4_STATUS_CB_PATH_DOWN |
+				    SEQ4_STATUS_CB_PATH_DOWN_SESSION;
 		break;
 	case NFSD4_CB_FAULT:
 		seq->status_flags = SEQ4_STATUS_BACKCHANNEL_FAULT;

