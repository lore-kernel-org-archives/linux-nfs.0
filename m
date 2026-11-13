Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794596437;
	b=N0eO/ESfUfRJyw/+7e1F36BFJt+YajoRQ53ovBTQ3Ltcw/krGU46eHYxmLzLC43DKJ2p
	 Qr/XcAcOkiSIAxqdF61m9Ed8ThYoAwFeDllz5SjbCn6W8sBLMYahk71fDXd9lnTwaIdHm
	 KxD5UsGdz0OCLAvjs4AIH+f74PuzGYXKgi/QVNkQk7yeV2CCfLLy1AWSDKWXT+BvbsMTK
	 Vy+BniXdduwBk3uc5g5OALQ3/CGK3GByxrkbNu6bpJEe2J5FUEwGVskfd5AV58sG/b+UZ
	 iNCfegzshYAacSj5K/sgcxagjyFhP5Idp8xogzKv+Rut8c0dX2bI2qXsUUH5GU939Gw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794596437;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:Message-ID:Date:MIME-Version:User-Agent:Subject:
	 To:Cc:References:Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=csx6P6c/RTJUi7VJsC/KXqV+r9tUOqmwPkvpTs3uj3c=;
	b=wo0ChOqqQJvppCQXqWbEdbCv2LxkbQMJ3ggzeKgfiLJzDuJxGJ5q9+JWxSHieccHzDxF
	 +SZmI0UMM0muxzpRFbFMGL1W4KwGHOzpgzuE6ErqoVHAO5McMVH/zfHOdlcWLPgFk4Ce6
	 S/TpD+VFm6zmYjCNYzj0+HPvuaWKet7Hz9V2y1tPfa4Bop+tQygB4/YrUKkxBodJgq5ab
	 Qz4m2FB5tYMbh++5M5E0cmuquKQPhKOcsqbWLh4y+XAejOcg1Iuv79mmFOJq9Z8TtfwYc
	 hTddVgqsxcwmXUAW2n5iFrJzWsTqzfT3gu1IlCyU5AE8RFfPR6uVRo7uEKFjYRltNfQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=coI6QXlj;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=WrUro1Ep;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35D1C606A334
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 19:00:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 35D1C606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=coI6QXlj;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=WrUro1Ep
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794596423;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=csx6P6c/RTJUi7VJsC/KXqV+r9tUOqmwPkvpTs3uj3c=;
	b=coI6QXljfpwEQY44nA1W9ZNLfJdMmdiddNfmcfqSeq+8dLwPJgkYxXQiiW65mWIWy9/i9M
	pQhHpWuokW4uFBTS2sqkF/84+85WK3kj1wt/O0eWFgAKdE/r7XIx3HAX4WNhUQyRDNszKA
	1JhS7UcBE/ty4ZAjy9D8zGOmenCqzgE=
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com
 [209.85.222.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-665-I2FHHwmJOF6X8wxE-VTHJg-1; Fri, 13 Nov 2026 14:00:21 -0500
X-MC-Unique: I2FHHwmJOF6X8wxE-VTHJg-1
X-Mimecast-MFC-AGG-ID: I2FHHwmJOF6X8wxE-VTHJg_1794596420
Received: by mail-ua1-f71.google.com with SMTP id a1e0cc1a2514c-99082f450bfso602382241.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 11:00:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794596420; x=1795201220; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=csx6P6c/RTJUi7VJsC/KXqV+r9tUOqmwPkvpTs3uj3c=;
        b=WrUro1EpiTnNG/TFgDySu1y51fzcW/M6qlpgBY92Qf9+cFPzjMJYGwz2pzKfAkecw3
         DUHHTmysam0t0cnmLDHE8LI4JyfTG+kKjAd2z3jN/Ta53tWekGzbFVmFIBPX4aQLmwwR
         bbCh6ektBjvsVzK0vG9mRKi8GXbF93dViFDAM3NCIe299ltidYhMbFKr94cIKo0t7FDM
         BC5z0+MBnvrz1wqA/F25A2Tgb451+/cFJfsx+jMKbG8SBpTnIUqPv1589O2FEFN1AoE4
         Gob2qY6Wg8iEwXU3Dzqf8zAwZJis5m9nrjiSUAkFME13DNmff4DgC4VvLV4EekUh7gzl
         5HSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794596420; x=1795201220;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=csx6P6c/RTJUi7VJsC/KXqV+r9tUOqmwPkvpTs3uj3c=;
        b=uZ2+0NLXrE/Z+4OKWFL8FatMibhpohmEEEwvCVwTp9yUBVJQ6DjPlg1dP/F4bVlCMP
         7UPunaU2vc3cMxHEQeoXhryHngdddCGgWDoeBUja9eDBrPMIEHp4Lrzont7/MKrAuldw
         /i4xHt7+SI5/42isdnNKsAmB4LfbZl8cLzRoZqxbH66R0eltpT1jIUliKjq37PRB5xky
         rXJviHgvVgvYaSonMRM/j3LlXh+5FPyIVYorU/qcrbyQDXW1V2zgvtVdKqdipsDsmlVm
         N1/NeBjlkTi8UlEuH1jvxu0+BgDqXWU439oALfNbvsJYJMtgamXs4EWiJvelOLjM6CBz
         pqkQ==
X-Forwarded-Encrypted: i=1; AL+hErEKhgIPMV1bJjK9sCNWQr46vn1UyYh+o/lMcf5ctSHNP1uIajeJvNYAftQUmveLvqveQs1Pw7N10i0=@vger.kernel.org
X-Gm-Message-State: APuU4Z83+9iviN7pMoE9FsBg0vg1OTRbO1fJ0Xjm+S2/9X9JoqAJkQ/8
	Pqpe7d6ax3Ww+nFx6qXdXjnh/kcnej7NuRpIoFlWejgG49M2zHiRJdc+eQrhqyi+PCfoDcwc22y
	9ATZi2DTFnLXW59Cdr10uswpfcE6gjqCkfommLxfWqeraUWTWI0I/IWrcQ5LZzQ==
X-Gm-Gg: AYBFou0ACezKa96vqIHf9c1ItVuEMcwFme10IEIle7qek73lQctK+A2HpZJ+ubg8lrx
	W0iIFAc59pyPbWwYS8ujgZxpDXunEeQdGHLwbizayv20kUy/Mx9CyLTY/UK5y81AiKyM8YLMcdF
	uco0ZaQR5USCm0z1zRyQRqqUoNRy3pOcYe1GUsP5f/0yiVgpjiV5YynRGgTxCKAnpL+bdtn+z5/
	3oEDsDSDUwK1BfGjrGLKX0vmrrlBhM6Iexc3Ql167Ku3t3GvpF02pLPBC5ZXsYghKmspyGxe23l
	uEAEUDrMkIIj5/rSXtyLtb/BIZ3qibOl3AUsum/8lgmnJgKcfgXuRD1hmy8LVxIqSKYhjikHASn
	Zl5nDY2bWDEu4yMa1swJ1tsd7ZJqK6kU+0Xksznnk1bAoV8mS
X-Received: by 2002:a67:e111:0:b0:7cb:fd69:4155 with SMTP id ada2fe7eead31-7d64d476cf9mr1357104137.5.1794596420074;
        Fri, 13 Nov 2026 11:00:20 -0800 (PST)
X-Received: by 2002:a67:e111:0:b0:7cb:fd69:4155 with SMTP id ada2fe7eead31-7d64d476cf9mr1357094137.5.1794596419690;
        Fri, 13 Nov 2026 11:00:19 -0800 (PST)
Received: from [172.31.1.12] ([70.105.240.105])
        by smtp.gmail.com with ESMTPSA id a1e0cc1a2514c-99c779474ecsm2026526241.2.2026.11.13.11.00.15
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 13 Nov 2026 11:00:15 -0800 (PST)
Message-ID: <99bd33b5-da59-4390-941b-3a6018caa77f@redhat.com>
Date: Fri, 13 Nov 2026 14:00:14 -0500
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
Subject: Re: [PATCH nfs-utils v2 0/7] mountd/exportfs/nfsref: netlink loose
 ends and bug fixes
To: Jeff Layton <jlayton@kernel.org>
Cc: Ben Coddington <bcodding@hammerspace.com>, linux-nfs@vger.kernel.org
References: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 10/19/26 7:46 AM, Jeff Layton wrote:
> There are some cases where mountd will use /proc even when netlink is
> available, and agentic review of this code also found some bugs.
> 
> This set fixes it to use netlink in more situations when it's available,
> and also throws in some bugfixes and cleanups. The last patch in the
> series adds a MAINTAINERS file and the machinery that allows b4
> workflows to work properly with nfs-utils.
> 
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
> Changes in v2:
> - Add Fixes: tag to patch that forces a path-based uuid
> - Drop the currently unused max_attr field from nfsd_export_policy
> - Fix default value of $output_roles in get_maintainer.pl
> - Use script location to determine top of git tree
> - Link to v1: https://lore.kernel.org/r/20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org
> 
> ---
> Jeff Layton (7):
>        mountd: accept -L for --no-netlink
>        mountd: prime the kernel caches over netlink on MOUNT
>        exports: describe the kernel's export features with struct nfsd_export_policy
>        exportfs/mountd/exportd: get export features from the netlink policy
>        nfsref: flush the export caches with cache_flush()
>        mountd/exportd: always give pseudo-root directories a path-based uuid
>        Add MAINTAINERS file and get_maintainer.pl
> 
>   MAINTAINERS                     |  58 +++++++
>   Makefile.am                     |   2 +
>   configure.ac                    |  24 +++
>   scripts/get_maintainer.pl       | 370 ++++++++++++++++++++++++++++++++++++++++
>   support/export/Makefile.am      |   4 +-
>   support/export/cache.c          | 124 ++++++++++++--
>   support/export/export_policy.c  | 258 ++++++++++++++++++++++++++++
>   support/export/v4root.c         |  22 +--
>   support/include/exportfs.h      |  13 +-
>   support/include/nfs/export.h    |   5 +
>   support/junction/export-cache.c |  82 +--------
>   support/nfs/exports.c           |  47 +++--
>   tests/Makefile.am               |   2 +-
>   tests/t0003-get-maintainer.sh   | 140 +++++++++++++++
>   utils/exportfs/exportfs.c       |   2 +
>   utils/mountd/mountd.c           |   2 +-
>   utils/nfsref/Makefile.am        |   4 +-
>   utils/nfsref/nfsref.c           |   5 +
>   18 files changed, 1034 insertions(+), 130 deletions(-)
> ---
> base-commit: 5090e0bb662c53b4552b28b121ac2c2c434adb2e
> change-id: 20261016-netlink-noproc-8e3bb540d266
> 
> Best regards,
Committed... (tag: nfs-utils-3-1-2.rc2)

steved

