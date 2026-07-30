Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2EF793E0091
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 17:40:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.41
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785433247; cv=pass; b=IxEZstzr2eiq1+UzTquwfMH039qC2rMmpi/yu+rZ51gim8WDcMDrGYaaNnMFj+FwmIKUTnSZ9VuOcaZfwM6XZAEneBZN/b0VjUy6Op54vwQo5+ppkx7OMhbOqs1G7trn9BcpnqLYvczLHx+6HiMpVaGxVoxRbQ8/GeyFmUjDlJg=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785433247; c=relaxed/simple;
	bh=SaO2GwcUuVir5GmS15OHZBlOQWPsR84MdCDSNA5BGRk=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=UuxEWrWGcQAkbxbaEztnmpY1fl9zG3m4TNegYVuzDSOlefAusxzKX1jrMUBI0Bw6SotGlsbKWFbbafFRmw8yFt7JL9jx+2x7Sn2FPuG+UMqnCuATedWgixg1MoxJLF8F+Pr6pWcRNNFyuMbIZJl9Iq1mTbrqm3jy4kd5HxtKMKg=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=tMIMANqU; arc=pass smtp.client-ip=209.85.128.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tMIMANqU"
Received: by mail-wm1-f41.google.com with SMTP id 5b1f17b1804b1-498012a61f6so5965e9.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 10:40:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1785433244; cv=none;
        d=google.com; s=arc-20260327;
        b=ZjgDb6tHk3bbDO0hl0vTRcF7mwag/CmFd+95jd66AToOwsJth02TP9N+Yy6MPSzjqd
         JwclnDCOd8q8oqlnIMCJuBN26wIRFpPanrYHdUou+Ka7RPyZwMcFRDXEi2MKXFkPiDrU
         TW7KWr3ub0MaeMuA4v9gzTGmEL7t/M+M3MYsh7n7UnEhHNtjSpQZjc3GbCrxcRFXgDs+
         Q73OEgnV/4P8LlBySNRsph2I6S0Y+7qiRRPQCpLV+IiRAP+nMFw4X6x3Dii2bhU2ngak
         r/GYKDbo/B+7XD4lGiMIQIYmeFP0WUF0zO3kRsj/hnoDE7RQGyGsZsUhZjrBQIT20HnI
         sRBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=XLMCRr3YVakAFIrgmUPrhARsAro1zufop+cwIiHnKcQ=;
        fh=I7yYmGbYyclz6nUNLtn7sYLpQGCOE+BH5aCoyaiQ0hQ=;
        b=JKQUxJyMqkynwNBCKBgjpkZuEAc5j2wBHV45jxVYUSqyi3lEPr6vsmfwDtcl6tt0Lq
         Hyk4axLxYVuAyly2Bs2IDfk+njpHZZoi0rHS8GnDKdufmPivu4L/PG7o1laZCT3QLFRb
         +QxiLpwgZO0a5Ay/Wz74I054G4UWDL285CAXupsuwxCuU5oPzxl9F+JAlOX2oHgd7IVL
         lV+m7V/6wCWWADVvFZmR4/Zf4mLYEH2X+ogKajyN6ay+XEfIKDNDkV9APd/gE0yogzoG
         Zj9QS3cOd72LI5oBaee3uTaEdyrayPtoIbnF9eh5zl1OvcJDBQNWN+Xq3i/tXpB87vyI
         DbAw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1785433244; x=1786038044; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=XLMCRr3YVakAFIrgmUPrhARsAro1zufop+cwIiHnKcQ=;
        b=tMIMANqUPrzbweELQxKavrKIDKF8wJDFV7pHGR72UWBRXJvF3CLrK7rAluBBTOtZwp
         P0ckv+HRUkSk++aETKZRNsNxD1a1MftdwqcS3wvJ4uVdKmq11DhGN5NRroSSGewtrIQ+
         Rzk/GAIMKwLhB4RgUT4csDvtkgialuntscfblf2RGL593RgsprZFVaNpKDI3lg+aJ+l6
         V1z/o5mywGY3z3+ayEgSFjjHH0K6LGRBV5yTwORVXmL5meXfp460oCXKg3tAFAjWr41L
         NKkq+zBWrAWsfCKUvo8VkEv0g46DI7ffc4sJ/ekvIgpV8XhCtJSI/pKpVpHm3RD++tc/
         DfQw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785433244; x=1786038044;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=XLMCRr3YVakAFIrgmUPrhARsAro1zufop+cwIiHnKcQ=;
        b=Ex2rlUYZSRx7r8rse4bZhyN5T/KJhJANzny2WzSqn3Hthi+JewgDU6YPd6Sl1KIOhU
         tMWjicTzAQDPwj0Mp80BazSidi7JgKXl+V6Zt7wnon7Bx4FAiw1/D8QcxCzxtU4fr3IS
         s2ufmBb65LY46pFJM14TxqmNJLLyqhzoYFy2UAeDdhgsTOAWitbTk5SBYbvx40SxdtGJ
         I+8BuG0xhbbEgzo1OzKEvW9Y0i7OdJQnCvhmt29WsWH8vjLvc7uLjUjZnhSZpexD56VP
         aZUqXn5XBE43LDLUT+0RBI0RZZln9Vj4V5z2mUfUYLhueRrkPts3Sdh0qVXpZkOWBm7N
         3geQ==
