Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794176870;
	b=BGK4tE2VnY1LWL5uCa45d5ye2KyhubkSSZ66+R1lobI7kwfhhq0dX9mx+XlAj4AeAgYE
	 sW86wt3pA++RDlOOiJRJUD+/Z2koSIiocHzYB+dnTUEthxnV4+398qjfWOukF5m+8DVjM
	 K+ScKA8d8Cj50ZSQya5BtcXapBUBX9CuQ/b0VZ4uitXIQOpRjYrSYGs62ITpROVGeY3MY
	 a2lh9WCi4CCt6UF5el+yN/yqBtxZLOJCEXHqaJU+CSlm0WLGVq+dStGOFmOLXuo7Kltcc
	 5VFc05p2NUjXeBHm3wflMq81EUeTSXZz5Tu4g/klHqu9eXXb1Sb3StwXAtE0uzqeHzA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794176870;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=oTmAk1GKQZspBWagSAR6F1HfSEYd3TCl+TiacOmEg44=;
	b=5e+b326JyT1GsHtMZRZt9on/gfgIkU66VyFLjKs5e0eohzNCu9NXQUs6VDRGICesUoXz
	 jvkBc+JcCLC/9vphUGFYLN7BtYkl2vOfnEjOw0nXMZxol0vCG+AkXf9p6NidKGwKjVPNq
	 mpu7gtJSj7+CFQxDhYk2fZUFAJ+4VLohwHhpLh3dR5oqQOHLsOZ2cCUTGGNMP16HGYKC8
	 k/SAXbuZzdX1m4OgnhB23W2iSYnjwjHArw+oqDQPOAXPpKseYF+29WzoWomFYnGiTgVLS
	 /l/7eGalrYOxZQaqzdZct9Rvkj5akZ4+H1LOJdqCrqevWLWCpzHONa7+oB+nnWnZkTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M64ylCbu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 758E5606A31C;
	Sun,  8 Nov 2026 22:27:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M64ylCbu
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id A82311F008A4;
	Sun,  8 Nov 2026 22:27:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794176870;
	bh=oTmAk1GKQZspBWagSAR6F1HfSEYd3TCl+TiacOmEg44=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=M64ylCbuWMtja8rZVExlsF4ZI/9WqdkiFcf5iv/pLa+jYVhNFw8AGPjQUTpa5KTcF
	 8DFYyyLPFyrwVUkgiNPgrLz0gn8OrCwyB/xDvu8jeE12Kx7m68Y/iozbWkcYekRtWq
	 gGDNmRh6vp9ETxfAnaNrqoj/88hQNl+DgWhpterjJQ/42K1EEY6kEdZUSI2TahKsRH
	 9Y7egByekL2FtbG+0cERTaJ+jEk/X7ak5JLdIMzfsa0J/7V1fH7btLhXYsKsh7K6Ox
	 6KXI3Ia/6MNM1xVmPn18CPn+9Gt6C+mC9b6aegbAiNnoHFgnJb5uSQnFXKee5H+BSj
	 IQWVNA/PsqvGA==
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
Subject: [PATCH v5 06/12] KEYS: trusted: TEE: Synchronize session lifetime
Date: Mon,  9 Nov 2026 00:27:12 +0200
Message-ID: <20261108222719.304712-7-jarkko@kernel.org>
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

The parent TEE device can remove the client device while live instances
keep trusted.ko loaded.

Update the static calls before invoking backend init() and reset them in
the case of a failure.

In the TEE backend, guard session context state with a mutex, publish
pvt_data.dev before registering key_type_trusted and sanitize pvt_data on
probe failure and removal.

When an active TEE has not been bound, reject seal, unseal and get_random
with -ENODEV.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 security/keys/trusted-keys/trusted_core.c | 15 ++--
 security/keys/trusted-keys/trusted_tee.c  | 86 +++++++++++++++++------
 2 files changed, 75 insertions(+), 26 deletions(-)

diff --git a/security/keys/trusted-keys/trusted_core.c b/security/keys/trusted-keys/trusted_core.c
index 0509d9955f2a..11d7d296d063 100644
--- a/security/keys/trusted-keys/trusted_core.c
+++ b/security/keys/trusted-keys/trusted_core.c
@@ -373,14 +373,19 @@ static int __init init_trusted(void)
 		if (!get_random)
 			get_random = kernel_get_random;
 
