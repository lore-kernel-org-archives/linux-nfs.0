Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.180
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794082857;
	b=kIMKEbSePCSsSVBW73dOd9rYLojtpk8tCRSkdIUioThReGjiQMYbfc/41XTuLFfKCcy5
	 1zd5NQCqgajhSpRpSwsFNm48K7f2sR7RWYcoeSH8f80Bs3bq7tgLdz8pX2C9HdMFiZYKn
	 UYqcS91se/wVdW6zSdgTX7n+RGsYfdytPNN42mQbUwDa4pu2q490YwAeJydl0WFGkYJtw
	 jIefDF6KsmBqk828VRZIeJzhI0B1SM4PjGj6FYsu4I0sStSH4wzH+zhJkRGJjkGfUnCp8
	 1nVw8h/FMEIVSXa/kVBcfe2P/aD8TkKO/kEJ0yxq0kLIdaYOO2Ljk813D6OuKH53VGQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794082857;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=cMIDy6YiKuskLuF6bgMiHdorFKnpoFKHC/9O868HH+g=;
	b=5gWiRDghlH7m5KnEBUAVsLVlAi2gyo7lyR8qex4liiIGPYYqi1geaOz2cY2XvT9Vh7Yp
	 88xJqFTddD5Kaplv/bvKE7pg+oTiwHVlB149RtdIaJ2hjml55hA1LoUwIkfE9SNwg3voq
	 73OBRNzEPm1uUy/1K/gr7eEvu2PxEnEPgeCp0PGahNGf1mQN8hxXmD9mbSKphyf8kIu+y
	 nZOj+/SsUxH7JQJzewl8KaSZ2rJSR4FX8fIzaZ7JAEhN2LQaNqiTjlGos2msismsDwBkX
	 1J58vVX5raBNEpesomR/rAU9bE8IBwYHWjTltWkz7c5FnclLqentyKupTyCXDQRA4Ew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=XttTIw0P;
	arc=none smtp.remote-ip=74.125.82.180
Received: from mail-dy1-f180.google.com (mail-dy1-f180.google.com [74.125.82.180])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10EF0606D802
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 20:20:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 10EF0606D802
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=XttTIw0P
Received: by mail-dy1-f180.google.com with SMTP id 5a478bee46e88-33bb5afa736so2367eec.1
        for <linux-nfs@vger.kernel.org>; Sat, 07 Nov 2026 12:20:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794082856; x=1794687656; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=cMIDy6YiKuskLuF6bgMiHdorFKnpoFKHC/9O868HH+g=;
        b=XttTIw0P9Fg741Kv0LgJYN9lGqLipPOOGHdoaR6W698rvSPs6Dmjm+EZwfo7buJeoi
         W2ETUUKAa3UCWv59uMBQG+JKrTB8rNfBaIsS9X/hHB2W0Yd8WhPFecvUiTmLVgvNxxMy
         N2F02qHemCKUfoWRbWoC908T/FNylTkKJ/a3+vmL3dkZSkfb29HYLApIzGo//ZX9fkbP
         Lao1CTEBKSMhAcjLwUvtFR0B910bOyULJYtJIiXiRR5B/tzh/GOl4AfKI5shztKtpiZ/
         r1ehulzgOHBEKiDkT1ZLxhfzPsyweKnxs43/Vm3FNicQG84E5olE7q2ekNsEsfy562Bu
         belQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794082856; x=1794687656;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=cMIDy6YiKuskLuF6bgMiHdorFKnpoFKHC/9O868HH+g=;
        b=cM06bsaJm9ZPrTbu4Ui3vDLfY6FOn+SH8z4E7X53simnlktblZGsx/75qjTzk37ilH
         a7LBozpIUsP2X++/dYQz1Fz0xfYg9L0Tv6W4haX2Msc+Z4jnXcNaoVTxN6NM1vPVpEzi
         ixtzVq1M+ceJBUXk3AQYdwSSlayKVIbAKuEVn9A7Y0kNvh+9GSCpdVEM4+JhgfATMhPc
         gI1I5GTbCsdPgSlXbl0VR742Kfei3LqAa8idXrqiWvW9EbwhmpU1iGO+xexhP5hKvDuz
         ONaBrc5wrirFEd9szGco1KKdo5NNSveqiJQQT2AZjpeanHH34VZQdwWJ29oni38KNYHn
         EEBQ==
