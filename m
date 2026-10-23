Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792764995;
	b=qknQByYbLGfgpP6IvaPctlyHYsDqzGMSHusW9aILEgeINsd/sHE+DpSdKlTnzBalLmZa
	 V/lRACS+olJU7/CvvojCYT5qiVOZr1q9YpTAFKXk/tBKN5tYbXJsFa96trkw1jqwACxB7
	 ku+9LDQzimR9Ul+bhzR1pR9sYGKdjnG8D5WPue3lS968NgU/aDB1GTeIX4M7lfOJmdsC6
	 mv0M3jhX+qk/D42QersPCBXjjIm1GENyBPNc+Pgd/PdWsNaxmu8+ERZnly5ogSA6XJxKj
	 Rq1K5TRjrqZbcrPAC53h136b278Jr/kdj3DjEv63qYyl2r095TJ4xQrwaodLGo4KdlA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792764995;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:To:Cc:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type;
	bh=NKB9EdW/UP/4nyminPprlgRfTROBUfQT9S0Hjy2s9TY=;
	b=0N3urcB6CGdnliAI4u6XU6TbXS4B41bggunK8FcwAfZTQZrs+IGawZ5SYuYVdpqqZtTL
	 1+mrWCFexp7hODZX0eYZFBJcPGeMJGaCo5JfWNGr2N+2sE1YU8Ele8rWlQNQcmTo0a6sW
	 DSL4+l0+fAkZ03s1ulec0XkIIvW4P2fCV/WTYaiE4hrd68hWvBFxGZ/9trh1nHPeusa91
	 uslyth2l662IpJnNUB76t1RdWNNVo2bvB72F4/bwF2Qo/GcN9lf97/rqI7DBHtjsAq+Ow
	 lTAuim1u6i/CPcIWoSTW+ExBClK88qooGTiKC9p1Jv0tNJ+g3Yr1zbI05UnoG3iOieA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=NNVHwayy;
	arc=none smtp.remote-ip=209.85.161.41
Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F016606A31A
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 14:16:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8F016606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=NNVHwayy
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-6f74f6b46abso456920eaf.0
        for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 07:16:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792764994; x=1793369794; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=NKB9EdW/UP/4nyminPprlgRfTROBUfQT9S0Hjy2s9TY=;
        b=NNVHwayywSyZOL0UAzj2h5PIgiuefctRUcD8r5i5+qsSwLo9NRUqsmA0wOlfOrPyMa
         Vfr/W0abzVsfGnlKrzlJ1h4Izhy6gFttVzqZ30+KnQfDkP5S44g+ubyfqwV8WWqrU3qL
         2aHPJGtbddJv0rYBpYn8s+SWHJajSafzxo9OfW1B9a+ukAge/3uaPgjhBTvex15AInGd
         GtI1IIel+TFrPWxyaIHqUZXjJ73ZmX8pf8l3M1ixb4H+qM777/bzYaQ1ROTRRaRhqZdu
         HhpLdvECHqe8Zw1dIPwi8Uu2wDyVKH4gtg5g34c0KaXHtXYQvrouf+sufByfTXbFEIuO
         Wwtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792764994; x=1793369794;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=NKB9EdW/UP/4nyminPprlgRfTROBUfQT9S0Hjy2s9TY=;
        b=WxLdoEcxBWHjWvFVaThKifucB0suxyoNPJEmLnx/cvNdZ7H+ZUOmD9qfCIQ2P+pDFb
         ZT5j6KlCd07ZhrBD2QPZm05+5CNSSqjugB3RBsF3XG6cEknJkoF0QLWNcRydAfEKok8+
         KwV7KmJev2EuPMuOKGvp4Ab7qMapUq1q2glU8h8AQaEFNvuMXekCsYFN+mbUuxWmNUeW
         PiNnzDfUln4NwpQbGy0Foiifl28rIqSgt+SSQkxQT2hkCj/0ywcDvUrg3UQ/dNLxSimF
         Q84vfKD3UOTZ5bHPlDIPqjUhDA8A5fkdtpma9UO7fna3jHw4zPaaxdMU4GZ3Tm/W2XhL
         SCmg==
X-Forwarded-Encrypted: i=1; AKwUvBysI1ROCUk1oOUiNZVpwXvjOqadOV1SEyJctMauwsimeufjQ2+KmZTJAdrk7Tvibs9tTzR2u4qHU3c=@vger.kernel.org
X-Gm-Message-State: AFq9FYIo+jCzt1zwOiVIeRZEP05lj31ZfREeusdpb9I5YxgZBAwetNju
	pXNFeZClL6ypkzONmBaVxrG5vTVmHvx8T+njCQitlJadnjeKphcxbAjCxSybmPp0u9M=
