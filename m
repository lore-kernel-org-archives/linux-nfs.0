Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794456195;
	b=3T3RB94BTRmndxsOBkVrx26WztWfxJ3093T83Z8al8is7Ktx4j2cI6Yu/EtVJzlTAJ0a
	 eI1vmy0Y2Ulcn8GTp/AKxZQVisAsln/rSHDCAQxvDjzDYasRJdeecN3CZ/dDJ6oxn4eJf
	 3j6lIBVTX3stPRLxu6HURO4xUfUaOecj9RK978ic+lPZmr1nNSzUdgrZHPgzwlTl0bh2Y
	 Day5DEg1HUp2Co5zEI0opa5+6m3c287f3fRHuh9wgoDvzlXZu007Ml7RXewQPbmOnKIKX
	 UnxD6s8KozDHbHZCVH4orwBysqnO+CpFVcUBAqN4xJ59lZWus1f7xebtNoBAYrzcOYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794456195;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=0tB8T/8/Vf4fFGUJiMpqK6eVISBvnS8fXk8P1RE1vVo=;
	b=oGFoWMLD8Ey5SFd5mz8QnkY4o/sTSSbnp+GaBNRQpXMIJw6QGgpdaXD3qDNIzjvYJdQr
	 9VxXdQsDkMB5qZzts4etDIp0Q8+rdSmJzHXo3wuw90l5V4z+yiXyCBNEu/hnMTJgbUwUw
	 /u5LW+SsxNbr33bHq/C0IIpa46C4p1Kmu2Xhx3rqEv16WETcnWhF5DWXoVS7pHBEdYIvY
	 zoBu/T0ZYDufR5bC0VVlrKbnY9zhpIesN3bsTRk/bkSlLyucbVm6yS6n0vQZGDJALIOai
	 YhMDqaYOr3Jt0irLgrscBirafvzXVoB7Q5cxbzUEYSXkGo1EO469xJnwI/K4UbLBsgg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gEAMwwna;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 7C5C6606A8B0;
	Thu, 12 Nov 2026 04:03:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gEAMwwna
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 140C51F00A0E;
	Thu, 12 Nov 2026 04:03:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794456194;
	bh=0tB8T/8/Vf4fFGUJiMpqK6eVISBvnS8fXk8P1RE1vVo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gEAMwwnaYqX34fFI1L6cLOgpLKyR0LusNxBdzSFD2PFn3/D66z2E+fIb93s03ZKeg
	 3soPSyqrDicFKlqxQiYwmyjd9MPBl8YdCsAZZlFrrQtCoOY/WIX9atxv4c1w8Gvika
	 /tqIFl3e2KHABXoDZAzTEozewk7TbBMRFRX1Jv8s79PrFgmuTf3U0ZKzL0N2UUlEUC
	 81PGWvdIJuuJOVAPDzE+AYGDGHo6Zls7WXw1xXo7UJ9cNLuKIlrr3WD7hB0n9Q8ij9
	 zHtWijfT9mUmDk43yUc1kHSwjC/7Gd4WbAYAYJ0OHf0L6Q/wTwdZKhR02g7dyxlDev
	 ousSHbuqhBhDw==
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
	Vasily Gorbik <gor@linux.ibm.com>,
	stable@vger.kernel.org,
	Sumit Garg <sumit.garg@oss.qualcomm.com>
Subject: [PATCH v6 07/13] KEYS: trusted: TEE: Synchronize session lifetime
Date: Thu, 12 Nov 2026 06:02:36 +0200
Message-ID: <20261112040242.247168-8-jarkko@kernel.org>
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

The parent TEE device can remove the client device while live instances
keep trusted.ko loaded.

Guard session context state with a mutex, publish pvt_data.dev before
registering key_type_trusted and sanitize pvt_data on probe failure and
removal.

When an active TEE has not been bound, reject seal, unseal and get_random
with -ENODEV.

Cc: stable@vger.kernel.org # v5.15+
Fixes: 0a95ebc91305 ("KEYS: trusted: Introduce TEE based Trusted Keys")
Reviewed-by: Sumit Garg <sumit.garg@oss.qualcomm.com>
Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 security/keys/trusted-keys/trusted_tee.c | 86 ++++++++++++++++++------
 1 file changed, 65 insertions(+), 21 deletions(-)

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

