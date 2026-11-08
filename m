Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794129561;
	b=YwrXnNOW4ySR/uNxvAjpXExEND9jqkLeb7txjvAWhULmb6QN9ITxFgdh0LyNmnpoKPGm
	 iy8HIRJClxvOaZFrn5Bh+TeEeg4XJ6wOcIM8NbUMG7EnN/uN1QiloqldZEUEUV7CRW+AW
	 yMJEbY2FXEoclcrtlOPyq4GERd8CELC+ixEAf6mn/pEpGNH0j8lSrx96XheHDciGk2/MZ
	 TX5hJQhcfu21pYfnowqUjJ9zAZtWse7VK5gljdrH3Vz6LiRYuDsKpifB3n1h7eku18zAz
	 llMGQp9qnfweIN99fDETxaZn+Py5kjawUiruSZ9hpxuooD1LVSn6VwF2v2068LrsOhQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794129561;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=6uUpvL+YwLioblRQLbYSDsaQDa3iQgozYi8OfO4zbek=;
	b=o4OM3Cj4g2iwaujecWcICNGm9nCvQZvGUaJJnfgA3ojk5JlStETSf6KuipRkJB8p1RQ/
	 W/OnpvHXiOng6NQCm6gaNrwHhFYzBzcJ8hTnYUjdwDtV2cAnUem+wkrzBGu0W1gpaNA9j
	 t39wJP7GK5GmwWShXGxMZExpbABm3pw3H/Y6ry3ptnAEMdkCG6zPcXAtUui5zqS3BVtAX
	 VLGIiEYtFxcSplcVO3TOwOqzpGqSvT10psLjjDv6ABjmEH6aG80a29Ynjq8UFdk3W0Bq5
	 SDMdvmLNKen81fSpakrR7/mMk0FqrDfDduLY4WrD633V/VfbY+C9HfNe2ncLNgYlCUw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=RtwTKzds;
	arc=none smtp.remote-ip=74.125.82.54
