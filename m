Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 483EC422552
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 18:22:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786818133; cv=none; b=k/+yGTMllCrHjz7cfpyR8oc/KK2qTyicM50sUEEdFwvMHAFFUH1hpembmQkZ+eTId3X1L5IVIlK0BIgBfZbvzQkUpMpQ/4XIxVFon6auJ3/RYDMGyGdoNDwy03soQa6Gd6zdfNLwIBYkxz7nRznW/3q8Rm1h7fvP5k+LHbD5xWM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786818133; c=relaxed/simple;
	bh=5rj2onx40hReB0t3KlFxlO9rw5sVk24ymDcF3mYHYCQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=j1eS91FgbNFBNyfhm020CSsr6IskOLXRZIGAbAMg34j99gLScj75i66Vi7d+zPEai6cvhesz/IeI+tUAPc0QLyZzXrJ033QQCQLu+drQPjHhR8aF5gOvZgjQ9lhu9uj5kXTbMUVwMXQ3wbryw3vesiG/sb1/FpGQzQm5OqQOKIc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=I6nn/QF5; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=I/AWo3g6; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="I6nn/QF5";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="I/AWo3g6"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1786818128;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=y5ncH4C2Hv2u1F63zOlWlqbEj+bMSjbAG0xzrx3y14U=;
	b=I6nn/QF5t14Xgahok5krvi4L2RsfJ+b6IpMhsemYdyl7En+0GC9f8lZ/f7moO1vXC46Rj1
	W0m+6CCl/IwrMTGFuqFDTsJ5tIsyHImseQ1qe3ZruUID1jQJkTbU6q1tf29SXkC2OQvUqk
	rHsv1e+BppRLxIgI8gI7oE4MOSAv+Ic=
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com
 [209.85.160.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-186-NwxLpIgxPO2WSHzOy8ihcw-1; Sat, 15 Aug 2026 14:22:02 -0400
X-MC-Unique: NwxLpIgxPO2WSHzOy8ihcw-1
X-Mimecast-MFC-AGG-ID: NwxLpIgxPO2WSHzOy8ihcw_1786818121
Received: by mail-qt1-f198.google.com with SMTP id d75a77b69052e-51c1c7f135bso36861221cf.0
        for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 11:22:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1786818121; x=1787422921; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=y5ncH4C2Hv2u1F63zOlWlqbEj+bMSjbAG0xzrx3y14U=;
        b=I/AWo3g6QNOCzfaKS9Vce/o3Mw/nNjeJM2y8mWsoVhKxaojEOYj9Jv8Yh8tbaAvNzW
         SVIyPNIs+0Qz5wmIwgVIMcy3rfiL7+l+xMd7/VQEbCcAhY6ygHoBuvh78Rr3RGTeGeTJ
         9ffsq3wazXu4vJUQYetejQmi9AevdSkY61tKr9IMu0b//CJVf5nmkb+ix8CFMt3sfRtE
         3yrN6OiAji8ieAiQ7JFOzesLAQ3SnumRtM3espdpyuDYYJOUp22s2ursYCAIUWDaIzor
         AAPlSzwfL4/6eEsIX/pha2TbqMJ2K/VRlkNgLfnbah6HZfkCXRSiqGdTGyAATIZ2M+q+
         +uIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786818121; x=1787422921;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=y5ncH4C2Hv2u1F63zOlWlqbEj+bMSjbAG0xzrx3y14U=;
        b=btoULyvihtzwGZ0l1+PYlvzhPTcqaLdR+HwuYs+znOHIPi7DKSxtJHAiMxHrdbLgEA
         Qoy094Q5cY5YCEA2mCrNH87W6/5XE62hJGNwqrb0o4ywHo5eHldQE6AVbWS68rs/R7hQ
         evsUxQgJIpZgEu7HP9cPMaF628q7y9To6oDj6oHN+ZjqxWlDCSfNqFIYr3jupj6YgCGF
         XCyQMW8Vmpx6+muIxaAqVccLYhoozWAMMdsRURnddMdKDARG5OIw5pDiqqbj0KQ3vrEX
         KkleWS7Bu4NLUZSj0/x/aBiGh0PBrc935q9dird8zmOzGpjqlxP6x49ZNCiJxSAgyt63
         6OXA==
X-Forwarded-Encrypted: i=1; AHgh+Ro3S6IihnV+WmmfWMjDblEQLk3a63jxu5q/H1tusuAxuqX0WxHYfmLxdhNhZHidEAm9Dd04yRwBxBc=@vger.kernel.org
X-Gm-Message-State: AOJu0YzVaeAK1lVasmDBLm9elL7Jupj9HLQrxaNTeRTUrYM/J0dQgwyN
	TXV5VPR3v+mCOshKaZYwC8Lm7JS3sv/jHo6SiNwvWSI5JAsKQj1KffXxoCuE31y6F8WRNcojXD4
	ewVsv5u0Onctv773Qoxnr9Sut3rRcblH6cCjpJIU0cFvt0HksAPqAR57iPg3aBg==
X-Gm-Gg: AR+sD13duh16D/cMoMHg2eyj7b0gvDlXZ7DUNbL5D4HQ9ExmsFzvQYQuk575XDQwf2G
	mqjAVbrBc94zrkQp2TxZFkhFxNCAdl4jc8o0Ri4iKxmUPZ6RqU93kxR7O3Hp48JXKVXtYMlyJJt
	kO2ji9f0kpXFecKM7rzkRnnCgk42eteLcUe0QxExwX4dDm7Lgx2wADN0EwVnJIuXQzzGRuDJwwr
	q1w9yRMq01Q9WjyJxocSJf5pWhq/o5Nj/LOk6se1mvCmaPgg0wdBYBbKfnWexJFpApnnYuwd39P
	bCBAB/AvJjS7yy3TUBJerkFfo/3VcyuZYoS+xP31nKGl4ww41mH7a9mTA25d8HJdBAePFgcf1A=
	=
X-Received: by 2002:a05:622a:28f:b0:51c:1291:911c with SMTP id d75a77b69052e-52d85361b13mr178295631cf.14.1786818121255;
        Sat, 15 Aug 2026 11:22:01 -0700 (PDT)
X-Received: by 2002:a05:622a:28f:b0:51c:1291:911c with SMTP id d75a77b69052e-52d85361b13mr178295191cf.14.1786818120830;
        Sat, 15 Aug 2026 11:22:00 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.241.57])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-90a921e74dbsm47337646d6.4.2026.08.15.11.21.58
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 15 Aug 2026 11:21:59 -0700 (PDT)
Message-ID: <f27338e8-5056-4bda-80ca-1a951afbd630@redhat.com>
Date: Sat, 15 Aug 2026 14:21:57 -0400
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
Option B does work... I can just added and make you the author...

steved.>
>    Thanks,
>    Jaipaul
> 
> 

