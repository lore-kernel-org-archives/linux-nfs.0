Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795047182;
	b=Fou7jj2c/+b4+5VIdEGB76QN4vw+/FZwsAQ6fXaxNfTZekCbRNSMHjHmUICbsMRNLv60
	 Js2iBtKx1iPcl/6oBouoTODrd9vmePIGcUt8s5TMPK5Rm5QUZ4PtGTMIMt4OiwOMGN3Ze
	 qyQpdM9YfQRuX0w7M5RYYDe+YV141hr1DnPxo99YuTQLHNg06bCEaJficpQAgMZNf3ae6
	 byxeXaKtk6aNN1NS1PhI0isUjt1Vy5H5pME8syLZd1yRsnWpkn5wjigBY6Fwcd8ak7MXJ
	 jVylKCFUo9Hd1+/24j352YT9c5orrIeaimsikA0kvkZKVoTQ5UqHJ/2SQWOx897hjaA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795047182;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=077/TizvhH3iQcetqO0vvepvTnfIkqb5hqSDa7XFIt8=;
	b=aaNmymQI0XodzE5d5+v7E108bTHy/Vk2KS7LlLtZdBmGREkkPIvQr9CKGl2LmCcFjuZH
	 iVCHzSIJFT3BJFHYrQS6dfYIFFJhYa5hQB1hJuaAzz2CY23kuNkfArsOykiJzhx0bTsmU
	 7HsNFAai29TpwNTWU+/299W9eXwPUkTnAlYgdJV1cU3VnyMPnX4Q9cuMpLnfjebcd1jYQ
	 UxoaXwz7DYDzwSgpJ/NGcETR7k9P74sbF31qPT8JfaTlwzd+xZZBBLaBsPCD9xtkdLPPi
	 XFeEsFZZL3qHtPd5BNn5BENFDgFIJW+cZWawTKvWyb1YC9lP9n1UAJIKy3gMD1jWJXQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=EjHXD+uH;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=gUck6dLA;
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6514606A32A
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 00:13:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C6514606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=EjHXD+uH;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=gUck6dLA
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795047179;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=077/TizvhH3iQcetqO0vvepvTnfIkqb5hqSDa7XFIt8=;
	b=EjHXD+uHIPilX0rB0j3Mlz2PJl5Wi/+DfCXmEOtxmu6urupg9yBolQ8etjCxA4Lu+f1RJA
	UnPoNl/XtRiUArG2jVcKflDK+1Z5hzEF1Pduh5IDJ0BymRJwdm4ZSe2v12QFbs5YyQUVYg
	glzbZU2VWYP3jIPfmZOsVF1LyqqNm7E=
