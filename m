Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.160.177
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794524367;
	b=JCMtFU48jtU8hMnfBvZQ+dIoyoLnJ7sRanXEs4PGSsTWWaEkygfUNZMVCm2OoBJ8IkLc
	 freDMkIwIxkLM53d52yR1xtCUd3/oJ3vUlsGvP+qzrVxSFnEb9svPmYsC8QYVjQMQSG1M
	 XIT7CpqFdrtcVAgyMFhoQDqjwb0RZWu3YvHw8GuJu6o8iiOuG7q7ber47m+FBEuTLucG2
	 b17qMQuaJVWIrIoMZZfYKcKj5vs1u8eRCgDCTAAkr32Fu6g+AvGMEXpf95C9L5y4cEMLs
	 iK7taOQZh5kWBk7ZMJ463MZK7RMw4HNkskx8LTqgJkXIS5n0dpbunBos2Pvu4KuVGjg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794524367;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=ZsSjLqJE2zg5KnRT+r/w8Y0ianrVtar664vxU/qkfmw=;
	b=f2hywTDhMhH/gc/TvnezHJ5uvcAPxN1lNXdnjrnbfMJeDk3ahwx4xH9kj+Q+1wUl3iIA
	 ebD+QmUruYKDrHEejI/1xmS4EMZd+Ni+aIRU++0yodiIpOf2EvpvvrLGQ7XzhgxntiKZf
	 qmzWA8SWNqUksBWvp5MqZeWR87DeYxLY6bVljEgnSdWMEAw92FrMZGsd6G/ZqqpdLM1yI
	 HiCAnTiVai5n+wLwMumFHbygQg0MFFA9jWDjJWIYbMq1aOyaqoDSC9h6rryfrCMHvyzgA
	 Vd8Ku84797wQ6Gcj3Wk8Jy3M08ImtcuenqsfcW6SzZ+oXlAZyj3Enqi+gqFMvSFmgJw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=NRwZn7LS;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.160.177
Received: from mail-qt1-f177.google.com (mail-qt1-f177.google.com [209.85.160.177])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB96760A5BDF
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 22:59:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AB96760A5BDF
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=NRwZn7LS
Received: by mail-qt1-f177.google.com with SMTP id d75a77b69052e-5383c97c8cfso7211cf.1
        for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 14:59:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794524366; cv=none;
        d=google.com; s=arc-20260327;
        b=iTBtRbIMAbZNUeX6XFWHgqS93iy7E3g8H0ue7hKneniLsS/Ca8FKZDqPAz3XkHCqrt
         Q37srxt0jYt1w4FgH2PukriwRdSDjL28u1IU6gVlmksnASR1uQ45gJDRYyD6/WTC/dL/
         YWfSHXN4rXXHs6wiKAD8nnDDBNfIG0tXDS/DDDwBhR+mUQMS7tnyhSxne524zAr+rOHe
         BQjEiO93uDRmNtIw6G2zJbNmT6TaMBB/rV+D818EasTDMr7HCNk4x9l2xmVteO3Xtftx
         pV3Y2cYdbco3TWrrAscpTaB8oBU/GKdYRgvRz6D5nQa8cAQ0jV4HgMYZksc/BOz1Wpcq
         FB9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ZsSjLqJE2zg5KnRT+r/w8Y0ianrVtar664vxU/qkfmw=;
        fh=nbxJdJSlp7wS+rHyOtRZIGGmbrAMKvxPamxh5UaovMU=;
        b=SoPliMvGM9sotM+WfDrmw31QBcGnliKd9/xbNz3g+JBGYXtE72fAovVUX1DJgdPTtM
         laeltd8fKgIXteAkws+fomC28GYHndNIfnVSByFn8v1Vsj20K/TvlcYbOHIKdjXKznKP
         y5jmdO9A/QAV7acwdiPIJ6mzEiHLsNbyzeI4B7/nSRvRS0J6bvv/Xfv4XbWpd/CLoSNO
         CsWBI384z9mF9263YzPoAG3kR5bkvukUfAZR1EesE0F/0FAMiDUcAdDuYOsq6gUmepTr
         0YG5c86D6Q8IOWYQ+LbLfe7DvhJ04L3ItBhCr4kozjMBi1unCeYJWlN1Bi6B2UTsYg/l
         /sYQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1794524366; x=1795129166; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ZsSjLqJE2zg5KnRT+r/w8Y0ianrVtar664vxU/qkfmw=;
        b=NRwZn7LSFGPxX3NtvX3Y7sFS2xItJxs0r16isV8pawPhbKhy9B1louAe6i72I/3N2P
         UniuOLDEYa6TVxl3FcjF+9fSBbbE6bEf8pNLK7WB6YbLd65ecGFIrlmSNUlXyyjpJ8vf
         ohFZkafmiEpB/6QdOpX3lVI6mIhmWqe6T/e+zzki4c0Prg7mBZOQ6GWxsjlHiixSscXX
         A2EnFSV9dgOF5i1DaoquT+PzW0SfWsEl1uNHbNVAhiQrzGs9Og4DdpgCz+Yv7QqLqs4H
         +ukKqWpoNHIUUbHnQO7MzVkr7o1J4ZHyugW+l4ektn2xy8z/xNEMyuKzLtfe2JdeXdLm
         aMkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794524366; x=1795129166;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ZsSjLqJE2zg5KnRT+r/w8Y0ianrVtar664vxU/qkfmw=;
        b=Yx/D6sKK6+GSq4Q0P4eOriMsG59T72TEhJiQqmRYDU6p1n2qbdy9gZTZAUDvTjQfqn
         i1IiTqsSBiz0wOshdsRTiIYyeVxo7nRquLrfHAN/nxuSwtcdV54v8SqLHCRIBIGA6O8C
         vGCCiY9xCy8elbMqDRyook4Ah0/LLrwaw46jS7zSK6wFIU0NztZzPRZyLVRNNTtOzkhw
         UvD6oAyvxop/STNBPBdb0uFA3GUuLhKwzF/A6NSK7OiVnalNz+N7Vi7lV8YRbVqN6gSA
         L0RdJFGKkLYhTd44fakS/Wfl76ooiNIm+ZSrjHtvgXOA0AiA/V3xhJLnqxMvFdbzP6mS
         9tlQ==
