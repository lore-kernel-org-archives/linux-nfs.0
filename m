Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53967 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbbF2E3B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Jun 2015 00:29:01 -0400
Date: Mon, 29 Jun 2015 14:28:54 +1000
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSv4: When returning a delegation, don't reclaim an
 incompatible open mode.
Message-ID: <20150629142854.11e14bb6@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


It is possible to have an active open with one mode, and a delegation
for the same file with a different mode.
In particular, a WR_ONLY open and an RD_ONLY delegation.
This happens if a WR_ONLY open is followed by a RD_ONLY open which
provides a delegation, but is then close.

When returning the delegation, we currently try to claim opens for
every open type (n_rdwr, n_rdonly, n_wronly).  As there is no harm
in claiming an open for a mode that we already have, this is often
simplest.

However if the delegation only provides a subset of the modes that we
currently have open, this will produce an error from the server.

So when claiming open modes prior to returning a delegation, skip the
open request if the mode is not covered by the delegation - the open_stateid
must already cover that mode, so there is nothing to do.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 55e1e3af23a3..c9b7ce0c5698 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1553,6 +1553,13 @@ static int nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmod
 	struct nfs4_state *newstate;
 	int ret;
 
+	if ((opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR ||
+	     opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEG_CUR_FH) &&
+	    (opendata->o_arg.u.delegation_type & fmode) != fmode)
+		/* This mode can't have been delegated, so we must have
+		 * a valid open_stateid to cover it - not need to reclaim.
+		 */
+		return 0;
 	opendata->o_arg.open_flags = 0;
 	opendata->o_arg.fmode = fmode;
 	opendata->o_arg.share_access = nfs4_map_atomic_open_share(
