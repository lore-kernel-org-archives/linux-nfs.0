Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792933170;
	b=4s2+uoBztWDuTVW0Zh3YxX78jvGz5TznzH057BcZC3ESulHHbZ00oBiy0geEsqONMssl
	 7qCiNKOLt6nKhyP21PixIb3bZXKWjtMyF8/vpMqklZ7AEG5XWcBOoZhx5EKi9my1n6hQQ
	 IBjOatu00bXsTzs2jq8FzXlHwCaF/8/cYsLTu7Rp9u3FSWLlw2fer3S2K2Nw5c8Poy9ex
	 2Um1GFWR7ZcHjmqe7GkXp4jcvcTdegwknafPQ43lRhoAYMKsl5r2azIIZUP/tHMEHctZp
	 4YWpGDCTVwcyAZRMjsPWGe3Nx0rsZpNx6AhN0P1tbP0VP4nt5MZRlbOa42xjZCpsouQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792933170;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=7VHZxL27tPxxp1usvovdEi4PohkLXe+WTp5TnVE1dnM=;
	b=gOsVdPbO7fqkOcvIMRrlFKEC/TwcjiY5RwFJagHU3GO08Bkd84rVP4yYkHyHKfZOulPw
	 i+RMBm77L/zcF3EM6xBbs6m61M7A6EYid1ghtMF1ANijvxlngaAJ09yKM06u9vhyvuaAR
	 D2qPNKmlfQNbN3HsZpGAIvllIlzzIjvcZm7h5ixdhxso1hbCUwkNdwlzzG41FdUnZshPZ
	 acdO9k3M99m5lclT7NnVnlBaZKys7S1v1IB95WL/zGDY8/Cuy+p8QoFv85Ic+nH9xqf5L
	 YBbcQ0DuJpt0fdXgVp2qQxnlRFYF5n8Rv/nQAKvHzXRL5Bq5T1YnntOX26ZRLwZ1Wvg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=rZk08NxT;
	arc=none smtp.remote-ip=209.85.128.47
Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C11A7606A31D
	for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 12:59:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C11A7606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=rZk08NxT
Received: by mail-wm1-f47.google.com with SMTP id 5b1f17b1804b1-4a1b07c3c5fso20603175e9.1
        for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 05:59:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792933168; x=1793537968; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=7VHZxL27tPxxp1usvovdEi4PohkLXe+WTp5TnVE1dnM=;
        b=rZk08NxTTVEpTzIZsF83JIm/vfJjHC/3TWlRjj/odwGc/R78ukigXNtW+Mu/QgSYN4
         jwiQVTMr32so9LFM+q4CL3OeKAzqOLRnDH+6lCswwFw2cNlbCkUdQlL/cjb/cR3Heb/D
         ef3iwdyultFPtA2c382MOTaCxropI+ycx/V9jBBfy51lGWhoeWDLhFZYEGw8Ifr6hoIF
         F41BB//tthWuFP/RQ+zB8NJvSlOBGMyXUeLkeiTgHbgpQjuYDLd7YdDTsPoRjnVGJw8w
         KWs9PcBS1hl0vP41aywQgWsDrdFh6Xjpimu3FJu1m2RHJonVaXzq6KJSBHSj8IzBfUkT
         FWDA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792933168; x=1793537968;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=7VHZxL27tPxxp1usvovdEi4PohkLXe+WTp5TnVE1dnM=;
        b=uQ1uUvi7jmQQP2h+RS29LeI4nGAN+wwjHhZ1Sata0u1MWWUu2td17cBz3TpG9efCXn
         5HaOfLjnQLXc+ehWz4usB3zXKoLjKFPvBvb/ukO6w0ri/kz/jQbfF4rwbyq+sIDvUkON
         8cFI34YePG19+rVHn5lAYcjs21/grlYJQEuERuuCgzl9qhCPqrH+isa1i7a1PA+VbZSe
         uSObGeWYARytFweaho7SyLBMt64Xt/KDnGq9bzUElUHxI+PAUOI+jthdgxZ0YfXrcFHu
         c9N8i9AdRKzbouEnN8dRE1jv8YIHKhcj51prYmxWcWoZUR/NFQIdkQJK+b8dZHEAKSBS
         +/fQ==