X-Gm-Message-State: APuU4Z/g7VEc2y/7FSJm72lVNMmX3gh16bHEtJdaH/uPgJ5OxlEwyVlQ
	6qMAHOl3nS7FlnRbg+7YOWCMJSWpHwygqMatGapwH9XYPRbUWrJs9GCrup2PK2KM
X-Gm-Gg: AYBFou1XtSA484Kygpq7GDPorJtk2itb5bjrc+cS0L0YLuf+GbZ0MM+lm8Q3TomkQB5
	qRtoYDsszm4KponaiXLvzDk1iyZ2q3MhFPRP8oKNcsGk4wZNCCV5Vhc+T6EvgkRfhlfIU5J4LEv
	o4pxJKZPdLczXnIk/4y3m+oyz3PdZno9rxS4W69/yzriu28IVXBWoUxyuZvfCJll1BX1OcXEqKF
	uWQ/kM2NvnRMBGAL/DDm7mVZDqemMwslbX7DuYqfw/rub+gcfJgR5uzLF8mmyXx4erID+x+2fw1
	vn1xs1R7k8fNYUnyRyRiwM6rjG0WQUWf6BfXVzVsX92ykFrZwWZWkWlp3pFUdlJDbVrKPs9A6MS
	FICa5j4kBL2aoaaVYp/UxIBjZt2AW9k6tStlvnMDodgtnDj/2E6RQupKUbVmNgmwTgO5cE0folp
	i8HJd/dTTJZTRnOBpiovEaj3xBzH72ynUEjds3TP5zJAY+jUac4jpBtRmxf+iuXx4/x+loebYN3
	IBlAnTFX1EUnuu+UVEuUuAXrs+0eEORbiTcYQmEv91XYUZAHSgt5LVYqyYbws9Qomi0W8Wffwwn
	HjRlSpTJ5ZK6H2zkYGkMiganJbYT3nMAtWm/r5Px
X-Received: by 2002:a05:7022:5f1b:b0:165:be2f:c56e with SMTP id a92af1059eb24-1b25d3042c1mr11536099c88.2.1794082855717;
        Sat, 07 Nov 2026 12:20:55 -0800 (PST)
Received: from localhost.localdomain ([142.249.36.161])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1b3771eccb9sm624003c88.19.2026.11.07.12.20.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 07 Nov 2026 12:20:55 -0800 (PST)
From: Chengyu Liu <lui2012qwq@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	cel@kernel.org,
	stable@vger.kernel.org,
	Chengyu Liu <lui2012qwq@gmail.com>
Subject: [PATCH] nfs: fix cl_acceptor replacement racing the callback reader
Date: Sun,  8 Nov 2026 04:19:26 +0800
Message-Id: <20261107201926.56191-1-lui2012qwq@gmail.com>
X-Mailer: git-send-email 2.25.1
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

nfs4_proc_setclientid() replaces clp->cl_acceptor with a plain kfree()
plus assignment, while check_gss_callback_principal() on the callback
thread reads the field locklessly.  The kfree() and the assignment are
even separated by rpcauth_stringify_acceptor()'s allocation, so the
field points at freed memory for a real window and the strcmp() in the
callback's authentication check then reads freed memory.

Both sides are drivable by the server without any client-side
privilege: the write side re-runs whenever the clientid is
re-established (lease recovery after NFS4ERR_STALE_CLIENTID, or v4.0
trunking detection), and the read side runs on every NFSv4.0 GSS
callback.  A malicious or compromised server can flood CB_COMPOUNDs
while forcing the client to re-register, and retry indefinitely.

