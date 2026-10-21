Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792560657;
	b=gR0DTRscX9EZsZaRE1w6yuOXnwpU1ohmP1PS4E/nE4CPNKPytkhloGbCmIZ7pAifajgr
	 /xTdE7vLqhgGcsLiKhDxE8cg4CWBW6euNppDZvdN1mcHizq6xgrlwkQTZyqWF51GuHt+q
	 Ijr166QLq9+tUR1gdCbzPz680fkvRynCXNX/TKoe9ON+PVjBdxmm4AG7uJ4kykiS/fcC9
	 O9dQ2ouzVMZLt5vmvoS/5u8Nri+MiUW47vcR7X4nq8FiV48/E/pcdYt3QdeEjF0XVXjGS
	 2MJxwB+M3UApaOJ0JeJL2wsZzbFqZgDjZoe9+SsZs4OE0BLKfVYxed43TpgJhbY2g2Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792560657;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Message-ID:In-Reply-To:References:Date:
	 MIME-Version:Content-Type;
	bh=wOxW4z1BbQYP9uEvGV85h66bQb0xJWZvNtv4eVINyQQ=;
	b=kOWyrOBujrmtzX5cQVQaUggdJu6kD4u3KP73g+WUSJJ/yJ5NfxgeHZEf+U2+blUoxjMZ
	 5sLpsoZHr8I1nQzbFD7EojvNkv/CVxtB8Nma7sLM79y001dVQYV5QYkJZSu4dbt5jXVyo
	 KUV79HQrvtzU1FvxTfbrYNrn6UfJhYB4j0wiLvdcsGkS1kQo8CnndpYFn9q01hY2Ajd0U
	 A8RqVbMI8b8SqQaUH7rRJTChIMDOz8O+9yuTJjCwL86o2HmTA0iXZVYyFx/oAfzD3He5l
	 wypDibI0/AchqrY+9z09JkxzIi3lJ3wJryyik6L4jqUnSmmbAFBYxOfM4AMaaYWLmvg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=innovatrics.com;
	spf=pass smtp.mailfrom=innovatrics.com;
	dkim=pass header.d=innovatrics.com header.i=@innovatrics.com header.a=rsa-sha256 header.s=google header.b=dZG9+Qrb;
	arc=none smtp.remote-ip=209.85.128.47
Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E40E9606A323
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 05:30:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E40E9606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=innovatrics.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=innovatrics.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=innovatrics.com header.i=@innovatrics.com header.a=rsa-sha256 header.s=google header.b=dZG9+Qrb
Received: by mail-wm1-f47.google.com with SMTP id 5b1f17b1804b1-4a16aaf2067so3148195e9.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 22:30:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=innovatrics.com; s=google; t=1792560650; x=1793165450; darn=vger.kernel.org;
        h=content-type:mime-version:date:references:in-reply-to:message-id
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=wOxW4z1BbQYP9uEvGV85h66bQb0xJWZvNtv4eVINyQQ=;
        b=dZG9+Qrbq6r8virMQzN/ZnScSqFL9UpktW2+0+n3rDobwVeYO2vFRf/TLLKIVXBmhF
         Gy8RLB4EpeJSlAY8DjkXHht8NBPQbM5e5fFurkIdO9DfEYRLT1UnIUiVHv5USugAATTU
         SMpXa/vr/CV4YYNC5DI0uYI78q0K+X5Fj4Q/g=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792560650; x=1793165450;
        h=content-type:mime-version:date:references:in-reply-to:message-id
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=wOxW4z1BbQYP9uEvGV85h66bQb0xJWZvNtv4eVINyQQ=;
        b=vF0uYbJIDP3yDyklKxiHOCQ1uZ7kubaqZOO3lHSbWBGduSMCW86hjW5fyyUZL7HBr+
         isjj4VYL3u9h4KCaQ2YBd9BTmIDJ3Q7mjDYpAE4dJbEETyjCzbrrQnFKoq5sgow1FYxK
         +nV7k3rMddgK0K9dFYYbLIwEioszJceKl4j0a2TZOplG6GmB7hYNBiWZ4jjFJXv/k/Lf
         3PcSsKQLK+bYI9E+MIfyc/yU0XP/mF7tVoZTZtfwOfNY1t84RBUJWrHXxC6urK2hKuCB
         w7b58SCIwjrVG0YMDU4TFqanZVfHQLtxPcXIDEf8PxH8+3aB6OBZuG/Vu9wu498UBdgq
         2gfw==
X-Forwarded-Encrypted: i=1; AKwUvBwcajTfYwIPtkM63nRl4XF7cnut4AHrZSv1gaFEf1fvXoJEuE39kXx6u2j6nU7zjfrE+eJD1RKZOCI=@vger.kernel.org
X-Gm-Message-State: AFq9FYKaQYntQ9+mNdTYiTgb0uMD+0iq9E3ulZuAwTRwZhrsiYYOYp+x
	PATR8EKvC5Tg33c7a51eGUs5+mGoE7EE2IW0QFBjTxlYvDxLtUbVhWJjk+DuALWgkg==
