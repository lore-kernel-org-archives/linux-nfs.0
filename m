Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.225.138
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794565562;
	b=Wk9WRgmxHEiSclVEGynqQ3yOp1GrkCQyxBsgb15/QXqk+LqGF5Xhsn93ckvMyPNwsRrA
	 SnCxXZXQL0oaJ2RmzFbOwDiKyIb/FtN10koK4uXUCGPIVHvub+SuRL4FNb2mbK6aYduYF
	 aT7Yb/UKOihT+ppFnSG4M0/s7seLEiSE1qvH96wCfPOlBULhD4YvPwfqb8j1w/iXwuRPD
	 JKPYvyLWmCKYIFgSiWD9PfcENbRHpbj2GbdBQ6jdWR3knPlY4yqgKMyXkld9w22f8jiSU
	 aeYME+/ikYG8S/0JEcb+stgq1nzgSuPOWHtLgCeS6bRdrF6rdJvZkj93Tsx5wTZVzzA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794565562;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=5OyDtStyAeBedN7jaZpmypaL0n4+GQJgji3UYOQMX7Y=;
	b=w9sAr5miurDlDjCGzn/WEnTEzz6MCo1bbP+I2rPVgsFOcMCqDsl8tJdlEb1PHxyCfw96
	 TfsXuzYkN7wLQsOYVT1hIvW74/EA0Z4XYxVwuZ1ADNsAB0hPdSg8JV8b1nhsWiGWmwHt+
	 NjWAivHqz6uv0OiIUy8Dnz1L2dc8YaYEKnxRt8AjQL3DAb9cv+SCiVPAhlzaDZRf5n428
	 ochH8+dIDxjKwyzaRXNqimnijYakVES+mlCNcu9I+ApjWFSncs4ExiVP7UEP16nSvX575
	 i387hhex+5IPA7+oXeXaHfUKkCTLG013KV7ow1Z+W7fIEyw3p8JuyEGbpUIM6qb9rXg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=EhCy1rjV;
	arc=none smtp.remote-ip=74.125.225.138
Received: from mail-wm2-f10.google.com (mail-wm2-f10.google.com [74.125.225.138])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C93E2606A888
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:26:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C93E2606A888
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=EhCy1rjV
Received: by mail-wm2-f10.google.com with SMTP id 5b1f17b1804b1-49ff9833fedso1224205e9.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:26:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794565560; x=1795170360; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=5OyDtStyAeBedN7jaZpmypaL0n4+GQJgji3UYOQMX7Y=;
        b=EhCy1rjVxVdFrlqlBXdnWdhZOgju6UqPO7MHP0T5eDQlLH3bu4fGnJjBmSeu+X4e2W
         fqknndYp9WUsPcSw+hMOJQKeOCVQ26f4CApHOuaHiz0ZnrEcpw06GAGjRX2e/v0KskXR
         kPbczhlJA2JL/E3RYwJYZ55bjMsTqV1bcwrFG/iNBMGzSlTlhWz25UxyOw6nI4axYZSB
         u0krz81cE8qJBpZN+Gj0XIkGJFuZa0vCttP7+3dXPKfvLd7fzcQdMwTNK/JaleYs6P1m
         dJAReh6EvrYwFB4nFlJdvgjX0mrHV5c8k7KozarvFnbaOIXtcKdLHY5nOcL1YTJjLQtf
         x2BQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794565560; x=1795170360;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=5OyDtStyAeBedN7jaZpmypaL0n4+GQJgji3UYOQMX7Y=;
        b=bXVBWI+ebTRODiyhIRe/FL+APnYoxIb+jCITTbsfwFwoSZlRmKNfc4He8q8G30rHQ4
         seinAqXx+7OskcoAeAsdK3OVUBxvcOyL2YL/t1KjSMHpj/EoM5dyzKWXxHHdag40R/ME
         oUe9Ywk3YkgWSeT9YWpb/0/j2eCO2xdfgDGrkUBFa/dB7RYIzXQlZwci3etn+0Ayq+LL
         uZ7MLV9e4qslhJ5ia6FfwBg503frasyLAF45LLqguqsiOjUR0d9ESbh/P+lztx686R+6
         Fx9ouq2t1eOyiGD1STjv21R93KOluDpJN2ahgHmW1xZ+G1Se7TI/yAzwupsn9/nMvhAP
         S9Xw==
