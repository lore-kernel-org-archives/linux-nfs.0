Received: from mail-pj1-f47.google.com (mail-pj1-f47.google.com [209.85.216.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D37033B0AE1
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 11:27:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791804443; cv=none; b=EzxKzfU0JvLFte7OTsI/KEr+lq9As6GQ3yR0wYJq3RFiN8q6A6rzKCE0DsXS63T/ixx7t/L9pf1Jwt6FZDLdcZwLg9MQUEiRjdvvsutWgLjV8NYubgbwPEhWdNI9VA00ec7oM1+QDRJZ6V3oLBG2yoQ531RCFLIv2wIoRxU3A54=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791804443; c=relaxed/simple;
	bh=2r6qyANix0ojTFgBMvWL2BfR+z7kHrZ7yZLJNWSzuGk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eM1OrlkCyLP1fTjvG2MrlnA55uZGGs26ezw7fwEbBICqFK6fePrtne624V/OADNuEY3vw2CraRY46wQRsQoU11sBLQW4KY/fVp0IwJgJJK6YvZ227hpg092/wQNcndv0iEOm9zZqOuv3bX5CcfN6SGS99QoV/PqtC+sOFCLpXgQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ZJbuSkbZ; arc=none smtp.client-ip=209.85.216.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZJbuSkbZ"
Received: by mail-pj1-f47.google.com with SMTP id 98e67ed59e1d1-398a5aad413so849725a91.3
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 04:27:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791804441; x=1792409241; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=quJxKdnKzJo+A3YoKDlJH6sZgbFvR9ogQFiP2wQAcz4=;
        b=ZJbuSkbZlzeqkJSOOA27SlOBTKxgqcH5EmW33USHr0dI46v+fMphijdiYInkHPYScr
         OPQlDmkKtR4lUnspzRxZ3eZHG1tfY+CIKTLKhMjhwc5THQUNNKC3Y3JCcWSMXszyHjwG
         Qkhe2w6WSk2kBAu1b7kNwUI1iRn95eDGjwYBdspZcvxldPETfBM8I+99H9FlmqCBRALT
         KaAyTnoXAD+oJHfZH/ML4fWPAEaBPumvyQ7JBfAttXV6vkpvX+ns0LSucNUQs/SLVn4+
         mKZI27hTZa3Vy/6QQcEmnNRWwo1tYuYIP3hOY4lLlsmKkOGwCRvfNO80z/A8Ap3GZZPB
         IplA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791804441; x=1792409241;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=quJxKdnKzJo+A3YoKDlJH6sZgbFvR9ogQFiP2wQAcz4=;
        b=fWkqssCI5ymOEfSahkBd3l4QYtzu8VfpHuBru+dyfmTGQFcHf7usXfQVJQloKukRPo
         XFT/+FF1QOPhHYffqcS9Y2Q7n1FDPXsPEWNoh0JeFBff9CWoPeWnl2Qqj3Yyjd8FO/li
         LutcsQdEtr0v42rkOJiwuC5T++9qGidEFX2+YsPU9GsFXPptZ+n7loxCGtW4n+10NBv0
         G0C2WxHyliiNZJxZ6b4QLH4pCEa/Z72jRyuwV+hsYkwHCVenyIJZjCZ6+/P1M4hYF55I
         OMSsfpY/Km2tYkcwmSHqWWFoM9KEnbabT6E9cnI9z552f+JqSYkf74tPHVjvgjz8Fk9B
         KvAQ==
X-Gm-Message-State: AFq9FYJawWAQhTlkfcpx2j+scwGCHlj4hlZvpraioanSSMcdLeANgOvs
	sD9R1ehLxM/Avde9ANL5wKyBEc8khk4PBzQyYCcCyGRKdg/wwFrUSe41DznCVwZsZnQ=
X-Gm-Gg: AYBFou2aqXQLp/rru0V6LOaR1YLr1oonMZQP1aFUZqLwXKDLy43gsTtAvIx4n26J3vu
	u7DmK1btGHAH1Zw6n8HeaNiMmpGSyHAwdZ8FgI8cnpqdxHRqpdBwafX0/9EaqlXAoOYSAlSyMJu
	Ofym2l5NRHbJ6J8iSUb5IvrGZboFdN6Yh3m+c2EQMixmgGpcbTC53pnieE1ZeXMrLqV53o50+zC
	Xu6dgItlUnm3+TBK2UN/n12WxSR9EAjZALDT7H9b3DiJTFef4egQVV3CRiHFGcX4+GRuR8ZEqYD
	bSp7sXsRaNYGplvR+3JV6kOuU3KjxajOhD6EFVQ+YMBL/hL/4j/0odHQVo2wf3MMaSsYr7553jA
	iAKTdD647taPXNdpc/qJrhoatvqpSrV/DcBH2pMkgsqiG6xbkYr01DXOXToiNHJtdRT2Hv6frbx
	8+jat21ceCQ4evJj/+0k7/HYokUCF2r4Z1rkpyjmymwEYiqOaVXC7RsHppatIfK3LcRoaJ/td43
	0MTNV4LUW+sdHZKrD8cHbTZXg==
X-Received: by 2002:a17:90a:e7ca:b0:39e:4c80:f67b with SMTP id 98e67ed59e1d1-3ab3a7a1526mr7253431a91.26.1791804440688;
        Mon, 12 Oct 2026 04:27:20 -0700 (PDT)
Received: from bintable.tail83b815.ts.net ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3ab38b9633fsm20286668a91.6.2026.10.12.04.27.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 12 Oct 2026 04:27:20 -0700 (PDT)
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
Subject: [PATCH v3] nfs/localio: pin UUIDs during global invalidation
Date: Mon, 12 Oct 2026 20:27:10 +0900
Message-ID: <20261012112710.773-1-bint4b13@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <031205cd-1099-47a0-889f-ae203fd6c8c5@slotpi15m67>
References: <031205cd-1099-47a0-889f-ae203fd6c8c5@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs_localio_invalidate_clients() moves UUID nodes embedded in nfs_client
objects to a private list, then walks that list without retaining the
containing clients. Concurrent client teardown can free an entry that
the iterator has already selected, causing a use-after-free.

Take a reference to each selected UUID under the namespace list lock.
Keep this reference count in nfs_common, independently of cl_count, and
have nfs_free_client() drain temporary UUID users before freeing the
client. Releasing a UUID reference wakes waiting probes and signals
completion when the last reference is dropped. It neither calls into
nfs.ko nor performs final NFS client teardown in the NFSD invalidation
context.

Keep the UUID on the namespace list until its files have been closed.
When another thread is already disabling it, wait for that thread to
finish unlinking it instead of repeatedly selecting the same head entry.
The wait releases the UUID spinlock so file cleanup can make progress.

Append registrations in sequence order and capture the last sequence
under the namespace list lock at the start of invalidation. Stop at that
boundary so new registrations cannot indefinitely extend the sweep,
even if its original last entry is removed concurrently.

Publish the LOCALIO association under the UUID and namespace list locks
before making the entry visible to invalidation. A temporary UUID
reference allows the handshake to drop the global lookup lock before
taking the UUID lock in the documented order; recheck the lookup in case
the probe was withdrawn. A new probe waits for temporary UUID users to
drain, then rechecks the association before reusing the UUID. This keeps
a transient invalidation reference from discarding the client's LOCALIO
revalidation attempt. Withdraw pending probes before dropping the owner's
UUID reference.

A deterministic same-base KASAN reproducer triggered the reported
use-after-free on the unpatched tree. With this patch, the same controlled
invalidation and teardown race completed without the target KASAN report
or another selected kernel diagnostic. A separate all-live run recorded
disable events for all 16 unique clients.

Test-only synchronization hooks verified that a second disabler waits for
unlink after ->net is cleared and that client teardown waits for a
temporary UUID reference to drain. NFSv4.2 and NFSv3 read, write, and
unmount smoke tests, export-flush and I/O stress, NFSD restarts, network
namespace lifecycle tests, and module unloads passed with KASAN and
lockdep enabled.

A full x86_64 kernel and modules build with GCC 13.3, CONFIG_WERROR=y,
NFS_FS=m, NFSD=m, and LOCALIO enabled completed without diagnostics.
Module metadata showed that nfs_localio.ko depends only on sunrpc, while
nfs.ko depends on lockd, nfs_localio, and sunrpc.

A separate NFS_FS=m, NFSD=y build also linked vmlinux successfully.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 085804110aa1 ("nfs_common: track all open nfsd_files per LOCALIO nfs_client")
Assisted-by: LLM
Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
---
Changes in v3:
- Replace cl_count pinning with UUID references owned by nfs_common and
  drained by the original NFS client teardown path.
- Wait for concurrent disable to finish unlinking the UUID, and bound
  each sweep to registrations present when invalidation begins.
- Serialize association publication and preserve reprobes by waiting
  for temporary UUID references before rechecking association state.
- Add same-base KASAN, runtime, lifecycle, and module dependency
  validation on the latest nfsd-testing revision.

 fs/nfs/client.c            |   2 +-
 fs/nfs_common/nfslocalio.c | 101 +++++++++++++++++++++++++++++++------
 include/linux/nfslocalio.h |  12 +++++
 3 files changed, 98 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 60386330aeec..d85711edecbf 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -256,7 +256,7 @@ static void pnfs_init_server(struct nfs_server *server)
  */
 void nfs_free_client(struct nfs_client *clp)
 {
-	nfs_localio_disable_client(clp);
+	nfs_localio_free_client(clp);
 
 	/* -EIO all pending I/O */
 	if (!IS_ERR(clp->cl_rpcclient))
diff --git a/fs/nfs_common/nfslocalio.c b/fs/nfs_common/nfslocalio.c
index e0a4273ae341..b2b8d7c3d93e 100644
--- a/fs/nfs_common/nfslocalio.c
+++ b/fs/nfs_common/nfslocalio.c
@@ -24,6 +24,26 @@ static DEFINE_SPINLOCK(nfs_uuids_lock);
  * that is protected by nfs_uuids_lock.
  */
 static LIST_HEAD(nfs_uuids);
+/* Namespace registration order, protected by nfs_uuids_lock. */
+static u64 nfs_uuid_seq;
+
+/* The owner waits for temporary users before freeing its nfs_client. */
+static void nfs_uuid_get(nfs_uuid_t *nfs_uuid)
+{
+	refcount_inc(&nfs_uuid->refs);
+}
+
+static void nfs_uuid_release(nfs_uuid_t *nfs_uuid)
+{
+	bool released;
+
+	spin_lock(&nfs_uuid->lock);
+	released = refcount_dec_and_test(&nfs_uuid->refs);
+	wake_up_var_locked(&nfs_uuid->refs, &nfs_uuid->lock);
+	spin_unlock(&nfs_uuid->lock);
+	if (released)
+		complete(&nfs_uuid->released);
+}
 
 /*
  * Lock ordering:
@@ -43,6 +63,8 @@ void nfs_uuid_init(nfs_uuid_t *nfs_uuid)
 	INIT_LIST_HEAD(&nfs_uuid->list);
 	INIT_LIST_HEAD(&nfs_uuid->files);
 	spin_lock_init(&nfs_uuid->lock);
+	refcount_set(&nfs_uuid->refs, 1);
+	init_completion(&nfs_uuid->released);
 	nfs_uuid->nfs3_localio_probe_count = 0;
 }
 EXPORT_SYMBOL_GPL(nfs_uuid_init);
@@ -50,7 +72,12 @@ EXPORT_SYMBOL_GPL(nfs_uuid_init);
 bool nfs_uuid_begin(nfs_uuid_t *nfs_uuid)
 {
 	spin_lock(&nfs_uuid->lock);
-	if (rcu_access_pointer(nfs_uuid->net)) {
+	/* The caller retains the client while temporary UUID users drain. */
+	wait_var_event_spinlock(&nfs_uuid->refs,
+				refcount_read(&nfs_uuid->refs) <= 1,
+				&nfs_uuid->lock);
+	if (rcu_access_pointer(nfs_uuid->net) || nfs_uuid->list_lock ||
+	    refcount_read(&nfs_uuid->refs) != 1) {
 		/* This nfs_uuid is already in use */
 		spin_unlock(&nfs_uuid->lock);
 		return false;
@@ -77,7 +104,7 @@ void nfs_uuid_end(nfs_uuid_t *nfs_uuid)
 {
 	if (!rcu_access_pointer(nfs_uuid->net)) {
 		spin_lock(&nfs_uuid->lock);
-		if (!rcu_access_pointer(nfs_uuid->net)) {
+		if (!rcu_access_pointer(nfs_uuid->net) && !nfs_uuid->list_lock) {
 			/* Not local, remove from nfs_uuids */
 			spin_lock(&nfs_uuids_lock);
 			list_del_init(&nfs_uuid->list);
@@ -113,28 +140,37 @@ void nfs_uuid_is_local(const uuid_t *uuid, struct list_head *list,
 		spin_unlock(&nfs_uuids_lock);
 		return;
 	}
+	/* Drop the lookup lock before taking nfs_uuid->lock. */
+	nfs_uuid_get(nfs_uuid);
+	spin_unlock(&nfs_uuids_lock);
+
+	spin_lock(&nfs_uuid->lock);
+	spin_lock(&nfs_uuids_lock);
+	/* nfs_uuid_end() may have withdrawn the probe in the meantime. */
+	if (nfs_uuid_lookup_locked(uuid) != nfs_uuid)
+		goto out_unlock;
 
 	/*
 	 * We don't hold a ref on the net, but instead put
 	 * ourselves on @list (nn->local_clients) so the net
 	 * pointer can be invalidated.
 	 */
-	spin_lock(list_lock); /* list_lock is nn->local_clients_lock */
-	list_move(&nfs_uuid->list, list);
-	spin_unlock(list_lock);
-
-	spin_unlock(&nfs_uuids_lock);
-	/* Once nfs_uuid is parented to @list, avoid global nfs_uuids_lock */
-	spin_lock(&nfs_uuid->lock);
-
 	__module_get(mod);
 	nfsd_mod = mod;
 
+	spin_lock(list_lock); /* list_lock is nn->local_clients_lock */
 	nfs_uuid->list_lock = list_lock;
 	kref_get(&dom->ref);
 	nfs_uuid->dom = dom;
 	rcu_assign_pointer(nfs_uuid->net, net);
+	nfs_uuid->seq = ++nfs_uuid_seq;
+	list_move_tail(&nfs_uuid->list, list);
+	spin_unlock(list_lock);
+
+out_unlock:
+	spin_unlock(&nfs_uuids_lock);
 	spin_unlock(&nfs_uuid->lock);
+	nfs_uuid_release(nfs_uuid);
 }
 EXPORT_SYMBOL_GPL(nfs_uuid_is_local);
 
@@ -154,6 +190,10 @@ static bool nfs_uuid_put(nfs_uuid_t *nfs_uuid)
 	struct nfs_file_localio *nfl;
 
 	spin_lock(&nfs_uuid->lock);
+	/* A concurrent disabler can drop the lock while closing files. */
+	wait_var_event_spinlock(&nfs_uuid->list_lock,
+				rcu_access_pointer(nfs_uuid->net) ||
+				!nfs_uuid->list_lock, &nfs_uuid->lock);
 	if (unlikely(!rcu_access_pointer(nfs_uuid->net))) {
 		spin_unlock(&nfs_uuid->lock);
 		return false;
@@ -211,6 +251,7 @@ static bool nfs_uuid_put(nfs_uuid_t *nfs_uuid)
 	}
 
 	module_put(nfsd_mod);
+	wake_up_var_locked(&nfs_uuid->list_lock, &nfs_uuid->lock);
 	spin_unlock(&nfs_uuid->lock);
 
 	return true;
@@ -223,22 +264,50 @@ void nfs_localio_disable_client(struct nfs_client *clp)
 }
 EXPORT_SYMBOL_GPL(nfs_localio_disable_client);
 
+void nfs_localio_free_client(struct nfs_client *clp)
+{
+	nfs_uuid_t *nfs_uuid = &clp->cl_uuid;
+
+	nfs_uuid_end(nfs_uuid);
+	nfs_localio_disable_client(clp);
+	/* Unlink before dropping the owner reference, then drain all users. */
+	nfs_uuid_release(nfs_uuid);
+	wait_for_completion(&nfs_uuid->released);
+}
+EXPORT_SYMBOL_GPL(nfs_localio_free_client);
+
 void nfs_localio_invalidate_clients(struct list_head *nn_local_clients,
 				    spinlock_t *nn_local_clients_lock)
 {
-	LIST_HEAD(local_clients);
-	nfs_uuid_t *nfs_uuid, *tmp;
+	nfs_uuid_t *nfs_uuid;
 	struct nfs_client *clp;
+	u64 last_seq;
 
 	spin_lock(nn_local_clients_lock);
-	list_splice_init(nn_local_clients, &local_clients);
-	spin_unlock(nn_local_clients_lock);
-	list_for_each_entry_safe(nfs_uuid, tmp, &local_clients, list) {
-		if (WARN_ON(nfs_uuid->list_lock != nn_local_clients_lock))
+	if (list_empty(nn_local_clients))
+		goto out_unlock;
+	/* New registrations go to the tail and belong to a later sweep. */
+	last_seq = list_last_entry(nn_local_clients, nfs_uuid_t, list)->seq;
+	for (;;) {
+		nfs_uuid = list_first_entry_or_null(nn_local_clients,
+						    nfs_uuid_t, list);
+		/* Use a signed difference to allow the sequence to wrap. */
+		if (!nfs_uuid || (s64)(nfs_uuid->seq - last_seq) > 0)
 			break;
+		if (WARN_ON_ONCE(nfs_uuid->list_lock != nn_local_clients_lock))
+			break;
+		/* Teardown unlinks under this lock before dropping its reference. */
+		nfs_uuid_get(nfs_uuid);
+		spin_unlock(nn_local_clients_lock);
+
 		clp = container_of(nfs_uuid, struct nfs_client, cl_uuid);
 		nfs_localio_disable_client(clp);
+		nfs_uuid_release(nfs_uuid);
+		cond_resched();
+		spin_lock(nn_local_clients_lock);
 	}
+out_unlock:
+	spin_unlock(nn_local_clients_lock);
 }
 EXPORT_SYMBOL_GPL(nfs_localio_invalidate_clients);
 
diff --git a/include/linux/nfslocalio.h b/include/linux/nfslocalio.h
index 8ce4d978a636..914246e3f342 100644
--- a/include/linux/nfslocalio.h
+++ b/include/linux/nfslocalio.h
@@ -8,8 +8,10 @@
 
 #if IS_ENABLED(CONFIG_NFS_LOCALIO)
 
+#include <linux/completion.h>
 #include <linux/module.h>
 #include <linux/list.h>
+#include <linux/refcount.h>
 #include <linux/uuid.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svcauth.h>
@@ -37,6 +39,11 @@ struct nfs_file_localio;
 typedef struct {
 	uuid_t uuid;
 	unsigned nfs3_localio_probe_count;
+	/* Owner reference plus temporary references held by nfs_common */
+	refcount_t refs;
+	struct completion released;
+	/* Namespace registration order, protected by list_lock */
+	u64 seq;
 	/* this struct is over a cacheline, avoid bouncing */
 	spinlock_t ____cacheline_aligned lock;
 	struct list_head list;
@@ -55,6 +62,7 @@ void nfs_uuid_is_local(const uuid_t *, struct list_head *, spinlock_t *,
 
 void nfs_localio_enable_client(struct nfs_client *clp);
 void nfs_localio_disable_client(struct nfs_client *clp);
+void nfs_localio_free_client(struct nfs_client *clp);
 void nfs_localio_invalidate_clients(struct list_head *nn_local_clients,
 				    spinlock_t *nn_local_clients_lock);
 
@@ -127,6 +135,10 @@ static inline void nfs_localio_disable_client(struct nfs_client *clp)
 {
 }
 
+static inline void nfs_localio_free_client(struct nfs_client *clp)
+{
+}
+
 #endif  /* CONFIG_NFS_LOCALIO */
 
 #endif  /* __LINUX_NFSLOCALIO_H */

base-commit: f27ad2d5441154f0178599c8ab2b1166acc543b2
-- 
2.39.5
