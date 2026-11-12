Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794456179;
	b=w8p0JwU5Y0GM8bB5jcRxSmD6awcXvcijxo+KEJrrz46RXU0TjKEmbm/+2dRIkCqzERvq
	 bAR/t9ta3AmuI2C3O33VwovxILLJ1eOSMapSf9OCz3EnosJdbYqLPyHBRgBF2n+JvZVya
	 awlo4KecNZcWm4NPCK69OKJWjBy1yMpiMFYuWwOo2r4LajLy2EYnGme5esjbo+iNbpRuJ
	 fE+WIYvSd/eIS6iBdbm9ZdEuhZMKIVmbhFF8w8i4qN1qRObQvCHAEggWDBXvk/3tlHCpw
	 fujoBfQD7f68Lb3A9cbLqTbezxyEFWXWbRMot8YiEgeG3V1CK9bKu2e8o8vWwvdKv/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794456179;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=QVH4HUhUjAGbn//KdcTKvYYK0jkAf27rpg6dT7GZY+M=;
	b=vTug+1C5TzvxTdRUD5KzgDiu2xLLFMWCfZ82cUGUvOAHDDcjm3mm3No+VQZQcrMmGC5a
	 K9JYzzCl80DFxbsJlDf+zMsg3J6viysL8XjVyH5AI2sYn5em8WshrT9VCGsIVrHLFd4ZQ
	 6Zx71Hc4CttlD0349owHD2ND1lrCZ7a9q+QLYqu/9D4ghSi9jc7//q7jYMmc0+i9sxBfU
	 cRSxHK19kD/GQc0F8p3D7rXjqxwrL2BvltmfY89q73wMl83I/W8tbHWk8yc1M0Ot3wuvS
	 WT/lGa4wQufkcDQD8OE2u8TryjwOGX2476WPwJI1p1J/bI2IBwLEb7Yv9HhAx5B8eCw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YOgWdqOz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id D9120606A324;
	Thu, 12 Nov 2026 04:02:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YOgWdqOz
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id D82151F00A0E;
	Thu, 12 Nov 2026 04:02:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794456179;
	bh=QVH4HUhUjAGbn//KdcTKvYYK0jkAf27rpg6dT7GZY+M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=YOgWdqOzEplW2J6e6awGUnpR7YVFES/XdT0aihnIfNY9nJKFQ5okhEvwV5o0kYVkx
	 G7PtRmSiLOyv33tab6dH4i3Pww9DhQYS2PP9l5vs0uI8+IzTItQABou0Epx1uoKRZH
	 MaF3VoUJmds/AJ38zHsSLVwktAyXl6J9IZG8VAtlOe4oWuYbPMlk8UQfWh/BaXqjsU
	 HPvLqFKhVcGdMlzcaHTW9s1T0g6xjQbMjIpCyJztggyrne5RRpC2vkuwlKpMhoGEbp
	 IowmCrozt5HGHKTHdi8Ca/2DFywSp73RhKODsYlNf6330bt9r+BiNRIAT2SmsHO1Sc
	 9buefzOQiWUQw==
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
Subject: [PATCH v6 03/13] NFSv4: Clear idmap keyring cache when the last client unloads
Date: Thu, 12 Nov 2026 06:02:32 +0200
Message-ID: <20261112040242.247168-4-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261112040242.247168-1-jarkko@kernel.org>
References: <20261112040242.247168-1-jarkko@kernel.org>
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