X-Gm-Gg: AYBFou2fVp2DSy1uAbjYoebhKpY/9i44mHr7thXYss3yS+ODxtpAWXm25YZAHeX15Qr
	LUKoNisH2923MbhzgQ3tpPDiDv0BXqyLqx5S3j/XmjDKC1QcHXYj0lfaBb3RalszUuDRZJQ+XtX
	128kSzucPjNLSG9yjJOTGZdJONGOM+fl5c42EXKgT4GZXBH5Ae9Wbu3cYq0Mom2OOXypN9LThfo
	wOR1aik4kU/zYpmHDsTSf5lHjL61sXNPiMSSdV6Vft5K22OXgemrdAOeaANB4ADBhxJgwnZMM1i
	aCZk7m3s0F8bFyyxjb50ymIjylhKMZOQTy55mN8YO4umm37G6ZboGYyw1Oz48Yb3QBHy1PAkG2M
	z6p0MC70j1iBeeBDagViWaihoEm/j6CoHImrV5kn5wz9XrCCgfsONT31GrlYJ8mAqi8RB9Gg1ZA
	qGs0fKSt/ZiNsrWjaT0oH/DdHqPi7467I0WL6VstRhpRnLrPz2A4ghYUoLYo3BcBsl7b3G+0dkF
	5sLOHnKsOuMsc6200uQSOFo9abxJvN9dxz3F7FFc21gzNasEV/chSaxT8+lNF+SWCp6iOlFOTRA
	lVv703hRtPlh+BuYdl3crlzgo+TWXz/sk20mw/SwVH7N9m5hLHAIlZ3fYzvn3RYXDPlcLcPJJBA
	fpnQw2iltvw68
X-Received: by 2002:a05:600c:4686:b0:4a0:b6:4619 with SMTP id 5b1f17b1804b1-4a1fd72e1e6mr17106685e9.0.1792560650270;
        Tue, 20 Oct 2026 22:30:50 -0700 (PDT)
Received: from [10.11.72.5] (bip-static-148.213-81-147.telecom.sk. [213.81.147.148])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a1f8016c93sm85779985e9.5.2026.10.20.22.30.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 22:30:49 -0700 (PDT)
From: Petr Chmelar <petr.chmelar@innovatrics.com>
To: David Howells <dhowells@redhat.com>
Cc: Christian Brauner <christian@brauner.io>,
    Paulo Alcantara <pc@manguebit.org>,
    Matthew Wilcox <willy@infradead.org>,
    Namjae Jeon <linkinjeon@kernel.org>,
    Marc Dionne <marc.dionne@auristor.com>,
    Stefan Metzmacher <metze@samba.org>,
    Eric Van Hensbergen <ericvh@kernel.org>,
    Dominique Martinet <asmadeus@codewreck.org>,
    Ilya Dryomov <idryomov@gmail.com>,
    netfs@lists.linux.dev,
    linux-afs@lists.infradead.org,
    linux-cifs@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    ceph-devel@vger.kernel.org,
    v9fs@lists.linux.dev,
    linux-fsdevel@vger.kernel.org,
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH v12 4/5] cachefiles: Don't rely on backing fs storage map
 for most use cases
Message-ID: <20261021.cachefiles-mainline-confirmed.pchmelar@innovatrics.com>
In-Reply-To: <2648476.1792482342@warthog.procyon.org.uk>
References: <20260910220242.2165023-1-dhowells@redhat.com>
 <20260910220242.2165023-5-dhowells@redhat.com>
 <20261011.cachefiles-partial-zeros.pchmelar@innovatrics.com>
 <1655268.1791878098@warthog.procyon.org.uk>
 <20261013.cachefiles-partial-zeros-trace.pchmelar@innovatrics.com>
 <1995693.1791971125@warthog.procyon.org.uk>
 <2648476.1792482342@warthog.procyon.org.uk>
Date: Wed, 21 Oct 2026 05:30:48 +0000
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"

David Howells <dhowells@redhat.com> wrote:

> Note that these patches are now upstream with this change incorporated.

Thanks, David, and sorry for the slow reply to your question about
the fix - I was on vacation.

I've now tested mainline (72a16bcff2) with the same reproducers as in
my earlier mail, and it fixes the problem.  All 4096 blocks read back
correctly on both full reads, and the reads were served from the
cache:

 - 9p, cache=fscache: 0 wrong blocks (936 on 13e340e397).
 - NFSv4.2 loopback with fsc: 0 wrong blocks (817 on 9f8b64f66),
   also after a server-side rewrite of half the file and after
   truncating and regrowing it through the mount.

Thanks again for the quick fix.

Petr
