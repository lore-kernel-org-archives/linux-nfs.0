Received: from mail-qt1-f179.google.com (mail-qt1-f179.google.com [209.85.160.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FDEA381AEC
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 19:33:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.179
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787599998; cv=pass; b=PH1NSbg1VWNG3UVk20mCdtn6zG+tGPwQqnR9sqex3uQ/07KusQOirThBgLyb+iDeJIzM3kgI3+LF7OyjGb4GK0ep1F2J6COKU/C7OvB/HEnVSIY2/fTMD7kiXLZbwSW8GtXr2voPd12poAYlpt+Mu9pg5mWRZFmkHbJpVLEDyuI=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787599998; c=relaxed/simple;
	bh=6nzgFXxKsg+JnpSIQP0/wxVzDkLsa2CzNa+jLf/mGAU=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=EgkWmaYUnLs2EOjdDogpXXgXYXehYBI1w7wX2BOX9J7qe1MmQbawJKb2ZVxusD1O+7oyVC6p4Ls0/pdbLHYzqmfY/WbYQWRJFmFrk3c7+u5TyTl5HvW3P+ScNuTrbwp65Y/NnIjx4s0oMQWI0V60m1ZE0z/YI9LKUq1yC62z+8s=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu; spf=pass smtp.mailfrom=szeredi.hu; dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b=rWbvmCWm; arc=pass smtp.client-ip=209.85.160.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="rWbvmCWm"
Received: by mail-qt1-f179.google.com with SMTP id d75a77b69052e-52e1f9da948so9577581cf.2
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 12:33:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787599996; cv=none;
        d=google.com; s=arc-20260327;
        b=G19Tjug3cTYOpN2zSthx46LEu1pxg3YqXq2khyi6tqSNqwA61xnJLOonMg3cuZsG7I
         BLck82Tp2vQlOfS6dY/YDhQMQHF22KECZagqCIeKLrb0KB/tIcMfkOHQGqnQp/l+A9Yw
         /Vvh9a7yiA2TomZWUZn7newJc9xXlyLL4UlVSF57x2niVq72qEYIQUfZIjp0TdvqkD27
         5kUgq0Vst8bCzfaGIUTyefErNbotFSqid0nvHnWCTY2F60NkONbQeZMeRvtCF8yFlb91
         85v4ISrSerDzxAQR7FRKeCPeS8PZt06PBFm/xXRKeqeBhHSHDQsSc4uD0VoLCYwqHs5n
         NbyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DK1kq+UORspwzlcL44O0F5OA7o6ZQNGRnMf+1R0tFOc=;
        fh=ztTabUAJG7sfGpPeWPZM7j5YlvdcJSpj31EUmi6FyqU=;
        b=k3kdGHece1m0EGE/YfafPK84O0hWCXku2c1oon7ValB/1dxYtY594amv++U8zYXKyU
         uQU36c0F+FcpTOsyJaJ8L8ylVEVYCmp2PS/E5gwxJL1pnrbG4PVywnZI7l306iP3rZto
         s8p5q0Sy0vKTgRtmmrZY4thKhROn+J3ZSvvR1xbhz+9N6mholeazFaAWOL9Ijnx3GQLM
         +Q5DoaEje1XnxULs+s870YRRX1QGe/ODz0kL/l+dFX4C+HCZIoogNRszdcfH8x4Ed56Y
         QBV0bcdJ0vG5PUEqb68Y+4JQsTV5KLlNcaBAwbr2x1/j4jnHtfv+PRX+Do3hQAFkPrZn
         ldLw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google; t=1787599996; x=1788204796; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=DK1kq+UORspwzlcL44O0F5OA7o6ZQNGRnMf+1R0tFOc=;
        b=rWbvmCWmjcCMV6cmRGcdr3+XqqhuMWDGjRX1T5jRxsvlEvHcuEqtIU8Ara72ZK/KBC
         Fo3btCJeMyC+8K71XbO+ycgkyzflH+/WAU7RjJ+jWdNq4ZIUVDtoY46nzEbAYFajZokv
         WbFxgJPYPnzHMK5AKBCgIKfsa0iEZf2co5VII=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787599996; x=1788204796;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=DK1kq+UORspwzlcL44O0F5OA7o6ZQNGRnMf+1R0tFOc=;
        b=SgfolJbFyu2YKj1UH7Cgbmwq6dIdAl5UePxtri38kYo7NLICiL/zPbEeTx1z3T+VTy
         8C762+C44BgXK7RxiaAhOSdwHtlG7uTAbk3eQq4CX+LnX/B9J1tLwZ/ptbsJmJygpT3T
         8JgVpC2bYV7UyX9lBW1OahJKRGV2LcI7bRIpVEon0rHEP5u0IeDl/xfa5YgM9EH8RLuy
         bQh4o+fwdduhsMXKRUTmuiYqxXJnoTSlDsOXYioR9rqkRNvRqC6ZPTVpExx+AmG7SwEm
         uvxLz7O9CHvGxfdYYbwc5RlanNK0yOx8LVw7YmLtZZE/px1m3GdexuvyST/wpEy6C7Zk
         mXIg==
X-Forwarded-Encrypted: i=1; AHgh+RpXPb6d8D3c1Gw9XkIqfFcr3aigl6egAFeIFOYmFNdbwC5wgq3AbcAC12naz2PV8IeVqVhfp1DexXM=@vger.kernel.org
X-Gm-Message-State: AFuF++mz2VmpBPYcq+QKE8BZhmdXQDL459DVSjAkU1/f7Gksszy7sPde
	RLe/U1Fbb3BVK7ztectO81aOQ//+tBNuFiGZCaCxEZH58jy1O1tJ9NyP8gISMjv3j+AKU5aDWVf
	70hesBM6zyrv4OZtzwjcKwqdAGAGDJQ7+xX8FlCNPBw==
X-Gm-Gg: AR+sD11piQ0Gi3MvmvDNGd+xdScr9ifBQNZNOwQbGlsxVEgLQD9tznThKPsFvCS6JSx
	gCTg3BiCRHOFm3FWE6whOwaizmdJr5Zb8mkCnLPbaBpeWLCcjFsyMxAMzlLcD4jZTZJLYWwmv/I
	5g+lDJISFw11fbG9/CbwFijpjQ83+nMNDo/7fgAa/XE0Jfb6rGJEkGMWZQEBKMqyY5tYe3bsgtK
	EDwC1RZYRg5tigIcIegIAVu+GSzRjSuDXZlQ7LZmdwMZ2jJfnlZTM+BBtkIUmFeuGSLv1txaNcg
	w6J5zijT77KXJmBXdeQs9jKUifPVs1EXM6DAO4/keUaPvQOsam1hYmNN7fGhXPGiexvgSnHnf4S
	Zvag=
X-Received: by 2002:a05:622a:411b:b0:517:78c7:d93a with SMTP id
 d75a77b69052e-52df57324bamr286714031cf.16.1787599995881; Mon, 24 Aug 2026
 12:33:15 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260820193343.3852967-1-willy@infradead.org> <20260820193343.3852967-3-willy@infradead.org>
 <CAJfpegvP3i8ZJc2T=+f4rAhZ4E1QcT5+jC6mQPLxtB-yoK9Brw@mail.gmail.com>
 <aoxHOSC9kTPbKeNq@casper.infradead.org> <CAJfpegv3Ak+qNLb=fTSCSz7-taQ3Ui-Hkmqgn4PaGPe=CR4cbQ@mail.gmail.com>
 <aoyKxvdQdeJQfPHj@casper.infradead.org>
In-Reply-To: <aoyKxvdQdeJQfPHj@casper.infradead.org>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 24 Aug 2026 21:33:03 +0200
X-Gm-Features: AcwNN1WHKWPg-gulrL_ybc1YuKIIGquGv3tDzpc2zs94XwMFk4U-dS3q1iLbtfs
Message-ID: <CAJfpegtgenUaudDcvecJuV2_WkkVw=gdcB0Eqg=UFKPMZP1uKQ@mail.gmail.com>
Subject: Re: [PATCH 2/7] fuse: Use filemap_invalidate_pages()
To: Matthew Wilcox <willy@infradead.org>
Cc: Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, Chris Mason <clm@fb.com>, 
	David Sterba <dsterba@suse.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg <martin@omnibond.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, 
	linux-block@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	fuse-devel@lists.linux.dev, linux-nfs@vger.kernel.org, 
	devel@lists.orangefs.org, Pavel Begunkov <asml.silence@gmail.com>
Content-Type: text/plain; charset="UTF-8"

On Mon, 24 Aug 2026 at 20:17, Matthew Wilcox <willy@infradead.org> wrote:

> Before:
>
> fuse_open()
>         invalidate_inode_pages2()
>                 folio_lock()
>                 folio_unmap_invalidate()
>                         folio_launder()
>                 folio_unlock()
>
> After:
>
> fuse_open()
>         filemap_invalidate_pages()
>                 filemap_write_and_wait_range()
>                 invalidate_inode_pages2_range()
>                         folio_lock()
>                         folio_unmap_invalidate()
>                                 folio_test_dirty()
>                         folio_unlock()
>
> so what's the serialisation that the filesystem can perform in the first
> case that it can't perform in the second case?

In the second case filemap_write_and_wait_range() won't write protect
or unmap the page, so it may become dirty after the writeback.

That can't happen in the first case, since the page is written and
unmapped while under page lock.

> or alternatively, what's the serialisation that would be useful by
> adding a lock/unlock of the invalidate_lock inside
> filemap_invalidate_pages()?

Nothing.

What would prevent this if we'd have writeback + unmap + writeback.

Thanks,
Miklos
