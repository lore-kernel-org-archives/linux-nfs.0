Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.160.173
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794524823;
	b=jgPmcHYBxDx0Ro6va+/ZkKs4u1Q0uHhf28n9bGI7fyK3i1M2yazBGYa7psqua40aBVMJ
	 0zvaLswNFRE51J/rgdB4VZ8HfkND9qWcTdSO4qIUbjtIdEqEGXPpUPwPTzuFOgCKKt+7l
	 K0VDgJACUY60qXm10DRJbeMZhL14RT8jcq78ji+Nq2DQmmmuX9klA6cXM0vSFQpnEvfNB
	 jskrNH776FQlBwf8PbKkkVEFV8WYInKq5enkXvHSoYOBRMhIj/E2BSZCXcS3HNx+IGCLo
	 HaIJxOskb08ydrzt8lpG/tVqAKlN5V/3HnWD9jjd5F++9tBbGErpoZOxTgnKtyhU4Sw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794524823;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=iq7zuX4mescGycMYtdVsnHt3n8ea5BUsLeUaRpIODWM=;
	b=jbBVTqtbkuF84fdMHhRYks6OJZC5tg1Ni4EGe3jzmdj1ydyYb9VCacrSIcnYgUqRlfMw
	 3TyPaovOsmIezlNpCt4UdW60FBTDzybXxNdt2vVmu6oH35Mf1ebN4/UNNRThEbVUvyVNo
	 2XwNbiGfWIxn8z5d7rRTx6UNHdKr6QYvJcfAFdOrtamkKYkvZffzQo+3MZ2h7zqOip16A
	 HgyMyvhnuA9FjfuB2RMFOKwzFsKrvRXBMyoHIA41r1YdKipiECna8d795xpJsxvvSXaGn
	 auPuMabliaCdQsg1dlfhaWmuRZxhUXoHcbt587ec4zAKGbkuK4Sil4kyi/o6ubDyaRA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=irICtOrg;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.160.173
Received: from mail-qt1-f173.google.com (mail-qt1-f173.google.com [209.85.160.173])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 027F9606A323
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 23:07:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 027F9606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=irICtOrg
Received: by mail-qt1-f173.google.com with SMTP id d75a77b69052e-5383c97c8cfso10701cf.1
        for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 15:07:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794524822; cv=none;
        d=google.com; s=arc-20260327;
        b=CJmI53CVdiI8tPRAF46nnLf1wiftIy3UFh24S0TxT9rdDECSuPm7sQlCnm1XSO2oPS
         yAEg9ZxX/CgwQtjAfV+qEjj0zuWsAvaUFnU9PX+L1waiwFgYh23Y+Mu0m86SwvL2B36d
         l7CKiaEnPAi7u1ou1QHaAaP9LdAxfluQqamEnYM+3SjgLj5sC6v/jUjkhbCKe0thfKxP
         jgo52vVOcg3+D3baqc1lBcZiQFr73OF17zPH9KIpskkb2xRvucz216vEAHysInGBmAXC
         7QF9jwjdV6kBZbaewW2oLjiBHUTh/fix3svSU/m146JSZ+Cnn1jWu/xYv8L6BPDPvENb
         MY7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=iq7zuX4mescGycMYtdVsnHt3n8ea5BUsLeUaRpIODWM=;
        fh=LyvUbY8pJtvCRGwIF2UPfbaws36TSTbHohtZyPdaNNc=;
        b=ArraE1vbIF+9vW9vJommlkA13DTxZ+vy9X5XabLAIUAvqbPxxlaefvLyjl9ulvQwiK
         DS3RShBXXNYmZYMx69JVw6wSzMWL0+fMN4R9DaF6db6IoWEz8aodT5uqQM2Myy0BUsin
         8RzLmqSglERnPMU/L4UzMIi/zaeD8oloQnepFzJcQdRm9ACfgGMfxxtjZekj1CC8yCaQ
         tOng+TLnrx3PUD2T0bDJs0jEp+553GgLqTpjX37axwNJyEmbFqtFS0FZYCVY3izwIClO
         mrlf5xuNcCG2XBZ7qkKZ3TGcpcnbzWN3+HY/irifcE261z7iZ7u3qG9LFer0sNvljkd6
         GPYg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1794524822; x=1795129622; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=iq7zuX4mescGycMYtdVsnHt3n8ea5BUsLeUaRpIODWM=;
        b=irICtOrgRGFSY53WuIyzu8TvH4VAFbp2Bm9vZ4Z1Z94hZozwaMXLPxyJx/tlti2mVi
         ctcdxtiTUfyI8LFpkjubrWADm37oXauz/yIIo60ytVeIRG1VBoLNFIiuy0k+6Ju3jFQd
         7REtp4u2l3gQJoyCxJncqUbeCGAoNHXHbZ6REFJqvzb2PcXCrmukCEXpQXNOYn1sLXrs
         ICu8svIF5y41B/8N5MbGb9qnQrAt5rMNJoRqqozkRerVUe62lhc7jCnCfoDqB6sF60RT
         LV5VmLgNaudkTgH3dH1fHWPWHdcavn/h+HTTkV/FsVRJr8IIipcHA5Up6ArQIs0x8H9P
         b6ow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794524822; x=1795129622;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=iq7zuX4mescGycMYtdVsnHt3n8ea5BUsLeUaRpIODWM=;
        b=L0Mkqfx/9UIETBkTKqn9qQDc3ykfND3WzAOVXBeg7ee8RsEjtaK7XbTK9EOO1Mxm6Y
         kYIDK5N9DJOsOc3/ia2hK/ek+E2xy2MYxkqMwQmvTbU7ahOjtCeHt08ZS8GDH6LZSSG1
         blQ9rog8qDl7ffKvCFa3Zl9ndVuLZ4VrA0F8wohhk879hJs5ccYpojZTEb7ql1e3Q1Oj
         TX6GKBjomucktNfjPDQRdpD46eABG849LZrPX9yWaUEMgiG+pJv/WwIkioR3rLsG+GwA
         Yr3qvDXCdqnUTmpbyCLlCq3eYcrqA3Zaa2Yujy4i+i5etgj3KLRybfO4rHkje2GwCh2x
         B8oA==
