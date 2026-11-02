Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793647658;
	b=qJT/2Q3Lr06YeyxbC2FRu2In7T4ugQvp4XkNwKHnq2/irW/nSdNtmdj+TS21snDJ8PfP
	 wuxhKvDZQ0AxHqQiQyhC0CQgNL6zFJhe8QyAMYpHC7zDapcOarv5gyhdWgN6HFegLmbkv
	 /S7YM83ndvpIJ+XuSIiL+1FYEw4AIzS4dcyWqVynZiH41aAdCHt0ha105gJqADYuQ445s
	 WxSaGMrKCF4W0nQcS7vTDfG4rt98k+bzc2IhlrCUD/uzRV9QxIE75tdyOpv3T89ARD6sM
	 5l40gnkt68II+KvfZs+Z2L5KV0HmrnCdjw1gfGDXhKNFvLa5Lh0Amq8ByKIf3PcfeDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793647658;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=5TEbyNKwRpbYrZWz4UfdyjbdbtGmZfyeOkfwZ7+qTCY=;
	b=PXu9TMIr5Pvq2sn/b6mBdHC6eNQr2RHYBKmtUvdhaW8z7EeBGG1XJ6wg7VYwbFHRKNql
	 7KABsI0qR3oIyshA2xgWEgQ6CK+mUs/upy4+HRv6L2JLZyzVPOVMouio3D23OvVez4Nbd
	 wipOjZBTAJxKdcDitRS0IjZQGP41tt1jcBPRmajM41Gxj8k+BdtEmGM+PZrZfp+0lU/9q
	 QAhGEfV+7bnFbfFlwxp3JKPwV+U4mBydtQiIRO4NkJMNUhj4yJaExXJCL8/c+jJzOzuAD
	 eRvAD1vgMp0JeKBG/0B9yejarxVg5u2/HnCvS0noFJYDtzjWsPlyPLDTW8xeLNLdbwg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=dd8j+iNP;
	arc=none smtp.remote-ip=209.85.210.49
