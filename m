Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.225
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794335503;
	b=DsB4AqtUEaUPJQZqhnp0IfCnPoj5fXBmDt9b7vNRYLjZBaeNyXaOTEmzKovohG2ZKkZ2
	 /yKXVlTuM6cRWTKBzcBwjdx1eFoeoWEx0Q+tXSBbD5T6ZOt41QHXty6ALWxOQyH8iBZ/p
	 wPnIGt7QeJm0Ds+Wqc/3fye89YDEzGgkeNbu4S9KMzWNN9jYHdxpgxX9ESbxRJPs1wRi2
	 JeB8spJqwZJ3pKlSuU7J0vpUKqjhK4uEye/XjnTtX5w60eR4CQuc9ADhQ/RJDpxDYX66k
	 nDAbwQjga0JrZo4zEHP6hVQNbb+zOdoJ6c2KQW90abKCGIYUSkW6ZZnUVEk/W7qxOrA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794335503;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=gbmSihoOxS8+qs59nCpK+zlfjMhPtRlMpwSw2IB+/W0=;
	b=j7K1gKeeaBk7hX7jlsUPijBpuEnYNj3y5Whr1BxHL21I1S/8b/JsltITi46y3NF5Jb/Y
	 LB+U3SD8yNtpaY0ec85c/M1bIhX5mU1+9L2jYFf37rdlOv2GTc82vndGYxTQhNdD9c/Jb
	 KG+SUJjEAAc8vfY+hx76OGAY4iIGFJWxPiX6TZmN+v+rABXZSpE1pwrtEYVniLS9nnI3Y
	 qPBC8xycIv/iJ4hG9+ALkLvCMtMX/3NMWxAuCRfzS1RS6EB6QGL/o/d2/bP26Z0SRSPcd
	 Ab5fOLdQ4WclmTR0tx6q8mE/uPe311lg62oJdQMl/1Rg407aPG74DzuM4lsI94UkAkg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=PrOoXgqs;
	arc=none smtp.remote-ip=209.85.221.225
Received: from mail-vk1-f225.google.com (mail-vk1-f225.google.com [209.85.221.225])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E45F2606A325
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 18:31:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E45F2606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=PrOoXgqs
Received: by mail-vk1-f225.google.com with SMTP id 71dfb90a1353d-5eabf7d5bbeso1444254e0c.1
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 10:31:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1794335502; x=1794940302; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gbmSihoOxS8+qs59nCpK+zlfjMhPtRlMpwSw2IB+/W0=;
        b=PrOoXgqsL16lXToUusS+qZtwaT9GFgP+vViq0F3mVZQFv7CrWmDImxCxt+zXsZ0qx+
         YiXhWN5SgHr5fm0c3l5BzC2qjJWycSrk0a9F3qZnWt7N/oUBOQe1Kai1gCdebQusUB5u
         9Tw/nFtjMwmCNxZGNRAc3O2a8FUFc59A9v7l8dSqdjPMyVpMVoO0OTtB/C+CeWUS9Liz
         7z+EgoDRaldwa2csFNLGRxndgakbHAf+SMqwtnIVHybiA1tH/IyrKghBsptuIod2i4oa
         cBV0GFIe35W/t0tQnJKwNBo8e+hN+Xhxw6CQggTTZxM/rbNamOaPhkIZoJ1nXUHoyftr
         CjnQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794335502; x=1794940302;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=gbmSihoOxS8+qs59nCpK+zlfjMhPtRlMpwSw2IB+/W0=;
        b=p1MQ2NxxYUyxRUJHajfb+o0AKPRZLbseyduGmSVb90dawq1yNG6dWsWbw8eS1P8iP1
         dW9GHMhOqOKinxRsjcdt48EWwdmFn4DQi3a21s6CZkTRjokTS/KO/g4QuX4RDmHVxaM4
         brhymCDWwAZTTEVEERboRmixA111X7zuedjhD1z+rDBKotopI/vXYY451AHlUSsamsY8
         ayDG9zGASlFgnihqktO0Op5NXVZZYQ65SMxebG/qbBv+iUneT41gIfTDznK9k191XIZF
         dkSfWvQpBiFYsa0GFDC7YNtyauEHeHkmYAJ34tkAleNi98mn/m+KOwt3kWn5j6VweGMp
         AFkw==
X-Forwarded-Encrypted: i=1; AL+hErGHzSvocZHJodlY1jZ+QCWuq/u6fDtsN2Bf3nsvQ3VmvimsgpxLLPxK2f2KsMgW6ntqvIRSZ2unNCY=@vger.kernel.org
X-Gm-Message-State: APuU4Z+ZOKaIKhVJN3y2ODG5dEshT9N+U+eI8edbfs3szqv8m7haBlGv
	/HUjxVeyPBwmcdJ+w9zCVULfuGWJAuFgUIg94kz9VDf2WSa8OQPoybW635aINO1j1VfwqpIvYRP
	ifaIUckUJTDH/sUkZ12e81SqL/6fmqZNwM669
X-Gm-Gg: AYBFou1P/a6MK4U3Rq8dFC+dxrkqKF5KcXIy8RBpIDOjTQiB3lGuwOlv8nCvy/aQ9oo
	u31+s9JhpgwDDeCzvXy3B9UDyc77zq9DjSWKtFSlHnUFRDUW1q64ntgyH/YKPplHKQAxmu22aJT
	2sRSMzMJQY+MLXqjopNs7EtYT9OSnsNNcHxS3gAsMPtXxKNA7LDB3AisDFXHxBlcT2nejxaemwL
	tvKVTlRfAxj0clTja2AO+O+5sW9h3hMrorfHgAgBmW6EbdOIWA1QWdh3EFOa1BOmxiTfm7rirEZ
	8hyd4fWtPvedUJyxxEPgDd7tegDWj0HjQf87F+6tx7ymR50Wy4y7s2QXAHIYGgBsK/ko2e5NafQ
	isQ+URUZX5dM4AF0VGiHoUhFBg+RfC7rR/QmafJU=
X-Received: by 2002:a05:6122:1313:b0:5ea:e197:93d9 with SMTP id 71dfb90a1353d-5ee0d1b1687mr1626172e0c.19.1794335501776;
        Tue, 10 Nov 2026 10:31:41 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id a1e0cc1a2514c-99c203e7280sm176166241.16.2026.11.10.10.31.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Nov 2026 10:31:41 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 108DB34039E;
	Tue, 10 Nov 2026 10:31:40 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: cel@kernel.org
Cc: Rakesh.Bhargava@netapp.com,
	anna@kernel.org,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	linux-nfs@vger.kernel.org,
	mora@netapp.com,
	slingappa@everpuredata.com,
	stable@vger.kernel.org,
	tmenninger@everpuredata.com,
	tom@talpey.com,
	trondmy@kernel.org
Subject: Re: [PATCH v5] xprtrdma: serialize unmap_sync with xprt_disconnect
Date: Tue, 10 Nov 2026 18:31:39 +0000
Message-ID: <20261110183139.1742129-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <dce03323-90e7-400f-8deb-63010d928460@slotpi15m67>
References: <dce03323-90e7-400f-8deb-63010d928460@slotpi15m67>
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

Thanks for the feedback. I have incorporated the suggestions in v6 at:

    https://lore.kernel.org/all/20261110182727.1739245-1-tmenninger@everpuredata.com/
