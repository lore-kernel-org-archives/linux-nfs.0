Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795090693;
	b=24ncxs2JVIKCOFS2yquuWe+p5es+YoYs2DeyEAoo7Kgo0N/VKq/uSgUcWRV093zavR0I
	 o+u3LWfbsosbZynXAahvshIO3+db3KyKIXaOJvq6Akq8j/jXV3d6XLL67Vi9+//ZQ+Tmy
	 asutVRM1Gi/VqQUQAUGGs1jLa381gxN2XlckxJU0kJBzXcJ6d3aWXhXOtsvB3zn9hmeP8
	 V3UQrS2JzjYE5XNx+9Nf+UHdZTRxI/GSVC/7YG526B0f9C4Qnhv0NrKlOnYWFnJreV520
	 Mna3n/Sr7f+93vlOYG5ayKIiOlYO+6O0In1tIM67X3q5Lyl0zBFwPKX26PGfgW8COmA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795090693;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=gqZVLpTgCP2ySw8awFBFsKWriU/az/ZtPImm1nmYhzQ=;
	b=xQFMIGjdHKqpBW/W9KCw+WZJs8LDsw8jdNsQ2N67jCZAmLuDCXCA5y8Iop4QsnNhmbyw
	 3XUWKqVQQ/Z64Go1u/O6LTjPu6fAnqJ8zqfNLSaZYTRMx3Y/e7g36OBncyG8pApoAf/oZ
	 s+WIprwb3E6fnGrNQACRYrwLnozEcsx1plYshe3SRUfaWpPkMZg2+jMkNWe4WqA6UpSNM
	 Eg3/GEcUXbr7BA+kmskx7+V5y4KFeEvjHamPuKQY8b1Mn86FAnsxCNDP/FoP+OEGuIg0q
	 1Sp/C/982XTWTAGNtlJumTNtrXwAOMGSDWXkqkRC8W0pDOwoLnTYMPosLkPkXuyo9JA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=VVOWvP24;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=W8hMqnqB;
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20166606A32F
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 12:18:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 20166606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=VVOWvP24;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=W8hMqnqB
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795090691;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=gqZVLpTgCP2ySw8awFBFsKWriU/az/ZtPImm1nmYhzQ=;
	b=VVOWvP249gQbGhATtzKUMg0j6A/tChNgM6jO1Wzx/AIp5s1eeCFdIDmMi18SOLWYhJ7m9Q
	rNIwphULxYcsY2zcibeAN2PgqHM5Qtp28R//iOmuShffADY/CVLIqnSe3r7UUPwPkLmGtC
	V+TK597djrbR/oLLHzUarUCTnIB8KPE=
