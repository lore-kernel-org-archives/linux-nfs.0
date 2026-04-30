Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6032363C55
	for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2026 13:32:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777555943; cv=none; b=uKumfCPO9ptrStVIvHP85LLKNPYKZPv/dVftHu5kpQ8sz/RG72SX6u3FbMYrPfftdbDTktvLfS6JzkTYJrRX/kP0rowhDQDoxig+GNTZpftDSc82Y1UZljKayBSOCWuc1kvuPC2RTbx1I+n/5xRfX1Hbu3Uefz09j6N04WAAdPE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777555943; c=relaxed/simple;
	bh=iGKyFxmVhIGmQI7rScEErV6RT23oJlBjXHq0PnPa6bY=;
	h=Message-ID:Date:MIME-Version:To:From:Subject:Cc:Content-Type; b=qD6MxX3Ogn+2F7QUaexyaqiqUbEeY2s8QOXFeRvrDtyz3B/m7rzGFSqi9UMVy40HrwzRodF+mjj+3OwXyUmhHJhc+m6I7oviyczqr4ji9SnmsujrdU3hvP5GBlx2qs9MXwE8ZunYUvEQLrJ1KrHlH35EeXncwkydee1iKHuURRY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=grimberg.me; spf=pass smtp.mailfrom=gmail.com; arc=none smtp.client-ip=209.85.221.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=grimberg.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-wr1-f46.google.com with SMTP id ffacd0b85a97d-43d43e09de5so494192f8f.1
        for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2026 06:32:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1777555939; x=1778160739;
        h=content-transfer-encoding:cc:subject:from:to:content-language
         :user-agent:mime-version:date:message-id:x-gm-gg:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=5atyFNfbIaJMsyBQj0OFaIP0b60ej/XPel7OimlNrng=;
        b=iTmG4+X2VwovrclGKoDT5S8EdsQ4aU8kP539AWMkE0KFIkIe88m8Skdz8vWWQDYW3F
         1kFkLB8Tt3k4TfEhi8acKd3f1HSlsQM65oT2KNgb137H0+H1ZMeHrPnBPkPSIQWt2asw
         WBge5JHpkRt7mX2iM7cgGpsACSJWU+GwdLRN348lg5Zf2B72Pf+m6+eU871i+fainu6D
         1KQg5jz6RIGtPWedEsPYehmoGuYl5MF5YDLJgysYCaW9qM1QH3MytRRi6niHiqz0wJVq
         d/WNeY6z5mQN7/Ad7W8cuyTEw0HuO++RQxifHcXz4zOoCEV54uv7Y3j7HWjZmsFNCrVN
         ZTIA==
X-Gm-Message-State: AOJu0YxiLUr/9j0FhwpwVnbKx6etv1YsJ6v3T64n9YEbe/UuUKvgx5tS
	d7/2xF5JiyueB4sYNruSn/ESL/DEiF8/ud4CnHF2N2Hok1Y49q744Jjms20YMw==
X-Gm-Gg: AeBDieuwX80s5EHRdlGfOC/S1vrf8d00hXhWU7B0I/gE05O5qLLKNu6i0/kqAuX3Iq7
	KIYYuzdqa9nr8K+dHzIgcNhX7lrE/wjYd8wfTiXDO+50dis4IBUVAXGDT46aOAuXWBukpxeRAbw
	9JhwKJaDviFQ7Spujaw934ghr0CK3b9Nga33ponRI8Y08nkcLbhXc7+X6MDCv743dEa2sMgK51P
	ysRunTeOBK+Nq8YZnFjbmgSvMx2KWwq1dfWhJsQeOI6P3iMKE/1qUGCLTkUb7vNW6Gbr28i0FrB
	6CXfHZ3K43CjfCMciCumgyDLMtdqCFy8iHirZ1p+wjSYBaf7nuJSZXyGpK3JACQQiMFjVBCUstK
	4xRlqIr1aNU74rQhas7pRXwTEbGH4QMGU/X4h0bBN7UVTGT+BYSw5X7Xp38It2M/xWDa+IxwpdF
	xXpjgOBI75SoYpn6NG95/55QlyeJqb2JCXA9Tc8lF9dboFjnsq0N4Z0W70D5bGiRLo2Jxw
X-Received: by 2002:a05:6000:184d:b0:43d:7946:badc with SMTP id ffacd0b85a97d-4493ec61dfemr5389860f8f.26.1777555938944;
        Thu, 30 Apr 2026 06:32:18 -0700 (PDT)
Received: from [10.100.102.74] (89-138-71-216.bb.netvision.net.il. [89.138.71.216])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-447b7217afesm13310748f8f.23.2026.04.30.06.32.17
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 30 Apr 2026 06:32:17 -0700 (PDT)
Message-ID: <fd4aaf4e-b1b7-4ca2-bc93-955c31fab317@grimberg.me>
Date: Thu, 30 Apr 2026 16:32:16 +0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Content-Language: en-US
To: Chuck Lever <chuck.lever@oracle.com>
From: Sagi Grimberg <sagi@grimberg.me>
Subject: Breakage in ktls-utils with nfs keyring?
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hey Chuck,

Upstream ktls-utils fails passing client certificate and private key 
using the .nfs keyring.
Bisecting leads commit facd084e43fc ("tlshd: Client-side dual 
certificate support").

I manually apply this (probably wrong) change and keyring works:
--
diff --git a/src/tlshd/client.c b/src/tlshd/client.c
index 2664ffb..a946797 100644
--- a/src/tlshd/client.c
+++ b/src/tlshd/client.c
@@ -327,7 +327,7 @@ tlshd_x509_retrieve_key_cb(gnutls_session_t session,
         } else {
                 tlshd_log_debug("%s: Selecting x509.certificate from 
conf file", __func__);
                 *pcert_length = tlshd_certs_len;
-               *pcert = tlshd_certs + tlshd_pq_certs_len;
+               *pcert = tlshd_certs;
                 *privkey = tlshd_privkey;
         }
         return 0;
--

But, I have a feeling its not the correct change...
