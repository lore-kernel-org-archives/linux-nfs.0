Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60197 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932269Ab1INLpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:30 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 25/25] nfsd4: better stateid hashing
Date: Wed, 14 Sep 2011 07:45:21 -0400
Message-Id: <1316000721-3289-26-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

First, we shouldn't care here about the structure of the opaque part of
the stateid.  Second, this hash is really dumb.  (I'm not sure the
replacement is much better, though--to look at it another patch.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ea338d0..0cd3464 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -168,9 +168,9 @@ static unsigned int file_hashval(struct inode *ino)
 	return hash_ptr(ino, FILE_HASH_BITS);
 }
 
-static unsigned int stateid_hashval(u32 owner_id, u32 file_id)
+static unsigned int stateid_hashval(stateid_t *s)
 {
-	return (owner_id + file_id) & STATEID_HASH_MASK;
+	return opaque_hashval(&s->si_opaque, sizeof(stateid_opaque_t)) & STATEID_HASH_MASK;
 }
 
 static struct list_head file_hashtbl[FILE_HASH_SIZE];
@@ -221,7 +221,7 @@ static inline void hash_stid(struct nfs4_stid *stid)
 	stateid_t *s = &stid->sc_stateid;
 	unsigned int hashval;
 
-	hashval = stateid_hashval(s->si_stateownerid, s->si_fileid);
+	hashval = stateid_hashval(s);
 	list_add(&stid->sc_hash, &stateid_hashtbl[hashval]);
 }
 
@@ -1083,7 +1083,7 @@ static struct nfs4_stid *find_stateid(stateid_t *t)
 	struct nfs4_stid *s;
 	unsigned int hashval;
 
-	hashval = stateid_hashval(t->si_stateownerid, t->si_fileid);
+	hashval = stateid_hashval(t);
 	list_for_each_entry(s, &stateid_hashtbl[hashval], sc_hash)
 		if (same_stateid(&s->sc_stateid, t))
 			return s;
-- 
1.7.4.1

