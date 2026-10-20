Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792515024;
	b=1ovKrCr/BjQyUuOc7oyrJjyILIQk5ufzgywTW6gNEXvC76sGrUTOCpSOMbxsJeTgZKOS
	 gGAprYAePAkss1NEBStqynqUewuDr+nD6/5woXV/Unk9clgngUSoM7v7bkzEwiMo0imWi
	 s/iqrAgBE9z8jQfUn2m3K+dHiyd3bQzuG0vkeIQFojiHcQ5Zvz7TowhpY9sTzyPAzYSet
	 drSEYg/sJkEzwPpTI48Jk077J1/yvsvfHjUMzab6HxB5frtEGe6jIfFNHpYCuUEFmidG5
	 YEKvx2hbdaO/SuvRKp4J4/7ToPd8khcgwdB0rzTd7SkG1oWVsd8QE1nslh9h0BlxMGQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792515024;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:
	 X-Google-Original-From:To:Cc:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type;
	bh=TbIWm7ZeUgPxrenKOZm6kGef70sedQPW1dd4r4lMzZM=;
	b=rLRFpmhqHJcgCCn3HEo/ZofXWD0fR6vr2RG3JllCWEKb4M+xx3zGlD+CjFArC7Pk26e0
	 bE0J08KCMXfQ9D6cKQ7O2mXp/xLm7JiCM8JvFDFHxLbpnYgUM+uizmmJM9OKu9GMdSYbO
	 qCIV3xQZhgPBo/BH1/4AmBuEgcREPlQcce59LtOuUEg0B4zpji8r/QNba6IPRyLDztZrE
	 SECki0/869C1tNrTYnHtD0HhgQgUWUQbYwOF1oNju4uWXX8WtJcJfIGbfRJ1PgwcQHCC1
	 lSPUavxe2q4378ErnQL2aHxVK8vTcqtS/fS0uPidAdvR8p18AH9ihGrD5KqZJfZQYYQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=SbgC2YC7;
	arc=none smtp.remote-ip=209.85.161.47
Received: from mail-oo1-f47.google.com (mail-oo1-f47.google.com [209.85.161.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C0035606A31F
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 16:50:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C0035606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=SbgC2YC7
Received: by mail-oo1-f47.google.com with SMTP id 006d021491bc7-6deb848ddd7so2241595eaf.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 09:50:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792515023; x=1793119823; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=TbIWm7ZeUgPxrenKOZm6kGef70sedQPW1dd4r4lMzZM=;
        b=SbgC2YC7bBFTVxZSvTT/P639kf4a6sYlIOjAkvB4QhDb01wKSqoL2HTVyoTkJKAKlW
         YqorBZ5+QwtFt+WUvxGoS1ZsKoA1P4kLVGVLIVsyuNfTJG+ytGawUXl+RU0HMTzpuQBi
         /pHASEVny7P73+xcOmVPt/2s9k16YfQoXZ459z9TviByVzXpAk3KpaEf8xpRoqEVZyv5
         4iNHRi0ka5qStrO5dc4dRxtIVVIudL0Mn69Na07KxdMNw26VVO3V4QqfUjdt8SAJJ14O
         IIyXp/1eB9FOinIOFhpYm4+nDCQ2JxNy/7S7wCfajKIQ/QiSJxmcjf3oUk3zHtUvjWrG
         wtAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792515023; x=1793119823;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=TbIWm7ZeUgPxrenKOZm6kGef70sedQPW1dd4r4lMzZM=;
        b=Xvj/x4mQj/ZPKKxbPdBkMqYFo7gectyesrWkANZ0W5Eo0Uy57GfGlPl3dwiqUeopLr
         vYaUi4hSxckxiTvCoxMLiA5ZYTZ04I+s4fmnRSaBpdmh9fGG6SxF0v0b0S6Ss8Qj+67H
         67RnsR3X8/KXmv4bcQA3dWTVFsy1C97D36dDGfSNBsHnZ3vw2rTKsD3Ysq8egkBZMai/
         g0Ds1eu5B565XnRhasr1nPjJVFeJ4sZJbCTEt86TAS/h694nUfFCHPJvT97A/dpJhQy+
         lriXCQVKfqRUmaW5mrVbuhxJP9wX1T0mWBJkKGf2gP6dnSwlqQBh0NnyCUcvyH/ScvZM
         b78w==
X-Gm-Message-State: AFq9FYIIRODICokGvOFFyryExpQILsRPDjB20RasYztGypY7oNsr/Jox
	UqI6h3PX05z+iL8kf2tmPjWKZDQkWaRsbB6ov+RD4Itasy2/2MHOf8b5oeS08fdOAec=
X-Gm-Gg: AYBFou0gaFIxLaysRoA3YofNfLHyAsGT6/fGjskI8WcnuH3oVQF14oXBoMD0rplTGfB
	QaJnkzpoj0YMQieQNJAwepHDekD6aDe+0C4jV8A6Vh9Vix193lnOuvefQLcJ2cBxcivDwlyWnoO
	Ab0lrKY+r1FNveZg/pc3md6wlt2WA+Whr5G+6TbnA0JSTvw0tRiRumxbLHXzWCn7tq3+6OvG2zy
	uJMhp0rzgRPq0KR1DtOvEBr9zVLq3YHcVkWXkB1v3EuXd+TXNfIWKkpBkMkf/ViOEZOKQ256FYQ
	NvpD9AnUqqW41H3p46ep6oJNxNS7BY7rAWq/6mH7KhShxpysK6rJ4h97uPhUbLUbK3T9jchfJZ+
	sliQht2ooF9rGO7nVEv7kYAVkW+pHFNH+cwQ9bya4F+aaSmu0ztsuogaExhL6EqsBTQKcjMTlvZ
	IEwPrYOXcvBlDBlVHGI0gkVs+C+6lVqkVkt7KHYXojrLc61CZ4aJ2bd2moPVGmE0Knbu1F/qQlR
	StTrSf35KD02WvgqQ==
X-Received: by 2002:a05:6820:290b:b0:702:f7c2:1937 with SMTP id 006d021491bc7-703584979e9mr7721594eaf.83.1792515022507;
        Tue, 20 Oct 2026 09:50:22 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-84cba7d46fbsm55998a34.3.2026.10.20.09.50.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 09:50:22 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com
Subject: Re: [PATCH v2 0/3] NFS: Modernize decoding uint32 arrays
Date: Tue, 20 Oct 2026 12:50:20 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <4D7F286A-63D1-4A33-B0F0-899BAF1F1CC2@hammerspace.com>
In-Reply-To: <20261020163749.262930-1-anna@kernel.org>
References: <20261020163749.262930-1-anna@kernel.org>
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

On 20 Oct 2026, at 12:37, Anna Schumaker wrote:

> From: Anna Schumaker <anna.schumaker@hammerspace.com>
>
> We've had several reports over the last few months people have tried to
> add bounds checking to the various places that need to decode a uint32
> array. None of them update the callsites to use
> xdr_stream_decode_uint32_array(), which has all the proper bounds
> checking already implemented. These patches make that change.
>
> Changed in v2:
>  - Properly handle -EMSGSIZE in decode_bitmap()
>
> Thoughts?

Looks good -

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>

Ben
