Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793674984;
	b=wy46Nf5u4su7Zvd6IxqFh4WdobJct0ytodgyRte+IwEARiK9JXOvTKQ/69keBESXj9nv
	 U0LzbDWK+rDyYZBn3WiI10LFG/yYnzzNggRuhOxZ2Ayo/1gi4ph63BdNeMFdonutSGpeZ
	 dzBwz1lDm2+LlrvxFL+EMxkpI1KYVj1ahIK4S3N0sALCxsteB2Nrl7lUHPxFSNqeKBsYx
	 sQQoUSZqI6ZJP2ecDPH+3caGj/vqfYLq4MQbm3D7gOR7SBdpIMmOpB4zDjiGRzp7/qlDH
	 +Q/70hAOmkF1ZF1GL4G+ARNPdWP+qvI2UeG9HQy3rSYPgGvVBY8A8cgqRERdxtpJt+Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793674984;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=8jK/PCP/uCQL+4V9HWiAs5S9eg3hKZGV0dMlOCnNEQ0=;
	b=luVL1U0anbQ86ugj3pYVBOya/4TdIT5myL3njuwyZcCDgO8vREWPMM/yRmSQOfjIA5I+
	 0ka8W0xdLAX28lQ9O3VoP5nCve0Pjb2aKNw4s/cyhZHn+1Jaw15mWV26kb+aa+A+1e4KB
	 yZGRci8WQLIa/xwNfaTMv+5LAI1NVvhkqw1nyIBLbgAMWX3JxRv99r+yVLIatsiIoTPyF
	 6S6zraJX3uRbvSFNyJkJgyMAf9uIN7xnJd9zpqQtspXWrJcQnD5iTEwjNoqsBNbDmHR0M
	 3zb8NmIelC2rnnJLjVDgd29LaiWG+X8CHhxnL/tYSg8BDnZudcW12Kw+DhCiKiLCxvA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="SCAz1zd/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 45834606A327;
	Tue,  3 Nov 2026 03:03:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SCAz1zd/
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 464231F00A24;
	Tue,  3 Nov 2026 03:03:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793674983;
	bh=8jK/PCP/uCQL+4V9HWiAs5S9eg3hKZGV0dMlOCnNEQ0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SCAz1zd/6d+Gfrtrf42ez1/U6L7rqXhR4MZ976YXOAZ0e1L8kIbfhjhxTookM+LK+
	 2LTwqKlh9SjB1Hz9Wyc0zDOG9exk9pewo1p9eXqlQ/Hd5q+AAulm9b1Avm6WuMWMRp
	 oig19pRQ3aTF1oh2jqaokac10rE/5cHx5J5JFpgkrWW5JAi19sMqV6zQV3Psx6g8Uk
	 wxaPAYHPK6Pw4nIBV1HVeZLAql7n2cJqtRDFEkcg4hl2dP8UR9+kbBYdnQbnJbaSmS
	 yYF1kKPh79igN8GykaZynhyOsn0GqA/h5bOZ9+VOfZ3FjtzHTrlyS8GJAPlqBpl/We
	 /DR/HcpJuqUmQ==
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Eric Biggers <ebiggers@kernel.org>,
	linux-integrity@vger.kernel.org,
	Mimi Zohar <zohar@linux.ibm.com>,
	keyrings@vger.kernel.org,
	Jarkko Sakkinen <jarkko@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Roberto Sassu <roberto.sassu@huawei.com>,
	Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
	Eric Snowberg <eric.snowberg@oracle.com>,
	Paul Moore <paul@paul-moore.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	linux-nfs@vger.kernel.org (open list:NFS, SUNRPC, AND LOCKD CLIENTS),
	linux-kernel@vger.kernel.org (open list),
	linux-security-module@vger.kernel.org (open list:SECURITY SUBSYSTEM)
Subject: [RFC PATCH v2 04/11] NFSv4: Clear idmap keyring cache when the last client unloads
Date: Tue,  3 Nov 2026 05:02:09 +0200
Message-ID: <20261103030226.2685251-5-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261103030226.2685251-1-jarkko@kernel.org>
References: <20261103030226.2685251-1-jarkko@kernel.org>
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

id_resolver_cache->thread_keyring caches id_resolver_legacy keys until
nfs_idmap_quit() tears down the keyring from module_exit(). Once live
keys pin the key type, cached keys keep nfsv4 pinned so module_exit() is
never reached after all mounts are gone.

Track active idmap instances under a mutex and clear the idmap cache
keyring when the last client is destroyed.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 fs/nfs/nfs4idmap.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index bc397110d977..9e3a2255be1e 100644
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
 
+/* Serialize idmap admission with the last client's cache clear. */
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