X-Forwarded-Encrypted: i=1; AL+hErHAxROd5zSPh363WK7WEXltlv7mYxb5Ye+qVDaFrQsH7WQ6IQ3nlDQF2mPdehpgq+jPMyDeBupgy5c=@vger.kernel.org
X-Gm-Message-State: APuU4Z+yY/2/Bt5lC90eT39mOoX2WNqu/Rs5mvVC/J6LwnjJ5DGNkizi
	GWyKPX0Hw5gpPre0CzpTZ91oQUlYS67V2AsgeLTsok6/M26EuD/EpOl172N9hhYHrvDNwg95WdE
	5AaSVACsvYW0cxLi7O5+7ZWLn2PPesBk7sPxjH7tl
X-Gm-Gg: AYBFou076C82yr8fnV4H/mGe3rZug3q1kUoMh1JQbedj16I4+wMf8gtZFHw2L463RMK
	8L3wdwnwPkaqao4Ax8E5X3syzazcicu37IBBbrok40Y3R6JT+9UhDDZyQ0HAVNVTKyUh3i/EdE5
	0lKFu7j/6BbgmbYip6NCRxXhWj2giXSMQvqoRJ6DveOVut9nJTKEo7P3jM4B7+A5d3Eam+/j5GP
	H3H0yWp9LfjSuCEHLLwbZXHTkK1F1oop0VSqFlsaz3KOky9Zsz4NmOIrmN3CBybyCTDKDpDKAqJ
	QUJ5lByirJdmWq1D1HcnOZhc5ZBC6hdSiT9xFTHFMjivIpuy8FOU/iHAhgWwS/Qhi79Np9mCXC5
	qzNAvm0nRsNGlA0mV+L7sd3KE3JSBYseedaFFTLjeVbd8GQm/DFTAy6Zk6cK2m33c23l+9RPU5J
	/bpLExKm3XAOmH
X-Received: by 2002:a05:622a:4885:b0:536:3ee4:81cd with SMTP id
 d75a77b69052e-55adb2a6457mr5607171cf.4.1794524821197; Thu, 12 Nov 2026
 15:07:01 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
 <20261103223025.2482227-1-nhuhuan@google.com> <7CF5AD15-B833-44E1-A9FE-C8E12F8C9E82@nvidia.com>
