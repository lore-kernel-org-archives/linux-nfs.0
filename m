Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0C053C5826
	for <linux-nfs@vger.kernel.org>; Mon,  3 Aug 2026 09:18:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785748730; cv=none; b=m8FttNmvE7+SdHkDNlXJ1XDUaV4OLhrfZjwngL7mFeKOvXrOrQL5D+0jsHB835gluPu5K+uTEfQOlo9zTU9tuXLQStMB3kCjs4cWI3du1d927MFGP6IXK/tVkmn4LIksW099DYoMGVeSd7iwlXXPiiYAjAScWjVUgrSKfjgIzd4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785748730; c=relaxed/simple;
	bh=bqdhnVDcs6Zgsj2SdRzxXuWePCxIzjTm9QfphD4KaTI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=PaTHhXZl0hqZiWvm3wkF7DrxG9adX7oxk3RqKyffT5H6z6KhrSAbDEnJ87jP5lvbtDQKmgiKI/qXJGOjTVDHRZbaqmbxzv1eSK+zk6Zb7TQlJDx2A9olTf+wGwu4tkgZuCzdger2sPIwhcwyw4+DIWVVw6en8ULoRIcmw4m0NsU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Uw6h/Dv7; arc=none smtp.client-ip=209.85.128.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Uw6h/Dv7"
Received: by mail-wm1-f45.google.com with SMTP id 5b1f17b1804b1-496b7622a83so11759225e9.2
        for <linux-nfs@vger.kernel.org>; Mon, 03 Aug 2026 02:18:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1785748724; x=1786353524; darn=vger.kernel.org;
        h=cc:to:message-id:content-transfer-encoding:content-type
         :mime-version:subject:date:from:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=L0Why+wsEH2NC6fGMzVjI2W/9nKKcfVedLRTdHacXB4=;
        b=Uw6h/Dv7gtCzVAEBGhSFf2un61jaP2wagVYuPOHS7rN/wMEskTY9Fn7R4JPrruTOz/
         zD18lt2oIoX6Coe4KFlu0W76O0X9kux+oekpwJyyy+wIk5dGjj1+4tfNneRxsL/gzcb4
         8B936gnYh5g+2DtiGvNgtFcPSGXgVoNxLwa8s4o9A63BL6zGcFQ+oG7BqL7YIp6Hm7vZ
         vY3VT/MbO5zH6CxroUzGgGCQS2OqilUJSnmdDOlYp/qM2eG857weVOLO6KIpx9iJr3B7
         INCXhW+VsVtJ2EoHJok/HThuLoP5x7zIZH5DKPvMjXaPfEMpKHJD6jpmTyuWxMuLBXMC
         czHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785748724; x=1786353524;
        h=cc:to:message-id:content-transfer-encoding:content-type
         :mime-version:subject:date:from:x-gm-gg:x-gm-message-state:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=L0Why+wsEH2NC6fGMzVjI2W/9nKKcfVedLRTdHacXB4=;
        b=h/HBPcQjBt3Y+skWAZ5A7rXQCk8fnw2JZsMmi1URccENf4Ni5KwulGe7bFvcPSgwfa
         GYspV43CdF54Qa2UEjKjd80026d7h8S2Z4i0DLG5O+qKsrI7AQYC39t/te+SQRkz9UAj
         dC4ygzpPAcUWpchc4lyrDDtUO5xUcQInWEhYJglqKlH2GDVJVspnybhZxw5xPLnJwucF
         kRq4glD6sUmGpouTiHpZ1oNTXhPGfvqOmvuIOpSklpgcpMXW+eyGeo7fZ5pUV2OHFU+m
         aPIcMqd+g6rWpL9uu/gtfsokhEGX59fS/TisDhFfzPu4AfNHdlklEk5qqMw1dufTuwHm
         O/Qw==
X-Forwarded-Encrypted: i=1; AHgh+RqdJBPH/psQIZGa4d4BnbcTD2/duB6l14fA/JEsqdA6KV3swMsdMEAbFdZopsDwmQejN2uyADnAob4=@vger.kernel.org
X-Gm-Message-State: AOJu0YzYyQxh56MPeKw87rcss6UfTli3K1Lni1nHxz/C/il/0jh5B1sV
	IKPGmAFQU5JJfZkN4+s99h5NUowgl110MgulxJpSQTTAVqYCzIzF6275
X-Gm-Gg: AR+sD10k0pVFVlfluaIbclDX+mYe893UPdo2y0xPMD3w9LKh6yL0O7BvWhTd3QZQYPV
	ZMio0TmzD8cno0r8gnIA9aQ4SF5sy1xPXOC6FWtkbBJv/CI1Kq6C3LwjP+mYF3ztJ5MtqaLZy2F
	ZzRJLFa7bAJgrqWgVGViDx2hDx+xD/qP80XqCSqg4UE8JJ1PS7UaChVFb2S/4dQ9LEgxzJcdkCo
	E1Dc/ugUY7E+U2Q2XFcU8Ibv/fCUxYFX7o2wXRrLw/jb9S+t2wNY9Zr7dJyLV/eBpCRzg6EAVN3
	T+4wrjrn8QTG49EJONavdgLe8M7GLJdeouxQciVCcZoCouC+aaAiHTSBrJDJRrkluEeFy+ZtjbU
	OXoq3Y5Z3wjJJm5EKHn5NK6qtf2yMQY107vffD2TslJIFNZOxqUXqKitk9CC8R9J7cgxDfaK6ac
	O4lI2pj2AUF2c1hSVFLmvHWg+EnJS9szFyxgxBZE917XgFAZRF7EWrZN1LYx2Dz8Ysoos68IW5P
	kv2wVNMvO3z4q8WK/Pztvhxbv+Ip6Dol72B68ZvlNPJYGsRNYmml5Dw
