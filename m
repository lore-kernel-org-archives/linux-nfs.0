Received: from mail-qt1-f176.google.com (mail-qt1-f176.google.com [209.85.160.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C7F9390200
	for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 12:14:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.176
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786450475; cv=pass; b=AJKCL/zigRFrGYnocl1XHBjQYdl7U73mSrjB97uH3Y05QLmh+sD4GGUxz96lhFwEVY6ZKIp5k4osJ+0cpbgzha0SsEfE3kE3iTBGmTckkVcCltzw3x6zz2QM9V880TfrirlQy1sHZlmLml9ZjqFfdTe2x2bvkyDz2fUya9oHvBo=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786450475; c=relaxed/simple;
	bh=uKswzyf3oANr0x5zb0bJBPrPAkNK77rK/33VzGVtg1I=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=brcUE5KViM4byGbx8j2H3phL225Xm/6v2CUExGUET5qzKSUbyaqK5wM/3VeC9YfY453lqBry+cmy72hxkLIsUVmUHcAzrf3v5S9Oi0k4xpMGnZa69aXDdzX/Q1LKF4AbthpTilNaxD6cO62L69lM8mQHcSdi98yevVORmmUh7fo=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu; spf=pass smtp.mailfrom=szeredi.hu; dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b=LYhhybqo; arc=pass smtp.client-ip=209.85.160.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="LYhhybqo"
Received: by mail-qt1-f176.google.com with SMTP id d75a77b69052e-52cd38ddcdfso4256351cf.3
        for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 05:14:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786450473; cv=none;
        d=google.com; s=arc-20260327;
        b=dNFK1NkJ1jB9rVkjB/xVlRyofasVZrZCGj2TA4FjRaXb5uEtdIjjJE5a+Wj3fMql5e
         m2/ZIpoc+58EGK+6LwjAElst85pUZxDb8Fw/5QIXsu0MJkEKMxzreeBgpWxSFOr5EI5L
         ZnmC1L0+UmmBIapnAcQ65tK4OkUWo8wZXBLCY6/iUJXi9KgFtKX8TQawh+WjncXLbOsy
         ahxt3WCUVahbEKn+/E7arX0TPH7g2VQrW8wzLuIoLcYrXorSe9dTn2m+vNyqGvUsTTyn
         zF6ij3Q9oq7zsqvfSRkIws6rMXXJUREq0eZXhxID2+I2KQlkdBJXkszIC8AkBvCOuD86
         bfWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NrfMxAmOI1dOmAoAUYNtBxs6J6vBQ4QSPSkOCCv87C8=;
        fh=ONx6678r622mDZdmRhG991MyKRmuBpDZpph0xZ52UWU=;
        b=U8iEqEdFG9dt0cvBLZwDnkPDeDLyBAPXBgyCUEswT/tR7HUTi2F/mQ6paCqOnAeEba
         vNdJ6S249tFRfiKNDihDxjZsYqF0hG3rrJFcgeOYYRvn+K+LugV9w5/kKU2yP4o+Xruy
         RuLz+cxPMeWXbii4ulHwJy5qwmcXuh59H5uwM2QR9x/NXeXBMVikeFKEndoVWtlDltc4
         wQBA8VUazM0jvOAHBoGAPDNsP9hW0FjxEZjbIyY+3i18wsbu7AY15Qcu95G0tshsUtDP
         vj8J9ycJ3QM28mBWdg0uHTOyaEJdKS1TkhYyKfYutIltVLQ842+AolbGsALOyKCUuf11
         ZNIQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google; t=1786450473; x=1787055273; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=NrfMxAmOI1dOmAoAUYNtBxs6J6vBQ4QSPSkOCCv87C8=;
        b=LYhhybqowWX6ZR+Nf5Xxsft7xXDxdFX3reI2VxNHFPBCKIsh8yC66ANIAQgBMBikIZ
         99mOfXZFzwE+fla4yJjoCv1zBbfR1iPecQ7opVFYRx2aUa01sY/qYo/E7B2JCkdw3MWb
         feyvqbpjBXul4yjwwI3Ksk3aN7ddKGi7W+kCQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786450473; x=1787055273;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=NrfMxAmOI1dOmAoAUYNtBxs6J6vBQ4QSPSkOCCv87C8=;
        b=oqapj86bsLiZNxCjzXMeMvbP4u2DwIejjJKOD4kCHELU6faH5wxYssHTYcUaLPmHsC
         unQ2a+fQJT5gyaisYPBYLqXaq02NYP1/kijE94UkSN2Q3Uztahxoi2pimo+6zpxz8jU6
         SPu/hcfctsrVefbqUZWdKkipy75AjbafW4ucULYmTDzvikdQejZm0N34LnZsRDGDezds
         Ih+65NloZQTmpzCIBoOD/tkDk36pSX/PDNDd+cqqGpWH5+P6S2SNyLw/hcUXt8MqlPFM
         rFKLiNNpwV0IcWwNeEVW7S7TbyG7A1sRMqPgvcvs38o5+vxixhwQUpT77veXRsKbKuy7
         g/5A==
X-Forwarded-Encrypted: i=1; AHgh+RopHy91I3yWWm6ZnXYdFS6RTyQL+OEFcunvClE9POPjEyRnDTDQbHkLeJ63kUpA+42JuqsCU2u9PyU=@vger.kernel.org
X-Gm-Message-State: AOJu0YxtBSL0gDjIOtNlVdlfj1kHa4c97Slg2XurTdhqYbSRRmTWDSMZ
	88kRs+7T9S6ashNKQTNqVIk8HKiSrSVl0r2SfU7kE7Q0hBejg5lidd8bhA6DldpyZ0uxKtyNtLA
	jdzHxJ0ZVxOaK3D5ASYvCeg5E5gGTV9ThslwJXpvj6A==
X-Gm-Gg: AR+sD10T9JoXhKLnWVLJBCQVpkGzcByPjmGpsxecB1S401T+yKX8GnmWdGN2vCAly/w
	W69HZVOPTAV07KEavcnGDWLy8QicVwEFPmCKrq+1KoODc6OhT1aTJiOElDssswu296E1ddrkI3C
	Wynt73w2Ltl36XqbKQpU7gTmrEsY388QIQ5YdTPn3w17b6sE80WIjOy1Pok/60mFMnC03PPRxRB
	xdpI7s1LGFWbomurBRA3lkRHBuXnjkTOwv0y3d254OVt6hkWhjLYpxozRlEldNMDP5/ORH7x8fd
	mcFH7j3r89nQ33OZmFtfVnEGhdPwRlV1rmIvMv3ppcNrEdfJVhJP4WBb6F8RAKOG/EXuugYg4ue
	uCQ==
X-Received: by 2002:a05:622a:1389:b0:517:906b:c043 with SMTP id
 d75a77b69052e-52d5869769dmr20988111cf.36.1786450473109; Tue, 11 Aug 2026
 05:14:33 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260803012648.2195405-1-neilb@ownmail.net> <20260803012648.2195405-2-neilb@ownmail.net>
 <CAJfpegt1wHngLs9uR943gT6zxV67D53k3n4GiFKowsAb3C6LJw@mail.gmail.com> <178641431036.2852630.14175693646176331672@noble.neil.brown.name>
In-Reply-To: <178641431036.2852630.14175693646176331672@noble.neil.brown.name>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 11 Aug 2026 14:14:13 +0200
X-Gm-Features: AUfX_mx5_QZpyNyj5Ni2I_IHkZVhUDCHgR5x1MospzmB8YaToZll8PeS64_iAm0
Message-ID: <CAJfpeguZh6Bo7hxVW5f-OvKJ3UazJTn26Wkba8+rXY-LC-QNWA@mail.gmail.com>
Subject: Re: [PATCH v1 01/12] VFS: don't count references through ->d_parent
To: NeilBrown <neil@brown.name>
Cc: Ian Kent <raven@themaw.net>, Chuck Lever <cel@kernel.org>, Jake Edge <jake@lwn.net>, 
	Ilya Dryomov <idryomov@gmail.com>, Alex Markuze <amarkuze@redhat.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, Jan Harkes <jaharkes@cs.cmu.edu>, coda@cs.cmu.edu, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Amir Goldstein <amir73il@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Miklos Szeredi <mszeredi@redhat.com>, autofs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	ceph-devel@vger.kernel.org, codalist@coda.cs.cmu.edu, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Tue, 11 Aug 2026 at 04:12, NeilBrown <neilb@ownmail.net> wrote:

> --- a/fs/libfs.c
> +++ b/fs/libfs.c
> @@ -169,6 +169,8 @@ loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
>                 hlist_del_init(&cursor->d_sib);
>                 if (to)
>                         hlist_add_behind(&cursor->d_sib, &to->d_sib);
> +               else if (hlist_empty(&dentry->d_children)
> +                       dput_dlock(dentry);

you mean dput_dlock(cursor)?

But that's no good, since the directory could be repopulated and the
cursor needed again.

Thanks,
Miklos
