Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([85.220.165.71]:43585 "EHLO
        metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752637AbeCUTwu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2018 15:52:50 -0400
From: Lucas Stach <l.stach@pengutronix.de>
To: "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, kernel@pengutronix.de,
        patchwork-lst@pengutronix.de
Subject: [PATCH] nfsd: zero out umask if the client didn't provide one
Date: Wed, 21 Mar 2018 20:52:42 +0100
Message-Id: <20180321195242.4250-1-l.stach@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the server is serving a mixed set of clients where some support the
NFS 4.2 umask attribute and some don't, we need to make sure to reset the
nfd thread umask to 0 when serving a client that isn't providing the umask,
otherwise a stale umask from a previous request will be applied.

This was only done in the nfsd4_decode_open() callsite, but not in
nfsd4_decode_create() leading to newly created directories ending up with
wrong permissions in some cases. To avoid any such inconsistency in the
future, reset the umask in nfsd4_decode_fattr() where we know if the
client did provide a umask.

Fixes: 47057abde515 (nfsd: add support for the umask attribute)
Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 fs/nfsd/nfs4xdr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e502fd16246b..1eb33b34c51b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -486,6 +486,8 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		dummy32 = be32_to_cpup(p++);
 		*umask = dummy32 & S_IRWXUGO;
 		iattr->ia_valid |= ATTR_MODE;
+	} else if (umask) {
+		*umask = 0;
 	}
 	if (len != expected_len)
 		goto xdr_error;
@@ -927,7 +929,6 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 	case NFS4_OPEN_NOCREATE:
 		break;
 	case NFS4_OPEN_CREATE:
-		current->fs->umask = 0;
 		READ_BUF(4);
 		open->op_createmode = be32_to_cpup(p++);
 		switch (open->op_createmode) {
-- 
2.16.1

