Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795124904;
	b=obKXeSJMJv4GIFEmrfg5YAS64uM+8lNUvHcCzT/pUaU/02iANrnB2EfEX3dtq5LpirHg
	 MpGKr98/hxQjcPi5QlBZI7r13UaHED+zxL9R8RWIRb7bq9z4SydpJFEnbE0DyEVYbgjya
	 XSBm56J0TSLI/acxQIxevIEvB5AodjyvCGtO0kDAoR0JMQN570bD+vJB6uYwScNsruqde
	 nRRi7Cj7JFjMe3SKCxzRZqdMBDSJihDwGy3Fg8+bbxpZFUz7VpYOTJFsRUsybmWlDgw5I
	 dcE42GWuOPMBkiVTt+qNbImw6e9pMcfUoHOj3CQ9flP5KgLtPiSszDcFNhnZPXZ4yWw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795124904;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:To:Cc:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type;
	bh=qRHkq6IGCkFUNP0gdjcKEKkWZyI8xAnZkL+Zb0GWFt8=;
	b=GGL6SfbjJYqrOIqrwdx0T2Gk69eY28Fb5yG5jKR3Ne71tnui3QBf7WVl2NmLFE8GU3E4
	 7SqTWbU96ZbZAqgGWIU5IWv1RgZ5JcYOOlPcyx13+IJrDgaxdkkw6J+lpK593g3/ic8LQ
	 dTbv//SFc6qkud7vK93pP2lT/oWpVfhDGYBLhISxk0PNfhlv5CqZEjtVJ361B47VxiiQM
	 2DesgQoMWnFPyF0ke9194ILhiymHqIWbPFZWD40zs47L0VntbrP3/KJHI7XVDb1b9m+Qx
	 YObfZhTOrGc1EXBdF/gTQ4WTHq0FRdxgVTDsdhHr9rDwVvnRrJ+0sQc9bDBBQnYUjbw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=f1X69JU5;
	arc=none smtp.remote-ip=209.85.160.47
Received: from mail-oa1-f47.google.com (mail-oa1-f47.google.com [209.85.160.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41E8D606A320
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 21:48:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 41E8D606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=f1X69JU5
Received: by mail-oa1-f47.google.com with SMTP id 586e51a60fabf-4a76f63b243so1280642fac.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 13:48:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795124903; x=1795729703; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=qRHkq6IGCkFUNP0gdjcKEKkWZyI8xAnZkL+Zb0GWFt8=;
        b=f1X69JU5xxK1YZLUkqTlVPwbeOJdk/pyyJ5t+uDMljdOERtCK2aOs0gHvuRsO/Ycft
         Fn4YGdbOjMRhowajO6R6XB/9igi3oDZbuvNnKvrZ543TvKPRyyyyozuBFVFCrqj6xEPr
         zqdp7pbDe2+/Q5VQqDOXM8vGTmp5QXydZgqHVMZ8Ft8zawFhErTS7Pvv660YFrweVb0T
         6uYFcs7EK3i3EgWokTFvLvuOEJ735rI0qo3xI6ZkRsvoNVlIbCq4LJ+AsdmI9a9Gm2ve
         GhZIE42PvrWpWBUBhvyYAjP916R2m/pmcvVDliI20cWul8LcVqBwgTeOybb9ViBBe2ld
         E6qw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795124903; x=1795729703;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=qRHkq6IGCkFUNP0gdjcKEKkWZyI8xAnZkL+Zb0GWFt8=;
        b=0peWAg0s4ogw56Y2rTl+vbU7/NIWjaSO7TQQm4K8FCcvu9aAKbN5B51L+zPQLy3X+7
         VqPAa2udcLxlmixs2cWW9nAndH9A1ZmOuZoXbBV0RA99es3jheI5yhiRVrHOx4kqR7hr
         YcHCy7gtOcmrOL8Z0FNKHrRixcCet0n9bP8ZOpiHTfPFlVrRFDN8wSt6EpXjZCHc3WaS
         L9VG9cEW1361EwTf2JaNeGCRIoiAZlU6Rf20ExTAFgaOjVoYmzNeAlM/Ar9gWfYkxAOm
         FlBShc3aV8ooT8IUqtzGe4CPrETtM4ym9dHsREuK6MnXD02McX1/Zp9Glm8TFoQ0q4M/
         7kgw==
X-Forwarded-Encrypted: i=1; AL+hErHh8avQDonhEMB21v4Dwjf3TPi4pukuTBUP9vWAxT56/athXORXFpUDnOAHMBKQQYURCW4k+hT0luo=@vger.kernel.org
X-Gm-Message-State: APuU4Z8Xf3OjxyBIslDvAAd/7mtWABlsTeI3A0wgUTMUUgjF3DfXTP7J
	570X9OCBSs4WMSdWsqvCNWomJRZz6o+vYduE3gvkkSlI5zoBip7DWoLrvOD4QLFbjHk=
X-Gm-Gg: AYBFou2QNrdyUAldpt9PtVpsesN3+ZkCgGA/0uJQtN/IbiuEiLm/ia+OqxhUgIM5VcQ
	uGmvZEh4/P2O82eJUz3AiWDEgerpuT5gY1mVSPPZhctwQPfheoJOP6A1Hw4t4cn3JyAb4jMyeua
	umVeKOshHDtAB8Eqj49RxBp5jo96jTxXwVA8q9qY5S404qb8KAI+I67mdnOnV4z480PxXxxPc65
	ITP2Owu0EEvhweGZmDJT9O/Q0hRYCiKFv82xhxigHq8TAq0j6UtqP90M4d++7uJRg19QTmqyCdn
	D/gUIRogqakZH8j25gXuoQrsgIq2fkchG5NrHiJLi4pP5p2tUMx3XI4Ti2Ve9uGPuB2sB2+fOkE
	fGkGbPPkegKNIQXYJthWeWrmG3x16P6UZAn0wwzLTbq2lNFDaCM6sCgVbtmR7P2HLtuRGR3s5DI
	GTpiKgPeCvQN2ouU+EndZcvE/a+F1lwiBn6vnGbfNrydclkJcikuwSIETzekBvxL4aLEyERTpiU
	QOX7H9EZRfH8OtWFiT6Rv96H7pNL18qWKVgJIhIlcU2VPlKvsXDxLwnKf/eB9xdZwb04PnUP9fY
	ZK1XAE9kvl0R7AG03BS0w9Qy4teAQxCnUC+W/42laMxk8ePDcnyjtYp5jegKQhpRWedKHhkl2w=
	=
X-Received: by 2002:a05:6808:4f5f:b0:521:561a:8e90 with SMTP id 5614622812f47-579789ceb89mr2532074b6e.3.1795124903017;
        Thu, 19 Nov 2026 13:48:23 -0800 (PST)
Received: from [192.168.254.51] ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4bc6108104esm928752fac.14.2026.11.19.13.48.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 13:48:22 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] pNFS/flexfiles: I/O without a layout under
 FF_FLAGS_NO_IO_THRU_MDS
Date: Thu, 19 Nov 2026 13:48:20 -0800
X-Mailer: MailMate (2.0r6272)
Message-ID: <4A070857-8502-4640-B7A4-5945912098C7@hammerspace.com>
In-Reply-To: <cover.1795117974.git.bcodding@hammerspace.com>
References: <cover.1795117974.git.bcodding@hammerspace.com>
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

https://sashiko.dev/#/patchset/cover.1795117974.git.bcodding%40hammerspace.com

Sashiko found two medium findings on this one, I have a v3 that I'll send tomorrow.

The high finding is pre-existing - I'll send a separate stand-alone patch for that today.

Ben
