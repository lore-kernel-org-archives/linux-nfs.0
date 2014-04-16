Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38857 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041AbaDPETh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2014 00:19:37 -0400
From: NeilBrown <neilb@suse.de>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 16 Apr 2014 14:03:37 +1000
Subject: [PATCH 15/19] nfsd: set PF_FSTRANS when client_mutex is held.
Cc: xfs@oss.sgi.com
Message-ID: <20140416040336.10604.67828.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When loop-back NFS with NFSv4 is in use, client_mutex might be needed
to reclaim memory, so any memory allocation while client_mutex is held
must avoid __GFP_FS, so best to set PF_FSTRANS.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfs4state.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d5d070fbeb35..7b7fbcbe20cb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -75,6 +75,7 @@ static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner
 
 /* Currently used for almost all code touching nfsv4 state: */
 static DEFINE_MUTEX(client_mutex);
+static unsigned int client_mutex_pflags;
 
 /*
  * Currently used for the del_recall_lru and file hash table.  In an
@@ -93,6 +94,7 @@ void
 nfs4_lock_state(void)
 {
 	mutex_lock(&client_mutex);
+	current_set_flags_nested(&client_mutex_pflags, PF_FSTRANS);
 }
 
 static void free_session(struct nfsd4_session *);
@@ -127,6 +129,7 @@ static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
 void
 nfs4_unlock_state(void)
 {
+	current_restore_flags_nested(&client_mutex_pflags, PF_FSTRANS);
 	mutex_unlock(&client_mutex);
 }
 