Turn the field into an RCU pointer: the writer stringifies into a
temporary first, then swaps under clp->cl_lock with
rcu_replace_pointer() and frees the old string with
kfree_rcu_mightsleep(); the reader uses rcu_read_lock() and
rcu_dereference().  The final free in nfs_free_client() happens after
the callback service has been torn down, so it needs no grace period.

Found by static analysis and confirmed with a KASAN reproducer: a
slab-use-after-free read in check_gss_callback_principal() on the
client's NFSv4 callback thread, on the string freed by the kfree() in
nfs4_proc_setclientid() during lease reclaim.  Under the same flood,
every lease-recovery window also produced "NFSv4 callback contains
invalid cred" rejects, which we never observed outside a window; this
is consistent with strcmp() reading the reallocated contents through
the dangling pointer.  The PoC kernel adds a kasan_check_read() witness
immediately before strcmp() because lib/string.o is built without KASAN
instrumentation, printk counters on both sides, and a udelay() to widen
the race window; the allocation and free sites remain unmodified.

Fixes: 1047ec868332 ("NFSv4: Fix leak of clp->cl_acceptor string")
Cc: stable@vger.kernel.org
Signed-off-by: Chengyu Liu <lui2012qwq@gmail.com>
---
Full dmesg and the complete reproducer kit follow in this thread.

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index bc282b744f34..d902c3e16a25 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -289,8 +289,18 @@ check_gss_callback_principal(struct nfs_client *clp, struct svc_rqst *rqstp)
 	 * Did we get the acceptor from userland during the SETCLIENID
 	 * negotiation?
 	 */
-	if (clp->cl_acceptor)
-		return !strcmp(p, clp->cl_acceptor);
+	{
+		const char *acceptor;
+		bool match = false;
+
+		rcu_read_lock();
+		acceptor = rcu_dereference(clp->cl_acceptor);
+		if (acceptor)
+			match = !strcmp(p, acceptor);
+		rcu_read_unlock();
+		if (acceptor)
+			return match;
+	}
 
 	/*
 	 * Otherwise try to verify it using the cl_hostname. Note that this
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 60386330aeec..517b9485b7af 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -265,7 +265,7 @@ void nfs_free_client(struct nfs_client *clp)
 	put_net_track(clp->cl_net, &clp->cl_ns_tracker);
 	put_nfs_version(clp->cl_nfs_mod);
 	kfree(clp->cl_hostname);
-	kfree(clp->cl_acceptor);
+	kfree(rcu_access_pointer(clp->cl_acceptor));
 	kfree_rcu(clp, rcu);
 }
 EXPORT_SYMBOL_GPL(nfs_free_client);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 04b1987115d5..433ea231ea5a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6664,9 +6664,16 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 
 	status = nfs4_call_sync_custom(&task_setup_data);
 	if (setclientid.sc_cred) {
-		kfree(clp->cl_acceptor);
-		clp->cl_acceptor = rpcauth_stringify_acceptor(setclientid.sc_cred);
+		char *acceptor, *old;
+
+		acceptor = rpcauth_stringify_acceptor(setclientid.sc_cred);
 		put_rpccred(setclientid.sc_cred);
+		/* Serialize updates to cl_acceptor */
+		spin_lock(&clp->cl_lock);
+		old = rcu_replace_pointer(clp->cl_acceptor, acceptor,
+					  lockdep_is_held(&clp->cl_lock));
+		spin_unlock(&clp->cl_lock);
+		kfree_rcu_mightsleep(old);
 	}
 
 	if (status == 0)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 34d294774f8c..ee6f57bc76aa 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -54,7 +54,7 @@ struct nfs_client {
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
-	char *			cl_acceptor;	/* GSSAPI acceptor name */
+	char __rcu		*cl_acceptor;	/* GSSAPI acceptor name */
 	struct list_head	cl_share_link;	/* link in global client list */
 	struct list_head	cl_superblocks;	/* List of nfs_server structs */
 

-- 
2.25.1