X-Gm-Gg: AYBFou222vFPRqhOQ9iHDrUD83XE2lYNz+we0O+qFwtHbekljNo3oTLhQ1zu4UpX47a
	dErcczbDyUezQvrqGWkxkRFqkot0g4W8xrM+m1k4/mDnamK24zJ8M/TVJKOxe0MmjafAuE7Salu
	lFQMcaKWWJ++d5MlSvZD19Tzfn+g+l8yB/SonXpe1r/hLcMSuFc5VGvlN5MTrbZKVKO/CR8RyrL
	Paeu7qlwKqQwjyJ4K7Ymwq6GxSTSxiXv5ukWP3++8AYSlkfoPTQK3qhGsrspnTzwnSTS8eOA2T5
	Ex3MZ0eVkbV5hcRmsbtcA4oOsYFTDC/jigSHwDw428SdphETgXgnNe32ZafosnuaQzoqzDDhVyH
	aQRQncQPUDVkHRq0Q+phBidKVMRjOPclYYBnDY5SSLwo/o4RuhGnn5dWtmbourN4/hkFRSwrAJ1
	117ieocfVzVpVpRqtwH4ePRERcZdB8MsEFoDyRnHCkePEvW15IuZMkRFIeGTAZ9EURL0IdtcYz2
	G1Uh/BKe4nL4IQjthzCz3HEgAOANcBlilf48EHKxNDdV5PSA/hp1l93xWhNj9Z5fe8R4SAhF6o=
X-Received: by 2002:a05:6820:1ca7:b0:6e2:3d8b:a007 with SMTP id 006d021491bc7-70b889c7159mr1509380eaf.32.1792764994407;
        Fri, 23 Oct 2026 07:16:34 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-70b9ae1a41fsm122266eaf.5.2026.10.23.07.16.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 23 Oct 2026 07:16:33 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Roberto Bergantinos Corpas <rbergant@redhat.com>,
 Mike Snitzer <snitzer@kernel.org>
Cc: Antonio Alvarez Feijoo <antonio.feijoo@suse.com>,
 linux-nfs@vger.kernel.org, Mike Snitzer <snitzer@kernel.org>,
 Anna Schumaker <anna.schumaker@hammerspace.com>,
 Trond Myklebust <trond.myklebust@hammerspace.com>
Subject: Re: [PATCH] NFSv4/flexfiles: add a soft dependency on nfsv3
Date: Fri, 23 Oct 2026 10:16:32 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <1925D89E-8A84-4FE3-95BC-93061E6578BC@hammerspace.com>
In-Reply-To: <CACWnjLzVeXAfVWgg_YTqtNTDd7LXSkM9dA0znwdPLY=4226bbQ@mail.gmail.com>
References: <20260902133554.28863-1-antonio.feijoo@suse.com>
 <CACWnjLzVeXAfVWgg_YTqtNTDd7LXSkM9dA0znwdPLY=4226bbQ@mail.gmail.com>
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

On 23 Oct 2026, at 8:30, Roberto Bergantinos Corpas wrote:

> There is another problematic case for this problem : if an
> unprivileged container attempts pNFS I/O, SELinux may block the
> request_module() call, leading to a writeback hang instead of a boot hang.
>
> Having the module pre-loaded at mount time avoids that scenario too.

I think this is a stronger case than the nfs-root, which already requires a
sysadmin to have knowledge and desire to configure the client a certain way,
and can certainly apply the work-around.

Roberto's case would look functional to the admin, and the failure would
happen later and be difficult to diagnose.

I think Fixes: 7a375cafc14e (7.2.y) is the accurate tag, though - because
before that the -EPROTONOSUPPORT would fall back to the MDS - it gives the
WARN, but doesn't hang the system.

I also think 7a375cafc14e also needs a follow-on fix (Cc: Mike) - because it
now causes permanent failure cases to retry forever- we should probably just
fail the IO.

The last thing here is that the MODULE_SOFTDEP is just informative, it only
advises modprobe and initramfs builders.  It not going to fix
CONFIG_NFS_V4=y with CONFIG_NFS_V3=n or m.  So - I think we should just make
flexfiles publish a hard dependency on a v3 symbol, which fixes the module
dependency directly, and also fixup Kconfig so that there aren't unexpected
build failures as a result.

My 2 cents,

Ben