X-Forwarded-Encrypted: i=1; AL+hErHmHMd7UPvAOiShMJntohH58It/nswhBT6VNZ+EowKuoxC1Neyx+2afUU1+fUYscWlMXLzGk21UfQo=@vger.kernel.org
X-Gm-Message-State: APuU4Z9bjpJeLsZl7oHO+G+hwQHVi1YERZlUKSSHdLZTu0TkUHvSjBbZ
	VkdbmVf+ZMVNwUJ5HTJdSZ+Qzh5X7UjLFEQsKDGb0c+/t7dyLseP9du9y/7JhmA8dW+ODIV+jlu
	Z6ya+IAex9OkMUztN3iYjmkOiac1puZ+vYRGl2Vxp
X-Gm-Gg: AYBFou2ERAFNMo4J6lwBeuJ4sMS1y/JZYpDxZNV0yLu/vN68H4mYnbkXJuK4ctLdJrL
	58ygQRpd/3fFtAmHoVqUY9wA2JBxM/tuVLTlCcbfkfYs6ByZJyGJfq0jl4aShRlVFRihZwEhk0N
	4OQehQVdspzoVIrpXREtgcMeU4lKd68opLFRwz6QStHTaEoYOOBqlVfwrIKrnqi0sF5a5+d6LSt
	m7LhrrqGanA/Axbmaox9J5njZn5lREUwu3a3MNTiJC7uoTEKeu0vZnszfOFeDlnM+inGeY8Ds11
	RA+tmYBQKw+6RYVTFWVI6R48duG+xpz49++nkVaMOcps974fCWPih/11Xf9V+jkun+vuUMbtZmv
	11kG9ZnOhYqj0OsWVE6TutyjPuvy4/vyWDYopMQO2SLxJKUpJmXcsMBTAbzVvjT2cUJU=
X-Received: by 2002:a05:622a:98c:b0:532:eff9:ca08 with SMTP id
 d75a77b69052e-55afcbede04mr2871271cf.12.1794524364998; Thu, 12 Nov 2026
 14:59:24 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261103223025.2482227-1-nhuhuan@google.com> <20261106085019.90487-1-lizhe.67@bytedance.com>
