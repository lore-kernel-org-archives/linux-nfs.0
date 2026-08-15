Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60B6717AE11
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 20:50:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786827023; cv=none; b=Wv5W8HvwvtJs8GNFPtWl1/xXR/auXzGv4om7utS4VNVcSuc//eK9WckDVoQqXiR9NHwL/4aQyX68xjVzi0lwBHOrIymFASeZDijUUZUSDZ+TLM/lBO03sb4pWaMJllOX+Q/RiIK2J4gTbQfoPF6aRF+kKaH1OQM1GrX1L001PpE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786827023; c=relaxed/simple;
	bh=nG+K6zftXd4sajWRXjLzbf3OrJ87pGrvgdDAv894lDA=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=aJF5N7MLy0IJD8wnc6eEt0E3Ch7FZvx1O8dnJaGXSjhwhcGWZAOBihkmap35jeE4nDZeFm3aVVADwnCCfOIBF7uRCTDkJPwR+3ge2QugpYfaTjamDZinLs4HxZjgsRk0XbbFD/A+Y8mntn8L8EilMIDuYSE56EqOutBX9wAw18A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=RJunFVQB; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=jtWg7d/f; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="RJunFVQB";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="jtWg7d/f"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1786827020;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Hje57RuuhJc0OBRQmVeOBtk7H9gcOBSnj5VR1CpqSJw=;
	b=RJunFVQBuVNGfY73PGcU3+lTE4LDxWHz2lRPmel65fFXEptPnufPeKpNYw4MCVvZbBOFyo
	XF/A32b+tWwLVeg8sE5LQFOhXwsnhXIP2ytQxIvdxg7Vg1DTgXDBtBEzfTqWHvoyTPB2/W
	qft8zpDyHXk2eQI8BCgZubSnssQkMvU=
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com
 [209.85.222.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-148-6mpGHQlqOu-RM1TAVTN_ZQ-1; Sat, 15 Aug 2026 16:50:18 -0400
X-MC-Unique: 6mpGHQlqOu-RM1TAVTN_ZQ-1
X-Mimecast-MFC-AGG-ID: 6mpGHQlqOu-RM1TAVTN_ZQ_1786827018
Received: by mail-qk1-f199.google.com with SMTP id af79cd13be357-92e5fc4c7e9so281134385a.3
        for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 13:50:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1786827018; x=1787431818; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Hje57RuuhJc0OBRQmVeOBtk7H9gcOBSnj5VR1CpqSJw=;
        b=jtWg7d/fYgwPYtqJ7qPH0+uxRUkoJgef1jBH7Ewo0bhOBOhI2MyReQypNZtBbNn0yb
         bqDqqrvpOcEHmykJpXzzPiD/8TXfr5dRdyAlLOD7pk/P1LY+q/BoxrF9+lKMFfPPTFOB
         6EuXca3jesdHMw1G34sr8nl5a/GG3i3WNwlT/SQaO4lmoy+D6F+x3PzXsetrLheY+NFe
         6smQqNfflKj63rLJl/Dvue6TMTZEqZtluBAAiXOD+/faJV1KuwZILGysX7WlGrheUsbU
         +HaFTOG52GN8gjjr3GjrWVbH9WIYXZp3RKsW48c803UKJ331Bd5UhzARXkre7+1pOYnn
         3elA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786827018; x=1787431818;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Hje57RuuhJc0OBRQmVeOBtk7H9gcOBSnj5VR1CpqSJw=;
        b=ZOCdtyvuwfwhYxiOHMm0x5wEKy9dWEWJ39YW39szcYJWil3Luck9DttnsnphIzRH8l
         eB9/uNXE8PmuvWhQZeftVxsdmxywNuqnMy1ih9ONsFo5rCMe8dscMNnI2IF2fsUI/Jdf
         7oLj0XU0b5c0YhE0soS0NegRQ9e3B65pCdnOQxnyL+/Rgq7WsN9bdFYWIcgxoXrm76yN
         k2WzjOazIHEjEGnSqumnCTL0XXKDMlM17U5tp9GMAMFXK2+gBQZJ0KuOewuHfMzN37/B
         hQoR5MW8mjDEWHx92FBVBPt3SeZYwzkcLN6Zm89nZ0Cp/OaweTDLJ1F4Ceq/V98JBziZ
         XVrw==
X-Forwarded-Encrypted: i=1; AHgh+RquCYyEfFzRAwf+CgHZQSo3t5wEbGPed+B3zUuav+PucEaMEMUai+bPMsRrD5Pfx5g0h5p5jq5mzHc=@vger.kernel.org
X-Gm-Message-State: AOJu0YydeehFHDjT8j0xv4ZEGVnYYFEfelBXqpYIECGbolo+L5CvgiGn
	i4tMWiuzlDbK4o7t+m3UgVVLEDFVgQmtfeNLphnxxOZ92VzTi78oQlB1kjFxkd/gU2DSzP29EFa
	UeEnvxFqE7whLm6AGqTpA8ek0x3ztmxwed0RXxqkWK2pmIdV0xB9so+8AyQwOY40gJzjllQ==
X-Gm-Gg: AR+sD10PHDQaGPg2cdM7ss0WntALljrNKPY+wJe70W4Gmnrz2QELkgv6Nf6EcvXthXx
	Zxa3ENtHS1I34Sz22tBf/8zidhKGapOgfBGGKu5eqDjCQCnvvOCzFWk7NfNW8iTwZVE6TjXF/an
	noETEdnRqvkyiA+B/YoIDGvZiDqQCb+0lwJGcu4D5MKm5Xvge8k7PUJClOyJ6TnnECie4MVWNQa
	5dS4gvo+2Kf5IsnNJIwHM/PeVYa05EgGc4h/aNbGDDoxtjiT7sSF8LxRuPGuKMLXbJdkXctNgPh
	8PsYn+Uwg1a8RKzsu/wlhV5eKioXw+PMQ1Y1OZBfANVh/jLiQOv72Govg6cwVP2SBvpj2mXNyQ=
	=
X-Received: by 2002:a05:620a:2683:b0:915:83fa:b3e0 with SMTP id af79cd13be357-936d1fdb95bmr1407793085a.5.1786827018318;
        Sat, 15 Aug 2026 13:50:18 -0700 (PDT)
X-Received: by 2002:a05:620a:2683:b0:915:83fa:b3e0 with SMTP id af79cd13be357-936d1fdb95bmr1407789485a.5.1786827017825;
        Sat, 15 Aug 2026 13:50:17 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.241.57])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-936ce22b36asm619016685a.39.2026.08.15.13.50.15
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 15 Aug 2026 13:50:16 -0700 (PDT)
Message-ID: <009eafee-5f36-4955-a07e-3df47d5018e3@redhat.com>
Date: Sat, 15 Aug 2026 16:50:15 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [BUG] nfs-utils 2.9.2: exportfs link failure with
 --disable-nfsdctl
