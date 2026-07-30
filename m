Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA79C4307A1
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 13:11:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.221.53
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785417116; cv=pass; b=MpPMiZh9lySpuj510nXhosgUWKiXVVWFFevk4jQ9Ll+QahgpCRKgKyCkSNeL1uKsE4pNeGeOdkaHxAmOeHWVndFDyWm+wUKXHn5xZWx/h4fpDj2mxRDc8HiRjm6E2OI1jnPZogoWNq+CsPOJGCpqyIUU7/A3Trz7vhASdR2cNd8=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785417116; c=relaxed/simple;
	bh=XHgYqQdbd6UXYLAfCM4eLJgkL7Zop9dsJ7MDxabavq8=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=JBiTkGFIsFD1EGAe7Ij/I7neigc+rn6UuVfyE3VJ7R5WUmUviFyNlnvJZFde6CC7vtbAG0qgtd5g8NfBRM2BbDcPiPZ38VSroxmpB4HOMhVtJJ0z8YacUrP/DBF8xOmAoWJaWIfFW147yy2KuAn+FxGPcl9yhvk0kqzfxTdpMLo=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=loUHIMtl; arc=pass smtp.client-ip=209.85.221.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="loUHIMtl"
Received: by mail-wr1-f53.google.com with SMTP id ffacd0b85a97d-47362928f65so1830626f8f.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2026 06:11:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1785417112; cv=none;
        d=google.com; s=arc-20260327;
        b=m6NkEsbNNUtzNPL4X2zKiXCxc5EQX9S0eMAsDf51OOSo/quBTD76P3uJeR3OcAY6uq
         KgDKMEXrctkmIYITAZt8Y1tRkTwLdEoFQB6D/9lV29+19w2rYbWwObOJsiWmt7cAcTCg
         KOYC4ETnibC962hLiojlg6anRxKiZTmQwrZ1ZU4lTEp7bcLJvYK6v+mwM20OqBVpijKD
         RDSmB+53sZpudYEpuiIO/LdxYiziUbeOS+2GmjEIt4HODVWuBeihUAyhSet7GGBUyCjY
         PxfptEiEZIShdOs43wmvJo1RcedgCDj5c5UxW21bAUIx/e3MHevenDJ/IS/eSUQ41szY
         Dy7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=JZxWQFrq5yQB1yLfY/DlKbs1Vg/HpnWd2qZlXhsqsB4=;
        fh=irwSlTAn4GcuW24qaWSJ2DWaz6FyiRySZxTj+bbBfnc=;
        b=OPYdnqV4Z4q6ZNTfcCX18msaFvahICxeqDlyd2AOEP8HJagu0Tl+NdVTz/uEY4aj4V
         ugB8PM2hD7I+6VM6NOhrUpIIsTh4QBQUrLtow948l7GuYGEXYhLT8H8MyLFvPOpl0mHf
         3hKk0HfwU1ZPaZwuoWuvtbDDfvBZuKCzYOnFLNsHwcRvTxzWNAUIC+YshamGOxe9o5uL
         niZz6EySnUDczxRqbtyWHU8GWu8tqM/kC79FeCGNL2L8R4FiuBC/HFsSwghjZISCeI+T
         JTZnXurLZbXjviLbHC6XxhzQM5/RMrgPOrK3xzrh88glH9AA9pSqOBydMQWEn/MRogsT
         ArRg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1785417112; x=1786021912; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=JZxWQFrq5yQB1yLfY/DlKbs1Vg/HpnWd2qZlXhsqsB4=;
        b=loUHIMtl+zQI1xPUlk7eEZeGWKbzEBToj3bbihMtFfaZijsztsPEXcVo/SCxH8VSkC
         3nzdrgBq2PuKAr9/+IJjBjRDG7B58pxYe0JuRKh5EjK/DblzLvZZ3wzLHZjtQGEiBFVj
         4FEoN6FRNE6xKg7WAJM8RyTx6CFc/LKlaaHpjl1kqgqQDy3Si+5W05w9QTrtVZZTBApx
         jZt7l6Z1U7/U1Kqmvj17RdiSBmY4ctECm91m01sSy2hmGsZTRWuiosrqO7uK8j4pfCdH
         wirMkfvQl0bUZOUpCW5ZIbFAqL7gpPoC8MmVtsE8cUrK+3miJlM3mYl6sGOKBJsJQ+ln
         0yuw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785417112; x=1786021912;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=JZxWQFrq5yQB1yLfY/DlKbs1Vg/HpnWd2qZlXhsqsB4=;
        b=TvgbZosD5fjKj9LsHYirxry80479u+vuUQeiSgi0OKzwSEDINIy3n4Arcc5cjWp1wn
         j+/clgvUbYBKjF+UvLuim9rUTUeERCrJmrA3bzZFtSY/n/1v0QrQWEmF79JYf7Dn+czK
         CHyZJfwIWRQNYgHQ7eSQJqDXRWkGwlnmUoLAhq82BKja4WK06RnWvDb/eNWcRWi9gcye
         eDSb1WGIXxGBXnvgf/Jcdwwc2meLfka+YyE1akFck68GqpvtTq9xTQYaf4m6IsBHU34V
         B+H0XZ1vxsQcqoRe8u/zF9OLcbGQ/ZrePReUOwwKE3G+CD7R1vMhLR4Xy4wwU0UC3HI6
         G6Pg==