X-Forwarded-Encrypted: i=1; AHgh+Rp2f/R3D1Y7fNpewHiD4KKONqdnLvqVWBYl6m2GHS6REuphjVX9CbqmssOu5vRhRLcTvWDNF9MtzgE=@vger.kernel.org
X-Gm-Message-State: AOJu0YwB9eEis3hpOHHrguhonYq9P8e0sF9YhzTxzfDC+gBus9O0VXDx
	fZnTQyXlNu3LKbl2R5K9npE5ebWYcSGOUnAed8tIWvEIzvPYgEDSGtucvLmuHBPjcsxo0ErkY9S
	zFj/NzVHtA2gSOw/bs0V3H+6f2CY1MbQWLenWNkY9
X-Gm-Gg: AR+sD12ermjN3qZBhidygQAtF8OZaO22SIqRBxDY70QFFKNMS2k1zdbOPE2AG0v3amy
	D1ksHJvIBaJsqyLg2xP2KfyvMhN2059gnDNuFFp9oU0ssLqGX7uc3tLw3FmKtVV6aXu8O5bLUj5
	z2/79e0mUwywwzmWMc9QAPMesHFEcAi19RA9tcT27zl0qJqVgrJLmcOrIwEMrYzsUWBjUMAX/1y
	KmvF0T0+xztBjIMSGMGlpqu0VZsl/KiJwZ2McAx1LqSv17Y515SzO68hPtYhCMQaHk6b4LtP5TR
	WYa7GNIJkiriUogZmpoBfS60UxsRAZmuIL99v7MyWrF3
X-Received: by 2002:a05:600d:848c:20b0:490:ab15:b9e8 with SMTP id
 5b1f17b1804b1-4980587baa9mr47795e9.2.1785433244036; Thu, 30 Jul 2026 10:40:44
 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com> <amuJbBrTW9W6_sx8@gourry-fedora-PF4VCD3F>
In-Reply-To: <amuJbBrTW9W6_sx8@gourry-fedora-PF4VCD3F>
From: Frank van der Linden <fvdl@google.com>
Date: Thu, 30 Jul 2026 10:40:32 -0700
X-Gm-Features: AUfX_mzF-rbdWdA029msHQErAvjm1m5KqVtwi7O3MQR1mBpjRQR1Wfxbg8w05fM
Message-ID: <CAPTztWatWbsF4KQwD-_nib-vrZ6uvrhMYcOc1mkWu-7DzN95AQ@mail.gmail.com>
Subject: Re: [PATCH RFC v2 0/3] Demote to lower tier using non-temporal stores
To: Gregory Price <gourry@gourry.net>
Cc: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>, Thomas Gleixner <tglx@kernel.org>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, 
	"H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, 
	David Hildenbrand <david@kernel.org>, Lorenzo Stoakes <lorenzo.stoakes@oracle.com>, 
	"Liam R. Howlett" <Liam.Howlett@oracle.com>, Vlastimil Babka <vbabka@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@suse.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, Zi Yan <ziy@nvidia.com>, 
	Matthew Brost <matthew.brost@intel.com>, Joshua Hahn <joshua.hahnjy@gmail.com>, 
	Rakie Kim <rakie.kim@sk.com>, Byungchul Park <byungchul@sk.com>, 
	Ying Huang <ying.huang@linux.alibaba.com>, Alistair Popple <apopple@nvidia.com>, 
	Steven Rostedt <rostedt@goodmis.org>, Masami Hiramatsu <mhiramat@kernel.org>, 
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Brendan Jackman <jackmanb@google.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Davidlohr Bueso <dave@stgolabs.net>, Fan Ni <nifan.cxl@gmail.com>, 
	Jonathan Cameron <jic23@kernel.org>, Raghavendra K T <rkodsara@amd.com>, 
	"Rao, Bharata Bhasker" <bharata@amd.com>, SeongJae Park <sj@kernel.org>, Wei Xu <weixugc@google.com>, 
	Xuezheng Chu <xuezhengchu@huawei.com>, Yiannis Nikolakopoulos <yiannis@zptcorp.com>, dimitrios@palyvos.net, 
	Ryan Roberts <ryan.roberts@arm.com>, Huan Nguyen <nhuhuan@google.com>, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, linux-nfs@vger.kernel.org, 
	linux-trace-kernel@vger.kernel.org, Alirad Malek <alirad.malek@zptcorp.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 30, 2026 at 10:30=E2=80=AFAM Gregory Price <gourry@gourry.net> =
