Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.227
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795461084;
	b=MB5lksqNSDW+e/AA2rJk/JPPaR/0OXnKsCMS76Unlmq4OS8D1nqq46soBByvBFUIUVc+
	 eeULcWpIEoPJCXxsKRHrtxdJAUDNpgThBCUrdybP5HyvAzC811/hrHZ6GyoIjYiF9seis
	 9kBUmiwv3dV6sj+J3Hjywrcbg/vHLZjJmANNOtPZ1E9g4COIj2ChxjBeiBuKV31jSBy7j
	 kqlOkljHU4lh2GW87AnxOKmQ+l8MN+w+sCxt6fkDIOBBOyzibCMjLvkCIDVR3KA2zpnL8
	 cs7Y1NFoAivDWV0JvJwdH7Eop8NkhKHDoRrcYEjtqWxtvlbw/TQOSdFWpy1wUABp3xw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795461084;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=MqjW0hsT+jUaSbjhgq/J0Q8J8U6i1pm0dFrQ9EH1or4=;
	b=YnA2aTbwXnBKtkVRpYvd+8HrK2V7rbj6DFGPbhq+ATyQrHFoMXeygp+xnCA5eZSKZT5N
	 v9NTAqB2d5fAt5zLO2gqtfVy3ONCDngnJfgz6uU6PFDtYCiD7KnVuQzVNHha3X1qqHeXm
	 vh9NyTmYBLTupjwMe69UFQYtjdpaZqihteCZksNW8/syh9U5Mv+NkdSORcoTww1lHsidi
	 hLrhgtpYrF9bd0QFGsjgT7rUGppN3C4czltRiWFsyWKX43j8dJwO2P4IfqcISB9YY/mT7
	 osiD3/8bdI8/ESRiiJw56xCorsMFAgXqIHWGKevjqmKU2cs6NIAGWAlv2mMutivas5w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=Zc8hcYSc;
	arc=none smtp.remote-ip=74.125.82.227
Received: from mail-dy1-f227.google.com (mail-dy1-f227.google.com [74.125.82.227])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B5D2606A31F
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 19:11:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0B5D2606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=Zc8hcYSc
Received: by mail-dy1-f227.google.com with SMTP id 5a478bee46e88-33fb4680717so9921595eec.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 11:11:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1795461083; x=1796065883; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=MqjW0hsT+jUaSbjhgq/J0Q8J8U6i1pm0dFrQ9EH1or4=;
        b=Zc8hcYScQnz85XtfBfVcG5UIkyudsTINdSxEfTb5Hjta0eF3zkJ/22em5JmMtALk3W
         d2JjGzuEoVF6A15xrw2lgsWugp7IXkf4XuKMyyHd6orzkoRKZ1Ydurq3E/itK6D+Qje9
         WaemBFGhPuHbrlLVvm08doVvwTz8rQobE2VzIt7IQuChKUxaVkXeqJ+2kvffHPF8cQuc
         FVb5ozWcIxtV0PsipLCriEYmBU+MXGAKnRpvy5vwP0bvCC1IdZD0ahmD7h07uEH6c/zt
         kEOLQ5+O+ktGk6amUCGE/de152uokpEFtf0g6+B7JgZErhSM8Owq46jl6vfmlYxXiMoo
         n5lA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795461083; x=1796065883;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=MqjW0hsT+jUaSbjhgq/J0Q8J8U6i1pm0dFrQ9EH1or4=;
        b=Z5jnRpYVYJP3zDhhsRNANA5IeHbcrQMQRgiUnAaqcs/u1OsB7LHKhPzfhoJBt2Ogte
         vUEKuMI5PeQ9TUYJZUkQN3AJpKpA3qNvlQN9GF+VDiGD1s00Q5YGuZJG+eP+3BgdffH7
         fKhlRGPhQbS43+4l01z+SALPqk0cuilmpOKdpYSnJr4eS/U/uoPH1KucNoXsbmKkJ2HA
         KLRQr3TBveXWiUSKCY0KwOzWCHxdt5SfDnan4pXpP0SMGE7w4zvrNJf/7JArh+XPV98p
         u3Jz9ERmD97yTcdDDJXYsWMt5i0D9xoxjFAUe8X0jSvgesjexqUMLYXpdu3+1/oYH329
         kg9A==
X-Forwarded-Encrypted: i=1; AL+hErEcNYLPG38PVGqV4cuC+XT1v8EnNCQOjbpvoHmja3JlEQivGjJO+JoXpJVyczPg6VBJVYwu8SRWWYk=@vger.kernel.org
X-Gm-Message-State: APuU4Z+O407nVL9R6M0S855hhIPj7mIsimmTmSI6sNR2HbjjRKHVNRjP
	hHVN2CDiRoOTUCCDyA1h5pP6+agY1Zd/pG6vxLVAiE5WN5ledhnBQMuZLf2xme8180cCrX/M3f8
	/PXsKlLAo2/3Be4UCxrYXUM+pQgdwmh1NF5gr
X-Gm-Gg: AZFdTZfQHUS9X3BKkkOsb9Ua6Wkcrs+Gk8AX+tLZoQIq116m648RH/TF26rl/f8e3Q3
	z4cHCDTGnNEC8z8HR81z4L65tu+oZ+V27OqjSOjq5Y+qoHOs9EcsmJyKtiBk2wBe2Vqy55cO6wF
	OdxV23Sqr7xOZs6DT9I9ImwKpgVDvcO3HitL0EYgaEuYan5xOHps1N6cbJLcBb1QFlK0UwHWhsl
	uHfGXaeTITHvTazUJzC+GVP/hv9i/sTWM5awJhwZkTD0bR463+VskKwQeG9xrGzDhbGu5udIi8f
	eyxQdDvUjoVPoJo0zK3gy6kD8S064LZr02BYxFnWH14ZJBZRF0RHbSs32bqrH5Lkhm7zaKf4p+s
	bjg/MDCGswG6uspdzOVQlh5SqCqiHgoF/tReEXVg=
X-Received: by 2002:a05:693c:8859:b0:386:b826:3f9 with SMTP id 5a478bee46e88-386b82605b9mr2057039eec.7.1795461082934;
        Mon, 23 Nov 2026 11:11:22 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 5a478bee46e88-3869bea0c92sm1285374eec.13.2026.11.23.11.11.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 23 Nov 2026 11:11:22 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 53D713400F5;
	Mon, 23 Nov 2026 11:11:22 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: cel@kernel.org
Cc: anna@kernel.org,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	linux-nfs@vger.kernel.org,
	slingappa@everpuredata.com,
	stable@vger.kernel.org,
	tmenninger@everpuredata.com,
	trondmy@kernel.org
Subject: Re: [PATCH] xprtrdma: Retire the connection generation when a connect attempt fails
Date: Mon, 23 Nov 2026 19:11:22 +0000
Message-ID: <20261123191122.1682509-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <90d0ff6e-e9d2-4b2b-9b89-8245ce502e99@slotpi15m67>
References: <90d0ff6e-e9d2-4b2b-9b89-8245ce502e99@slotpi15m67>
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

> LGTM, with a couple of cosmetic suggestions.

Thanks for the review. Posted v2 in
https://lore.kernel.org/all/20261123190823.1680365-1-tmenninger@everpuredata.com/
