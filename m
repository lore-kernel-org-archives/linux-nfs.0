Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795525233;
	b=UtHwezQsLNd3FSHTRjA1yspHSNfkooy2KioZQ/AWpcfKp7uD2A/rFsBiOvdamAcACDeY
	 DTmEMPpLq4918PqfjuUmzgjzmGYmmi68FDKG+GjdON7RLL0vIk4EjZoqX+5fron+YMs54
	 JeQLNrSi21aqLgYPSMth9d9wDUY341q+34CJjV53hJjflUeVS6+qxtEMnwKaUf/nNzxpp
	 OtO+qOyFL4KJuWDUOsXKbNI0iEbPLeM6FM76sOKXmYMTtvJc84NjR2qCThteG1Ib3hPxL
	 LUYQGr8aCHKxLh0aQ6tVW6xdZer80IGLn9W+RoZeOOaezW2adMtSwIj8km5r/WpKngQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795525233;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=rw5nKJexAikrczIwVl4gp40ubNw/wjUJNJ/IKuENRwk=;
	b=n4HPtDY+ROe6iwH3iNEz2CTylwW8nNJ0cncHcsi9C5/q52B3CRgk1XxSj+bJ53LfK36r
	 8C0lbT5EtMFdKv1R7GqB8kUAFJ/gMbJF6qaLJhNU/ccOnvTn5flIIz2VZh0mZMXcUpY2Z
	 Ez+eKeYYVnC96+MrM+nWxWdZFTnfauSzokLT67Uc0DZolxUUnRyg6ltSw25kY4YkA6+4G
	 qJRIeZ/YavZj2cg7RKb3xO9FJXpqxtXuhX5h/5D95R25luWJhPFlcbTZPbg253n7Vv852
	 WVMu2j4MEzrMRAj+aVgavXEonkiAMvlU4iuRqQ/UxVLU6gJ57cbYZfoRd9PFwtxtFUQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=vastdata.com;
	spf=pass smtp.mailfrom=vastdata.com;
	dkim=pass header.d=vastdata.com header.i=@vastdata.com header.a=rsa-sha256 header.s=google header.b=QS73P2aX;
	arc=none smtp.remote-ip=209.85.128.51
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F23F9606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 13:00:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F23F9606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=vastdata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=vastdata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=vastdata.com header.i=@vastdata.com header.a=rsa-sha256 header.s=google header.b=QS73P2aX
Received: by mail-wm1-f51.google.com with SMTP id 5b1f17b1804b1-4a210470b49so44057415e9.2
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 05:00:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=vastdata.com; s=google; t=1795525231; x=1796130031; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=rw5nKJexAikrczIwVl4gp40ubNw/wjUJNJ/IKuENRwk=;
        b=QS73P2aXmqzC6DxDFEgmGmSFsy1bI9st8OtN92uNbFq9czbb/8eCMfomkDnvlWuUD4
         oguRulGuPso9nbjgZR0XN127x87aLnVnw+xKSI/HPlMhvlzJFiza0LVIkIZWvKxYwwwS
         wnHiGRMnuV45nsOrLGr3rQpYWq/qm3LtdoozU51uJxCIWKvniUdWxf1COoSOGs8y/mnj
         5wUBjDhp/iIZuASRbIZTlB97zos78yDsvrSu4yZcP4if9QCne8LGOydcRFJBoCKlubbF
         hi8kWp+/anjq6pzDhQb8AnDJ17b2HVgSmBIm2YIYc9v5wSldmFGfa93PmlCO/kLkrpUs
         t/fA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795525231; x=1796130031;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=rw5nKJexAikrczIwVl4gp40ubNw/wjUJNJ/IKuENRwk=;
        b=Yp9J7uAk5mR1YHHqOy9/X+HwQD6dwyQQT0Xl5GIpdMpFn+Cuf725bNnyv3Aj7dR+HQ
         R0D7yhfD/3YtdD0FLr4zI5mfOipClUIbqQu1hka0X7IBDJUf2RvQpntVXJciJqHL192L
         maI1v1xW+YwRUwjSw50nY4OcoQPNQfLyNB3I047W446MdzehFGR+Nsp0dU8OWrmYw3zz
         yVk8GSLWXkm9N1DAnLr976ETIwLvwD3RG27FY64AHTEBhs99E/HiCVzZc7UkrB3Y4hGy
         ymkL/IoYm6p/wCf3kCAYZ+KS/bgVIC5EAdlgyif39TahTi/v4pjWzYtyvtRMLtlRDTl2
         JQ8w==