X-Received: by 2002:a05:600d:6405:20b0:495:5e86:4e11 with SMTP id 5b1f17b1804b1-4980c672c9fmr151889815e9.12.1785748723540;
        Mon, 03 Aug 2026 02:18:43 -0700 (PDT)
Received: from valmpani.valmpani (cgn-195-14-217-60.nc.de. [195.14.217.60])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-47fd41d0064sm29956137f8f.5.2026.08.03.02.18.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 03 Aug 2026 02:18:43 -0700 (PDT)
From: Vasileios Almpanis <vasilisalmpanis@gmail.com>
Date: Mon, 03 Aug 2026 11:18:29 +0200
Subject: [PATCH] NFS: sysfs: fix use-after-free on delayed kobject release
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260803-nfs-v1-1-034176dab4a3@gmail.com>
X-B4-Tracking: v=1; b=H4sIAORccGoC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDCwNj3by0Yl2DZLMkcyNLE/NkI2MloMqCotS0zAqwKdGxtbUAuoMNZFU
 AAAA=
X-Change-ID: 20260803-nfs-0c6b72947c23
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Vasileios Almpanis <vasilisalmpanis@gmail.com>
X-Mailer: b4 0.14.2
X-Developer-Signature: v=1; a=ed25519-sha256; t=1785748722; l=2658;
 i=vasilisalmpanis@gmail.com; s=20260731; h=from:subject:message-id;
 bh=bqdhnVDcs6Zgsj2SdRzxXuWePCxIzjTm9QfphD4KaTI=;
 b=swsNU4eQbh8dAPLgHpAAoMIebwRi8fkX09nlwq8suqnzgEA/VaN4Sfwi4/wpjCHMstSkEa1sE
 K+fgUcMFaDcD4NXWgsUHYpH9FpLiaKk9IU1Q+XeyflG86CSEU4acOTt
X-Developer-Key: i=vasilisalmpanis@gmail.com; a=ed25519;
 pk=gn5Uo6yL8Tlpq5uATxA3nqoq+U8eWLRbjD+bOk0qSpU=

struct nfs_netns_client embeds two kobjects and is freed by
nfs_netns_object_release(), the release function of nfs_net_kobj.
Despite that the first one, p->kobject lives in the same allocation.
Nothing keeps the allocation from being freed before p->kobject
has been released.

When CONFIG_DEBUG_KOBJECT_RELEASE=y each release is instead deferred to
a delayed_work embedded in the kobject, with an independent random
delay, and nfs_net_kobj frees the allocation first in some of those
cases. p->kobject's timer is then left armed inside freed memory, and
the following splat appears:

  [  139.805951][  T131] kobject: 'nfs_client' (ffff888027fdb800): kobject_release, parent 0000000000000000 (delayed 300)
  [  139.808019][  T131] kobject: 'net' (ffff888027fdb898): kobject_release, parent 0000000000000000 (delayed 100)

  BUG: KASAN: slab-use-after-free in __run_timers+0x932/0x980
  Write of size 8 at addr ffff888027fdb868 by task swapper/0/0

Reproduced on a KASAN kernel with CONFIG_NFS_FS=y and
CONFIG_DEBUG_KOBJECT_RELEASE=y by:

  for i in $(seq 16); do unshare -n true; done; sleep 20

Give p->kobject a reference on nfs_net_kobj for its whole lifetime and
drop it from nfs_netns_client_release(), so the allocation is always
freed after p->kobject has been released.

Fixes: e96f9268eea6 ("NFS: Make all of /sys/fs/nfs network-namespace unique")
Signed-off-by: Vasileios Almpanis <vasilisalmpanis@gmail.com>
---
 fs/nfs/sysfs.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/sysfs.c b/fs/nfs/sysfs.c
index 3a197252a1329b30b7b957ee97a437bf18aa5d5b..a5ea51b5935ae700b32123da9ddfb676fa76889b 100644
--- a/fs/nfs/sysfs.c
+++ b/fs/nfs/sysfs.c
@@ -126,6 +126,7 @@ static void nfs_netns_client_release(struct kobject *kobj)
 			kobject);
 
 	kfree(rcu_dereference_raw(c->identifier));
+	kobject_put(&c->nfs_net_kobj);
 }
 
 static const struct ns_common *nfs_netns_client_namespace(const struct kobject *kobj)
@@ -187,6 +188,13 @@ static struct nfs_netns_client *nfs_netns_client_alloc(struct kobject *parent,
 			return NULL;
 		}
 
+		/*
+		 * nfs_net_kobj's release frees the allocation that p->kobject
+		 * itself lives in, so p->kobject holds a reference on it for
+		 * its entire lifetime, dropped by nfs_netns_client_release().
+		 */
+		kobject_get(&p->nfs_net_kobj);
+
 		if (kobject_init_and_add(&p->kobject, &nfs_netns_client_type,
 					&p->nfs_net_kobj, "nfs_client") == 0)
 			return p;

---
base-commit: 075b74841bd0065a3bda3440873c747938e69b68
change-id: 20260803-nfs-0c6b72947c23

Best regards,
-- 
Vasileios Almpanis <vasilisalmpanis@gmail.com>

