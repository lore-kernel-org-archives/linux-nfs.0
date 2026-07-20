Received: from mail-qt1-f175.google.com (mail-qt1-f175.google.com [209.85.160.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B2D53911CA
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 09:58:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.175
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784541510; cv=pass; b=EPDwVGLhsJuEADqMOJx5NH6gvnZS/l75psuI34fTNkLmcS1FsHtA9AyXn4ilcphRT6ay8v0UgM13fKXa0Jgqq/bSbqlV5eKFWsrLeSWSX1Bi4z9DksxEABmGDSi3r97Nu1PhadZGcPNiVOSTQB6FTI5DCnc4UXOa2i83ytuKc2I=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784541510; c=relaxed/simple;
	bh=kEFjACGfN5Mv6vqShSwIb0iC96xq8g68uewoYj2b2I4=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=arWmvvlyW6/wd1e+FaecTb7sgGKpQ/i3FmWDQPYzdHwGiPv7+El5yiEpBoeFIgwSu5RwAStUwEZf/if8c5kGJadfrqMyTRKGecrSEEU3LSQXj7rUX9uV5uIGKJLFnyBcMQoqoA/aw+xORR90Zl/A+WmS3luLenCaBlfHmECPkjU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=SvZo/Dg1; arc=pass smtp.client-ip=209.85.160.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SvZo/Dg1"
Received: by mail-qt1-f175.google.com with SMTP id d75a77b69052e-51c10ed63c0so801581cf.1
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 02:58:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1784541502; cv=none;
        d=google.com; s=arc-20260327;
        b=n4dCQI7C2jz9zUf5b6/+JlxgKFYcmam87j0/kzWtD6BhVeO4nf/hva6ZxFokoUaTgL
         BJIGOO8uhOBA0CD5/b0Nx9C16kCehHcX1PXbF9g300yRO9sqFdQl9ffWU/aoB+xUb3tJ
         SuEfkbYy3AOEQ0TkJvIqY4/nU6QOMruCaiBFCkpgRYY6gYAx0hBomksSMxk3kIAL/h7e
         U7QPn8FkOLGSiRQJeWhHGpSxPCHwTLLn97z3Zs+48kefUfuxmiVvc/WoDZ2bbw7y5IRg
         8jRgVZu9UW2Jd40/CH17PHNov6uOR8E46yg9l8FmRL7ZYezq3icNAbAOy8sKLdNO4M+u
         A+hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=hvDfTHrwZHejRymuJb/B06PTdjYcc+YhxsDIaGscHQE=;
        fh=DJrDELUF7Sy5YRuXzP1zNFg8JQDqJUxsC2HQ4drLlTA=;
        b=H8JG4I2JYP+gG3yYJIIFwvJ5PoRoZ3+dxvUS3wW8o6frYyeydDAza8t4VTLnhyc3Xv
         0Bj/Rb1J5e7UGxcH9zZFrVstbPyGlNjHv/iZK57AqnHEmKwE5ok+aH0Esnv1FFS89j9u
         b62j51JBriUpEDHHHDwVNgJhVHT2SPBt2nvtwWJD0oS4nGmFOxrCyt1g6AzxgOxvlQ1S
         3g4d51hIkVwfRmQtI6r6bjBo7PfNeChc5kU/2oSVKp8W4jCYjUJZxoTcAH6opx96VkGA
         N5h7EuQxC4hDcg9jtKVJOFRZr/E2LNejgfalOaGdkbG/j3ZhdVtblv1wGjnuFhm/H3SY
         aELg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784541502; x=1785146302; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=hvDfTHrwZHejRymuJb/B06PTdjYcc+YhxsDIaGscHQE=;
        b=SvZo/Dg1qLMvVWHevtlhd19gzo/6IY2HIEqJUOoXNwSEzLuT5SSZCScziElmnIgb3M
         T8lU4Ga0l58/91Ck5dODBmDkiAyWCsLs3aGdIMTZvvgXBJ//lerNk1eyfxaL3LYL/2yK
         +UORm+uwONq52D2fHTVrd3TMIGHtvbiNQRam0QD29wYNbjsK/BeIJ3sSXUbfkQbSe473
         gbOhbHu2Prgrr3ftxnfM8Bmg78VfFDiZFnxMio7ZKmyQr+MIBUZ2pXr200bsnYMkl8d8
         B4eCPv/g9eAQyPz8TdB/bs8PXthah6/lvZ7D3NRr9xcacchJ+QDvE6NijxZDDNIVJa/Q
         zs6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784541502; x=1785146302;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=hvDfTHrwZHejRymuJb/B06PTdjYcc+YhxsDIaGscHQE=;
        b=pBPjgEd9JqpC4jWlPrsZg9fF57atF0e+qjEKKA9oZeM7X/g13jpN7ObIZUZBulzeOI
         uvk4RiMOPZWLzfgyrud2wZxJeDWU/K/3wrTkXbP8ekDBRwhG8U8ffmAgdA6YFmeP020l
         9bhpF8TrZ4240WsirFm0aC9UWirLDAauxE/P2nOc+UMBM8vl18K709dSEKqR7kZGAq2N
         P52g/u2sJJc2/pSllxoQHNftskRI07PUeaCPxKWUqqjihCUVyE59/F3TOY28kaa7o1ll
         u6M/pj9jXwURNbJwN3Kb6uATpIn2Gm249AQxrg6j8Ylwv16nMofMdp473N/ftXn1BwXE
         DkfQ==
X-Forwarded-Encrypted: i=1; AHgh+RoHYS1v+jBbNaG0GPRAoSVyoZCfts1Qx28IymDZLRMnrPgansfozOQpsvGdP5vRqm3qqWH0Wv1g02w=@vger.kernel.org
X-Gm-Message-State: AOJu0Yxn4tFTtwr6GaEdCS5X/w4/vb/UWF2CJAUMQcHjxDk3e4Bsh+HN
	wL3v4hA7Vch/L8OTceQ5B0nw6MoOQSmcYHqaTJMeWrbnUo9C/GqdLeKhZkGHxy5bapbDzdUbqHe
	+G1S/tXzdswrDU9G/J9jIXZL8lGCbKV9g7pIlDVwh
X-Gm-Gg: AfdE7cnGBOYo+oNWF+itDGH4hTK6pjqmH8z13JEBfi7y6KIfXUYqz13QX724HP9i7qN
	jzD48VYYi2qoK/ftqVZKgEVqKpmOWcGSh32wqkQBxaEfRRAgyj4sYSJjosTT/EltLrWt1i5bu6U
	kOSSGLoNemVWaRLG2LjempxA1rxpFAGkIWmWFRTEvZDoHXZ17GYkcUEsISeixi3j6YKC/9GSCvd
	yBUacAxiHrGz9jkjFIMZp9YDGwofh2Z+HJa99n4aFNwZhpC1ZnCWYvM52nU1Jo4v/2Rmw7otN58
	W228niCvwSkhBbv59fLHEOnaF5P8nSduM7ISEBkQxzXGBDY5l0j/
X-Received: by 2002:a05:622a:48:b0:50d:edb1:6bd1 with SMTP id
 d75a77b69052e-522620dd7c2mr14223141cf.13.1784541500062; Mon, 20 Jul 2026
 02:58:20 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260715143540.3597616-1-praan@google.com> <20260715143540.3597616-4-praan@google.com>
 <20260720091505.GC24298@lst.de>
In-Reply-To: <20260720091505.GC24298@lst.de>
From: Shivaji Kant <shivajikant@google.com>
Date: Mon, 20 Jul 2026 15:28:09 +0530
X-Gm-Features: AUfX_mzZMPcyHs4G_t5jKfKYQ71kCdRTHOUOtRtezglHlIfk1lucEret0Y4gcKo
Message-ID: <CAMEhMp=eHz105-t+pDLbX+6uWOPAGHWfkjd4PqTdeXmXf0tPGw@mail.gmail.com>
Subject: Re: [PATCH v3 3/5] nfs: Introduce nfs_release_request_list helper
To: Christoph Hellwig <hch@lst.de>
Cc: Pranjal Shrivastava <praan@google.com>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org, 
	Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org, 
	linux-rdma@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 20, 2026 at 2:45=E2=80=AFPM Christoph Hellwig <hch@lst.de> wrot=
e:
>
> On Wed, Jul 15, 2026 at 02:35:38PM +0000, Pranjal Shrivastava wrote:
> > Introduce a centralized helper, nfs_release_request_list, to handle
> > the bulk release of nfs_page requests from a list.
> >
> > This serves as a preparatory step for two upcoming improvements:
> >
> >    1. Pin-Aware Cleanup: As we migrate to iov_iter_extract_* API,
> >       requests will hold pins (GUP) instead of standard references. The
> >       helper ensures that the correct unpinning logic gets applied
> >       consistently across all requests in a list.
> >
> >    2. Folio Support: In subsequent patches where nfs_page structures
> >       will cover multi-page folios, this helper provides a clean
> >       infrastructure to unlock these larger units of I/O in bulk during
> >       completion, similat to the pattern in bio_release_pages.

nit: similar -> similar


> >
> > Additionally, refactor nfs_read_sync_pgio_error() to utilize this new
> > helper.
> >
> > Signed-off-by: Pranjal Shrivastava <praan@google.com>
> > ---
> >  fs/nfs/direct.c          |  8 +-------
> >  fs/nfs/pagelist.c        | 18 ++++++++++++++++++
> >  include/linux/nfs_page.h |  4 ++--
> >  3 files changed, 21 insertions(+), 9 deletions(-)
> >
> > diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> > index 19792a38c924..96995736fac2 100644
> > --- a/fs/nfs/direct.c
> > +++ b/fs/nfs/direct.c
> > @@ -314,13 +314,7 @@ static void nfs_direct_read_completion(struct nfs_=
pgio_header *hdr)
> >
> >  static void nfs_read_sync_pgio_error(struct list_head *head, int error=
)
> >  {
> > -     struct nfs_page *req;
> > -
> > -     while (!list_empty(head)) {
> > -             req =3D nfs_list_entry(head->next);
> > -             nfs_list_remove_request(req);
> > -             nfs_release_request(req);
> > -     }
> > +     nfs_release_request_list(head);
> >  }
> >
> >  static void nfs_direct_pgio_init(struct nfs_pgio_header *hdr)
> > diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> > index 7d51e10fe97a..569bac4faff7 100644
> > --- a/fs/nfs/pagelist.c
> > +++ b/fs/nfs/pagelist.c
> > @@ -622,6 +622,24 @@ void nfs_release_request(struct nfs_page *req)
> >  }
> >  EXPORT_SYMBOL_GPL(nfs_release_request);
> >
> > +/*
> > + * nfs_release_request_list - Release a list of NFS read/write request=
s
> > + * @head: list of requests to release
> > + *
> > + * Removes each request from the list and drops it's refcount.
> > + */
> > +void nfs_release_request_list(struct list_head *head)
> > +{
> > +     struct nfs_page *req;
> > +
> > +     while (!list_empty(head)) {
> > +             req =3D nfs_list_entry(head->next);
>
> req could/should be local here.  Or you switch to list_first_or_null,
> which some folks prefer.
>
> > +extern void nfs_release_request(struct nfs_page *req);
> > +extern void nfs_release_request_list(struct list_head *head);
>
> Please drop the superflous externs for new code.
>

Small nit + fix christoph's comment,
else looks ok

Reviewed-by: Shivaji Kant <shivajikant@google.com>