+		static_call_update(trusted_key_seal, trusted_key_sources[i].ops->seal);
+		static_call_update(trusted_key_unseal, trusted_key_sources[i].ops->unseal);
+		static_call_update(trusted_key_get_random, get_random);
+		migratable = trusted_key_sources[i].ops->migratable;
+
 		ret = trusted_key_sources[i].ops->init();
 		if (!ret) {
-			static_call_update(trusted_key_seal, trusted_key_sources[i].ops->seal);
-			static_call_update(trusted_key_unseal, trusted_key_sources[i].ops->unseal);
-			static_call_update(trusted_key_get_random, get_random);
-
 			trusted_key_exit = trusted_key_sources[i].ops->exit;
-			migratable = trusted_key_sources[i].ops->migratable;
+		} else {
+			static_call_update(trusted_key_seal, NULL);
+			static_call_update(trusted_key_unseal, NULL);
+			static_call_update(trusted_key_get_random, NULL);
+			migratable = 0;
 		}
 
 		if (!ret || ret != -ENODEV)
diff --git a/security/keys/trusted-keys/trusted_tee.c b/security/keys/trusted-keys/trusted_tee.c
index 6e465c8bef5e..ad9c7baddcef 100644
--- a/security/keys/trusted-keys/trusted_tee.c
+++ b/security/keys/trusted-keys/trusted_tee.c
@@ -9,6 +9,7 @@
 #include <linux/err.h>
 #include <linux/key-type.h>
 #include <linux/module.h>
+#include <linux/mutex.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/tee_drv.h>
@@ -56,6 +57,8 @@ struct trusted_key_tee_private {
 };
 
 static struct trusted_key_tee_private pvt_data;
