Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792694609;
	b=Pcy4NxIJzARq4pU1VQl1lTUxd6Oj0mjlgpFIIwgXxkpeV0dgendNUSLy6YL0zrve3XTH
	 S7kj/vXbAvvTF0/KrbftR3DqHNYcDx55X0A3HjmmzxHZUYBACQSqeCeMAZHbZEhy/FQ9r
	 YfSKIilQ+oKLnPNmZ3HlWPPsGu4V9wQHM0B81x9lp6UlX3IhQCz6nwR37/xEBAoSdhwTF
	 EqDx33S9g2ju+A6Nd6dRSaumo257Y2i6oV+jp+ikAiJP2Ynjvu0EHuRx8P+Em1n+YBSPO
	 8dUgZs5an+qmqOeNgZXoZdbJs/o1r8v2ybbexDdBOk1MdPmqlVCQBeJ3veP6FmKlLxA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792694609;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=dvCZQWq4+ahGVVWHnYLAUW7o1Ivhc2lxe5JfwRib5CA=;
	b=h1FypNGvG90Jr/6U4ZzxWc+TosFVXPOPNaVWFQ8okZFMF1pmhF4/7aCu5/XPajb0kcCN
	 6iJhWH/F1xAbtCgTPfFw4aohAWu+jr3ZFw4xNr0eTXJTwWtqh0DORsmzxzeKF9i9N/sem
	 uyTO56AWFiH63Fu+kXUBiFyzcL0L4oWZTH/DjmZHMlK5n5LWzmIpgcV9EgnPaJBQVByws
	 9V6qbnk98BiqLciBTe7dZfIs6byQlXHNkFMDvl7q6VNayPOvTxijUdVS4PpYnhM4+T2Fw
	 DLT4D4OoVwXVh8D/1KUQ7VGyHvyzwWLliigCaKq94CxaieecxONFIsApmOHOcfXAlWA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=S8UsU7PZ;
	arc=none smtp.remote-ip=209.85.128.51
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C7D5606A319
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 18:43:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8C7D5606A319
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=S8UsU7PZ
Received: by mail-wm1-f51.google.com with SMTP id 5b1f17b1804b1-49d0da752ffso665055e9.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 11:43:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792694608; x=1793299408; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=dvCZQWq4+ahGVVWHnYLAUW7o1Ivhc2lxe5JfwRib5CA=;
        b=S8UsU7PZVOK6N4ZlhEahb3KOdDVrIfmg++ozbIyuRaqGxEZsNATad77Pd6sQ9q6hWN
         WgOHPMLcDo9OvpvVsAfIgtrskb2KoBznspVg3/gNqCRP7XLPiHr/QDw26FNrroGSTYuO
         Mhnb+0Fj58PBzATG0yhEI1Vi4fFNVn8cnNa3DsbnU2it3gHj7huDy3sqKKZ81f/Gf4E3
         X3YHZyYIoaRINxR2sVXyYpDcxR7DpU3paQFMVj3ZOnxVsCqyR0Kflzb6umdnvdJm3SFS
         RolgSdhBaQxAtfFEoFvZKB11Yvf9LQxmiXdv9BQVShlosJmGyEo2xdvjYoZHvAKwe1ab
         jX1Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792694608; x=1793299408;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=dvCZQWq4+ahGVVWHnYLAUW7o1Ivhc2lxe5JfwRib5CA=;
        b=YUOc7iss3VboFmopjFnfHLlfv7XCjH3VphJv/Fll3pzL5Nvdne8Q5CiA5uZpfyy7Ph
         ENWo6aOt8qaqAUevDE67HKjPo6xNQ8OnwrLtB3B2pBULkDm2qmtD8gmZzKQHiZy2plbs
         AW8JrBSdOntx3QIE2ZA5AU6ed8PIJdsGc5ZNsf2nGSHljxdG5ogC4ZncHrmQG4MbH+K5
         3VbpZRVUJajant2fhdgMZY8zeV3H3FjEk92nOdoCyKRkronh6VvBKL0Ce5NwwpavMxei
         lF+JBrnYpcsYfO3EWTfnUQw4NRDYv/1a5uq6/ef/G9TDq3lxXonJPS0FqeeyPzDFBppI
         8kJg==
