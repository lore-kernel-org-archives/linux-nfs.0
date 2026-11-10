Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.214.171
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794323279;
	b=DnkIlCP9nmcTHmvWLEgu2VNopBJiOP6U0bIX1pCIOlAqwjDhhMaKjwX9jvNEH6N9phiq
	 5DNwi68glEq2+QJE4eJyGd18RElUqKCq1TsZY2+KEHzhaLPpVlig4JfTsw/55ZQqNbHNs
	 ceqvqM0t2GBietp7CZa4gcfTEfpQO5TSd9BOXgHdYkELZg0rpUQiTzq5afjoN4MxeCpsd
	 KZO72R8+VBHpeohaCDxEXpxSkxmJlW1+8bbgnDGaJntiBOZ1ksCOWSHK+RFRRuPbDPB9L
	 Xoie6yV077OMn7KGObSqb+U23NWyeBC1ugteFB85Y7l9j72Hh87kQwEBPPCi48ZfLuw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794323279;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=JtM9UtzYhAWCxTCfoBKbcmHIR3U4Wq7tzdw7gboBY64=;
	b=nxRZeH0Nv1vRGDSikh0xzEcNbYnS1oZmiICK6Lf9BW3QWGLT58FAgrs8VmFsLTvmw9cX
	 XBRPjoqZE1PNPUKk7GxvA1Mf4h/U8Mxb8MF29YF4oaFr4SsAIzlpyUvfLurSW8NiFuvLv
	 bGTV7effu+lazZ444RtMz11MZO/IoBJ2gbjOWO6Ns+tdbnL8rSJIOFt2FgH56dir4Byl5
	 2Q9R7kNsU0Vq5/hbakyso8/H2JxGa1yN3ARHYge9lg1IVxE/QlR+ZFmocD2/IiOwYA54C
	 AJIO2PsFrMHCFRY7bkwu17FvwrojoyLeLDQfLxQmAfzeK+zjIox8P+kYFxsaJdvS87A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=LHozpx7Z;
	arc=none smtp.remote-ip=209.85.214.171
Received: from mail-pl1-f171.google.com (mail-pl1-f171.google.com [209.85.214.171])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 29BCD60A2628
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 15:07:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 29BCD60A2628
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=LHozpx7Z
Received: by mail-pl1-f171.google.com with SMTP id d9443c01a7336-2e8da6ef7ddso12775895ad.3
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 07:07:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794323277; x=1794928077; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=JtM9UtzYhAWCxTCfoBKbcmHIR3U4Wq7tzdw7gboBY64=;
        b=LHozpx7ZkQyIUBsAkv4C311vzxfheFN2pzrL9Y/FTHkEXQzaVUkMAz9U9wFUejAOr8
         YATASi40x9WcOvyF4dkS6SJQ2bBJHO0yE68WsOT8oewufPXMhMYT6O7d4/5H33a+EMHR
         jjCu1KqktdAA/9c8ZIpbjFjA/3BLyNbgEZc3fS3F9+PTZ5y3jCgkJQ9rhGft5ONP+cJO
         aTEF5vn9sQP8UWqDXO8UszNcV0yZFTKvtrsUk25y1Sz/3h5njQt9uj1PBQLO+FuWPgpB
         LsGoLTWDE/iFYFuKD+GJLya2PXFipxPXM8zYDthkWkjgd0549O004Xgoom3qc/ylK84T
         vykg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794323277; x=1794928077;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=JtM9UtzYhAWCxTCfoBKbcmHIR3U4Wq7tzdw7gboBY64=;
        b=NtotcBGHA8SZjDR+eSU3fl635m5sU6eXS4yveP4a/YHmbrksTK/WnQahcP0HrGk2mv
         DxVTPmImKhMIeyegL4wGYjlTDS+Gt0ZTS1WM5Wd+Z9LrrS0bFea8dl4rL9XPKj0ZCczI
         9VqrMOVSBU2h4es8WWWeR6r6Ta4gC2c1ntrOBsWEsf2o+oQlydM5RNSusJndqPKH+iYd
         qiiuTtYVe4fPSvrSDXNohXjtE7RJODITMrVdGJi1ClO8/rQPdXrpoqdUASN0xT1Vhvea
         8CdD6ODpT9igEdYCzjV5lkMqT5ToS1kmyjMXNtuyMGUDRSLPLl3/S0JJ0R/nHdQZBUQ+
         fC5w==