+/* Do not hold this mutex across key type registration or unregistration. */
+static DEFINE_MUTEX(trusted_key_tee_mutex);
 
 /*
  * Have the TEE seal(encrypt) the symmetric key
@@ -67,6 +70,12 @@ static int trusted_tee_seal(struct trusted_key_payload *p, char *datablob)
 	struct tee_param param[4];
 	struct tee_shm *reg_shm = NULL;
 
+	mutex_lock(&trusted_key_tee_mutex);
+	if (!pvt_data.ctx) {
+		ret = -ENODEV;
+		goto out_unlock;
+	}
+
 	memset(&inv_arg, 0, sizeof(inv_arg));
 	memset(&param, 0, sizeof(param));
 
@@ -74,7 +83,8 @@ static int trusted_tee_seal(struct trusted_key_payload *p, char *datablob)
 					      sizeof(p->key) + sizeof(p->blob));
 	if (IS_ERR(reg_shm)) {
 		dev_err(pvt_data.dev, "shm register failed\n");
-		return PTR_ERR(reg_shm);
+		ret = PTR_ERR(reg_shm);
+		goto out_unlock;
 	}
 
 	inv_arg.func = TA_CMD_SEAL;
@@ -100,7 +110,8 @@ static int trusted_tee_seal(struct trusted_key_payload *p, char *datablob)
 	}
 
 	tee_shm_free(reg_shm);
-
+out_unlock:
+	mutex_unlock(&trusted_key_tee_mutex);
 	return ret;
 }
 
@@ -114,6 +125,12 @@ static int trusted_tee_unseal(struct trusted_key_payload *p, char *datablob)
 	struct tee_param param[4];
 	struct tee_shm *reg_shm = NULL;
 
+	mutex_lock(&trusted_key_tee_mutex);
+	if (!pvt_data.ctx) {
+		ret = -ENODEV;
+		goto out_unlock;
+	}
+
 	memset(&inv_arg, 0, sizeof(inv_arg));
 	memset(&param, 0, sizeof(param));
 
@@ -121,7 +138,8 @@ static int trusted_tee_unseal(struct trusted_key_payload *p, char *datablob)
 					      sizeof(p->key) + sizeof(p->blob));
 	if (IS_ERR(reg_shm)) {
 		dev_err(pvt_data.dev, "shm register failed\n");
-		return PTR_ERR(reg_shm);
+		ret = PTR_ERR(reg_shm);
+		goto out_unlock;
 	}
 
 	inv_arg.func = TA_CMD_UNSEAL;
@@ -147,7 +165,8 @@ static int trusted_tee_unseal(struct trusted_key_payload *p, char *datablob)
 	}
 
 	tee_shm_free(reg_shm);
-
+out_unlock:
+	mutex_unlock(&trusted_key_tee_mutex);
 	return ret;
 }
 
@@ -161,13 +180,20 @@ static int trusted_tee_get_random(unsigned char *key, size_t key_len)
 	struct tee_param param[4];
 	struct tee_shm *reg_shm = NULL;
 
+	mutex_lock(&trusted_key_tee_mutex);
+	if (!pvt_data.ctx) {
+		ret = -ENODEV;
+		goto out_unlock;
+	}
+
 	memset(&inv_arg, 0, sizeof(inv_arg));
 	memset(&param, 0, sizeof(param));
 
 	reg_shm = tee_shm_register_kernel_buf(pvt_data.ctx, key, key_len);
 	if (IS_ERR(reg_shm)) {
 		dev_err(pvt_data.dev, "key shm register failed\n");
-		return PTR_ERR(reg_shm);
+		ret = PTR_ERR(reg_shm);
+		goto out_unlock;
 	}
 
 	inv_arg.func = TA_CMD_GET_RANDOM;
@@ -189,7 +215,8 @@ static int trusted_tee_get_random(unsigned char *key, size_t key_len)
 	}
 
 	tee_shm_free(reg_shm);
-
+out_unlock:
+	mutex_unlock(&trusted_key_tee_mutex);
 	return ret;
 }
 
@@ -205,50 +232,67 @@ static int optee_ctx_match(struct tee_ioctl_version_data *ver, const void *data)
 static int trusted_key_probe(struct tee_client_device *rng_device)
 {
 	struct device *dev = &rng_device->dev;
+	struct tee_context *ctx;
 	int ret;
 	struct tee_ioctl_open_session_arg sess_arg;
 
+	mutex_lock(&trusted_key_tee_mutex);
+	if (pvt_data.ctx) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
 	memset(&sess_arg, 0, sizeof(sess_arg));
 
-	pvt_data.ctx = tee_client_open_context(NULL, optee_ctx_match, NULL,
-					       NULL);
-	if (IS_ERR(pvt_data.ctx))
-		return -ENODEV;
+	ctx = tee_client_open_context(NULL, optee_ctx_match, NULL, NULL);
+	if (IS_ERR(ctx)) {
+		ret = -ENODEV;
+		goto out_unlock;
+	}
 
 	memcpy(sess_arg.uuid, rng_device->id.uuid.b, TEE_IOCTL_UUID_LEN);
 	sess_arg.clnt_login = TEE_IOCTL_LOGIN_REE_KERNEL;
 	sess_arg.num_params = 0;
 
-	ret = tee_client_open_session(pvt_data.ctx, &sess_arg, NULL);
+	ret = tee_client_open_session(ctx, &sess_arg, NULL);
 	if ((ret < 0) || (sess_arg.ret != 0)) {
 		dev_err(dev, "tee_client_open_session failed, err: %x\n",
 			sess_arg.ret);
 		ret = -EINVAL;
 		goto out_ctx;
 	}
+	pvt_data.ctx = ctx;
 	pvt_data.session_id = sess_arg.session;
-
-	ret = register_key_type(&key_type_trusted);
-	if (ret < 0)
-		goto out_sess;
-
 	pvt_data.dev = dev;
+	mutex_unlock(&trusted_key_tee_mutex);
 
-	return 0;
+	ret = register_key_type(&key_type_trusted);
+	if (!ret)
+		return 0;
 
-out_sess:
-	tee_client_close_session(pvt_data.ctx, pvt_data.session_id);
+	mutex_lock(&trusted_key_tee_mutex);
+	tee_client_close_session(ctx, pvt_data.session_id);
 out_ctx:
-	tee_client_close_context(pvt_data.ctx);
-
+	tee_client_close_context(ctx);
+	pvt_data.ctx = NULL;
+	pvt_data.dev = NULL;
+	pvt_data.session_id = 0;
+out_unlock:
+	mutex_unlock(&trusted_key_tee_mutex);
 	return ret;
 }
 
 static void trusted_key_remove(struct tee_client_device *dev)
 {
 	unregister_key_type(&key_type_trusted);
+
+	mutex_lock(&trusted_key_tee_mutex);
 	tee_client_close_session(pvt_data.ctx, pvt_data.session_id);
 	tee_client_close_context(pvt_data.ctx);
+	pvt_data.ctx = NULL;
+	pvt_data.dev = NULL;
+	pvt_data.session_id = 0;
+	mutex_unlock(&trusted_key_tee_mutex);
 }
 
 static const struct tee_client_device_id trusted_key_id_table[] = {
-- 
2.47.3

