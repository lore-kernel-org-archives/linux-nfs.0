Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794176864;
	b=Od7VAoJ+D8g414MQEQ7xBj2foiLnL/pHvBHfFtA8pP1T3epLQH2OWlM9VzIDh1Bs5vmy
	 VZX0f5zY9V30wzd30+qwUKgRAe9qA4U4H/0hhbarFMAtqD/2p3roXgE4mpsMtWOZAO37P
	 AMXX4aEb5eQYxL+YI/q83wJpaw4ujyzUhmyJrvf+STO0nSZh8L+rIfbMdxCnJhCX8mqkQ
	 WO9ADNUsEmbRZT6n6DRlsYc5ASVxlHL1vv/ixK8GBCrykqoot7JL0IYYxz0NTKCo8/xL5
	 D5tYli23OxgtTkXwpPZPnXxQSqJYriI/7vi8Xiz7/rfHVXGx17aaeVCquy60HDJp3tA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794176864;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=QVH4HUhUjAGbn//KdcTKvYYK0jkAf27rpg6dT7GZY+M=;
	b=zuB8rWQxthQr2yqBS3aJF8OgUqAqwr+G/u1Jq6k7wqWi0zUHokv3KgTw5sIx8n4QlcrS
	 D5L7sDFCFz7jp6Lb/aVqO2J5qjs3myBYvCxF+XxcBsp80H+BZeqp2lzCNXR+nsh2XuDTd
	 TURbeeV12JNYdv7Dr/r6CZSgZHdW6zTucbiHdskmGgYoWSR/k8sDB4nI5pPkE4csX8hxi
	 t4NkpINs1CZEsqWTPB0Aq+1I4JSsAK7jJPZ2AIA1SCFKg7c6ZkVrRN2DhfLzE+EUR3I+A
	 CqPoySMAzynQT10CmalzrXO1NjaALvY86RucaINb503G6c84pTOSrTM5pMsFNvs3lYg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oceCXOQY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 2090F606D80E;
	Sun,  8 Nov 2026 22:27:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oceCXOQY
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 17E9D1F0089F;
	Sun,  8 Nov 2026 22:27:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794176858;
	bh=QVH4HUhUjAGbn//KdcTKvYYK0jkAf27rpg6dT7GZY+M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=oceCXOQYa8RnOYFv7iKGZaaidjgrR7xA6olTQKux+I9fPkN//QtFKi5e/BdVP4tYC
	 OnvfcXo+5mm8tTKdSA/swcQ+EKOltg5N8rTaUwXx98EbeEUX04q3lrGqlyEHcnLHoT
	 HKYP6hgqNBMzaVnsFKQyPL7OIDW7Kb662arSn4f6MR1XSeL9py0rbLLfA30gfUJ9j4
	 TWFOLX97sHaHK+aFXPVBqv5/0DmFjOUMWmGdoZvSrVT2jXw7Cw5y4NYHmfsga0oJy4
	 RFsmfo6oylTRexxNiE8bXJUvFNydilmGEuLQt5hcBbtNpxCB6XcYL40iUNSlnZDQZs
	 nLv7O+fCTkbEw==
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Jarkko Sakkinen <jarkko@kernel.org>,
	keyrings@vger.kernel.org,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-integrity@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org,
	Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>,
	Sumit Garg <sumit.garg@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>
Subject: [PATCH v5 03/12] NFSv4: Clear idmap keyring cache when the last client unloads
Date: Mon,  9 Nov 2026 00:27:09 +0200
Message-ID: <20261108222719.304712-4-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261108222719.304712-1-jarkko@kernel.org>
References: <20261108222719.304712-1-jarkko@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

id_resolver_cache->thread_keyring caches id_resolver_legacy keys up until
nfs_idmap_quit() tears down the keyring.

Once keys pin to the kernel module of their key type, the cached keys
prevent module_exit() from ever happening.

Track the active idmap instances under a mutex and clear the idmap cache
keyring once the last client has been destroyed.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 fs/nfs/nfs4idmap.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index bc397110d977..c88444cc6bf6 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -47,6 +47,8 @@
 #include <keys/request_key_auth-type.h>
 #include <linux/module.h>
 #include <linux/user_namespace.h>
+#include <linux/mutex.h>
+#include <linux/ratelimit.h>
 
 #include "internal.h"
 #include "netns.h"
@@ -58,6 +60,10 @@
 static const struct cred *id_resolver_cache;
 static struct key_type key_type_id_resolver_legacy;
 
+/* Serializes the idmap cache. */
+static DEFINE_MUTEX(nfs_idmap_cache_mutex);
+static unsigned int nfs_idmap_users;
+
 struct idmap_legacy_upcalldata {
 	struct rpc_pipe_msg pipe_msg;
 	struct idmap_msg idmap_msg;
@@ -469,7 +475,10 @@ nfs_idmap_new(struct nfs_client *clp)
 	if (error)
 		goto err_destroy_pipe;
 
+	mutex_lock(&nfs_idmap_cache_mutex);
+	nfs_idmap_users++;
 	clp->cl_idmap = idmap;
+	mutex_unlock(&nfs_idmap_cache_mutex);
 	return 0;
 err_destroy_pipe:
 	rpc_destroy_pipe_data(idmap->idmap_pipe);
@@ -483,6 +492,7 @@ void
 nfs_idmap_delete(struct nfs_client *clp)
 {
 	struct idmap *idmap = clp->cl_idmap;
+	int ret;
 
 	if (!idmap)
 		return;
@@ -493,6 +503,17 @@ nfs_idmap_delete(struct nfs_client *clp)
 	rpc_destroy_pipe_data(idmap->idmap_pipe);
 	put_user_ns(idmap->user_ns);
 	kfree(idmap);
+
+	mutex_lock(&nfs_idmap_cache_mutex);
+	if (--nfs_idmap_users == 0) {
+		ret = keyring_clear(id_resolver_cache->thread_keyring);
+		if (ret)
+			pr_warn_ratelimited("NFS: Failed to clear idmap cache: %d; cache pins remain\n",
+					    ret);
+		else
+			key_gc_flush();
+	}
+	mutex_unlock(&nfs_idmap_cache_mutex);
 }
 
 static int nfs_idmap_prepare_message(char *desc, struct idmap *idmap,
-- 
2.47.3