wrote:
>
> On Thu, Jul 30, 2026 at 05:02:56PM +0200, Yiannis Nikolakopoulos wrote:
> > In most memory tiering scenarios, the memory to be demoted is expected
> > to be cold and most likely out of the node's last-level cache (as well
> > as target pages in the target node). Using non-temporal stores instead
> > of a standard memcpy path can reduce the cache pollution in the local
> > node and the bandwidth overhead to the target node. Furthermore, for
> > certain types of CXL devices that support in-line memory compression,
> > the last-level cache eviction patterns can negatively affect the
> > bandwidth of the device. Non-temporal stores can mitigate this.
> >
> > This patch-set introduces a new migrate_mode flag for using non-tempora=
l
> > stores that is used only in the demotion path. Patch 1 adds some helper=
s in
> > x86 and mm to bring non-temporal stores support to a respective folio_c=
opy
> > function. Patch 2 adds the new flag and necessary changes for compatibi=
lity
> > with the existing behavior. Patch 3 uses the new flag for demotions.
> >
> > Experimental data: in a CXL system with 1 memory expander, a microbench=
mark
> > that allocates N=3D64 GB memory in the local node and then triggers dem=
otion
> > using memory.reclaim, shows a practically complete elimination of read
> > traffic on the device, i.e. write traffic is N GB with and without the
> > patch, while read traffic drops from N to almost 0 with the patch.
> >
> > Opens:
> > 1. There is some "duplication" in the x86 tree and a bit in mm. Can we =
do
> >    something better there? As it is now in copy_mc_to_kernel_nt we
> > duplicate the machine check functionality, which if available will over=
ride
> > the non-temporal. We were not sure how to prioritize these two and what=
's
> > the best approach here. Can we completely skip the machine checked for =
this
> > path? Huan Nguyen has some ideas here that we will align for the next
> > version.
> > 2. I am not sure how this should be structured so that it is easily
> > adopted in other architecture trees (e.g. aarch64). We rely on
> > memcpy_flushcache for x86_64 but this does not use non temporal stores
> > in ARM. ARM support is currently out of our scope but any input is
> > appreciated.
> >
>
> I'm still a bit confused why using NT Stores needs to be an explicit
> option - rather than the default behavior if NT Store is available.
>
> Lets assume we did this for all ASYNC requests, is there a negative
> effect? A positive effect? Why the new ASYNC type? Is there a
> correctness issue?
>
> ~Gregory

Yes, this is a good discussion to have. I believe that the initial
reason for using a separate mode here was to be non-invasive, e.g.
"don't break anything else".

But why not use non-temporal stores for everything? I don't know. I
suppose one argument might be that if you know that the destination
will be used immediately, NT stores might be a slight performance hit.

arm64 already seems to use stores with NT hints by default.

In general, though, I agree that for ASYNC requests, just always using
NT seems fine.

Maybe the mode and reason should be folded in to one variable, so
that, further down the stack, a decision can be made as to what type
of copy to use? E.g. if the mode is !MIGRATE_ASYNC and the reason is
MR_DEMOTION, then non-temporal is still a good choice. If the mode is
MIGRATE_ASYNC, NT is still a good idea. If you wanted to get fancy,
any mode with folio_test_waiters(folio) =3D=3D true should not use NT,
since a task is waiting to use the data, so caching it is better.
Maybe that's overthinking it.

- Frank
