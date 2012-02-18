Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60653 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab2BRIRF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Feb 2012 03:17:05 -0500
Received: by wgbdt10 with SMTP id dt10so3337209wgb.1
        for <linux-nfs@vger.kernel.org>; Sat, 18 Feb 2012 00:17:03 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfsd41: refactor nfs4_open_deleg_none_ext logic out of nfs4_open_delegation
Date: Sat, 18 Feb 2012 10:16:57 +0200
Message-Id: <1329553017-2791-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <4F3F5B30.3000501@tonian.com>
References: <4F3F5B30.3000501@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a 4.1 client asks for a delegation and the server returns none
op_delegate_type is set to NFS4_OPEN_DELEGATE_NONE_EXT
and op_why_no_deleg is set to either WND4_CONTENTION or WND4_RESOURCE.
Or, if the client sent a NFS4_SHARE_WANT_CANCEL (which it is not supposed
to ever do until our server supports delegations signaling),
op_why_no_deleg is set to WND4_CANCELLED.

Note that for WND4_CONTENTION and WND4_RESOURCE, the xdr layer is hard coded
at this time to encode boolean FALSE for ond_server_will_push_deleg /
ond_server_will_signal_avail.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4state.c |   43 ++++++++++++++++++++++++-------------------
 1 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ad21b06..94daab4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2853,6 +2853,27 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
 	return 0;
 }
 
+static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
+{
+	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+	if (status == -EAGAIN)
+		open->op_why_no_deleg = WND4_CONTENTION;
+	else {
+		open->op_why_no_deleg = WND4_RESOURCE;
+		switch (open->op_deleg_want) {
+		case NFS4_SHARE_WANT_READ_DELEG:
+		case NFS4_SHARE_WANT_WRITE_DELEG:
+		case NFS4_SHARE_WANT_ANY_DELEG:
+			break;
+		case NFS4_SHARE_WANT_CANCEL:
+			open->op_why_no_deleg = WND4_CANCELLED;
+			break;
+		case NFS4_SHARE_WANT_NO_DELEG:
+			BUG();	/* not supposed to get here */
+		}
+	}
+}
+
 /*
  * Attempt to hand out a delegation.
  */
@@ -2909,25 +2930,9 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
 		    open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
 			dprintk("NFSD: WARNING: refusing delegation reclaim\n");
 
-		if (open->op_deleg_want) {
-			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
-			if (status == -EAGAIN)
-				open->op_why_no_deleg = WND4_CONTENTION;
-			else {
-				open->op_why_no_deleg = WND4_RESOURCE;
-				switch (open->op_deleg_want) {
-				case NFS4_SHARE_WANT_READ_DELEG:
-				case NFS4_SHARE_WANT_WRITE_DELEG:
-				case NFS4_SHARE_WANT_ANY_DELEG:
-					break;
-				case NFS4_SHARE_WANT_CANCEL:
-					open->op_why_no_deleg = WND4_CANCELLED;
-					break;
-				case NFS4_SHARE_WANT_NO_DELEG:
-					BUG();	/* not supposed to get here */
-				}
-			}
-		}
+		/* 4.1 client asking for a delegation? */
+		if (open->op_deleg_want)
+			nfsd4_open_deleg_none_ext(open, status);
 	}
 	return;
 out_free:
-- 
1.7.6.5