X-Forwarded-Encrypted: i=1; AL+hErGLrmy4dHko54XgEpcw9Yiqw8tRI19JaR+87h5nDTe4PuombxioZmcSDAkAo0gf9cVzl8yuojfgSo0=@vger.kernel.org
X-Gm-Message-State: APuU4Z+4dsMp+7Qt46CTdIaU5sbUtR/C+OnGSQiQIFy9AlFil/cwvPkl
	ZHpy+Y8pBfdK326Pvb0VRnSjA0Rvc/SkYJUK9RSAp95OByW1stADHwrt
X-Gm-Gg: AYBFou0o8PDyEDFdxr5FwSNkp5Mp2MmPY39E7C5+cvV06ZmTvU0P5AwnNwEntcADZrT
	K69stCrHUzEXz3AW2tSPXiWdq3BRGROLo/eVcQqqeUN09ruZt/bcw6dXxg+p7ZzXQ1d0NyupuUy
	I70sZhqKO56gEee2rNcOurL7rcrBn/WXQQ6NMKJgT427T/2R8RdMm4vhzeAvolLVkU3IfFFnNh/
	ZHBRLZvNDdMjEXvGnpo/U2Ch4sNmCNztRqy7kf3CzuDElwpniA9azTEsU1qyeE9DNh2pkVsYeon
	4l07XpajEfdx9jxw7GKDA2XJArJo+Owm7/mJjfELmdOJvV9nftJ/MTXFe1crOwcCPop1QAKmbHt
	QBiAMEsmpI2GyOgFijGggwkgjx6AZm99mZqIdY3CiDydVA9+C/up/p6ksZ+trwByP9REoffRcvD
	M0TdhqwT3vTlhdLjUsXz7baJeg7/HIjYap+D54WNSZ6oOBNPK8EBIZPr5jkaxipSWcd4swzqIpX
	7UxlOhWYu6sMkqSHi6x4tvzIl2M6J3vpl1JaBJ1sIPP8nhK/M/3B8m8RLphyOovrKzW8DTSoQR3
	Vu5hRhZnHHYB5iDvDH/iQrbTs1QDdCBVCtVjH3LWZ8lEGzOXkdeAlWfhV6Q86kAsi19vHNF5Clh
	3MrokQLZv5uk=
X-Received: by 2002:a17:902:d481:b0:2ed:1ef3:9ec with SMTP id d9443c01a7336-2edb9172a2dmr26826345ad.14.1794323276968;
        Tue, 10 Nov 2026 07:07:56 -0800 (PST)
Received: from [192.168.2.6] ([27.75.101.24])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2edb6d78dbcsm10397575ad.27.2026.11.10.07.07.48
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 10 Nov 2026 07:07:56 -0800 (PST)
Message-ID: <71f76e5e-ce24-4a71-863a-169ad262c510@gmail.com>
Date: Tue, 10 Nov 2026 22:07:46 +0700
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC 36/41] nvmet: refuse files on pseudo filesystems as
 namespace backing files
To: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>,
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>,
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org,
 target-devel@vger.kernel.org, driver-core@lists.linux.dev,
 linux-mm@kvack.org, bpf@vger.kernel.org,
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org,
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev,
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org,
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org,
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org,
 linux-kselftest@vger.kernel.org
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-36-4c998976c6c7@kernel.org>
Content-Language: en-US
From: Bui Nguyen Nhu Quynh <kaylovefoss@gmail.com>
In-Reply-To: <20261110-work-loop-pseudo-v1-36-4c998976c6c7@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 11/10/2026 4:14 PM, Christian Brauner wrote:
> The file backend takes any path that isn't a block device. With
> buffered_io=1 that includes files on procfs or sysfs which then get read
> and written by a kernel worker on behalf of the host. Refuse files on
> pseudo filesystems just like loop does.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
>  drivers/nvme/target/io-cmd-file.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/nvme/target/io-cmd-file.c b/drivers/nvme/target/io-cmd-file.c
> index dfa8aa46188c..71c69bac5394 100644
> --- a/drivers/nvme/target/io-cmd-file.c
> +++ b/drivers/nvme/target/io-cmd-file.c
> @@ -52,6 +52,11 @@ int nvmet_file_ns_enable(struct nvmet_ns *ns)
>  		goto err;
>  	}
>  
> +	if (file_is_pseudo(ns->file)) {
> +		ret = -EINVAL;
> +		goto err;
> +	}
> +
>  	nvmet_file_ns_revalidate(ns);
>  
>  	/*
> 

I noticed patch 41/41 doesn't include a test for nvmet. Would it make
sense to add one with buffered_io=1? The test would need a pseudo file
that can be opened with O_RDWR and supports both read_iter and
write_iter. Otherwise, it could pass without ever reaching the new
file_is_pseudo() check.

Thanks.
