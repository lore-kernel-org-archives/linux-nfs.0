Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.bugwerft.de ([212.112.241.193]:35459 "EHLO
	mail.bugwerft.de" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752215Ab1EPOi2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 10:38:28 -0400
From: Daniel Mack <zonque@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Daniel Mack <zonque@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Subject: [PATCH 2/2] nfsd: make local functions static
Date: Mon, 16 May 2011 16:38:14 +0200
Message-Id: <1305556694-6513-2-git-send-email-zonque@gmail.com>
In-Reply-To: <1305556694-6513-1-git-send-email-zonque@gmail.com>
References: <1305556694-6513-1-git-send-email-zonque@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This also fixes a number of sparse warnings.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
---
 fs/nfsd/nfs3xdr.c   |    2 +-
 fs/nfsd/nfs4state.c |    4 ++--
 fs/nfsd/nfs4xdr.c   |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index ad48fac..08c6e36 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -842,7 +842,7 @@ out:
 	return rv;
 }
 
-__be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name, int namlen)
+static __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name, int namlen)
 {
 	struct svc_fh	fh;
 	int err;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4cf04e1..35f559b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2462,7 +2462,7 @@ find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
 	return NULL;
 }
 
-int share_access_to_flags(u32 share_access)
+static int share_access_to_flags(u32 share_access)
 {
 	share_access &= ~NFS4_SHARE_WANT_MASK;
 
@@ -2882,7 +2882,7 @@ out:
 	return status;
 }
 
-struct lock_manager nfsd4_manager = {
+static struct lock_manager nfsd4_manager = {
 };
 
 static void
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c6766af..125b276 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3120,7 +3120,7 @@ nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
 	return nfserr;
 }
 
-__be32
+static __be32
 nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 		      struct nfsd4_sequence *seq)
 {
-- 
1.7.5.1

