Received: from mail-ed1-f52.google.com (mail-ed1-f52.google.com [209.85.208.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C130444A3E8
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 15:39:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.52
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787586000; cv=pass; b=RvZIVGfE/N/bM5RU1fWQ5gJrK4Tr8W6Kb5M1U86eiVMZKc4tuYCfEHq2gr3k7oo+WVovAIQt5KCWRL978SZUKr6PP3Oe/rSZCL1ikLB36PwiLolz6sdobdWbHF9FvSHCv0XqFcSmCNeerRZLmDHU89Yxap1w+Xz/yatRHeRML8M=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787586000; c=relaxed/simple;
	bh=TKa+7Rt0HMct/L3Y9OQKcWqR+kqwOl5wJxjs0oMkUU4=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=OWxr0g7aPnJa7eStHAvJVJmXoX1jwIdWYC8zVH+O/xjPLVTybRaeymtiL8RpwbKGmUv2+taB8xeeW2qvqvwBymnDGy+wPh1bUPmbax9Qb+H78/rxbFkiKLeFV5S9n6NgBkLNSrITlGtTLKw4irMzpI5zSxd7ekaJwU+v7RXtPow=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=W3PgV/+u; arc=pass smtp.client-ip=209.85.208.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W3PgV/+u"
Received: by mail-ed1-f52.google.com with SMTP id 4fb4d7f45d1cf-6a17cb94b26so6893280a12.3
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 08:39:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787585997; cv=none;
        d=google.com; s=arc-20260327;
        b=eeMXcfh24GZssyr5GQ58GYV2BqC7Q82W1LsDT9A3UZtBG6KhYXjb7FqBNNA+PaEohU
         MWBzNfzz2Fq+eV9rlm3HNUs9ibqByKLDijzLkmU9hMXAvjbPkyhhYOavZ/Z4DfGZTVxf
         91zG4worLiWJzms8IDB5fXnE9XZUpHRJ2dQ69NyxrWz8bEX1CPZaHyz7mm20iIVd3OoG
         YI3fdcqP+aQZb11GGX5hiu/k1eNP4xivx4knxvloK1yAWAyPwac2ZkFSqotisxGhTnrj
         cKK5hvxkcCNFKml/0+sCI7vwSzdBFlNkGwWGtuxc7Gmpf8ImzaEXqEuSPiNlO9mG3Jm/
         0xig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=wJCHcWH/H7HoSqeQAsfWyCv2ylIhs9AEwOmpHAgZ6Mo=;
        fh=j8ECeZhRcibOr4S/W+mQJQ/Yl3CYEobL9AGWCO6Ppwk=;
        b=pijTOwf5slYVF/Q0JPpKGRr8nWhQrjq0X93pTJrmjVdJfkWMG7M3h7GHQMgoZBtrTF
         cQ8x9MIZs0ivLk+YIcjv9hbINLu+Yw9YbjGWcow39lXlPfpA1cnODdjKOwSwyExWswch
         lo2PhQ8QWrs+r04PsOiL3PAP0NJXSnF6Ohp+kT673vYJZ4EzUF2nLihs8bS6NUVgkEkW
         opj3JQBa6ZwXExfCJ0rBBquKljpt9XrgECvjh820f/6/vYXSNdcvx+pZRUH4Qsd1Ialx
         /ZOQ7ejv79tZLld5pKpblKolZk2aaH+2zPhgBOK7QiBKg0+MdBDchInNafWgnkJ2eBs7
         rwoQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787585997; x=1788190797; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=wJCHcWH/H7HoSqeQAsfWyCv2ylIhs9AEwOmpHAgZ6Mo=;
        b=W3PgV/+uOfQUz8pF76YCRrs84UlPEQPXY6HtwG0yI1HdTUh2ba/YB+1YJpUAS8XdXn
         Nx3XJL9Oc00PyQABJxkNHFOgjCSoI/xWe345bzxJ/b+/kz+4kSbygw7HCiQgxjGaaY4w
         sghmbsvrUQl3pnPyXdGdA9OZQnrQ3Opb24oUwzcYrUtP9FEkKTZuwypkY5AjwFbFS7XO
         yXa9rXb/qmJZWLA0UVIlNsn2+ODVi/ShtKx/zqYe1EQzakHcxF5auvyTFihZJF/CcTTj
         7uN/TKfLsHjfnw2WMoiN/6eXZExCjtCWKoYymHKhPSIbWZYRwFyYcpRQTDjzw//We5Rb
         2vuw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787585997; x=1788190797;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=wJCHcWH/H7HoSqeQAsfWyCv2ylIhs9AEwOmpHAgZ6Mo=;
        b=peff5wWKxm+qy9UfeWMcqJkCBoGHjqgElbELwnSMVOoNNSLo9mLoFTU65A7tumf9iC
         2HubpUu6qJ4NwxKw9LMg6fhVkYQ3I3kcCKv6K7ckc7O/l+oUGvjeesBj4gbJF5l2rh+s
         HOcE0Ax6P6Ms/2ZiTyHN2HzZp1whUK5ByYZ5XO2lcZq4rVg7hkxVEB819hFRbinVEuVa
         jcbiQsf6GKMft55Hgl0iYmsKTka5FPw1T8H/lyBduo2JBEPOGZftX953PxRPYhuiZ0Cc
         +x+7oTcS6VcfaZSiu0WYKXtYaMAzRkKYMO/GtTYFfOLD9LbOakedznZre0UdSlQf5e/4
         Qk9g==
X-Forwarded-Encrypted: i=1; AHgh+Roo2CGTEdCXkqHBQiOchAl7OJ8I6YwoVD8iEF+p3uMsmlrWTVhYVQBFozPQCaxIKy4e45eS+7lKCpM=@vger.kernel.org
X-Gm-Message-State: AFuF++l9uZ6GwToZPEyZecL+2RWv4dbATTcLyt1dEIQzYEg6GkfFb1aT
	H8kjS+c/pb+JRAnakpLf11BQX/UVAUjIR588aBQRBRCD7pNPgywfsfyPPp8uE68W4+uRypGaSfq
	KEsA76Qx4VY5308vluLtqA55YtkfhlFM=
X-Gm-Gg: AR+sD11HSDQP8ks6Ja75is9TkpN/aFpc9cYK0gEtsK+XMRk76yDaWsmQu8gwf0BxS7E
	ran4VVRB8QXn/YJBJxtub24IZ3/r9Wl1q/3TR8xp3RmUN0Qb8j3r3ocaE1CEPXOX8Jswn2QHos0
	qK2XnebLS/mSYoWIjLP4BW2iwuMEoAQ44apPOCoEH2JXRL2UGFzdx8Cl75AoRnSjjg9MtwI47Bh
	Z+yECjxFWkoy3jdqpHj78vGFJgbPww33J2s3Frcrn5xz6pCCmjl/gZ3y5Qz/TFWVZCXPZh4gfO/
	mOiqc3T9hhS4MnDbV9xdnpcgoQISIhh1jzYwxEt0kPybyn4HiCwzfg3vZxQHCcsrgB2C8c84kJX
	b
X-Received: by 2002:a05:6402:1ecb:b0:6a0:dda3:83db with SMTP id
 4fb4d7f45d1cf-6a42eec0421mr29612154a12.0.1787585996720; Mon, 24 Aug 2026
 08:39:56 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260824144130.759997-1-dhowells@redhat.com> <20260824144130.759997-31-dhowells@redhat.com>
In-Reply-To: <20260824144130.759997-31-dhowells@redhat.com>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Mon, 24 Aug 2026 17:39:20 +0200
X-Gm-Features: AcwNN1UVhOm3jvQyZ6QNY0YG-DuDugP0zSGCGTU-9BV_0e1-yGju4sTdJrlUq5g
Message-ID: <CA+1jF5qPZUhCevwbu7zQDEVWss6gMdoDMhqKqH3k7v=WStRtEA@mail.gmail.com>
Subject: READ_PLUS in NetFS? Re: [PATCH v10 30/35] netfs: Simplify read abandonment
To: David Howells <dhowells@redhat.com>
Cc: Paulo Alcantara <pc@manguebit.org>, Christian Brauner <christian@brauner.io>, 
	Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@kernel.dk>, 
	Leon Romanovsky <leon@kernel.org>, Namjae Jeon <linkinjeon@kernel.org>, 
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>, Marc Dionne <marc.dionne@auristor.com>, 
	Stefan Metzmacher <metze@samba.org>, Eric Van Hensbergen <ericvh@kernel.org>, 
	Dominique Martinet <asmadeus@codewreck.org>, Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev, 
	linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>, ceph-devel@vger.kernel.org, 
	v9fs@lists.linux.dev, linux-erofs@lists.ozlabs.org, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 24, 2026 at 5:04=E2=80=AFPM David Howells <dhowells@redhat.com>=
 wrote:
>
> Currently, if one or more of the subrequests in a read request fails, the
> read collection algorithm will attempt to salvage folios that are fully
> downloaded but that span multiple subreqs, provided all of the contributo=
ry
> subreqs succeeded, but this makes the algorithm quite complicated as a
> subreq can contribute to multiple folios and a folio can be contributed t=
o
> by multiple subreqs.
>
> Simplify this by just abandoning the rest of a read request once a
> permanently failed subreq is hit.  This is what read_folio, DIO/unbuffere=
d
> read, gap filling, RMW and write preload all need to do; readahead is the
> odd one out as it doesn't have any return other than unlocking folios.
>
> With this change, even for readahead, the rest of the read is simply
> abandoned; read() and suchlike will call ->read_folio() on each
> non-uptodate folio to retry and retrieve the error.
>
> Note that retryable failures still get retried by netfslib as part of the
> request as before.

What about READ_PLUS, i.e. sparse file reads? If you do this kind of
work of handling partial abandonment, can such a work also benefit
READ_PLUS?

Aur=C3=A9lien
--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
