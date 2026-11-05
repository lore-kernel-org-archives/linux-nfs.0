Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793840012;
	b=n0eZUYmlHXbh1NGtU8JkEltiSd6S+xc4mB5be2om708hscS0pPXSBGCtJFkKCpDsjACO
	 r/NPJoGLDhItOZGdO//yM/PyeqHttyultinYaX6RG82wGgV73Ql9WYrBcAMwfrjeTVvi0
	 TeLG902/pNLiCQnWzS5B2uEU8AvgKUEzx6lk0NuuRjafW7dBE7GrDpUT9vtUhLJFYbBcw
	 ro9eH4dyd0/B0w6nvGz5X5H3vb8bwco0qcUSpDh7IW6uWUEYp1aiplfJhk6HWiM16Ma6S
	 z+TeLUVErLgmhhiCPEHJ4llr223VWf+lYOKErhE3iMouENor42WnxhFOlN2EiTAFK7g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793840012;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=QVH4HUhUjAGbn//KdcTKvYYK0jkAf27rpg6dT7GZY+M=;
	b=tqza5Uxbue9UNALwAiz7D12LqzSOh5jCN2GgeUtaX9Y467AvVoQhkg/i9f9WIQ8XEaek
	 b+8UXR/+Tth5k6mMpv9fMZDUPYhGK0eokEPkBXMEfElrEVVH8S5BXmgARscCo8VF9Vh2o
	 MfuiJqh+zFFL+PawjKq2S+ihe5ZAW3yVtoAWKbMS5mkp6VNu6DIWmChu4gwlUp1qkTTm3
	 Mm0qHI3w7PMCCdfOIoNcQYYwmPZN6x8W0Crn4KRSVQAJ1gN40hzw8eTM/SSmkbHQ88dFt
	 TEuqIGfJzAri4Dmec2+n443e5AoyUaFeNSl+AT1BJ7MbFVweIP+t3LbLayft+0Wcb2w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MiMrQwuM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id ABF21606D80B;
	Thu,  5 Nov 2026 00:53:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MiMrQwuM
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id C06D91F00A02;
	Thu,  5 Nov 2026 00:53:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793840011;
	bh=QVH4HUhUjAGbn//KdcTKvYYK0jkAf27rpg6dT7GZY+M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=MiMrQwuMBREr4QW2G95o26V2fXh5j8Qsrn2stfvv6IvyRC+Xxb9L4QjZRsKIrQff2
	 58r11XU2ceL6mI+kXwto2tiiIeakIB/kRiYolt+W8NSgtX/HLoRsQeUDQvjs+eaTmW
	 ZveBD+0WBsyKbuNlLYLyUfan5gQ/JtvoIpx5V/qzCPpm2h0MWU5MY72l0/0Kpqan3o
	 LFRWSQ6jzJcDENbM05ItxqNTSRXeclKOVnDo65yfnTMOye3Qq1/D/nBWdQdTcGnbMt
	 ZfEW7y2FrUzAAPgmOKB5KqyZ7AkXZHhSzp5b1UoE5ajOosLp7cjlSctQvNI9HIBx2L
	 OQT1x5dkm5x6w==
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
	samba-technical@lists.samba.org,
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
Subject: [RFC PATCH v3 03/11] NFSv4: Clear idmap keyring cache when the last client unloads
Date: Thu,  5 Nov 2026 02:53:02 +0200
Message-ID: <20261105005311.804098-4-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261105005311.804098-1-jarkko@kernel.org>
References: <20261105005311.804098-1-jarkko@kernel.org>
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

