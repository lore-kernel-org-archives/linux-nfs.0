Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792766320;
	b=nfAJUs2rGwoXSGOdzAkhOoQ8D5gDsoNQDvWLNz+ech0W97T1nKhe5L24EAeO5TlPDERF
	 8bR8Y51LdGQkic3JQGZZkA5EIYZ4O8emWYvWiMfcACptI/Yj7aeMEgM2YSGXaziXX5Eqk
	 IwZiGwTRfcETzAg9NaPeHjbC/hzfSIr+PULd3XAllN0N6fp2CoAdkF9Uy4BfBniyB5PLS
	 oU4WIBG/bQhhVM5DJYbn93YUDeOWDf7IrGkuFcG0YcyShGAiyKG4C0ZulaoCwwJcOhtUs
	 oLRcBakPmM9jT7qm9renDhh+RBvQD565bcGWx6vyw7suF2xr4nq4MgNCRurP/zREGdQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792766320;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:To:Cc:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type;
	bh=8kBP06/wOlnERuCqJs+Y5bm/y6KqBpdjzMi3s4CcFqM=;
	b=Pfg6QU31SkLo/9DRJCvVflA8lyvtTkxsOi1N/ssS32rOLw3kowavHalvCQbGSCf7LWd4
	 wAV6cbRf+B1uuYZRDunlyAt+FSHN/DjaaOEq3PzrdFLwbrboGB5xNFikciPmI9ddUn+SR
	 w+rW5AzqWOtHw4d99k9jrpJJ4W6rEMR1l+ktoTpKGa1doLmhB+SuZZn9mO5rtK3JEFdYi
	 jTh8To1FRevPZfVLS38i1Gl+DdACp5O1k4HosK0mn9N++O/4zfaS24R+a+aE4vRmToPtl
	 sijmf3xMHx5wKWVg/Siuve1YlrO9oiNPPkn3BQMpnhisxMIyZmqhsJ3+ciTr82LKlKw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=LgrTemra;
	arc=none smtp.remote-ip=209.85.210.48