Received: from mail-ot1-f49.google.com (mail-ot1-f49.google.com [209.85.210.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80D12606A336
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:27:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 80D12606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=dd8j+iNP
Received: by mail-ot1-f49.google.com with SMTP id 46e09a7af769-8479f46ecd8so1429995a34.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 11:27:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793647657; x=1794252457; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=5TEbyNKwRpbYrZWz4UfdyjbdbtGmZfyeOkfwZ7+qTCY=;
        b=dd8j+iNPqTgOktCEjj6QOQvD3dv2SIEAF7eprJeDOMKupgLABLg8rcRE92duQMUetn
         3ruSUvnHJFo07sujlgKRMaHWZNfJTIPm0Pbtu6pPbX++B5XnwTXxiML3gje9UhaSD/iv
         z0gnVr1v002BEqPWdeCtURCGvVWe8MvdNuWjTl/ntcn11GijmfrRjGfiXIRVyH3WIBWS
         OVWciRbNZMgjrljQSatL9OaxBQ5frSPa2Z6ZHRsxu3YcHN1tWyKT1qGuem/FFFLQrboN
         WV1ML8iYAj4NujA9HcO/nQpCuJ8CgeEBwZL/WrqQ4jMmyMc5/KFnYjUk+Oo7D3v2+aEv
         10SA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793647657; x=1794252457;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=5TEbyNKwRpbYrZWz4UfdyjbdbtGmZfyeOkfwZ7+qTCY=;
        b=2GquKlc52vlQ4F9vzudUQhsi7P4TxdDvMPWrdoFm7NKAZSWeEzN1Xs9DEgCSmRVZMw
         HBvP1bVLrUGqfbxysJKPKg15qyTxaPg5Ih9femciHrZe4P+af0SIpYkpmevKbSSoluG1
         HlNzLBYR+IMaJTQ6J1KzXPhlMDtd/IrgWG1EQRmFzLGojKaF5VsVrwQ0jl2BhJWzdY9S
         6BZvpewPvWKMPMNSQtSie7xj+2IiE30qf8of8I6VOMTub6J3+8zTkI2Wh8uGOzz/gsgQ
         9DEpbXhHGOuz4uBx2UZ0SeDUU9Qb7Lxkn1Tu0nVXYKmocsZCr8UTwh+LMQNYiz7xvOC/
         AbXg==
X-Forwarded-Encrypted: i=1; AKwUvBwRbax4JN9D+pUxXmbVxqDb3tDv0JtCGODkg1pxC2ZiNU4jRH3v2EvRZA+udeEE1IwtL4fGQdU3J8o=@vger.kernel.org
X-Gm-Message-State: AFq9FYLEmSpXjdpMFroOLHzZwDIdX1ClReAJgC3yJtkOJrDG8qRgQlLJ
	H1WSEarEGEtpBH36+0h7O/X0AVOD+4mIp9ln6TYM9kgbwib1tIdbWv+lOtlfRr2kUic=
X-Gm-Gg: AYBFou3+Sko1nENRiACuqI1PaTxDDNr5CTgk9YuBxzSGa6o3VqQLarQfWoybeud28G+
	j7NkCMzGq7RVbzIc3VhmjhFD8zO5mcqByWlDqlHSuBvhrPa6w9PPgyqZ8TLMIADXLvDKB9Nrg0E
	i+Rw3Jwa65wE8rL0bQWSU6lerNcT+xXUdClhTvdMOjP4Gwh4KTktgOCVJ3kjlyOReJSY9m2ix/A
	XPm8aqw3o7OELhQgoSm2DTycF13U+CMbSRw9+16JTpZCSTif5U8Qtkk2jnHoIvGkjLuATA0teJ/
	zdXK5nDWDjXItmQE7u2m2zHwcw7UzDHNUntH7dp8daMGozy7SRZqRIZXi5xZW+aTqcYlbKz4ZbE
	X6H522MiirLq7eg2oryD6z1tRsqVlQSGh9m9Bq3f1GnZcjYvH0FFaKpXtDNFkB5ko+N5B62U+RJ
	qDPDhKjB0wUnJIbtqwNUjFP8PHJA9GcW50MIoTwoU1gPJb2+lBZF0Vq7Wr3doqEKdNTjYHK9CZ1
	QweHF3FggJBd2mzremEg6yNUew2esFMRWaaBG0+9ok8D15bFc1w+BK3sVsBxCQ7iqSGButFninZ
	ApdLhK+YmNDLVKSAo+R1KBUdPfHdaPuagPVNvVFkm4YARAOlK9t2FUA4w1EIecSO
X-Received: by 2002:a05:6830:4391:b0:85b:c75:dc65 with SMTP id 46e09a7af769-85d364a5597mr9385400a34.7.1793647657367;
        Mon, 02 Nov 2026 11:27:37 -0800 (PST)
Received: from localhost (174-24-9-35.clsp.qwest.net. [174.24.9.35])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-85d354d12f2sm9827185a34.17.2026.11.02.11.27.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 11:27:36 -0800 (PST)
From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
To: Benjamin Coddington <bcodding@hammerspace.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] NFSv4/pnfs: Keep data server connections across deviceid eviction
Date: Mon,  2 Nov 2026 12:27:35 -0700
Message-ID: <20261102192735.2158612-1-jonathan.flynn@hammerspace.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <cover.1789733774.git.bcodding@hammerspace.com>
References: <cover.1789733774.git.bcodding@hammerspace.com>
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

On 18 Sep 2026, Benjamin Coddington wrote:
> Keep the nfs4_pnfs_ds hashed once its last user goes away, and reap it later
> if nothing claims it.

I have been running both patches, on top of your flexfiles striping
series, in a 7.3-based kernel on ten NFSv4.2 clients since September:
flexfiles layouts striped across 240 volumes on ten data servers, with
nconnect=16 to each data server and dataserver_linger at 3600, on top
of other NFS patches.  With linger the data server connections stay up
across layout returns, so I/O after a layout cycle does not wait for
reconnects; with it short they are torn down and rebuilt as you
describe.  No problems seen with it applied.

Tested-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
