Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55411 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750916AbdHRHNr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 03:13:47 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Aug 2017 17:12:51 +1000
Subject: [PATCH 2/8] NFSv4: don't let hanging mounts block other mounts
Cc: linux-nfs@vger.kernel.org
Message-ID: <150304037188.30218.6679182255685764801.stgit@noble>
In-Reply-To: <150304014011.30218.1636255532744321171.stgit@noble>
References: <150304014011.30218.1636255532744321171.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If you try an NFSv4 mount from an inaccessible server, it will hang as
you would expect.
If you then try an NFSv4 mount from a different accessible server,
it will also hang.  This is not expected.

The second mount is blocked in
  nfs4_init_client()
  -> nfs4_discover_server_trunking()
  -> nfs40_discover_server_trunking()
  -> nfs40_walk_client_list()
  -> nfs4_match_client()
  -> nfs_wait_client_init_complete()
It is waiting for the first mount to complete so that it can then
see if the two servers are really one and the same.

It is not necessary to wait here when an nfs_client cl_cons_state is
NFS_CS_INITING.  Such a client will, after changing cl_cons_state, call
nfs4_discover_server_trunking() itself.  So if the current client just
skips those clients, trunking will still be discovered if necessary.

I am unsure of situation with NFS_CS_SESSION_INITING, but I suspect
that the comment "Wait for CREATE_SESSION to finish" implies that
it is only clients in NFS_CS_SESSION_INITING that need to be waited for.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/nfs4client.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index e9bea90dc017..d8b9b7ff19a9 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -482,7 +482,7 @@ static int nfs4_match_client(struct nfs_client  *pos,  struct nfs_client *new,
 	 * remaining fields in "pos", especially the client
 	 * ID and serverowner fields.  Wait for CREATE_SESSION
 	 * to finish. */
-	if (pos->cl_cons_state > NFS_CS_READY) {
+	if (pos->cl_cons_state == NFS_CS_SESSION_INITING) {
 		atomic_inc(&pos->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 