Received: from mail-dl1-f54.google.com (mail-dl1-f54.google.com [74.125.82.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A733606A320
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 09:19:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6A733606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=RtwTKzds
Received: by mail-dl1-f54.google.com with SMTP id a92af1059eb24-1adbf62dd31so9313c88.0
        for <linux-nfs@vger.kernel.org>; Sun, 08 Nov 2026 01:19:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794129560; x=1794734360; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=6uUpvL+YwLioblRQLbYSDsaQDa3iQgozYi8OfO4zbek=;
        b=RtwTKzdsFGiwBACSqeOAkR+dkCeWYMGQNkrNYFgTXikDH3stO1cn+aJfGTK/Dty+w6
         QKueq5ZHucEL1R4f80DPzR3DdJkl+u6oI1nD01Cc8hrGLIDbmw5i2QTwUcefVsV/Stxr
         zHABn49sWVtvn1EQqZXdjZMEnzo4HaIT/5IVzKg3PVHWHQrJVaZe/4nKSM0crrmLgmiE
         8+OF+plHKbxFAR8jbWEIUFNAIwJpHrkZghOPV2jDPfCiu0ohGDGUBu+8syDZW5nQaLte
         XTBin04ggXUAv85OYsBoTasuzgE5CG2Y9j84PpuxtddlSRDWnJb48EsZJZaMISr9pgD2
         X/QA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794129560; x=1794734360;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6uUpvL+YwLioblRQLbYSDsaQDa3iQgozYi8OfO4zbek=;
        b=ooa6MC2l6dILjm2ohqx9THFlK/n/w+jZue7z83/LYWhkp/zHWiu0b69EhwMtXgGgYT
         bRB5VXjgk4YkSgQFDMiwOSm6t3xv+lsxx/znaIVR6BEtq3epRsLzBDneoCLjwEEIha+w
         gQnCMT3ve8G1Sqh/wRI0uJ30D4st6lnr1Ap3MdnAUvRve7gYp3cQWuJr8B9m/x+WLoOQ
         j/5Ybnxtyqwfdj/PIHIgQPioc7NHUIG7hDebtq/YgUSCYTQglaUQe39ahSxqbgwW5oEm
         k4FvnSicRVsqACCJFdiFkHE6PdfK/3x3wtyxLmTMXVzZ9KFGXUr2t4l90H1iaBUayFw5
         vY0Q==
X-Gm-Message-State: APuU4Z9pWw+IxT7D0nEVUqTpGE9h1SEUbi9u3n5TBnIoY1+mmGmLVg6j
	3IhNjOZY8IpoJCS5E4wfzIA2jlV3DX31xfOOSUNjj5c7h1gEvofQhX1vD8eXQVcU
X-Gm-Gg: AYBFou3ge1dDJPnn04jqHOzIk1peCztl7xiKDa3/BDDYu7BuvP/livQR5Z0UJLq0x80
	gDGUtgZGKAFaHu0ItZo+K+bUgWIXArhe/uVoMEAmP3rCoYFj7zV7BiAY7b2CmHw0o+F8yDfSZTq
	YzyHuC4ccKfJxjIK4A0OtkzJDVOuXDqETq9XXOCSca6WwdD+54nsKsBZHxaX2gTlLaESmnlj8Xu
	uG9mnXNAHlqQRSgafKB6sjItOOH4DEQLL6mGTH0PG9PG+4kNsP1GWoMkmIzanm9dbvomXGrOIg0
	n+InonUrCxhCaQAihhaGekI7hu+fRpzoQWiN/Dn70n4RDqM7GiPZMa/n5RqVY2FXVZ/7GgDJWoM
	6+oD7aovVlRH+SJBCiMGhsMYtnRTrbLsfYG5AJaiNdimQiFEFS0z5VN+a72dAj3/BLfD60sRcBW
	Ev+hq7tfj6dIpBvL8cjEKsYMn90jMwpP0AM1j7e+ZVMS0Jo0vBVGa9K7tssk5t+TAaNEK3uxouX
	wV9qui5GPsvlus/fkLY5M6Gt94LaDPf15WZPmscpupAmCx2I5Zsra9dzgMStpQR1b7uTDXbuevF
	Fj8K5jU5bWgnkyRI5PQJM03aYn66QTxR663C2g==
X-Received: by 2002:a05:7022:628a:b0:1b2:6eef:3f32 with SMTP id a92af1059eb24-1b39febf214mr1870562c88.37.1794129560390;
        Sun, 08 Nov 2026 01:19:20 -0800 (PST)
Received: from Hruday.lan ([2409:4091:903b:c404:6c1e:2d0d:b35:6b46])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1b3731487edsm4884409c88.2.2026.11.08.01.19.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 08 Nov 2026 01:19:20 -0800 (PST)
From: Hruday Rao <shreeramrahul94@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	linux-kernel@vger.kernel.org,
	Rahul Rao <shreeramrahul94@gmail.com>
Subject: [PATCH] nfs: fix resource leak and warning in svc_destroy on callback init error
Date: Sun,  8 Nov 2026 14:48:46 +0530
Message-ID: <20261108091846.114471-1-shreeramrahul94@gmail.com>
X-Mailer: git-send-email 2.43.0
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

From: Rahul Rao <shreeramrahul94@gmail.com>

During NFSv4 callback initialization, if creating the PF_INET TCP
listener succeeds but the subsequent PF_INET6 listener creation fails
with an error other than -EAFNOSUPPORT, the function bails out without
cleaning up the previously created IPv4 transport.

This leaves serv->sv_permsocks non-empty when svc_destroy() is called
during error unwinding, triggering a svc_destroy warning.

Fix this by invoking svc_xprt_destroy_all(serv, net, true) to properly
tear down active transports upon initialization failure.

Signed-off-by: Rahul Rao <shreeramrahul94@gmail.com>
---
 fs/nfs/callback.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index bc282b744f34..3d2ad5297297 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -61,9 +61,11 @@ static int nfs4_callback_up_net(struct svc_serv *serv, struct net *net)
 		dprintk("NFS: Callback listener port = %u (af %u, net %x)\n",
 			nn->nfs_callback_tcpport6, PF_INET6, net->ns.inum);
 	} else if (ret != -EAFNOSUPPORT)
-		goto out_err;
+		goto out_destroy_xprt;
 	return 0;
 
+out_destroy_xprt:
+	svc_xprt_destroy_all(serv, net, true);
 out_err:
 	return (ret) ? ret : -ENOMEM;
 }
-- 
2.43.0