Received: from mail-yx1-f70.google.com (mail-yx1-f70.google.com
 [74.125.224.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-346-d-oiMjYTPAiKzzcgeWWPcg-1; Thu, 19 Nov 2026 07:18:09 -0500
X-MC-Unique: d-oiMjYTPAiKzzcgeWWPcg-1
X-Mimecast-MFC-AGG-ID: d-oiMjYTPAiKzzcgeWWPcg_1795090689
Received: by mail-yx1-f70.google.com with SMTP id 956f58d0204a3-67994567a44so2821091d50.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 04:18:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795090689; cv=none;
        d=google.com; s=arc-20260327;
        b=nTELgtVRchju5Auq1t4HtV28KP79X35+M/of50+dvYVC29bRbga46X5t+YmL2etSvy
         pBVGPEWDkS8XSmOarlCIvExxx8SX2grfqZRHJATw4kn782m2fBf8ANgC1E9v2IedwXUR
         w5io7Vegb8IEciJWm00fcKGgE3Hlf2qorOK4yBLKdYNPvOT6abjnZcT1bZ/NkI6RjqH/
         O8aRxmFx/ju4fOHA14dhNJ8fAmXShytqYN+sd8KDZRK0E80+2jLJbtpvzs+5KrRigN02
         iSuikn+3NmlCR/5R26uxos9JnA3ejc21rYH6YSP4Fm1GOURATZl+kPwJ9Z0AAW7q0VBF
         2HZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=gqZVLpTgCP2ySw8awFBFsKWriU/az/ZtPImm1nmYhzQ=;
        fh=FYLOBfY30eJUAGByEDWn/WQ73mVq38Ss2lS0OcKrt/c=;
        b=Bw4tBSQflXCffz03MJYQPONs7r1mn4metajCK06/u6h9JvZzloeUL52d7GGdr7JKlU
         eikTQ0yMQF8KtwltHCLiUoX3WdQcP7RuGlc/rO2w0iZEvLn9KkfYo9cmcZpomjZYyZ8+
         Xt3RlcltQ48YZjjyjsUKRQHjhkeTYADqpK3RIt180dOe5SnpmhMnWDilpvw9tXvfPZyS
         yNgpg7Wh4NpoJYniluJS3hct37/2u2IVsgtNemst0uVljykYg7ItFnCxXkZD2v+opugE
         y7TNo5EdKQXLBOQ7xCuR3dYrlprovBxxC/WgIc3SWLEkN8oT1hxWSWh+fs+tzizeVOfL
         o0EQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795090689; x=1795695489; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=gqZVLpTgCP2ySw8awFBFsKWriU/az/ZtPImm1nmYhzQ=;
        b=W8hMqnqBRGair6EoKrRvZxO77dqdj+YfYgkTq7D/3LAyjuaoOoDi6CBjJj2/uTyIN/
         fDpxDop4wdBIhC4E/qClwWzfxDsRKlC+fQO3UGaRGo+wxRGTZreAoLQjwFDN+CvKuSdK
         Xfn4nra5rpcDvAioHGKENKEPM3Q9kGHAhtzrGoyfmonoJyWGpgd9XJyQO6Ah/a7T2Ppn
         zsB9YEoDNUbUZ+k9HrlxOWcwAWQDOlDoV3XTlJHvYLtC3OS9sGUDCz3KiS2aQ5OT+IOK
         ip3K9h84fcgxMAozSavkACkeLTUU+AZnecsWcPbDZVD/GsrbNUaLtT+6HgqlfHiMchXd
         tWww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795090689; x=1795695489;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gqZVLpTgCP2ySw8awFBFsKWriU/az/ZtPImm1nmYhzQ=;
        b=rtftA4i9mVBGZSAaUJrGwhZnNjdtrTAEZgt5WQ877dFgMZ5CYXqg5RjDKQHH/iTYLn
         BNKEg2dIGLFXjn/FWUvohMlta6EDPsV41T9Q+qFohPXXWw88dyAHNHObdtHzShUNEsz7
         9FqvxSZoGObjmKKSM6K+vFR9RRfw+Ps7kGTU6u8rpctvs6tVCOXq46xKFa7VWoJd70yT
         EuqoaTU+WAL41z+svHzPBpYPIK6UgDGyX2i1o0eYwICYYkHz9gfsisTQOiRKSKNEchku
         fT5SK2m8W5b/sp1yIMRqYSwzo1T6FPXahhjVU9w1Kl+JegEpx45Z93V0b02jeezz9+/4
         G4tQ==
X-Forwarded-Encrypted: i=1; AL+hErEYoM9m+Q3Un+weHQIWjXJjcVf7UgipSoA4W8R/iGmacX4FMve6uir9lZjqdUxStwk3fAvegUz2+NI=@vger.kernel.org
X-Gm-Message-State: APuU4Z8ZmlTt2gJr/KK0reENgMxH6cLz8OE/fEjfYuy+caFSd1VnmvGa
	Y4P34mTmXjPNLPEfbc332Y0iOmR1XlQzRv0r4Cu6G0CT7RU86x7yq3cOix7wHH6eYhDyHwBkMg/
	+2Y8ecSHBHhT9vLeoAqx2tH0bbMyqN3BnQUtJWYI+gWrXrjO0pQou56cgIvWwUxQbgX9WJoU6Wu
	q+7JSv0JMk7NlgHrHWrbcbsPtzagSd4/lzTuXK
X-Gm-Gg: AZFdTZeEmS+e2VhyyafnKKK4Bdx7/ZJhz2a9g0XZwRXm/S+XJ28GEGBwz3D0IpTO0i7
	k4l5O9WkIx4wqLx3S+xGINyKmFYK+9ZKhGGATSVzJlqMdPiHQjD4KM5TmufqSBbfdKmurna0SE3
	gtj2w0uNjROSwFdILzMsBgtbfIbx9TMH3pGeJ09FRxAuWXQdjFB4eJyA4cfu5GINyrDmkyYoeID
	/4sGKDQldJSphFV4FA0LTKHhewjYOI2W8pELm6oh1WaAw==
X-Received: by 2002:a05:690e:806:10b0:67d:a6fb:ceaa with SMTP id 956f58d0204a3-67dd3f193f3mr1716882d50.19.1795090688852;
        Thu, 19 Nov 2026 04:18:08 -0800 (PST)
X-Received: by 2002:a05:690e:806:10b0:67d:a6fb:ceaa with SMTP id
 956f58d0204a3-67dd3f193f3mr1716866d50.19.1795090688232; Thu, 19 Nov 2026
 04:18:08 -0800 (PST)
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
 <CAHc6FU7NoZua98SGP9Kuga58gAcco6X__u=kOPfsUqbefAKLFQ@mail.gmail.com> <wo5723b7wrmu35q5qffzs7zzqwnojk3ireel2jkit2kxgv6bra@yd3gbigdmmdk>
In-Reply-To: <wo5723b7wrmu35q5qffzs7zzqwnojk3ireel2jkit2kxgv6bra@yd3gbigdmmdk>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 19 Nov 2026 13:17:57 +0100
X-Gm-Features: AclHuK-GbM7XVFxqU3dJAQePNml2N4MUSkkmDt3mktzVCdVYt3Td22WOXOu6yXM
Message-ID: <CAHc6FU5HY9x5ntTOz_xk36T0XTzjNc8R4jy2zzpQKo=19HNMog@mail.gmail.com>
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

On Thu, Nov 19, 2026 at 1:05=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> On Thu 19-11-26 00:35:42, Andreas Gruenbacher wrote:
> > On Wed, Nov 18, 2026 at 4:00=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> > > Check for I_DIRTY_PAGES state in gfs2_fsync() is racy because
> > > __writeback_single_inode() unconditionally clears the flag and
> > > reinstates it only later based on PAGECACHE_TAG_DIRTY tag. If
> > > gfs2_fsync() unlocked read of i_state hits in between, it will not se=
e
> > > I_DIRTY_PAGES although there may be dirty folios in the mapping. Chec=
k
> > > for PAGECACHE_TAG_DIRTY instead and use inode_is_dirty() helper for
> > > inode metadata dirtiness check.
> > >
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> ...
> > > @@ -760,12 +760,8 @@ static int gfs2_fsync(struct file *file, loff_t =
start, loff_t end,
> > >                         return ret1;
> > >         }
> > >
> > > -       if (!gfs2_is_jdata(ip))
> > > -               sync_state &=3D ~I_DIRTY_PAGES;
> > > -       if (datasync)
> > > -               sync_state &=3D ~I_DIRTY_SYNC;
> > > -
> > > -       if (sync_state) {
> > > +       if (inode_is_dirty(inode, datasync) ||
> > > +           (gfs2_is_jdata(ip) && dirty_data)) {
> >
> > this adds back the I_DIRTY_TIME check explicitly removed in commit:
> >
> > 3aac630b5ce1 ("gfs2: don't worry about I_DIRTY_TIME in gfs2_fsync()")
> >
> > Could you please clarify what's going on?
>
> I wonder how you remember this after five years :). Anyway, the truth is =
I
> forgot fsync path is calling sync_lazytime() as well before calling into
> ->fsync and even if I remembered that, then it would be fragile for the
> helper to rely on that (and there are already users of inode_is_dirty() a=
nd
> inode_or_mapping_dirty() which want it). So to summarize you are correct
> that the added I_DIRTY_TIME check is unnecessary for gfs2_fsync() as it
> should never trigger just for that but it is also harmless and the helper
> is more robust that way.

Alright. Could you please include that in the commit message?

Reviewed-by: Andreas Gruenbacher <agruenba@redhat.com>

Thanks,
Andreas