X-Forwarded-Encrypted: i=1; AHgh+RoOpSAgZ/D8WTc8Fwv37e21+NCYmdk+UYyB3YttJv4nrha/wA1zs7L4/Mc5mLfMRE5u8aTjw5Yxtp0=@vger.kernel.org
X-Gm-Message-State: AOJu0Yw8F4kDKsii1uFhsUWMbNKId7sQnKD2B9dvE7HgTlwfzbCnXa31
	RO0oV8YiIdNVSbTorujCovnccJG4umpCOAjdhWZqK+06DpQOM/OITdXJIKPNfPJ3JpVPkGc/C4b
	F/5YR73gjGu6el4vlFzv3o5OXbERXKXo=
X-Gm-Gg: AR+sD12unhHAyfmpeOjfCTT4WlfzAHO9kQqR7Kb3SOp1nbDKPyofa65lxfgsQKsb9zt
	zb4pUjp1Ur/lnvCt/K2aWxFfvp9fopaJfMXctfEUUIQ0Zvo9pXfJsVSz/sb1g7Lt1j5T6EEWksO
	gaY4m2fmZmCTsGWLSxa86R6QSBl12Rp8ODNPQxrIAQdMcQvpxI0d0fA5+R+s1XAZgugY7bx5j9S
	+/QuL0qei0eQc2u4cpruhDyX7v9sf0A02ymfdQ4rsv7on/sNXU3V7DLK9mCxjdguIDPu2+OKMB/
	1B5jRXSG9x398BU0wgllelMnyTXMN3i0NY4LjJtb3FNu
X-Received: by 2002:a05:600c:8707:b0:493:c182:6b08 with SMTP id
 5b1f17b1804b1-49800ed12f2mr35808775e9.36.1785417111834; Thu, 30 Jul 2026
 06:11:51 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260526-rfc-nt-demote-v1-0-eb9c9422daef@zptcorp.com>
 <20260526-rfc-nt-demote-v1-3-eb9c9422daef@zptcorp.com> <ahW7gwgaF0zIPTAz@gourry-fedora-PF4VCD3F>
In-Reply-To: <ahW7gwgaF0zIPTAz@gourry-fedora-PF4VCD3F>
From: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
Date: Thu, 30 Jul 2026 16:11:38 +0300
X-Gm-Features: AUfX_mwGq9AjTR5NxgyxAqgBeEwNx--Sq9pL4ych9I9IxB6UA5FR819gtzB2mWI
Message-ID: <CAOi6=wQ7CxHf8QMFXm5oyHZFc9n6BQecL45rBud=hMubmayCnA@mail.gmail.com>
Subject: Re: [PATCH RFC 3/3] mm: use non-temporal stores for demotion
To: Gregory Price <gourry@gourry.net>
Cc: Thomas Gleixner <tglx@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
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
	Frank van der Linden <fvdl@google.com>, Jonathan Cameron <jic23@kernel.org>, Raghavendra K T <rkodsara@amd.com>, 
	"Rao, Bharata Bhasker" <bharata@amd.com>, SeongJae Park <sj@kernel.org>, Wei Xu <weixugc@google.com>, 
	Xuezheng Chu <xuezhengchu@huawei.com>, Yiannis Nikolakopoulos <yiannis@zptcorp.com>, dimitrios@palyvos.net, 
	Ryan Roberts <ryan.roberts@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-nfs@vger.kernel.org, linux-trace-kernel@vger.kernel.org, 
	Alirad Malek <alirad.malek@zptcorp.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, May 26, 2026 at 6:25=E2=80=AFPM Gregory Price <gourry@gourry.net> w=
