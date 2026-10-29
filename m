Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793299483;
	b=dTp2lqIWbhUZCYtV2/kkgwX9neMaH4FrdSAQgkv8F3HD09XY2LsRynIxGX4j6jY4W3CB
	 kRfBYN+ojnb/G7H6d4hyxbf+LQIXbaw08g7fUqCDAd4KCoAlW2ZR7vIw5zj8n6cR6nbox
	 EH449iZKNZnDifeMwp+h2/AXeiksJiBVdZSsLapSNMc98oKCL9Asay0P2i6HCvTfX7gpw
	 FlRa+NOKyCg/0wMIFzFVkN5SdkJCx/vEmy1hUf0e78mHan/TMeI+QcDXawQGJSTlOuQI4
	 XR3qkGxX8Uphns+iClDPpmf0lK52OxlOFLsyn8FwY+tBQDv/B0mlbnmfHLp9H5tvUPg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793299483;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:To:Cc:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=IyOrKbyHJH54cGusIXP47gxk4FpbgKc03QbJxxIxXG4=;
	b=DzI3X/XKbfgjrnXmTR7G/vMCq38qsykNkif9uyBoKM9lrwqXYAzrlQ9SD0CiSPc2Nlv/
	 i/3DNMWs7zD9nVO3iXqEkL7r9KNRXxVvpMo4e8m0p0faj/n7frP0fVxJYYezNTqcADyKo
	 cmx4Wz1PVk0CSCC8akU59ALi3rfXy1d3N4ZAgi70FvbpjmUf/bnC1PGDsmxUR1eWd7RR7
	 se677Sl+kx7KykAklNUiJOO6LV2ncpITDOi26T3NtPx0fEjods+t4KhEYqqkVtDLZjWh9
	 jAm19eRuqgTOjiMXyu4PhB/3PZcDk+d0j2G0RjeJveLl+7Ir01bVl7YHx7VHPIASgYw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b="jtuHBm/2";
	arc=none smtp.remote-ip=209.85.161.41
Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67F74606A31E
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:44:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 67F74606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=jtuHBm/2
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-6fbf1ba31fbso1139500eaf.0
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:44:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793299482; x=1793904282; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=IyOrKbyHJH54cGusIXP47gxk4FpbgKc03QbJxxIxXG4=;
        b=jtuHBm/2gL4SeOhvipi/cv2HPGWxpV8/1VOvYzgzAq9H9bYn8HowXcxMce4OUPu7m8
         0Df6lzPhxn1C/gbOJJ3s8f6x9WeA1xNVPGPdD7JOB+Fn8w/OSm9BE341E6bKjtRE6ssd
         7mGBTcrHLZyYIV4KfkT17QOMlMDppVGsbcFIcxQehfTxFdw4CBAYwCTQzPAvDeFw8IO9
         +Cz58cfobcfWTOiQPgTWT+XWS0PpkZwtVrkhAUEtEufSYj5z/EQlbODj4AeJYJDj/D3l
         3KfbUHsHfCXDV/j+fe8q4Wb2hM0ZtHRdBQQ7UmmJD4ENq466rAhQFrGHB+AYyN8sBgzy
         Ny1Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793299482; x=1793904282;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=IyOrKbyHJH54cGusIXP47gxk4FpbgKc03QbJxxIxXG4=;
        b=xWyjXuVieEX0D8/PUtPiHaZqyk6E8P0gxnH7kMKEu3psU8J0tCAsrB0iL9x6eqJ4Dh
         hY/mdmJp8p9UtDuTVJu9JrX3OBWLg7Ht6dqh5JE48ANf9WKxgcMnvKBYfIUui7u9/nhY
         o3Fggmbq6AjYPBFis1VTlPx0EawTK2HS+F3kp3JNn7VbnLJ9ItqcVPOp+6PE0ASd07Z6
         7m+Idad+EKnQmxuJiuQ1Ua5RfbSdJ/O61W83tuqEshM5C9Ho5OLsC0BCR7sFwJJS3L4j
         hgtUFm0lv6uMq5/fyAqG3z6+G6dhTI+nGvSRULT4ClRTHQnocEH0nzVhWFXfABVunezc
         2muQ==
X-Forwarded-Encrypted: i=1; AKwUvBw1vXJOpk2tYFUcx9SAh2PqP/DxTkOqu1KYpGdUJEqOgf6VNvJuxIy5qT/gHkwN8VVBDWIDK+onspI=@vger.kernel.org
X-Gm-Message-State: AFq9FYJG5mgNEdimO8V00km30UZAA4zADkDVNRYPbXdYzRzu7ZfgvzB5
	qUyiMkoKFk0gavtAUUQJQEV++P0HVS4R4D1HJQbpm3+Phy3z5uoJk+lHCK/4iZ8/KkE=
X-Gm-Gg: AYBFou1d3zQR8RKhrblltLpNX0WDPBTTDmjWf5Cx/a1mD9ui2RGiDaIMCibJPNs2dD3
	TApeZdGc5kNuYxVrnd6RqIL8QGJ0Dk9xvOBO6QGr4yAVgcAporrYSEKzg5oZiuK79aDaC2jXrfn
	fwLRKHBe7grWl83ZJ6kgZoN+mvNlISfASJd6dsr1l6qK5TB3NbGq00kwbkL0tb2Dvte/SWydQV1
	XYrbybrlcQn/jBF51VO5d4x6ik0KjdK8aFe60RVhkIPw06MiqYyaKxcEh3JZNENs0s+1DcpQrkn
	lIDsO8cWaSVro90nnONXzImBC5j9ON4V6JQWNQmONTxEvmW7z+CidnIgYHaX/OVn655El2SjPY5
	mGmF7CoOFujvKTiU7bpYP68D3iMkRVupDiLrK+xYrtH+F8Pysetd16PLpEI2jk5MGl6/mgqAQkV
	r3PaoikUlplzdpTbksC+zXA/J2hMHxleMh+fDl8LeycqBk7fqX8FQv3UejxybcuAdC4f927yO9n
	XAriVO8fi+HmsCf7uGgVArWeUSada2yi0jFw7BZwh2gSv+dp/qndnc/RatOzAR611CsCHODPrbF
	j5bfZi6tTkwfRe6YGs3KF3mwModoqK+4cKMV7+J+vxEdgbU5X1Fs
X-Received: by 2002:a05:6820:1354:b0:6e0:8fc2:84b2 with SMTP id 006d021491bc7-714f23f630amr142668eaf.20.1793299482262;
        Thu, 29 Oct 2026 11:44:42 -0700 (PDT)
Received: from [192.168.254.51] ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a9048c1237sm185590fac.7.2026.10.29.11.44.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:44:41 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] pNFS: don't send _NOMATCHING_LAYOUT if still doing IO
 on a layout
Date: Thu, 29 Oct 2026 11:44:40 -0700
X-Mailer: MailMate (2.0r6272)
Message-ID: <A4E65DEF-82E1-47B5-969F-F3DD57F03480@hammerspace.com>
In-Reply-To: <2e7ae55d6eacf80d2b65f7231933460dd198ae49.1793134903.git.bcodding@hammerspace.com>
References: <2e7ae55d6eacf80d2b65f7231933460dd198ae49.1793134903.git.bcodding@hammerspace.com>
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
Content-Transfer-Encoding: quoted-printable

Please drop this one.  I have a v3 of this patch in series:
https://lore.kernel.org/linux-nfs/cover.1793298149.git.bcodding@hammerspa=
ce.com/T/#t

Future versions will be in that series version.

Ben