X-Gm-Message-State: APuU4Z9eT/joayOvzD8su6gy6haehq2fsED6PAKlgZxxYYVKk89dXtO8
	kJM2RRdRGX4JSamo/snG67zLGQjTaxPC7GKVo1jGBkd9QvKIq3X5mEcqC3CwYHZvnbkBlQphuwa
	jeZWJ8UayXg==
X-Gm-Gg: AZFdTZeQydsLEn4mp7IavGsminq1Wed4k8D/7ba5VILIR/EggyLjpk9wremPXGuQVL7
	6wAdDLKgsB4jHNVANaXHb2Pc2j/YkYjcNBtcSJrirGYDGxAak9rXtxrjEKp32jeTPSsxg/7k4Ok
	+e6J5P14lKWXK4mexZv4QUCKXbc+IztyIsFdBqjQ1VjsElrheBczz7pqQxbxaAjA1QbzApsvoc6
	5kQI5dm4zX9rkPit07MihL0Sr8tE35XN69U2A/wqLkApn/82vwhcgBKw9pVjTntA24LorYdXEVv
	V5GE5C5481myNqPOd8aKcilKpr3mNcmAC1vSOtvjB2morbq66ADn9o2ctFjAsiI+dX8Lw9xUHQB
	wX8VOvxKCjVroEN5wyVbSF75taBbpMwxshLdW+aVqLPlp99MkipBzezELCmJkdvGmnmMr1gXYdM
	7KatyXYNeGpesJJhndLonAmg430+VcQX8yY13m3lgNU6R1rnCr6qLs5wV18TanvK17+7vEfXLtD
	i7vYV6zWqbFGJCJRtp7yKwsiBLvzpNy7m9gzD4L2gMjbH+/U9iTODowGKD17giVHwOvogSZsRa8
	PoXAOP6Ch67kbI1dzdEUrpXz6Myrku5m0WzXnkCwCKOS532aU2nqEIAZUJZbfqJeZ5O0YQ==
X-Received: by 2002:a05:600c:4e43:b0:4bb:5bf3:8ee9 with SMTP id 5b1f17b1804b1-4bb8893c2d4mr302632835e9.31.1795525230772;
        Tue, 24 Nov 2026 05:00:30 -0800 (PST)
Received: from jupiter.vstd.int ([192.116.95.190])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb88402ce9sm348764785e9.0.2026.11.24.05.00.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 24 Nov 2026 05:00:30 -0800 (PST)
From: Dan Aloni <dan.aloni@vastdata.com>
To: chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org,
	Hubert Dziedziczak <hubert.dziedziczak@nmc2.ai>
Subject: [PATCH] sunrpc: fix for missing initialization of GSS au_flags
Date: Tue, 24 Nov 2026 15:00:27 +0200
Message-ID: <20261124130027.1432127-1-dan.aloni@vastdata.com>
X-Mailer: git-send-email 2.52.0
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

gss_create_new() gets struct gss_auth from kmalloc() and never stores to
rpc_auth.au_flags except through __set_bit(). That sets
RPCAUTH_AUTH_UPDATE_SLACK on every GSS auth, and RPCAUTH_AUTH_DATATOUCH only for
krb5i and krb5p. __set_bit() leaves every other bit alone, so a leftover
DATATOUCH bit from the slab stays set on plain krb5 when the kernel does not
zero allocations.

This had led to non-determinant behavior of `rpcrdma_marshal_req()`, which reads
that bit as "this GSS flavor must not place payload bytes directly". A large
READ then goes out as a reply chunk instead of a write chunk, when it it not
needed.

So we should init this field. Another option was to do kzalloc instead, but I
thought it's better here to stay aligned with the current initialization manner.

Cc: Hubert Dziedziczak <hubert.dziedziczak@nmc2.ai>
Signed-off-by: Dan Aloni <dan.aloni@vastdata.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8ddc65e894dab..a666704f1eb9b 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1056,6 +1056,7 @@ gss_create_new(const struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 	auth->au_rslack = GSS_KRB5_MAX_SLACK_NEEDED >> 2;
 	auth->au_verfsize = GSS_VERF_SLACK >> 2;
 	auth->au_ralign = GSS_VERF_SLACK >> 2;
+	auth->au_flags = 0;
 	__set_bit(RPCAUTH_AUTH_UPDATE_SLACK, &auth->au_flags);
 	auth->au_ops = &authgss_ops;
 	auth->au_flavor = flavor;
-- 
2.52.0

