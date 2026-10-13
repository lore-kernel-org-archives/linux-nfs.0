Received: from mail-ej1-f43.google.com (mail-ej1-f43.google.com [209.85.218.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 803DC427F8F
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 10:44:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.43
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791888269; cv=pass; b=WIKjpd0eiByk/XRnbe69eiXiy9Uzpcdao8DXabStIGB6RlvAdINWsKGFdsfMRw7Zbml/EQjmp+R0Ni50muy/xGsl+zdtsSgdXygA0KZkFn4fZui+zDuXUZlxNzHjj/o1NV4Ss1E7P02LbA5n3kzqc5eWJPgj7gox/cwGN791wYE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791888269; c=relaxed/simple;
	bh=PelTeFwd5ud7mnoUu0LqIyINYO9v9og7hyCKjE+gurc=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=W/w+13uW3lFLJXX84XJk4qrX8SULLeG3kupk+IjcW1AbCufXH84o5JmBKQfsVUElzbJuLBlvywa6plxxQAQBD4UcfLPUwAJWBAtVZG1DhFUBHN4Hn+OgQ/b6DWbGwocl7x/aLfyXXoXxh8JMGh01Wcd98kjdqsv0UMg/2DWdwnY=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=dneg.com; spf=pass smtp.mailfrom=dneg.com; dkim=pass (2048-bit key) header.d=dneg.com header.i=@dneg.com header.b=Ef83ps0A; arc=pass smtp.client-ip=209.85.218.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=dneg.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dneg.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dneg.com header.i=@dneg.com header.b="Ef83ps0A"
Received: by mail-ej1-f43.google.com with SMTP id a640c23a62f3a-c2acc1e170cso451046366b.1
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 03:44:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1791888265; cv=none;
        d=google.com; s=arc-20260327;
        b=n8hC6KsmtIUoriIdSS6Vu9VRQe4hQXhSJnsqx4/UQXqU2b0JRBp4HBOcj850L644an
         bHZ9E+zl9zd4eYXtGUbKWB/VkrcgqWQX0d+hxJ7xM6XeFuP5NLcnsEmByGQK2GLD+4Nu
         U9MTa4MuN0RjMPzJim+GicyG3QS5ynqI924X2paT/X13z4U+pStb/7LZXtakyqtxAFYU
         JPiwYhIx1a43pIgRpKzLQTtnMz+1GxQE+aKmc9GVY6jL2lqz9RhdK4xRYMY/0s1lREAZ
         XxIRQafbLyBFGp03X026wOIah09WjeAivB9+SsQgvOWFRRgfC0Yv7nXaeNXBsMMZ3kwR
         +0pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VgQkjFUz0Kq5wc1rWCSsIQFYXBAR5PgY4WxoDpZtyJ0=;
        fh=7ixGAM3SPf33Qnfeumy/VOSn1X/qitB0MUDgzFdfF2g=;
        b=DUF9yjst4dWcJgRDx/DKq3jsC7lzLctC18WSvJfyuVQiAkBVIlhxmY51NhYpf18RS7
         Mao/FL9cVCOI1ng8NSqG3mVIqheZ0Jf8ppG44UyNyuQyP4/KfJymYrJcBjPvxQBLuBbP
         KLRk3T7WJ99/5fvpqWM+UZ1DmgAYDX5Cqzqkj6UtuczzAJ6+iQfTk1GsLFDr9kkAYWZj
         ewl+1/INtLb00lxxF41YVlZ68aw9f4l3EPAg1pDBbGV5QLjheOrJsL+xFF2/DBtooPsc
         S+KaV/2rjWRbq47I52Wonm3yMNOo9QJguaCzHtyfoeYEDz0TGAwTJ/Dq2rQhw+vlhLBs
         WSsQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dneg.com; s=google; t=1791888265; x=1792493065; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=VgQkjFUz0Kq5wc1rWCSsIQFYXBAR5PgY4WxoDpZtyJ0=;
        b=Ef83ps0A9eB61HeKmj9MUPxwLvkKuGBdnGyjMmBDDoXZjqVmkpB7JCCbSFTIMU1O81
         Dt2gd1bz3npeQth6eFHSfT/q0/lcqN1GJJE3DnDjEq0/cvZBkUK6wAFTScbN/oHdREgc
         xxYa8SNV5St5nC5kr3Fp5jK5dufkEVUoceR18VwZmk5fG1w+QUq/Iu8Ec+zgN1flsa25
         vJv3PEL3sgdlxRosCI5xubiuUTYMwGm8IYng6uryuhgWasTC15RSAyBIx/o/wEVxr5Z9
         yIr09MV+vGY6KlRSzFGqnohq8URD3COQew7Jr2eAfbxbnZUJzR1smMmq4XU2+avHa7y+
         nlOA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791888265; x=1792493065;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=VgQkjFUz0Kq5wc1rWCSsIQFYXBAR5PgY4WxoDpZtyJ0=;
        b=ZQEtlfek++n66WbZA5leNiwVCpSpHqJcV38mJCdj2GZ3d9V4eWlKjhaT+jvLDExonU
         Ab4yhVjahJditfd4FUvRpOhGyn6rV8ipQJvD+s0ZbcOJkYTXhzHf4Dbijkjv7od2+OKB
         7x0zLRiiLdoOLZ3+uzPba/3jme47GgoXs8HCwbPtaBEteBol2bMBOxlXr8Q0hIlOztTw
         OlDJokxkq6Ls3m5fJUb6Hdlv7moTcJZ2GwYEg1SmspgTb9VFMOz9w4iuiecSZf5CSMc/
         qFqPpuONjHif90RPDIdp8MYXl4cJT4duq9bKtgWDAXqby+tBoSgCEAqv82NIyeBO01KL
         LcSg==
X-Forwarded-Encrypted: i=1; AKwUvByFvXNo7kVIFX48834OzRyaorDXXL9IDfWGFyN3OKDF5/FIVs8FFUzfP+DsyBAZisYftl2q06EtCQ8=@vger.kernel.org
X-Gm-Message-State: AFq9FYLz5HX5H00ZNR0eggNMWcF2toRN09bzleKLeQO0t1Cnm8IAeT3b
	hjLzkDnTmVIJON+QQ4eqrMQCdsXeySu8BKjLIPkMqqozD1R4wOmMIn1Bk+uhjbynj0VFC/qL9Pg
	WMfuQzOPUiwMbFsDt2I2BqwzIJCECVs4chTAyT3pQtQ==
X-Gm-Gg: AYBFou2BxjwDhtG4LSPsDXmgQ/v/RcWrVPIJ//GWlQa+fqAThjKySKX32dbtjqkeur4
	AO3ROtpCxLLALx+sRy6epFF3QRiIGInSM7x7Em+VTVPZx8f7Zl7ZPcRhyfl6RTkzde0QKk0duhm
	kizs801Vozx53FR5R6+k8UgdRAs/oVCDUjAHIejcVB3LKIlr/ZDbdNjVAtLbUKTTsRefn3JwMPY
	G74mg1izfH/Hp1sJxQVK3kk/VuSe1f7ZH/74Xq3rW+RgSZ2icVaxEQ3sQXp8Pkp/S/BcZEWNcE3
	apyQom7coR8B3AKXo1viNWCdgkjEkCsNp6cCHaqd1dvDuW6M8CI6e7qUg+UYyUEl5oLhoD5Bno1
	rtQ5L0HwZBro=
X-Received: by 2002:a17:907:e158:b0:c34:e9fe:82ed with SMTP id
 a640c23a62f3a-c34e9fe8db4mr344907066b.28.1791888264638; Tue, 13 Oct 2026
 03:44:24 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260910220242.2165023-1-dhowells@redhat.com> <20261011.cachefiles-seek-hole-walk.pchmelar@innovatrics.com>
 <1655915.1791879248@warthog.procyon.org.uk>
In-Reply-To: <1655915.1791879248@warthog.procyon.org.uk>
From: Daire Byrne <daire@dneg.com>
Date: Tue, 13 Oct 2026 11:43:48 +0100
X-Gm-Features: AclHuK_oVCRmnPd9NH08Wt-JPyd6g1EMor68YJAilUyzKCf7DPZ-awFW_Pr3mM8
Message-ID: <CAPt2mGPPYTv=mBo=ysFt49t9=6AVh=P4uvHh4EwZ4Xh=ZULo=Q@mail.gmail.com>
Subject: Re: [PATCH v12 0/5] netfs, cachefiles: Changes for next, primarily
 occupancy tracking-related
To: David Howells <dhowells@redhat.com>
Cc: Petr Chmelar <petr.chmelar@innovatrics.com>, Christian Brauner <christian@brauner.io>, 
	Paulo Alcantara <pc@manguebit.org>, Matthew Wilcox <willy@infradead.org>, 
	Namjae Jeon <linkinjeon@kernel.org>, Marc Dionne <marc.dionne@auristor.com>, 
	Stefan Metzmacher <metze@samba.org>, Eric Van Hensbergen <ericvh@kernel.org>, 
	Dominique Martinet <asmadeus@codewreck.org>, Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev, 
	linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org, 
	linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org, v9fs@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Hi,

I don't know if it's particularly useful (or relevant), but we set an
extent hint size of 8MB on the backing XFS filesystem for
fscache/cachefiles.

For our workloads (mostly larger files), this seems to work quite well
in keeping down the extent counts on the cachefiles objects. It's
perhaps not very space efficient at first, but it seems to improve
over time as more data is cached.

Also, compared to XFS, ext4 seems to do a better job of keeping the
extent counts lower even without an extent hint.

In terms of granularity, I think we'd be fine with something like 256k
(as we are with 8MB). But we would still want to be able to cache a
wide range of file sizes (4k -> TBs).

We also have a particularly horrible random IO 4k workload where the
files are MBs on disk but get read in random 4k chunks over a few
hours. We specifically detect these reads and have a (readahead)
daemon that goes and reads the entire file into cache rather than
waiting for it to grow organically (in 4k chunks).

Daire


On Tue, 13 Oct 2026 at 09:28, David Howells <dhowells@redhat.com> wrote:
>
> Petr Chmelar <petr.chmelar@innovatrics.com> wrote:
>
> > The cover letter leaves non-contiguous objects, which still use
> > SEEK_DATA/SEEK_HOLE, for a later series.  We hit that case badly in
> > production, so here are numbers in case they help with its priority.
>
> I know.  But it's a tricky problem to solve as I need to store a map of the
> content somewhere.  xattrs are painful as I can only read or write them
> atomically and as whole blobs - and also I'm not sure if I need to limit the
> size of any given xattr to 512 bytes.  Further, the xattr wangling interface
> inside the kernel assumes a flat virtual buffer rather than taking an I/O
> iterator.
>
> I have patches that store a bitmap in an xattr, with 1 bit per 256K block of
> cachefile, for a 512 byte xattr able to map up to 1G of file size.  I need to
> revisit this at some point soon.  It may be better to switch to storing an
> extent list, but:
>
> > On our NFS clients (Ubuntu, v6.8, cache on XFS), a sequential read of a
> > fully cached 184 GB object with 1,080,732 extents ran at 0.4 MB/s.
>
> Trying to store a million+ extent records in a single xattr would kind of
> suck.  Now, it might be possible to collapse that somewhat if a lot of the
> extents are virtually sequential within the file, since I don't care about
> physical sequentiality.
>
> Also, can you tell if you have a preferred cache granularity?  Would a 256K
> granularity, say, use too much space?
>
> > I expect the right fix is for cachefiles to track what it has written
> > itself, as CONTENT_ALL now does for contiguous files, rather than
> > something like the above.
>
> Indeed - as mentioned above.
>
> > I can send the workaround if it's useful as a reference,
>
> If you could, that would be great!
>
> > and I'm happy to test whatever you plan for this case on our workload.
>
> Thanks.  Now I just need to reproduce your bug.  Note that I posted another
> cachefiles patch that Christian hasn't picked up yet:
>
> https://lore.kernel.org/linux-fsdevel/1091807.1791483394@warthog.procyon.org.uk/T/#u
>
> David
>
>