rote:
>
> On Tue, May 26, 2026 at 01:37:04PM +0200, Yiannis Nikolakopoulos wrote:
> > From: Alirad Malek <alirad.malek@zptcorp.com>
> >
> > Memory demoted to a lower tier is assumed to be cold and most likely ou=
t of
> > the CPU's last level cache. Additionally, in certain demotion targets (=
e.g.
> > CXL devices with compressed memory) the bandwidth can be negatively
> > impacted by the eviction patterns of the last level cache when standard
> > memcpy is used. When the feature is enabled, use the
> > MIGRATE_ASYNC_NON_TEMPORAL_STORES flag in demotions to trigger the foli=
o
> > copy path using non-temporal stores.
> >
> > Signed-off-by: Alirad Malek <alirad.malek@zptcorp.com>
> > Co-developed-by: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
> > Signed-off-by: Yiannis Nikolakopoulos <yiannis.nikolakop@gmail.com>
> > ---
> >  mm/Kconfig   | 8 ++++++++
> >  mm/migrate.c | 9 ++++++++-
> >  2 files changed, 16 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index ebd8ea353687..4b7a75b57f6e 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -645,6 +645,14 @@ config MIGRATION
> >         pages as migration can relocate pages to satisfy a huge page
> >         allocation instead of reclaiming.
> >
> > +config DEMOTION_WITH_NON_TEMPORAL_STORES
> > +     bool "Use non-temporal stores for demotion"
> > +     default n
> > +     depends on MIGRATION
> > +     help
> > +       Enable non-temporal stores when migrating pages due to demotion=
.
> > +       If disabled, demotion uses regular migration copy paths.
> > +
>
> Do we actually need this config flag or should we just default to this
> (if the arch supports NT stores)?
As discussed in the sync call, I was just being defensive :).
In fact the non-temporal instructions should be in all x86_64 afaict.
So I've removed this in the next version (landing soon).

/Yiannis
>
> >  config DEVICE_MIGRATION
> >       def_bool MIGRATION && ZONE_DEVICE
> >
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index ff6cf50e7b0b..368d40dc8772 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -862,7 +862,10 @@ static int __migrate_folio(struct address_space *m=
apping, struct folio *dst,
> >       if (folio_ref_count(src) !=3D expected_count)
> >               return -EAGAIN;
> >
> > -     rc =3D folio_mc_copy(dst, src);
> > +     if (mode =3D=3D MIGRATE_ASYNC_NON_TEMPORAL_STORES)
> > +             rc =3D folio_mc_copy_nt(dst, src);
> > +     else
> > +             rc =3D folio_mc_copy(dst, src);
> >       if (unlikely(rc))
> >               return rc;
> >
> > @@ -2081,6 +2084,10 @@ int migrate_pages(struct list_head *from, new_fo=
lio_t get_new_folio,
> >       LIST_HEAD(split_folios);
> >       struct migrate_pages_stats stats;
> >
> > +     if (IS_ENABLED(CONFIG_DEMOTION_WITH_NON_TEMPORAL_STORES) &&
> > +             reason =3D=3D MR_DEMOTION && mode =3D=3D MIGRATE_ASYNC)
> > +             mode =3D MIGRATE_ASYNC_NON_TEMPORAL_STORES;
> > +
> >       trace_mm_migrate_pages_start(mode, reason);
> >
> >       memset(&stats, 0, sizeof(stats));
> >
> > --
> > 2.43.0
> >
