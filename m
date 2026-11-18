Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.129.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795044957;
	b=wvnGMWwpAUoDtWitUDRiQUjWhCvamDqh2lGaQgmp5emMNXILmvZiA/F0VCMa7uTjfISI
	 QF0+tFpyyrtXyHJfVrYeKZClJ6TNgeCr+diRDjbkP+O34KVvtrxy6Q8wEmYAvYALpwUE4
	 sC3riLi7fzaeqBXpj4qTiVbJCbp5GQDmMg7wn05PCbQIbESUKgq6RAhRPpOKR/2jL0l7r
	 DKjmXIZYlp43Lb0f6fZ7vUGgcHe8vxzOE9AZKbhIs08wKX7yOywkyI7U3VWUp4KlOISLC
	 olzGsegxcVBceAQTVwG99ekaPVLqBS+/B9xKX4E498d7xYTIYM2ika9Agfs0Qj/++IQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795044957;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=1sqaAoxbPYdo18ldNOsiM1TbcJ03Gv+SVlc5ayXI+nY=;
	b=uIdALrp+Ugqk/EBtmr/tVSwCOow7YXaOdMoXpjx8VX/Fm1SxPpXR3pbwl27YE5d+KbdD
	 l4n6d6lKWwKlQ0TB2CRcNYHjD6R1uQ9nKT9wr6GkPT4PJHIqlk4EvursF2WsAEW/76qFe
	 xkjzwrgltzcVPXLS6IM5G5X2ktwE0adTvkm4nlnSLGCt7nsFwiz8kXoa9mhHOzoWMyQfW
	 unhmJ8kqTsPs/gz1WEIbNHZQvjgjt662hMpJ4mXivHUrFt5xFvHRQk+TzTSYAJqb9OfQm
	 YnwHD28T2lVLXbZeopkCOdhGtcLBi2DF283O4JDrQgrJOUqIEMC9yeI/9kbOa6kPfEg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=OeZtfPG5;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=VV4lacCc;
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BDBC5606A330
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 23:35:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BDBC5606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=OeZtfPG5;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=VV4lacCc
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795044955;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=1sqaAoxbPYdo18ldNOsiM1TbcJ03Gv+SVlc5ayXI+nY=;
	b=OeZtfPG50Fjqj40s6Sj+6Did4ufEl3tVHRxceE+mdWNbGwx7fNYk44K7y6G04p78xFCD/R
	1kv1BumxCx310EyVnA8d4SqhUasQR7TMJCm7IYNKBrDLFc8ygMd69JH4NPy4EA0UV5oaOI
	oaiqNL+fbnuAUb7jfi3vcX/vMHMt/3w=
