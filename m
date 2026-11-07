Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794057333;
	b=xzn5tvFaRQy+kMBjdRWwl7r/QjBIt1JM1hWwVoDX2A49VNlQA1KPDwj6XasqIVfbkYkI
	 6cJbf6AeDc3WjECLzjO1OM/MPtGCBPy75Ft9d4OWuqpv3a1FLIYuJLSceuN7Lhi262F+M
	 5sexyN5A82E0zEhBT9XN9mX4aKyYcG8I7vRPbYWVnmZTVKXwFouA282s5hoQLDj7LShku
	 NmBizrlqZZC3JNm/dDPO0AMsalxgqI5EBrXSEjlk2jRp1vPJhTqyO8FtsOJA9Vopdk9qe
	 sldcCWQ88oAk9r2yGh0rW+Lr5/WuV71JTTwbOYVnUwllG3akWfSlNwTnnbsGaiU6skQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794057333;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=QVH4HUhUjAGbn//KdcTKvYYK0jkAf27rpg6dT7GZY+M=;
	b=TJkagmgIHlgxsDw4CKYfi09Ai4LfMr/l3IRCHjHNVgzfI3EXSuxkGK8EjjiFjmehVJ0z
	 +rBo9lbMzbfqJs/kW+dZ2HzKwuv/UYZPZrdvVZoUy2EGCnBw3P9+Ye6nR/xdXwUvtpb7s
	 NZpb3CPwT1lo7ibK66/VdC/upvk9cbXUgiIqDbrOmGlhbWjXLFQxqOud3EPLT6BIblGEu
	 JasP2dFlLvGYji/KM1ETL7h1oW/l4Sgn+q65YUOLh5Z06jApCGgFnX98UTSzbSipT3byv
	 su6yLTQA3Gce6U9RZF2RHokqu4ve5cFrq8dDwRFr9IgfJkWVv4RKIE3RZjwAMo/azvA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=h5apHB4l;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id D99E5606A33A;
	Sat,  7 Nov 2026 13:15:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=h5apHB4l
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id CE1E11F008A4;
	Sat,  7 Nov 2026 13:15:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794057332;
	bh=QVH4HUhUjAGbn//KdcTKvYYK0jkAf27rpg6dT7GZY+M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=h5apHB4lqPF7nfc45yEcgZ+MQfI6X20q0FtUozYBlEjG79+wGQ+VSZd6aDGlybjkC
	 PtZx2gYlzxraGiPPFCm6oXgtfhSBx8qYbeg/vVCFcUlk5c/aFeZEbaaQxOjQGRhNxl
	 pgX5DsGop/PB1pdm4ZGdc5fNQlCgeBo45XZewHNfNi9/SvCscTz1MpRoFwIaMpKTpt
	 NwlyJmHSzVi9QwNhTLAXMDa0hZ0w02QE6FaZf4zaxplPGPdZFMW9K/kXfzQ+wcA2ie
	 4Y6vv5o+H/98a9b8d0JoTafHTCVFuABYxlSd+EgxoCUEJaHEhsIG2E94RF5r2YzqDn
	 zbCmkcMYNHeag==
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
Subject: [PATCH v4 03/11] NFSv4: Clear idmap keyring cache when the last client unloads
Date: Sat,  7 Nov 2026 15:15:04 +0200
Message-ID: <20261107131512.3603168-4-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261107131512.3603168-1-jarkko@kernel.org>
References: <20261107131512.3603168-1-jarkko@kernel.org>
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

