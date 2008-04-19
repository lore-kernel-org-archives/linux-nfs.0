From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/33] NFSv4: Remove bogus call to nfs4_drop_state_owner()
	in _nfs4_open_expired()
Date: Sat, 19 Apr 2008 16:40:49 -0400
Message-ID: <20080419204049.14124.78865.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53673 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757091AbYDSUug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:36 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoXD9026109
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:36 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There should be no need to invalidate a perfectly good state owner just
because of a stale filehandle. Doing so can cause the state recovery code
to break, since nfs4_get_renew_cred() and nfs4_get_setclientid_cred() rely
on finding active state owners.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f38d057..424aa20 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -982,11 +982,8 @@ static int _nfs4_open_expired(struct nfs_open_context *ctx, struct nfs4_state *s
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
 	ret = nfs4_open_recover(opendata, state);
-	if (ret == -ESTALE) {
-		/* Invalidate the state owner so we don't ever use it again */
-		nfs4_drop_state_owner(state->owner);
+	if (ret == -ESTALE)
 		d_drop(ctx->path.dentry);
-	}
 	nfs4_opendata_put(opendata);
 	return ret;
 }

