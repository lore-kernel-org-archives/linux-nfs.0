Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552575;
	b=1p36JJWZaeTjT01OnQniD26jUzO+LZh8bXjTsUVnkxZnf/tsdPI6TUR4kTFM7yXfu5/B
	 rman9fvjBBVDmAEzzdTi9Rz8yeUCWo/17jGLwdSBdFFTe0MQFsnF8vfuOpDK9qROjD7kI
	 YGR1yoFXXsY1IW7n41MQHF9XYBZQLYf3kcxhrCMIfI856ztGgfQY0N9Mo6s4ZsSAPIJTL
	 nE8fT+lesRNxWtV8UUv/LSFS7SF3kwYhIdolDL57gQ+nLmLmSI87xpYjg1NFp9uIgotsW
	 pi+3pakcXVEH5HvOn03qpgW6CPhA3ziQEatB2Qg8TUEfUK2VKTIxnA85y/yJ2ceY0cA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552575;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=uKOjlqXGHLJlkCL9f8d9rTFDqw8tpf+tLxaHjmSpkKA=;
	b=0Un7N6cx1zehA3UFalbOhCndMLr7ta6yfoo4eao19b00PIXwxYJTrDupgB42THNs471n
	 swrUSwaXOCEF3PPkT8DVCxKJzJXPWDzfPRIyAnnwnqU+5fQfQGlQgsAkeVvqpsbhqf4YD
	 hyB8lcZ+zMei9O5beNeYHKSR+ChT3OBFxk4ftDIBI3L91NCz8mDZHKicA2T9wiY4fesv6
	 +7vvvB72EC2sM0zfmT1oa10tUqA7Y9yYL8EuO+Uv9CmeKyZWxOTtDJsF4SjVN3gBQAIt6
	 D88WLLto+iz819lAdKFgY30arcH8I7coXQnrD6NKB01dg4sEre4DPR1Pm3/44TNnQoA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=Gv9RjMyE;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C9BC760A3828;
	Wed, 21 Oct 2026 03:16:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C9BC760A3828
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=Gv9RjMyE
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552572; bh=U300U6JBBikbKqzajlQay6DlU/YNXPzZuXT3M0eIs4w=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=Gv9RjMyEN8DbUWWtlROM7CV/VPVlno1DteTYy1x7+1M9V/i8RwaxOw6oJzeNuTbLz
	 ixX2I/stDeS4UAUFFgMCT5fjyvgHP4ZOoLMqw1PfgCw1TPOTmxFWk1dFlVcNHa5fHN
	 N9BBl/EmRaapJtzyksGHAGehIgqlLcySEG21zDVoIAKQZYkCVQ6lzSyqpTvfVMbZZz
	 VOAKO5Q8PjSlEH03zYu5l0CF6lVzcrfsbuyqGxOKuBFhNZy9huAnhMvTiNX0YC1Xvi
	 LxOhMkutE2vjhlCwKBcfVIGkBjX1y4FJTvacXdcTmG5TIYbduv4qONCSz1P9ZMZCeF
	 5rzVX5lxx9IXQ==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 277538A092D;
	Wed, 21 Oct 2026 05:16:12 +0200 (CEST)
Message-ID: <91ba959f368000c0946cb846af3cbb8c97f7e005.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 15/41] SUNRPC: name UUID and GUID users to gssd as
 uid_r=
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:15:35 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

gssd learns the user of an upcall as a 32 bit uid. UUID and GUID users
would all reach it as the overflow uid and share its credentials.

In the text (v1) upcall, name such a user as uid_r= with the text form
of the id instead of uid=. gssd versions that don't know uid_r= find no
uid= and refuse the upcall, so nobody ends up with the overflow uid's
credentials; where gssd's user namespace can't see the user, the upcall
names no user at all and fails the same way.

A downcall for such a user starts with uid -1, which is never valid,
followed by the user as __kernel_uid_r_t; downcalls for classic uids are
unchanged.

The binary (v0) upcall has room for a 32 bit uid only: fail it with
-EACCES for UUID and GUID users.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 net/sunrpc/auth_gss/auth_gss.c | 44 +++++++++++++++++++++++++++++++---
 1 file changed, 41 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8ddc65e894..5e9e2cf4e9 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -18,6 +18,7 @@
 #include <linux/sched.h>
 #include <linux/pagemap.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/uidgid_r.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/auth_gss.h>
 #include <linux/sunrpc/gss_krb5.h>
@@ -438,10 +439,23 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 	struct gss_api_mech *mech = gss_msg->auth->mech;
 	char *p = gss_msg->databuf;
 	size_t buflen = sizeof(gss_msg->databuf);
+	char idbuf[KID_STR_LEN];
 	int len;
 
-	len = scnprintf(p, buflen, "mech=%s uid=%d", mech->gm_name,
-			from_kuid_munged(userns, gss_msg->uid));
+	/*
+	 * A UUID or GUID user is uid_r= in its text form instead of uid=,
+	 * which gssd versions that don't know it reject rather than taking
+	 * an overflow uid. Where gssd can't see the user at all, there is
+	 * neither, and the upcall fails.
+	 */
+	if (uid_is_legacy(gss_msg->uid))
+		len = scnprintf(p, buflen, "mech=%s uid=%d", mech->gm_name,
+				from_kuid_munged(userns, gss_msg->uid));
+	else if (kuid_has_mapping(userns, gss_msg->uid))
+		len = scnprintf(p, buflen, "mech=%s uid_r=%s", mech->gm_name,
+				kuid_str(gss_msg->uid, idbuf));
+	else
+		len = scnprintf(p, buflen, "mech=%s", mech->gm_name);
 	buflen -= len;
 	p += len;
 	gss_msg->msg.len = len;
@@ -536,6 +550,15 @@ gss_alloc_msg(struct gss_auth *gss_auth,
 	err = vers;
 	if (err < 0)
 		goto err_free_msg;
+	/*
+	 * The binary v0 upcall is a 32 bit uid: UUID and GUID users would
+	 * all be the overflow uid there and share its credentials.
+	 */
+	if (vers == 0 && !uid_is_legacy(uid)) {
+		put_pipe_version(gss_auth->net);
+		err = -EACCES;
+		goto err_free_msg;
+	}
 	gss_msg->pipe = gss_auth->gss_pipe[vers]->pipe;
 	INIT_LIST_HEAD(&gss_msg->list);
 	rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
@@ -752,7 +775,22 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 		goto err;
 	}
 
-	uid = make_kuid(current_user_ns(), id);
+	/*
+	 * A uid of -1, never valid, is followed by a __kernel_uid_r_t: the
+	 * reply to a uid_r= upcall of a UUID or GUID user.
+	 */
+	if (id == (uid_t)-1) {
+		struct __kernel_uid_r id_r;
+
+		p = simple_get_bytes(p, end, &id_r, sizeof(id_r));
+		if (IS_ERR(p)) {
+			err = PTR_ERR(p);
+			goto err;
+		}
+		uid = make_kuid_r(current_user_ns(), &id_r);
+	} else {
+		uid = make_kuid(current_user_ns(), id);
+	}
 	if (!uid_valid(uid)) {
 		err = -EINVAL;
 		goto err;
-- 
2.56.0