Received: from mail-yx1-f71.google.com (mail-yx1-f71.google.com
 [74.125.224.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-118-ZmnjYk_tNNu351jcQc9vdg-1; Wed, 18 Nov 2026 19:12:58 -0500
X-MC-Unique: ZmnjYk_tNNu351jcQc9vdg-1
X-Mimecast-MFC-AGG-ID: ZmnjYk_tNNu351jcQc9vdg_1795047178
Received: by mail-yx1-f71.google.com with SMTP id 956f58d0204a3-67be4f2f42eso2524928d50.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 16:12:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795047178; cv=none;
        d=google.com; s=arc-20260327;
        b=VKcZ2nt4owcnosw8kC2uVTTRqqXjtfWJyQbyoiDz/UElp7aNnpzg3cYS6aVB99k8fH
         ZH8uPUF9FDlSKvLnK9TNQXpqb5kZffxEOuE5rYF5UxfZ/v4ckwf4wXu0IpIs4LZ3tqu1
         yGq5igwMEtWADO7oK/OBE80HQl01n1ajdHP5PPvkGxKOTjbk8PICovl4Eq1L/jngKHyB
         ENHfR/Sw1YZJFYirrHGKaWjnoB0P4zdcW3S6nSbgUTHmIeNixJFNyhC4qPtK6OFjmL04
         DisrM0i2K/IoKQJFLjN735lvVx3HAZiRu/fmo9zk/T8nnrXqa1N3mmEpubEAN3gBLXoI
         MHAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=077/TizvhH3iQcetqO0vvepvTnfIkqb5hqSDa7XFIt8=;
        fh=Upthn1pJOmHU/u0iSlHYs8QYuziqDu6rTNicwYpggco=;
        b=m2DGMlTiKKvM4KOgZTuQ8973jo10K4XWlsdjAWS7tXw/NxzHI2G3oCu7ZjlaCCd9PN
         f50wdgXWz6jUsN8mothdLhyUGiMyyxNzOBuMdbmOOxkJg+vuWY9ytiPiOTV5R4oxn3rz
         mL1l9/+TEcAQl9o0hBkQ0FTPtdcYw96rtuAguW/WAtyihqp6bSAFrPGqXzfo2cjcBTBv
         s3q10r5mGkOl4hZ2TD9SHgKO6m4y37EffUawk9c8re4Bae2eGeCj+NZi0+zWtNoR0id6
         FVWpNVFiPMLhTRiYAdcFMiKSnLjWJ2/8lS9g/L9ghLuVenwjJLB7DKvvDvb0Pu1MFayo
         vC2g==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795047178; x=1795651978; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=077/TizvhH3iQcetqO0vvepvTnfIkqb5hqSDa7XFIt8=;
        b=gUck6dLAwdhYR60Buifwx95UYkvNlKNRmPnyo7USrjas+FkHH6q0XlA8zMbJUAOSEc
         4esQdx6pFabYHTtqUnRAbnqHQA+DgcA1v9Z8q382bLMxM7p546hudO1FBCaRByt15IEm
         /5vyT5BVDmw2cAmmuJOGyhMjBm6Z38q8chTcv+ssHh/G49YDGn4gHaXvGAwNX+jSP5Bt
         Y6dNlXK3huhbk8odG0lKZoxQMQgtT0ra6l6EpuazzBV6saVVp3imwrgtOTJyno51uUmc
         6zZmOUm07V1gdA8XhQX9VKm6Mrqa2q5yZBP+0CYfzheFkQJZm4upXymWAt8SIYWCbdr8
         DWBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795047178; x=1795651978;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=077/TizvhH3iQcetqO0vvepvTnfIkqb5hqSDa7XFIt8=;
        b=sLxVO1jCdzSSHTBdIBW2CrPeERyQF/M7N8xeCNL+fidcEBU6AAACaMIH9pejyPgEO6
         L/svxFFQyWrbncLFx4F3g8Xw8VSt0ndoXs5/1xP7VT9cdX2g6Lg3JpSyNI4lu5uBK7hL
         dYKLAvViILrWgn3d8AxoCT5qc4NIZvWwGYK6et2jdHxpx7yChexX+P0XBD4HuF3npUv4
         5MeccEvLGjsR+hTmDwFhbhqddzjxnyc4Y2sH/ET7rmP5rQLM9tadECsAkq9qI1VY0Rc/
         Q0/U+adUXaHP1R4xOenU8WAxKjj1MK/jGslc9HDo9qk7bLBo3APcXam0Bd/7pnnFUdxt
         0CoA==
X-Forwarded-Encrypted: i=1; AL+hErEydLAdb155CxXRkWD6CFP1r481FA0+KxIxwRTffMbleMkgkaUcHMGjbvy0TrOUHH7ldy8TQVPl4xI=@vger.kernel.org
X-Gm-Message-State: APuU4Z8WS+FFWn7t7b8ZXLaOAIj+u97aB9WqRMvIFRSn3Li6k6WemhNw
	+Jj3pSykH73SbrITPHk4ySmLbUvon92u+qH53e1RV2RSiY2rKs7wAIC5sIp90Ql0wvkOfriDMBa
	4Rl9Q88Sh+LzG+lcnJHsx8X3jOu+GGyQvaggC7di0sLkjlwcOZ9/VKkaSQ+2h3s6ZneQeVqebB1
	VXX3rTcV2qEJXh+wYi4lcGXsNLbucHlu7+kFaw
X-Gm-Gg: AZFdTZekEK0HIAqPcO2QSb7JSw2sbSA8KYVaralXx9tYSMtniNZLUHbYZ7LN2POuSQQ
	OWsOCLpTcS7L7g2DXtXBHqSUb5UT7eWDOSDC6G5PyO4NZBmAKXREVnJVB2Lj119eukhm+YDDzH5
	LLNdEGqzLphlCVhF+N8CEudrMxB5FLz0WXww2Zm5j6vysEenoHl4Hmu2uMClQYLBBlcwo120IQ6
	LI0IPqMjj2B8kOn3rvIb9ByfEMI6Vulwlgo3Zdiu5FH7A==
X-Received: by 2002:a05:690e:1907:b0:67d:b34c:9f19 with SMTP id 956f58d0204a3-67dd3fdcc80mr1565901d50.106.1795047177729;
        Wed, 18 Nov 2026 16:12:57 -0800 (PST)
X-Received: by 2002:a05:690e:1907:b0:67d:b34c:9f19 with SMTP id
 956f58d0204a3-67dd3fdcc80mr1565894d50.106.1795047177150; Wed, 18 Nov 2026
 16:12:57 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116171044.6938-1-jack@suse.cz> <20261118145941.1063127-22-jack@suse.cz>
In-Reply-To: <20261118145941.1063127-22-jack@suse.cz>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 19 Nov 2026 01:12:45 +0100
X-Gm-Features: AclHuK8R-2iEv0c9btS3snfH7Yzq75Yl9vf1mN1FPuSVCWTRM2Ut7aYcwFy-L9Y
Message-ID: <CAHc6FU4+FV=A2UK1oPejHSt5XQ2Ox+CyvZfT4Q17YaceJ+NJ1w@mail.gmail.com>
Subject: Re: [PATCH 09/13] gfs2: Fix dirtiness checks in gfs2_write_inode()
 and evict_linked_inode()
To: Jan Kara <jack@suse.cz>
Cc: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org, gfs2@lists.linux.dev, 
	Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, 
	Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, 
	Carlos Maiolino <cem@kernel.org>, linux-xfs@vger.kernel.org, 
	David Howells <dhowells@redhat.com>, Marc Dionne <marc.dionne@auristor.com>, 
	linux-afs@lists.infradead.org, Miklos Szeredi <miklos@szeredi.hu>, 
	fuse-devel@lists.linux.dev, linux-block@vger.kernel.org, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org, 
	Eric Biggers <ebiggers@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Ja,


thanks for catching this.

On Wed, Nov 18, 2026 at 4:00=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> The checks are bogus because they check against inode->i_flags instead
> of inode->i_state. Use the inode_or_folios_dirty() helper which actually
> checks what was intended.
>
> Fixes: 957a7acd46e6 ("gfs2: Remove inode from ordered write list in gfs2_=
write_inode()")
> Fixes: bd67f17718cc ("gfs2: Fix data loss during inode evict")
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/gfs2/super.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
> index 04bb4cf787d4..9b723dd591a5 100644
> --- a/fs/gfs2/super.c
> +++ b/fs/gfs2/super.c
> @@ -460,7 +460,7 @@ static int gfs2_write_inode(struct inode *inode, stru=
ct writeback_control *wbc)
>                 mark_inode_dirty_sync(inode);
>         else {
>                 spin_lock(&inode->i_lock);
> -               if (!(inode->i_flags & I_DIRTY))
> +               if (!inode_or_folios_dirty(inode))
>                         gfs2_ordered_del_inode(ip);
>                 spin_unlock(&inode->i_lock);
>         }
> @@ -1418,7 +1418,8 @@ static int evict_linked_inode(struct inode *inode, =
struct gfs2_holder *gh)
>         struct address_space *metamapping =3D gfs2_glock2aspace(gl);
>         int ret;
>
> -       if (!(test_bit(GLF_DIRTY, &gl->gl_flags) || inode->i_flags & I_DI=
RTY))
> +       if (!(test_bit(GLF_DIRTY, &gl->gl_flags) ||
> +             inode_or_folios_dirty(inode)))
>                 goto clean;
>
>         /* The inode glock must be held exclusively and be instantiated. =
*/
> --
> 2.53.0
>

Reviewed-by: Andreas Gruenbacher <agruenba@redhat.com>

Andreas

