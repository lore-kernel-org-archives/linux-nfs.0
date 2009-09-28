From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [2.6.31] NFS4ERR_GRACE unhandled...
Date: Mon, 28 Sep 2009 14:16:40 -0400
Message-ID: <1254161800.3308.1.camel@heimdal.trondhjem.org>
References: <6278d2220909261114g2e1529dfn4961d450460b00dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8919 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbZI1SRV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 14:17:21 -0400
In-Reply-To: <6278d2220909261114g2e1529dfn4961d450460b00dc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-09-26 at 19:14 +0100, Daniel J Blueman wrote:
> Hi Trond,
> 
> After rebooting my 2.6.31 NFS4 server, I see a list of NFS kernel
> errors [1] on the 2.6.31 client corresponding to NFS4ERR_GRACE, so
> lock or file state recovery failed. Is this expected noting that I
> have an internal firewall allowing incoming TCP port 2049 on the
> server, and no firewall on the client, however I can't see how it can
> thus be callback related?

No. It looks as if your server rebooted while the client was recovering
an expired lease.

The following patch should prevent future occurrences of this bug...

Cheers
  Trond
------------------------------------------------------------------
NFSv4: Handle NFS4ERR_GRACE when recovering an expired lease.

From: Trond Myklebust <Trond.Myklebust@netapp.com>

If our lease expires, and the server subsequently reboot, we need to be
able to handle the case where the server refuses to let us recover state,
because it is in the grace period.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ed7c269..56182eb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1491,10 +1491,17 @@ static inline int nfs4_do_open_expired(struct nfs_open_context *ctx, struct nfs4
 
 	do {
 		err = _nfs4_open_expired(ctx, state);
-		if (err != -NFS4ERR_DELAY)
+		switch (err) {
+		case -NFS4ERR_FILE_OPEN:
+		case -NFS4ERR_GRACE:
+		case -NFS4ERR_DELAY:
+			nfs4_handle_exception(server, err, &exception);
 			break;
-		nfs4_handle_exception(server, err, &exception);
+		default:
+			goto out;
+		}
 	} while (exception.retry);
+out:
 	return err;
 }
 
@@ -4047,10 +4054,17 @@ static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
 			return 0;
 		err = _nfs4_do_setlk(state, F_SETLK, request, 0);
-		if (err != -NFS4ERR_DELAY)
+		switch (err) {
+		case -NFS4ERR_FILE_OPEN:
+		case -NFS4ERR_GRACE:
+		case -NFS4ERR_DELAY:
+			nfs4_handle_exception(server, err, &exception);
 			break;
-		nfs4_handle_exception(server, err, &exception);
+		default:
+			goto out;
+		}
 	} while (exception.retry);
+out:
 	return err;
 }
 


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