To: Jaipaul Cheernam <jaipaul.cheernam@est.tech>, linux-nfs@vger.kernel.org
Cc: David Partain <david.partain@est.tech>,
 Daniel Turull <daniel.turull@ericsson.com>, roland.kovacs@est.tech
References: <9fec9f1b-1c10-4a20-8282-dfc9addb4ee8@est.tech>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <9fec9f1b-1c10-4a20-8282-dfc9addb4ee8@est.tech>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit



On 8/5/26 3:32 AM, Jaipaul Cheernam wrote:
> Hi,
> 
>    Building nfs-utils 2.9.2 with --disable-nfsdctl fails to link
>    exportfs. This is a regression from 2.9.1.
> 
>    Reproducer:
> 
>    tar xf nfs-utils-2.9.2.tar.xz
>    cd nfs-utils-2.9.2
>    ./configure --disable-nfsdctl --disable-gss --disable-svcgss
>    make
> 
>    (--disable-gss is just to avoid the krb5 dependency; the bug is
>    triggered by --disable-nfsdctl alone.)
> 
>    Error:
> 
>    /usr/bin/ld: exportfs-exportfs.o: in function `unexportfs_parsed':
>    exportfs.c:491: undefined reference to `nfsd_nl_cmd_str'
>    collect2: error: ld returned 1 exit status
> 
>    Root cause:
> 
>    nfsdnl.c (new in 2.9.2) provides nfsd_nl_cmd_str() and is compiled
>    into libnfs only under if CONFIG_NFSDCTL in support/nfs/Makefile.am.
>    But exportfs.c calls it under #ifdef HAVE_NFSD_NETLINK, which
>    configure.ac defines unconditionally:
> 
>    AC_DEFINE([HAVE_NFSD_NETLINK], 1,
>              [Define to 1 if nfsd generic netlink support is available])
> 
>    So exportfs always compiles the netlink code path, but the
>    implementation isn't linked in when --disable-nfsdctl is used.
> 
>    This isn't triggered with the default configuration because
>    enable_nfsdctl defaults to "yes".
> 
>    Possible fixes:
> 
>    Option A — always compile nfsdnl.c into libnfs (remove the
>    CONFIG_NFSDCTL guard from support/nfs/Makefile.am). exportfs would
>    always have netlink unlock-export support. libnl is already
>    unconditionally required so this adds no new dependency:
> 
>    --- a/support/nfs/Makefile.am
>    +++ b/support/nfs/Makefile.am
>    @@ -11,14 +11,10 @@
>     libnfs_la_LIBADD = libnfsconf.la -luuid
>     libnfs_la_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) -I$(top_srcdir)/ 
> support/reexport
> 
>    -if CONFIG_NFSDCTL
>     libnfs_la_SOURCES += nfsdnl.c
>    -libnfs_la_CPPFLAGS += $(LIBNL3_CFLAGS) $(LIBNLGENL3_CFLAGS) \
>    -         -I$(top_srcdir)/utils/nfsdctl
>    +libnfs_la_CPPFLAGS += $(LIBNL3_CFLAGS) $(LIBNLGENL3_CFLAGS)
>     libnfs_la_LIBADD += $(LIBNL3_LIBS) $(LIBNLGENL3_LIBS)
>    -endif
> 
>     libnfsconf_la_SOURCES = conffile.c xlog.c
> 
>    Option B — gate HAVE_NFSD_NETLINK on --enable-nfsdctl, so exportfs
>    skips the netlink path when nfsdctl is disabled. nfsdnl.h already
>    provides a static inline stub returning -ENOSYS for this case:
> 
>    --- a/configure.ac
>    +++ b/configure.ac
>    @@ -256,8 +256,6 @@
>     PKG_CHECK_MODULES(LIBNLGENL3, libnl-genl-3.0 >= 3.1)
> 
>     AC_CHECK_HEADERS(linux/nfsd_netlink.h)
>    -AC_DEFINE([HAVE_NFSD_NETLINK], 1,
>    -   [Define to 1 if nfsd generic netlink support is available])
> 
>     # ensure the system netlink headers have the latest features
>   AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/nfsd_netlink.h>]],
>    @@ -279,6 +277,8 @@
>      enable_nfsdctl="yes")
>      AM_CONDITIONAL(CONFIG_NFSDCTL, [test "$enable_nfsdctl" = "yes" ])
>      if test "$enable_nfsdctl" = yes; then
>    +   AC_DEFINE([HAVE_NFSD_NETLINK], 1,
>    +       [Define to 1 if nfsd generic netlink support is available])
>        PKG_CHECK_MODULES(LIBREADLINE, readline)
>      fi
> 
> 
>    Both build cleanly. I lean towards Option B as it preserves the design
>    intent that --disable-nfsdctl disables all netlink interaction with
>    nfsd, and keeps the feature gating consistent between configure.ac and
>    Makefile.am. But Option A has merit if exportfs should always release
>    state via netlink regardless of whether the nfsdctl utility is built.
> 
>    Which approach is preferred? Happy to send a formal patch either way.
I just went ahead an took Option B adding you as the author
and I did the Signed-off-by: since it did fix the bug.

Committed (tag: nfs-utils-2-9-3-rc1)

thanks!

steved.

> 
>    Thanks,
>    Jaipaul
> 
> 