Received: from mail-yx1-f72.google.com (mail-yx1-f72.google.com
 [74.125.224.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-7-6ZgDLzdsOwm8FqvJKGAZgQ-1; Wed, 18 Nov 2026 23:35:54 +0000
X-MC-Unique: 6ZgDLzdsOwm8FqvJKGAZgQ-1
X-Mimecast-MFC-AGG-ID: 6ZgDLzdsOwm8FqvJKGAZgQ_1795044954
Received: by mail-yx1-f72.google.com with SMTP id 956f58d0204a3-6755fef4f96so2608495d50.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 15:35:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795044954; cv=none;
        d=google.com; s=arc-20260327;
        b=IKTuSFkHwyyYwRAgZ6d6onj6CLX0OL7Pp3MmYyq9hgmlcyqNiPb1Kn6Yvvp2JdXsxG
         g1U1N0yF7gwu6N0kv2a1hH2luOMyuhVqbDV/3TW3FBNAduZ4+cjy7XlLs+o2q7xOgIx3
         k6+R5SlLS2VmXfxW7Gn3c/snjWdpQWZ4WgX1eUrQOqTLox+cmPcpZe932gMQreM4iAmP
         I22hf+qSV2SglaNkMCZEpU7O4qJPfroIdn2WSihCmw92CGKr+aazwnNePguD7nmqWHBb
         Bh2fxbWSR4806MoMrQC5VJJ3z+F8qw6Z07qeOXKsa/yjZdJ9gwWp8Eh8LI6vhIshb6BE
         YzHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=1sqaAoxbPYdo18ldNOsiM1TbcJ03Gv+SVlc5ayXI+nY=;
        fh=pzH5/KY3DFXrT1wL46CkeLy/0c240xsGPKY6fgxaer0=;
        b=m/0aqSI/JetJ+bUhmSpMNQ0DGB6iVM4Gt7RmDnmr7IDgsaRTuD4fRpugFKn20E2ke6
         gUnOSW5ZenBp7EalMqxksIa0VdWO3qBE6EvqpsaYwgEP9Qas5LYeitkXIZPOU0Is+4qI
         kCzfEwzcZ98fk7f3r17zBf2lEcIBzzxwHdQ14y7rswwrznpsjp867NeQeXyNfmWnHyow
         NQEu2m5WJ91xQyQ3zCyVPtvuG4uvfNTTyfh6IezgYIrXB1WP9+S3OqERH3QcAKUJCQZb
         8Sh7Exrlf/fiM3RWZ0Bwvg+uuA3kKd7ZiJf0j52MQm1wwlceyhuKJrgB3KISPHwF/bs0
         1byg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795044954; x=1795649754; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=1sqaAoxbPYdo18ldNOsiM1TbcJ03Gv+SVlc5ayXI+nY=;
        b=VV4lacCcYXl3jx6oU1yk7ocsmoMzxU9SP0AoOrXpBHytOyD+5/iloPPuTFDwHot85c
         i1CuguwIDMKYkYwOifW2jU2ON3pcwrl2ze+1M1zXcGvzpEjssC/9u8BP5GrnFxyulUg4
         m3kl+sBRcRdHC6cSbeJi+MrV0kK8R6nXJ+1+w101Ltg7NsQzens8JvDyW07HuceLJ6GS
         rA+E2+jV1u9T1OR/mFRBlrYQhI5+p4bfkvpqrJOCTWbtpDO3YyPi5JSYd2/v8scOcjke
         d/uPzbLWNdLsBIgq0z3OZKLiCCq8cx+Fg79vmPk4t0z6mQMU/UeaNF5w+hvK8lTtE+Iw
         eTvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795044954; x=1795649754;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=1sqaAoxbPYdo18ldNOsiM1TbcJ03Gv+SVlc5ayXI+nY=;
        b=XeR6PpHQGoE21uXK1gLuCRPapRwQYArT2m4DtVGIsSeDcMeDv+mL+H6TlT8ow5ijTx
         4pb7beaH3onbZcNwRk2eb/StICot/rM5xfzgSsyTYzz5v6M424gE3IoVfaTq+tf9Ql5P
         Zn2NxCSfXsezXIhK/pqvs/hS92c6oW7xpJvtqwizMeXlsA8U2uQXl+bLVvfn1/KtlIKU
         dihASuZGlGNcC3o17cT6Dd6PsBmz9jtBdJT/jpyvEf8nlGLv9hRDavhUQ0mn3jK5qc8R
         ZBrkJiQnFbUB4ZqzBMgkr6jTqOI2BQTfMwVwPW6PagF2VPAejih85jXomEsn/QXVbC7n
         c1gg==
X-Forwarded-Encrypted: i=1; AL+hErF4Fq2kwHsaOBuXY0oW2+92Vcp5f+O6ECmKJqT2SQCdeWXBbt6UGpk1+rR4brZ6fpp/F782b2bXJBs=@vger.kernel.org
X-Gm-Message-State: APuU4Z8xp9vns7VN6ai9iPfpTj2KRMs6bFGV94UUbGT40ohoyatAKVUz
	35BZ7Z4nZte8nQYt7lIg8VlN/Mc4YdrOjmFMWiYIC/O1M6fYHxHvz+xyopT/yknSNInna4++WWs
	wKi2nea/J7pjZO4wHP3J6N53DovjnGxPC6w6C5segWNhokzbByAtQYencR//lmTOPRvsZIm10UY
	C88sIoeeYhGqTBxCtOfmD6Pn6riUXXVVeR+Fux
X-Gm-Gg: AZFdTZcaCGuzDiSaRm/OQ7ZZx0PMQ6h2WAcH3VyzBK9qGqSBcNtxsozaC9MtFFnBAR2
	/uGNxbunof4G1Q1FLUPsMoZlvEVE14CLGJ9neZLpbAWt8cWe/IWd+cNsTlnK3jq8QD6weepHGtK
	EzcrTewK0Y89T0A5DMINhRUN84e0hqC1d2HsFkypTshPvWdRp5XBXVU8dxr2iv3Z5DjsIuj3AWT
	qcK3pMwxhznoLc/jLsf3wbyGfJW2WBLKmFZnSRIeExn0Q==
X-Received: by 2002:a05:690e:128a:b0:679:2a90:d3ad with SMTP id 956f58d0204a3-67dd403bf8cmr1618050d50.102.1795044953799;
        Wed, 18 Nov 2026 15:35:53 -0800 (PST)
X-Received: by 2002:a05:690e:128a:b0:679:2a90:d3ad with SMTP id
 956f58d0204a3-67dd403bf8cmr1618023d50.102.1795044953295; Wed, 18 Nov 2026
 15:35:53 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116171044.6938-1-jack@suse.cz> <20261118145941.1063127-19-jack@suse.cz>
In-Reply-To: <20261118145941.1063127-19-jack@suse.cz>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 19 Nov 2026 00:35:42 +0100
X-Gm-Features: AclHuK9zTsUN7zuq72-DSL1ny4jnrrzy1tFjBUU4DEu6A9maK7lyiUQZqwV6vuE
Message-ID: <CAHc6FU7NoZua98SGP9Kuga58gAcco6X__u=kOPfsUqbefAKLFQ@mail.gmail.com>
Subject: Re: [PATCH 06/13] gfs2: Avoid racy dirtiness check in gfs2_fsync()
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

Hi Jan,

On Wed, Nov 18, 2026 at 4:00=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> Check for I_DIRTY_PAGES state in gfs2_fsync() is racy because
> __writeback_single_inode() unconditionally clears the flag and
> reinstates it only later based on PAGECACHE_TAG_DIRTY tag. If
> gfs2_fsync() unlocked read of i_state hits in between, it will not see
> I_DIRTY_PAGES although there may be dirty folios in the mapping. Check
> for PAGECACHE_TAG_DIRTY instead and use inode_is_dirty() helper for
> inode metadata dirtiness check.
>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/gfs2/file.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
>
> diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
> index 1efd0679badd..f5532f72ab99 100644
> --- a/fs/gfs2/file.c
> +++ b/fs/gfs2/file.c
> @@ -749,7 +749,7 @@ static int gfs2_fsync(struct file *file, loff_t start=
, loff_t end,
>  {
>         struct address_space *mapping =3D file->f_mapping;
>         struct inode *inode =3D mapping->host;
> -       int sync_state =3D inode_state_read_once(inode) & I_DIRTY;
> +       bool dirty_data =3D mapping_tagged(inode->i_mapping, PAGECACHE_TA=
G_DIRTY);
>         struct gfs2_glock *gl =3D gfs2_inode_glock(inode);
>         struct gfs2_inode *ip =3D GFS2_I(inode);
>         int ret =3D 0, ret1 =3D 0;
> @@ -760,12 +760,8 @@ static int gfs2_fsync(struct file *file, loff_t star=
t, loff_t end,
>                         return ret1;
>         }
>
> -       if (!gfs2_is_jdata(ip))
> -               sync_state &=3D ~I_DIRTY_PAGES;
> -       if (datasync)
> -               sync_state &=3D ~I_DIRTY_SYNC;
> -
> -       if (sync_state) {
> +       if (inode_is_dirty(inode, datasync) ||
> +           (gfs2_is_jdata(ip) && dirty_data)) {

this adds back the I_DIRTY_TIME check explicitly removed in commit:

3aac630b5ce1 ("gfs2: don't worry about I_DIRTY_TIME in gfs2_fsync()")

Could you please clarify what's going on?

>                 ret =3D sync_inode_metadata(inode, 1);
>                 if (ret)
>                         return ret;
> --
> 2.53.0
>

Thanks,
Andreas