Received: from mail-ot1-f48.google.com (mail-ot1-f48.google.com [209.85.210.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5252606A31A
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 14:38:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E5252606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=LgrTemra
Received: by mail-ot1-f48.google.com with SMTP id 46e09a7af769-7f84a55cc06so555119a34.2
        for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 07:38:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792766314; x=1793371114; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=8kBP06/wOlnERuCqJs+Y5bm/y6KqBpdjzMi3s4CcFqM=;
        b=LgrTemra783sa+ZxdZU6VF2t1/CBhSZTakPoKDDnqRhwM+Cyo5l7vdQZOd2ULAzkin
         Qi6WxoWZkZKyM6NmxjfLu3v9wIbidpPs9EREXZXorPg3G6SlheMzuZJNxRDpjDlKWgUn
         Mzc0DSyDc94g3QeXFqUAhnrb/DCHy5OZmF2VZdswK3CCEKr2rufeKmt5xCVMWW34yDkQ
         QXORijeTC9K4Et44lXGEfhb6ewHNblhu9XjYTizos1yVYjgK727XB3EpnDPy0dpqQfaK
         6ghokHtT7xF2O4hM0ZgXPOwocxAdmBv3XbxyVFiSONwbOZM4opGFAK5icV5UAetdOaXp
         GjUQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792766314; x=1793371114;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=8kBP06/wOlnERuCqJs+Y5bm/y6KqBpdjzMi3s4CcFqM=;
        b=al3oDDF7Zp6eRLNO4QEF03m+cIuAoTYCKuViZVx2Gfoujceb/v4V6eRuAlgBUaXUVT
         dpMXdtQ8tn3I+fV2A16li5PLtSLvC7KkD90QhXkTaaYQ2YS4/cx3plHINmvBDi4nIgl4
         UAlE2YObjfCNfufRksNqe0JIKm8FsiC0B6BR/mr/K/nKTZCBebj6wXtmmx6TbSuAId8J
         w34vPKCwlE9Hnh6JcVbrmG2B65534SUhVWqP7n9uqqw+3cL8djt7I9bv6FE7TKBSrIUN
         2O1uy2V6OcW5LoznnGbZntBXXxIxXee2KIUrtMtlpGp33ZxwPGC1P2aNeMWBiXELBKxF
         IZpQ==
X-Forwarded-Encrypted: i=1; AKwUvBybaBzhyRYxrr91VPS5kGEC0EjT4efW0UH0z/TkIYXNlJ97T5UA9sbZFeE3tbRC6Q/EfCa2v86Cb50=@vger.kernel.org
X-Gm-Message-State: AFq9FYL2xrhfpR11WeiHKh3/bz91zSS+OVBGo7d4wNsVtICMeLCp9M0m
	6oF5wSK/6zl3tBjYbjg0HH+r6uj9TPcJTccKHOIq4pJHH6yRq6vzmskAF1J5ooaKsEk=
X-Gm-Gg: AYBFou1tFZR1Fac4LoFaSQpZVA3NhteNivBtS5EROicG1FvDbis71jNcK2xWgCgzlkd
	8g69ByBvG9cjSaXaxuysT6bp41og8pmKHLHg/J1UtYE/6esdlFiPuTKe9OHw29+iSNqrmT9pxhB
	HOwMFHc3Im3V9/KYKkkrh+zMX5IhRlIqv06RQ1WqIrxVdLonKt0pL599d67YAfpQ1tUcpMbenIQ
	U4/N06QkNd3rJutMjBKayXSfsfY0rEzvzOUKyeFlEkEzMelE2Kz8lmBqaQXOOp9yHdCjztyyOJp
	93lAiUidwDRYVVvgYX7kLZUv44Z5MbE8neEhL/wNubN0cQ1UPYD6Mu29x+ylQ9Cq6N+X0ps2/vn
	93NnAh+dPC8ts6FfjH0a0rqikIPhfThqv+yzmqP8v/o0n43Q1TZUXorHBFWGPQYKUWsDEOu5yTc
	zvt/5YXYdWzt+NXbEx1mKnf3aeTQbeKVZ7RouGlCwCgb8vt5ROzxD2t85Hmc0ObkKe+sUBptB1U
	uxrFlDfn+t0wXCPVBZr7jdTvG8MSRLLOdMV+Yt5q+FMythVl1mwiHiVTqYv6pU5Tw18DLnh3g==
X-Received: by 2002:a05:6808:150b:b0:4f4:857c:98ae with SMTP id 5614622812f47-55be80c4668mr1554002b6e.11.1792766313526;
        Fri, 23 Oct 2026 07:38:33 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-55be987bb39sm1555431b6e.11.2026.10.23.07.38.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 23 Oct 2026 07:38:33 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Avi Weiss <thnkslprpt@gmail.com>
Cc: trondmy@kernel.org, anna@kernel.org, cel@kernel.org,
 linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix TCP-with-TLS transport class identification
Date: Fri, 23 Oct 2026 10:38:31 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <FCA6692A-E79E-46E4-8349-D4A77B818476@hammerspace.com>
In-Reply-To: <20261023084819.609293-1-thnkslprpt@gmail.com>
References: <20261023084819.609293-1-thnkslprpt@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain

On 23 Oct 2026, at 4:48, Avi Weiss wrote:

> xs_setup_tcp_tls() assigns the ordinary TCP transport class to
> a TCP-with-TLS transport. When rpc_clnt_add_xprt() is called
> with an unspecified transport type, it inherits the class
> identifier and can create an unencrypted TCP transport.
>
> Looks like a copy-paste error from the commit 3 years ago.
>
> NFSv4 trunk discovery uses an unspecified transport type when
> adding server-advertised addresses. If the additional transport
> passes server-identity validation, it can be admitted to the
> client's transport switch.
>
> An isolated loopback test reproduced plaintext application RPC
> transmission for TLS- and mTLS-configured clients, including
> an unpinned TLS-client RPC that selected the added transport.
>
> Assign the TCP-with-TLS class instead. With the fix, the
> plaintext-only test peer receives TLS negotiation probes but
> no application payloads.
>
> Fixes: 75eb6af7acdf ("SUNRPC: Add a TCP-with-TLS RPC transport class")
> Cc: stable@vger.kernel.org
> Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>

Hi Avi - does this also fix the problem where the sysfs "add_xprt" silently
failed to perform STARTTLS for the new xprt?  If so, this is significant fix
IMO, and worth mentioning for products that might use that interface.

Thanks for this.

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>

Ben
