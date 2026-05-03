Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CDA3C1A0728
	for <linux-nfs@vger.kernel.org>; Sun,  3 May 2026 07:31:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777793463; cv=none; b=O18PdOXa2KzMsf4JLmUUAcCAdHqU4q30TgWQudQ2iPfgkGmCd0SxN0/ttC5mAPCSw2LLcjULtcazdxH/3K3qhL9WfHTAoPms2vong6aC6ND4BjzucEqDto6NH77W4ftRMd4enD2VQYAdcnND/UtJ7Ot642w7poTikuhkfgOBwe4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777793463; c=relaxed/simple;
	bh=KobCtF2NoedGEbE6XbclqvTtIPCxvwIWc63HzA/1X7s=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=l2QfUT85xNYOH4YcaPE/7KmCtXOzqmwM+VhBSFlbEP+rsMntXIezyB8c9bp7TgALQAbtbOBReXQgXMoLkiuPCN9+q4DSvWQpKflHIn8rB8NiRcH5Mt1tQTnbnHGtry8ZzdkkIUh5VLVIYU6RJrH1HlHmPVkFh0RkTOed5LgHpJQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=grimberg.me; spf=pass smtp.mailfrom=gmail.com; arc=none smtp.client-ip=209.85.128.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=grimberg.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-wm1-f41.google.com with SMTP id 5b1f17b1804b1-483487335c2so31851945e9.2
        for <linux-nfs@vger.kernel.org>; Sun, 03 May 2026 00:31:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1777793460; x=1778398260;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:cc:to:subject:user-agent:mime-version:date:message-id
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=KobCtF2NoedGEbE6XbclqvTtIPCxvwIWc63HzA/1X7s=;
        b=EoGfjcaMzgcqVN8l+toN5H9R0fIxGXh5O5ahVciFaHZBEFs6H4TphoKvMCkBu4yCGr
         +052TvldnoPFHW4VIwJMxgTBK7b9umhtVdHYLdKeG5PBwyfDW9Nc2pgCzcYBFkqc+NQQ
         gUf25sY1ezvd4/DewUBpZLcfyGOr7VoQN5BZYFHdQCFsI6XeP/YfPh+gOaU5NeoWstlR
         XKpTg+y45eg67IFmArrZTAb0f8z2qNzRNth08ucOmdSF+uzgpV54VT6Zy+FGw9ThsIiu
         fCd8IsobKzFKyzALY2g9jB6cyCHzZNT8EXLP1mggeL/80lQBw2w6LAFSYUSAOFpb2xdA
         yjCw==
X-Gm-Message-State: AOJu0YydrXY0BUOShYHgsLLD/mPZYvCFFGNT4GnbRDzUp7//xCajr3Q/
	XA8h3I8z7e8pbYKjjida2zZjAqg57zKPxNquyVmD0gzNV8yIeYyTCDa8
X-Gm-Gg: AeBDietfMzbwQmaxEti1Ol9P1rGA7cOVZKrbD4JHaMzoikGGlFaTUaAqPQgn2UDBSiL
	ZmULVedhjCpDPJJ2LXMVZOBV5ZHnJ5vTWgW1ck9bxkK3JIXUpAdv4rfX4wMUx4Nc9kW3LS18iHh
	TXnN0IN639bIOOXPYZqNWS+s2uDu28tuV/dxjmI+reh3CbM1XeHVs+kbDhXpPO7tlEP6t/VXqzG
	lQN7Wup8o0rxi36frMqrM1oukDC9oxQkcCNZvBxv1qULyZHBydBMQRmtpx63iGic8VKOLT+IHvq
	LWWCO1jA5B3G7aBjLurB3pCKA2QtDM5/Hi2WWZsElij3ZPS9k16sA/y0QQWDAPsbCnRRK2bfC33
	ahlDdotsBUyW4ECQL9dDQ1fi9WyEGqGbZiwAJZ6PP2lY2ycsKhTSUMW1gTXijO8ohR/1iUDDSls
	lunEPeKiE+z+jMNMFV/rj3+wnxT8cYuF4mPiZNsozDKMyZ2DzKnW/a7Ox8Fb5G7yWx+3HOzASTa
	Q==
X-Received: by 2002:a05:600c:c058:b0:483:8062:b2f with SMTP id 5b1f17b1804b1-48a9886c2aemr49135115e9.6.1777793460200;
        Sun, 03 May 2026 00:31:00 -0700 (PDT)
Received: from [10.50.5.21] (bzq-84-110-32-226.static-ip.bezeqint.net. [84.110.32.226])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-48a8ebc4201sm288447095e9.15.2026.05.03.00.30.58
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 03 May 2026 00:30:59 -0700 (PDT)
Message-ID: <44f3b3fb-8d08-4171-9f5c-ff1a643a412f@grimberg.me>
Date: Sun, 3 May 2026 10:30:57 +0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] tlshd: fix keyring cert retrieval
To: Scott Mayhew <smayhew@redhat.com>, cel@kernel.org
Cc: linux-nfs@vger.kernel.org, kernel-tls-handshake@lists.linux.dev
References: <92a53963-1e4b-42eb-af81-6be9f63f9e43@app.fastmail.com>
 <20260501195856.1126025-1-smayhew@redhat.com>
Content-Language: en-US
From: Sagi Grimberg <sagi@grimberg.me>
In-Reply-To: <20260501195856.1126025-1-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 01/05/2026 22:58, Scott Mayhew wrote:
> The code that gets certs from keyrings currently only gets RSA certs, so
> we need to zero out the PQ certs length fields when a keyring is used.
> Otherwise the retrieval callback will look in the wrong offset in the
> tlshd_certs list.
>
> Reported-by: Sagi Grimberg <sagi@grimberg.me>
> Fixes: facd084 ("tlshd: Client-side dual certificate support")
> Fixes: 14f5349 ("tlshd: Server-side dual certificate support")
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