X-Forwarded-Encrypted: i=1; AL+hErEh5RWdN+PGX9ejbcBtw3mmnD1cQ3jsT0iHFeAG46Ad+gVp3PXzbpQMMEs87mr/5frrb9TulVVBm80=@vger.kernel.org
X-Gm-Message-State: APuU4Z+Lgv4WcsebEekSzMBMdAPDT5VXTbuHt409czEJF+Sh3y92JvaQ
	KKBcE6E3wliC8L3pMqWw70C9xHYPmrF4LGoXJKwossamkfDtZYUqe/xP62laSVXUS/eH
X-Gm-Gg: AYBFou0lN6gTLzfpulpQjdgnYNZZuyUnZiNwNctFG1Y3Wk3A7vLKjsTcJNTLR/MHlYP
	sywIl29NOw+VyZi0dnhdQtJss0H93OJlo9ZQQUndVfUzm1sjQrsi0ORhounZcSFkqoTq5emSyeQ
	pSSeuFjQ7aEWDv3OBF7zEFik04LRIhqHBVOq2BE8D7r/TtPeyxzuC988S74T16gwsKWRXXesq5Z
	HhlWJg6VFZYY6ViQlWBUCmKXwiZGgbe3l7pGQY0aoMhk4PlTMygSsCjjGNwCUCuuEe6jtNq/AE+
	/S1jyazqWdEYsAvruZC1nS/O4S6RU6sA4XUKnueZjk88GK8Ht0k8h8Lzq3WRpIvyN6Bwq0CKZz3
	R+/QXs479PEsmWgXm7anqKfHkeUWRehc/DBLepEimjtTvybxkKO78Cl7KFXXFM3M+1uWrRcZdCi
	eONXGzff/NhfAd4ubs8iG5FlJ3Mzi2zsZ1tkBDe5hL5/XrzUMzw+b3/fwKky172OpbLlod3ZRAy
	x0+T57rf9pblVOvDDqt8LZQ33i43vdJ2qbnf6RNVgwVF7mXx4tol7mxOqxV+fN786P+WaoRm0m6
	WJ6w+icMzpxk+7YiLwO9oXVWM0EKjBIXXb4oyiCQQfRG9vVSq7H5rrqFYpZfmJo=
X-Received: by 2002:a05:600c:4e49:b0:4a1:78c5:79f5 with SMTP id 5b1f17b1804b1-4bb55aa999dmr38995625e9.33.1794565560090;
        Fri, 13 Nov 2026 02:26:00 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb4e2538b9sm244439965e9.1.2026.11.13.02.25.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:25:59 -0800 (PST)
Message-ID: <fb1d72cf25d10a960da627f6d93a3e041820ed3a.camel@amutable.com>
Subject: Re: [PATCH RFC 38/41] fuse: refuse files on pseudo filesystems as
 passthrough backing files
From: Alexander Mikhalitsyn <alex@amutable.com>
To: Christoph Hellwig <hch@lst.de>, Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>, Chris Mason
	 <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, 
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org,
 target-devel@vger.kernel.org, 	driver-core@lists.linux.dev,
 linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, 	fuse-devel@lists.linux.dev,
 linux-efi@vger.kernel.org, 	xen-devel@lists.xenproject.org,
 ocfs2-devel@lists.linux.dev, 	linux-s390@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, 	linux-usb@vger.kernel.org, Amir Goldstein
 <amir73il@gmail.com>, 	linux-erofs@lists.ozlabs.org,
 linux-kselftest@vger.kernel.org
Date: Fri, 13 Nov 2026 11:25:57 +0100
In-Reply-To: <20261111151202.GA11391@lst.de>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-38-4c998976c6c7@kernel.org>
	 <20261111151202.GA11391@lst.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.56.2-0+deb13u1 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

Hi Christoph,

On Wed, 2026-11-11 at 16:12 +0100, Christoph Hellwig wrote:
> I've seen setups where people use fuse to mediate access to sysfs
> sysfs in odd ways.=C2=A0 No idea if that's still around, but if so, this
> patch will break it.


Oh, that's painful. Do they use backing files for that?
It's a relatively new feature in FUSE...

Kind regards,
Alex