X-Forwarded-Encrypted: i=1; AKwUvBzaJc31DLr4RElawvb8R95c+8OHjp6zxgtilWvQumsKWSNePiw+ZvLuN249WG5kW13WYfJaVCPngpY=@vger.kernel.org
X-Gm-Message-State: AFq9FYLxhCQO0V2A324fLTxMc3udB0T22xpAeH88gXeYdEkhxG0Dd5VP
	ZM7hXuBG1sfTgq+Z8WZ2krhvJj5Dlc9w/6WLbplLAlR62l8yDR3UAGtn
X-Gm-Gg: AYBFou3flNPhpvIySv6FySLVCYa+rolKqFIiDJNAdJssmRtqIcMyKXNYyqprIM+OhT3
	hGkvbPsCBe1nCpDeWWZCQmdI2k3W203brf3jxKSdtZ1O4cqnZxJ//rU/ObNVAU0XJIOg2kxb4kL
	+qMbU16bDnvSAQbJNJtclPAKqyPvnM+WUjORE6mUD4T+vFfbOq7vmtGwDb8AiAMagX8kHCYngwP
	KE6P8AQi2Pl3Qw1xUz3C0jdzlKsn5TnevTJ31aM8IgG4+mA+QdVusQ+Oxe3jBpaF4sXOmedYGHN
	mzn3IG9phWgWc+JZz646gt2ekhgiljIbtEfN0JQw/elt511o2LWOYWm2vcrWOLuozhTLdLHTxwP
	V0Udoxoa0fNZlvs5QvWdlxxhqFqJ8FznVhzKhSHAH4LJIEp2KjiFWDBtodOgH+Hn5o2hC/o2ck6
	fHvmDdOxF4scTLmVu7O1wfpywBOrCMojKp0OQn1ZEo7IULA4SEuagww89ZJGKNvKE61iyZUPYoH
	TD6WX1HMk9cC0kA6yVpZNvLR3wKdQI942vaj9/a0ppgOtHcw2bbtP4aUV85MvO2HJc4tb6tus85
	qzTR
X-Received: by 2002:a05:600c:46d3:b0:4a1:97c6:d2e8 with SMTP id 5b1f17b1804b1-4a1fdd234a6mr126206525e9.32.1792694607672;
        Thu, 22 Oct 2026 11:43:27 -0700 (PDT)
Received: from LAPTOP-AVI.taile24b5.ts.net ([147.234.101.15])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e379cf522sm102672f8f.17.2026.10.22.11.43.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 22 Oct 2026 11:43:27 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: preserve transport security policy when cloning clients
Date: Thu, 22 Oct 2026 21:43:17 +0300
Message-ID: <f07b12afb33009c8a23da4abc316cfd64f90c063.1792694006.git.thnkslprpt@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <1596f1b91f9f6ad14a75e3889ab80ba7d98cb52e.1792694006.git.thnkslprpt@gmail.com>
References: <1596f1b91f9f6ad14a75e3889ab80ba7d98cb52e.1792694006.git.thnkslprpt@gmail.com>
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

RPC client cloning does not copy the parent's transport security
policy into the new client. Clones consequently lose their TLS
policy and certificate/key serials, even though the shared
transport remains protected.

When NFSv4 migration replaces a cloned client's TLS transport, the
missing security policy causes xs_setup_tcp_tls() to return -EACCES.

Copy the parent's cl_xprtsec into the clone arguments before
creating the new client.

Fixes: 500053191297 ("SUNRPC: Plumb an API for setting transport layer security")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
Tested under x86_64 QEMU - TLS and X.509 clones lost their 
security policy and key serials before the fix and preserved
them fine with the fix. In addition, TLS transport replacement 
returned  -EACCES before the patch and 0 afterward.

 net/sunrpc/clnt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 0f6e44a11d83..a27ba8682b75 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -653,6 +653,7 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 	}
 	args->servername = xprt->servername;
 	args->nodename = clnt->cl_nodename;
+	args->xprtsec = clnt->cl_xprtsec;
 	if (!args->timeout)
 		args->timeout = clnt->cl_timeout;
 
-- 
2.43.0