In-Reply-To: <20261106085019.90487-1-lizhe.67@bytedance.com>
From: Huan Nguyen <nhuhuan@google.com>
Date: Thu, 12 Nov 2026 14:58:48 -0800
X-Gm-Features: AclHuK_MjdqInx2d6Ru3Fw1h0wqnaU6otNi9RKFyMPSDK4f5OfZNd4Zh3wXDlV8
Message-ID: <CALwWd5tttbaNWoaXnPZjHFgYhG8yMyT67_9nhRKN336EHOVhqg@mail.gmail.com>
Subject: Re: [RFC PATCH v3 0/3] mm: use non-temporal stores for demotion
To: Li Zhe <lizhe.67@bytedance.com>
Cc: Liam.Howlett@oracle.com, akpm@linux-foundation.org, 
	alirad.malek@zptcorp.com, anna@kernel.org, apopple@nvidia.com, 
	bharata@amd.com, bp@alien8.de, byungchul@sk.com, dave.hansen@linux.intel.com, 
	dave@stgolabs.net, david@kernel.org, dimitrios.palyvos@zptcorp.com, 
	fvdl@google.com, gourry@gourry.net, hannes@cmpxchg.org, hpa@zytor.com, 
	jackmanb@google.com, jic23@kernel.org, joshua.hahnjy@gmail.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, 
	linux-trace-kernel@vger.kernel.org, ljs@kernel.org, 
	mathieu.desnoyers@efficios.com, matthew.brost@intel.com, mhiramat@kernel.org, 
	mhocko@suse.com, mingo@redhat.com, nifan.cxl@gmail.com, rakie.kim@sk.com, 
	rientjes@google.com, rkodsara@amd.com, rostedt@goodmis.org, rppt@kernel.org, 
	ryan.roberts@arm.com, shivankg@amd.com, sj@kernel.org, surenb@google.com, 
	tglx@kernel.org, trondmy@kernel.org, vbabka@kernel.org, weixugc@google.com, 
	x86@kernel.org, xuezhengchu@huawei.com, yiannis.nikolakop@gmail.com, 
	yiannis@zptcorp.com, ying.huang@linux.alibaba.com, ziy@nvidia.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 6, 2026 at 12:51=E2=80=AFAM Li Zhe <lizhe.67@bytedance.com> wro=
te:
>
> On Tue, 3 Nov 2026 14:30:22 -0800, Huan Nguyen wrote:
>
> > Using non-temporal stores and prefetching on x86 bypasses CPU cache
> > allocation, protecting active workload working sets and improving
> > demotion throughput.
>
> Could you show some real workload numbers for this? I am wondering
> whether the reduced cache allocation and improved demotion throughput
> also translate into visible application-level benefits.

I do not have direct benchmark numbers for non-temporal demotion with
this implementation yet. As far as I know, Alirad and Yiannis (cc'd)
are currently evaluating its real-workload impact and may share
results once available.

>
> > - Memory ordering:
> >   Add a wmb() barrier at the end of folio_mc_copy_nt() to ensure weakly
> >   ordered non-temporal stores are drained before page tables are update=
d.
>
> I have not looked into all the details here, so I may be missing
> something. But before migration completes, there should eventually be a
> publication step that makes the new folio visible. In theory, that
> publication step should already provide the required ordering before
> userspace can observe the new folio. So I wonder whether the wmb() in
> folio_mc_copy_nt() is really needed here.

On weakly-ordered architectures like arm64, the publication step
indeed provides the required ordering, because smp_wmb() and
smp_store_release() emit real hardware barriers before the new folio
becomes visible.

On x86_64, however, those primitives compile down to a compiler
barrier() with no CPU instructions, since x86 assumes TSO. Because
movnti bypasses TSO, the standard publication barriers do not order
non-temporal writes on x86_64, which is why folio_mc_copy_nt() needs
an explicit wmb() at the end.

Right now __HAVE_ARCH_COPY_PAGE_NT is only defined on x86_64, so that
the wmb() is effectively x86-only today. If another architecture
implements __HAVE_ARCH_COPY_PAGE_NT in the future, we can move the
wmb() into an x86-specific scope in v4 so weakly-ordered architectures
do not pay for an unnecessary barrier.

>
> Thanks,
> Zhe