X-Forwarded-Encrypted: i=1; AKwUvByPtDcSCW3QEK2hdKJjLkgFOG1hwXjsnY9gDyQuT4G64Rxql7KGtxenxAmj6HbNbRN/ZvRbrK5FFtA=@vger.kernel.org
X-Gm-Message-State: AFq9FYKhXq6uJoPvbBWhS8XtfOh/MU+XPUAx1sva9v1hfV/OKce6FI6f
	5fHQdxqyZBW07JJEeQwZ6SNBX1PdloR8pWyZvgoJNudAQBohjP/cNADE
X-Gm-Gg: AYBFou0mG7Ap+b4eyagLrw+r0v6a1s8eM6IKhRtDYdTAOFQ7INZ9hbQux2Pq9Ff9pF9
	I9f+JsFdkZlYthAbeGJsKbKQ82SX/OoRlMbXkGWqDarhMJ9ktxqcjjb0I/XfeMHQHrzrK+883Vs
	QNJpsKvY4RCF66aC8EDGxFostMr7TAgaf2+aVrTGg8+hA5OEz6zzent1fHh+syH4FBOr3q4L1UC
	iPgRTJGLSHaH6zZOKDcfWYtOXP/QbVTjUdvmW97kv0KUbVFxuDVsFLjROZgUwFigEqXCT68HSVX
	z/27uESuAAbQYFz+jyjg/wNngSQ00Ra8oe0UtBDlLTF6ayz6tWXixMSEhSBKYtoJef3HeNSKIy/
	UqHwt9zX11S6VK88i3rJUFEYQREYZbchAZ+/71Q02zWv4Hoe+qI9YjfzBW68hBbcMWkgkv057B8
	you936U7Zp3M5E35SGYK/s2zk0m8KS/enLlXdJgLT0nN8dYW11Kyg1IxFX+9QIGGTNVE0ykzvFO
	ZlrLJB8uh2oT1eSyzRWeKPS8Tol+qBmKYjDiEZ7se/IeVQ1wsyzUVOLGelTVrJKv+bwHUIe
X-Received: by 2002:a05:600c:6289:b0:4a1:cfa7:e968 with SMTP id 5b1f17b1804b1-4a35acc8109mr68061445e9.21.1792933168107;
        Sun, 25 Oct 2026 05:59:28 -0700 (PDT)
Received: from localhost.localdomain ([2a06:c701:4778:c500:4c6b:e3c0:928d:b2cb])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e3eb8f36asm10250807f8f.1.2026.10.25.05.59.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 25 Oct 2026 05:59:27 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] SUNRPC: Balance switch queue length on transport removal
Date: Sun, 25 Oct 2026 14:59:24 +0200
Message-ID: <20261025125923.2221205-2-thnkslprpt@gmail.com>
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

When call_connect_status() moves a task off a transport marked for
removal, it decrements xprt->queuelen but leaves the switch's
xps_queuelen unchanged. The stale count persists after the task
finishes and skews multipath transport selection.

Decrement xps_queuelen alongside xprt->queuelen, matching the normal
transport release path.

Fixes: 6f081693e7b2 ("sunrpc: remove an offlined xprt using sysfs")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
 net/sunrpc/clnt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6cedc824cf82..9b980cfd1bd3 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2257,6 +2257,7 @@ call_connect_status(struct rpc_task *task)
 
 				xprt_release(task);
 				value = atomic_long_dec_return(&xprt->queuelen);
+				atomic_long_dec(&xps->xps_queuelen);
 				if (value == 0)
 					rpc_xprt_switch_remove_xprt(xps, saved,
 								    true);

base-commit: 7be4bc52fd9e0e55dc9a2e0232b89427d2c4b614
-- 
2.43.0