In-Reply-To: <7CF5AD15-B833-44E1-A9FE-C8E12F8C9E82@nvidia.com>
From: Huan Nguyen <nhuhuan@google.com>
Date: Thu, 12 Nov 2026 15:06:23 -0800
X-Gm-Features: AclHuK8R0WzJXR4yHYxHSMICSWxLr-x7bnN-BX27nSJiTtbJXgPCv-FYzS8TYcg
Message-ID: <CALwWd5vAtSSuFoex37AzDBcK0RaBP3fbbst_fy9BGBQ5jr-K1g@mail.gmail.com>
Subject: Re: [RFC PATCH v3 0/3] mm: use non-temporal stores for demotion
To: Zi Yan <ziy@nvidia.com>
Cc: tglx@kernel.org, mingo@redhat.com, bp@alien8.de, 
	dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, 
	akpm@linux-foundation.org, david@kernel.org, ljs@kernel.org, 
	Liam.Howlett@oracle.com, vbabka@kernel.org, rppt@kernel.org, 
	surenb@google.com, mhocko@suse.com, trondmy@kernel.org, anna@kernel.org, 
	matthew.brost@intel.com, joshua.hahnjy@gmail.com, rakie.kim@sk.com, 
	byungchul@sk.com, gourry@gourry.net, ying.huang@linux.alibaba.com, 
	apopple@nvidia.com, rostedt@goodmis.org, mhiramat@kernel.org, 
	mathieu.desnoyers@efficios.com, jackmanb@google.com, hannes@cmpxchg.org, 
	shivankg@amd.com, rientjes@google.com, dave@stgolabs.net, nifan.cxl@gmail.com, 
	fvdl@google.com, jic23@kernel.org, rkodsara@amd.com, bharata@amd.com, 
	sj@kernel.org, weixugc@google.com, xuezhengchu@huawei.com, 
	yiannis@zptcorp.com, yiannis.nikolakop@gmail.com, 
	dimitrios.palyvos@zptcorp.com, alirad.malek@zptcorp.com, ryan.roberts@arm.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, 
	linux-trace-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 3, 2026 at 4:09=E2=80=AFPM Zi Yan <ziy@nvidia.com> wrote:
>
> On 3 Nov 2026, at 17:30, Huan Nguyen wrote:
>
> > This series continues the non-temporal demotion work originally posted
> > by Yiannis Nikolakopoulos [1].
> >
> > Motivation
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > Memory tier demotion moves cold folios from local DRAM to slower memory
> > tiers, such as CXL or remote NUMA nodes. Standard store instructions
> > force the CPU to allocate cache lines for cold data that is unlikely to
> > be referenced in the near term.
> >
> > Using non-temporal stores and prefetching on x86 bypasses CPU cache
> > allocation, protecting active workload working sets and improving
> > demotion throughput.
> >
> > Changes in v3
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > - Unified MCE-safe NT copy (addressing v2 Open #1):
> >   Implement copy_mc_page_nt() in x86 assembly to provide machine-check
> >   safe copying using non-temporal stores (movnti) and prefetchnta.
> >
> > - Architecture abstraction (addressing v2 Open #2):
> >   v2 relied on memcpy_flushcache(), which lacks non-temporal stores on
> >   architectures like arm64. RFC v3 replaces this with a dedicated
> >   __HAVE_ARCH_COPY_PAGE_NT interface and generic fallback, enabling
> >   architectures to plug in native non-temporal routines independently.
> >
> > - Memory ordering:
> >   Add a wmb() barrier at the end of folio_mc_copy_nt() to ensure weakly
> >   ordered non-temporal stores are drained before page tables are update=
d.
> >
> > Discussions
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > 1. Migration mode vs. migration control refactoring:
> >    Currently, this series introduces MIGRATE_ASYNC_NONTEMPORAL into
> >    enum migrate_mode. In parallel, Shivank Garg's migration refactoring
> >    series [2] consolidates migration arguments into migrate_control.
> >    Once that lands, demotion can simply rely on the migration reason
> >    instead of adding a dedicated migration mode and helper.
>
> If that is the ultimate goal, why not do it in this series to avoid
> code churn? You probably can coordinate with Shivank on how to move
> the migration control refactoring code to this series.

Thanks for the suggestion. I reached out to Shivank and we are
coordinating on this.

Best,
Huan
