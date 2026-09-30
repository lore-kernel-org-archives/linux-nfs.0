Received: from mail-pj2-f12.google.com (mail-pj2-f12.google.com [74.125.227.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 896BE368D71
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 05:51:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790747465; cv=none; b=hwKz8zCdsVXEp5P+ejDoRBdAh0A/Ib/Tk6cOyKTFPmXt51nBr0d/wivLqbgAQvQFl0ohnKOcIohRuXrAMiUyeb8kgF2BphcGumzqo+J3mMl8CXbs/PS63oNDctOFoV3Bds+9HVtHgBdlhKFUrxipHeitMH+QebZjRF/n65Wuiy0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790747465; c=relaxed/simple;
	bh=LPCNJepiMmlQ81AVXuGzwDWQn0EsH62ugGlKqeQjnl8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Nc10R2+wWRzGVuBDrXympaHhWqfEvzreSAtSGKxw7+aoiqytQzdIBK1oBBevnLKDqICyhAP8apdp3rrgn47Qmp6H4Ot4EKlNs7zEnlyQRN+rOpogoOukTcT+6CVGodqsZEG6/ep2bGBmxjGJAmRh3Edqe2xcEFVipW3HFulzDJM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=SCzNA/4K; arc=none smtp.client-ip=74.125.227.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SCzNA/4K"
Received: by mail-pj2-f12.google.com with SMTP id 98e67ed59e1d1-39dacf053eeso2510429a91.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 22:51:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790747463; x=1791352263; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=clecnWLVra+yy85lTaNTYQZeGc9ml6bZUE3ZytKutKU=;
        b=SCzNA/4KwkR/Mu9wZ7gYGisVcfR9HX870eMrEkmafZQOMhwX9XmzOc4BGZyrZUBrrh
         F6EqkvtAT/buG6N3S1JtTuHSYJLaKoLXLA2e33LElgpK/ahf2TNvtQaYUWh1UAJWF/La
         HQ7Z2Fk5y7AMn7Zc8Ie65eRWxZE/stdlii/fiz8jSqfWO4ZAwaT9DeYis3SCD9WDRTf5
         Iugo3RYZXx+ltYQWv+bb7D5UfF0U8DGFgWR5S4VkeYk6q2JPGk3z8qblicZj8WRseIKa
         k/l+sxUskvHx7zGTDUcGZ7/v3673TXfoCx7eudoGQL7JcrSTCoggFDJPg3+mYlqgSHYw
         NG/A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790747463; x=1791352263;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=clecnWLVra+yy85lTaNTYQZeGc9ml6bZUE3ZytKutKU=;
        b=X0YSWHwQaKJOhg7whSbdrszvz/JyIEHGk4ucEMX5PxncPaZBl1tGE/bR95WLVKTe+f
         aucxB5DbR3d+nqheXfdRxug5g/0PrXjx5MgWSaMMG7EijFv3ICQ+ApldwD9LB7AjeYWQ
         2ZeudH7aE1+ViDyUNSbDxrcM1rSVXbWgzyvm0SAzRa7ogW6hAKcUbFXLFTgx8VYdirwo
         zIk0T1E78g5pD7GWSS+T4gZ7ca+6J3+HAEF522j5bLICdG4D6pxL3zTODDhas8HiU/Fm
         lkOT1VUlulVJVf6GHs0Q2DqRNtEA78UjN9UyPGpM2+bkyfV1r39VvnalkBZgGimgG8lN
         zE/Q==
X-Gm-Message-State: AFq9FYIkfQ+ahyt+0l/CNLLfPk8nIBBGn3iFLtPdcZKlJMgUAGqoE65b
	GYk29vIPMO9NAsWhnSpK50UAMk9C+JUOj9UiBPBRJUU8129t0aWVA7qh+3VFVQYwiB4=
X-Gm-Gg: AYBFou0JDkEIwoaVVmCiUSWorHybEXnkD7JV62mbuWcT5S2ywRDevYnFVvD8D5E2VJy
	zwNjpWIluMtkDyPoQ4QxzrHj+NBlQaIbMzbLlirXpj2cZc7IfWZ4wLP8lLPiAPhlMz3pSAbqbyp
	0t8O2dRchip3f+D4ICi4osttOIMLMTqGr73Qs+HyxYUXcr1WPlxQHy3D4rctZLwulGhGyHw7I3m
	qoK+q5uKkAQ1wnxkjZZ+bfsSJhbQzQFPvTwZdNvRfP2hc2yzv5JSTrQpZbmBoky3kPy30iC0zs1
	FRKyD6OdSbfKMHLB1o8qDinlNtsIzt5LlO9Kzc3s/K+h4xjy8mm2g3+rYz9VVI07fK1oV8Wfsps
	9VaCtfyZ0eFK+nNF/jlneyBTj/OfmkjUVH3ZNCipsUaTg0lFpf2TxvTL9XKg4BYweDhJYBSXac8
	ukyYKWKDSk38FoY7V87XG6COjBuf1WAD/JD1CzJpzDDyiRl2XwCQmovOznRlInxevxZUYL8k1oA
	hGq+U7+T+Yc7OA=
X-Received: by 2002:a17:90b:5143:b0:3a4:945e:bc33 with SMTP id 98e67ed59e1d1-3a4d1b4bd43mr297312a91.47.1790747462607;
        Tue, 29 Sep 2026 22:51:02 -0700 (PDT)
Received: from bintable.tail83b815.ts.net ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a4ce1cf254sm1206975a91.13.2026.09.29.22.50.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 22:51:02 -0700 (PDT)
From: Jinpyo Lee <bint4b13@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	bobtobabz@gmail.com,
	Jinpyo Lee <bint4b13@gmail.com>
Subject: [PATCH v2] nfs/localio: pin clients during global invalidation
Date: Wed, 30 Sep 2026 14:50:53 +0900
Message-ID: <20260930055053.134716-1-bint4b13@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs_localio_invalidate_clients() moves UUID nodes embedded in nfs_client
objects to a private list, drops the namespace list lock, and walks the
private list without holding references on the clients that own the nodes.

Moving an embedded list node does not retain its containing object.
Concurrent client teardown can therefore drop the final cl_count reference
after the splice. List iteration can preload the next UUID node before
processing the current entry, allowing that node's nfs_client to be freed
before the iterator advances to it. Generic KASAN reported an eight-byte
use-after-free read from a freed nfs_client allocation in
nfs_localio_invalidate_clients().

Process one UUID at a time under the namespace list lock. Acquire a
cl_count reference before releasing the lock, disable LOCALIO, and then
drop the reference with nfs_put_client(). If the reference cannot be
acquired, yield and retry so final teardown can remove the dying client
from the list.

Expose the existing nfs_put_client() declaration in a public NFS header and
remove its duplicate declaration from the private NFS header.

The reproducer creates 16 clients, populates their LOCALIO state, and races
administrator-driven global file-cache invalidation with normal client
teardown. It demonstrates the lifetime error, but does not establish
controlled reuse, privilege escalation, or an unprivileged end-to-end
trigger.

On the current nfsd-testing head, the unpatched KASAN kernel reproduced
the use-after-free in nfs_localio_invalidate_clients(). With only this
patch applied, the same race completed without a KASAN report. A separate
run that kept all 16 clients live recorded one LOCALIO disable event for
each client.

Basic NFSv4.2 and NFSv3 read, write, and unmount smoke tests also passed. A
full x86_64 kernel and modules build with GCC 13.3 and CONFIG_WERROR=y
completed without warnings. A source reproducer and complete logs are
available privately on request.

The vulnerability research and validation were conducted by members of the
Tobabz team as part of the Best of the Best 15th program.

Fixes: 085804110aa1 ("nfs_common: track all open nfsd_files per LOCALIO nfs_client")
Assisted-by: LLM
Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
---
Changes in v2:

- Move the nfs_put_client() declaration to a public NFS header instead of
  duplicating it.
- Make the commit message self-contained and document current-tree runtime
  validation.
- Correct the author identity and DCO sign-off.

 fs/nfs/internal.h          |  1 -
 fs/nfs_common/nfslocalio.c | 27 ++++++++++++++++++++-------
 include/linux/nfs_fs.h     |  2 ++
 3 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index abc81f5ae5780..c377075a8b5b5 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -223,7 +223,6 @@ int nfs_init_server_rpcclient(struct nfs_server *, const struct rpc_timeout *t,
 struct nfs_server *nfs_alloc_server(void);
 void nfs_server_copy_userdata(struct nfs_server *, struct nfs_server *);
 
-extern void nfs_put_client(struct nfs_client *);
 extern void nfs_free_client(struct nfs_client *);
 void nfs_cb_idr_remove(struct nfs_client *clp);
 extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
diff --git a/fs/nfs_common/nfslocalio.c b/fs/nfs_common/nfslocalio.c
index 85aa03a7b020c..00fcba467ee8d 100644
--- a/fs/nfs_common/nfslocalio.c
+++ b/fs/nfs_common/nfslocalio.c
@@ -226,18 +226,31 @@ EXPORT_SYMBOL_GPL(nfs_localio_disable_client);
 void nfs_localio_invalidate_clients(struct list_head *nn_local_clients,
 				    spinlock_t *nn_local_clients_lock)
 {
-	LIST_HEAD(local_clients);
-	nfs_uuid_t *nfs_uuid, *tmp;
+	nfs_uuid_t *nfs_uuid;
 	struct nfs_client *clp;
 
-	spin_lock(nn_local_clients_lock);
-	list_splice_init(nn_local_clients, &local_clients);
-	spin_unlock(nn_local_clients_lock);
-	list_for_each_entry_safe(nfs_uuid, tmp, &local_clients, list) {
-		if (WARN_ON(nfs_uuid->list_lock != nn_local_clients_lock))
+	for (;;) {
+		spin_lock(nn_local_clients_lock);
+		nfs_uuid = list_first_entry_or_null(nn_local_clients,
+						    nfs_uuid_t, list);
+		if (!nfs_uuid) {
+			spin_unlock(nn_local_clients_lock);
+			break;
+		}
+		if (WARN_ON(nfs_uuid->list_lock != nn_local_clients_lock)) {
+			spin_unlock(nn_local_clients_lock);
 			break;
+		}
 		clp = container_of(nfs_uuid, struct nfs_client, cl_uuid);
+		if (!refcount_inc_not_zero(&clp->cl_count)) {
+			spin_unlock(nn_local_clients_lock);
+			cond_resched();
+			continue;
+		}
+		spin_unlock(nn_local_clients_lock);
+
 		nfs_localio_disable_client(clp);
+		nfs_put_client(clp);
 	}
 }
 EXPORT_SYMBOL_GPL(nfs_localio_invalidate_clients);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b85a73ae7919f..8c1e2d2027c62 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -84,6 +84,8 @@ struct nfs_file_localio {
 	void __rcu *nfs_uuid; /* opaque pointer to 'nfs_uuid_t' */
 };
 
+void nfs_put_client(struct nfs_client *clp);
+
 static inline void nfs_localio_file_init(struct nfs_file_localio *nfl)
 {
 #if IS_ENABLED(CONFIG_NFS_LOCALIO)
-- 
2.43.0
