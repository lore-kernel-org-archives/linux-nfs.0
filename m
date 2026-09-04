Received: from mail-ed1-f46.google.com (mail-ed1-f46.google.com [209.85.208.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 684BF374730
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 19:04:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.46
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788548682; cv=pass; b=qHVU+TZJnnkvcsmRNUKuVFkkioEvTGTLfo671CUxQnYqhZpyp+c2ciwIXX3cqbDfhQHsv6hGMZrjkyQA2MVJni/+9ip5F8HrDYvUvBzbN1icaW+eJMMMgTg18hBGP+BfUoyl/6iZY1iXCPcB/VDluKYvSA/+L6d9SB034zUQ7UA=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788548682; c=relaxed/simple;
	bh=fY51Nm7//N8CrgPPDWq6X/4KvqN+2A5oq4YO4LZ3kWk=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=qOZ7sxapdTMnQpzKQ/oTjHVEkWmlqZHSHnTOUlwkJlgd62AQzxPd934PU/NnIhuTs3LwweDeXkxnKtQbLMZGX3jcgTXLPB7w2OtENk7aq/44OTWFXuaKsXI+zLq7XxIMyCMC/Qn4zBzKX4EbOsxukUdIJeGS+ooLDh6UYp719FI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=W6PKVYQ3; arc=pass smtp.client-ip=209.85.208.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W6PKVYQ3"
Received: by mail-ed1-f46.google.com with SMTP id 4fb4d7f45d1cf-6a60f0dbeccso1970624a12.0
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 12:04:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1788548672; cv=none;
        d=google.com; s=arc-20260327;
        b=CTxnmO/2wI13Yz3Finc4SDEX7f13U6y6GsW2Qea+Np6PHh8vnIsuB7Jky2RvWVeKdL
         CiGvUp8qatWXV8poYiioL2f+gM1/TQtaj4tpvVOXCFhqoU0xFJqyckCp+8LDcdecbpIH
         D1v8Ed98ISOusGCA/h5M63z16lzikwiyCPo9mkhaBqc14sJegjjBoa/hwgIY+U0ijIHo
         MwnSsz1WsFAnMyTjyVDNamdaUPJ7zkdvd7rsC0bsKRG/QbCX9A2W6t+coogyevLrXfge
         /Alv8SxYsHQbQ6W64TcwDdeo81TiGxVAfEVk5So8bSkS0Ht32A984GWApe8fEy/lDXUT
         FIJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=8WIXDXXIb5GWVAPPT449/WXotAVKzuJdLxiT/W06EUM=;
        fh=gWqxWQJNmEpqG2r5KmNN0wU/qbTRJxGrSl77oInTDKI=;
        b=EWZMkp/d4JdcFqmSmFwiTLL4XawlS9MqzpJRN94B7jHPKPHt9wWKVUfJz9ysHVLuaR
         NT+hkY4PLREwgS6pv9ydBaq1wF0F/CiGR2Ix3K/TF3GVgSm9WH0W7v4UST2kySyaSFxU
         uJcEE0Bu+Ek1VWEo2nAVfbnLK7tL+HSpBwHjfLL3JlTplp+sIa3hKpGKuw9XXEHxKbD7
         6jU8IerGmwHxK8eRE5Py6K9XCV1SgyaPKeSqsaxC8r2+OB51K+1g3pglz1MyQrTdDy+d
         Wk3OQT9euQ+b4np+K59BuUBMs1Pft4tSYegHBRx1KS7nCFZgOwBRNpVQtKOBCSxaAMvP
         kqsw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788548672; x=1789153472; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=8WIXDXXIb5GWVAPPT449/WXotAVKzuJdLxiT/W06EUM=;
        b=W6PKVYQ36W3D9fJi0d/XNUwh6wf14R6gXncMEa3rfNZ2uq7aWmKrlOojqg8EBXgPNX
         OkWioHRkOrsYKGAEDKYC0ugYfE+gz/wxWzSbellZBZk4nFIRZMLjQdazN5xVxUh35OeP
         Ysu4A6SAjXSey0BkQS6GlLRYmBUjvU+iWrzwZXIX4ES4IaJhFrqrYWGE1uegM+ig14fB
         k5jDRMqh7olDBO04tAhR9XtCvX93dUZqDds3yLuj74P3GZbZUy3W9S/9S3NbWLZOEcCj
         4BM8egQEtQiRScJqVG3q3dbH3PqhD2buW+dnLhGF3zaQOlt81ZtbXgNFhQoIkQZBAt1r
         qyWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788548672; x=1789153472;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=8WIXDXXIb5GWVAPPT449/WXotAVKzuJdLxiT/W06EUM=;
        b=c7FOrkDgM42mO26847J1E4pPZTNcUWogK+WRVHhnrBCKYJLpjLkMz5IyECSvayk73G
         Cqt2VNNI5VQDB4fkL9CS+trNrhXjzAcb5UwcaAqo4HyTnszra0Eg2R0M4F6sX+jGHera
         LB2ssI9NoHnoEQnzRXULJLJXnXVklALUBjQUFfB+a0/TvNrkkiAxfb0qpb91ocQOMStC
         xheID2G9o22ZDvoBa7esCKikeyFnNCdew+4FVSv3KWqliQdZn4oliytamN8iOvvgaWsp
         VFqSnG3G7M527mYx4vJKPw8VaidbRlxbOjqFeOBn4p17RE3sgp0hUauieAciezH2IZka
         2zZw==
X-Forwarded-Encrypted: i=1; AKwUvBx9GdOuFOB8dN19Btd1pW3b4pqxPl4b2P5Fuv8vfU4s2RChWa8pTK+xRjCIMtc4RlhvWiko4UbJFzY=@vger.kernel.org
X-Gm-Message-State: AFuF++lRbIEaDXPE3I+0isD4eaiFTQlwNg2wvBTK920f997MEYpBE6y3
	/m9+bRujUiFTaTC0zl96v40QyouaMsbI+/xaj3eGDMJjNNyrY+whQTy5Y3v5tRSlrSUwm+fAs8p
	giZHnfwJNRlGit0YLP5IIfrrDpdM6Tv+c
X-Gm-Gg: AYBFou12f34TfS8v6QA+89uCTE8p6jdRl1LOm9e7ip+iPU7QD73P12SzdhoA4eTDyWe
	IHDTEiXfanBVVLK/Jt89dYSzPMLA7M0ubp9CM0z7U1E763usCbqiYyyKJfevRu9CWq9AQWqcsO4
	Gw98k1No59XlpkEMqNz1JqPmxT7yZ3qH+UrTNBZD0kBKiFNkqY+EW/7ejZ4X3WcgUJle/zITbsE
	8W+SK2RpL+HR5C3cS1z80WoAqXMdj2AiAFxp9LIjVmYhvJikOahBoGaV4YW6jXEzE2EqQPlKgmT
	YjtGvLEBV1Fom8oSHGn4JcTLCSdLMzuGDt6cwGiEALoJTtt4sZekaIt2NpMtbLwjNQBI4TlUWUp
	5wawjVJptPfM=
X-Received: by 2002:a05:6402:4607:b0:6a7:f6ea:2858 with SMTP id
 4fb4d7f45d1cf-6a7f6ea38fdmr111175a12.9.1788548672271; Fri, 04 Sep 2026
 12:04:32 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260904-pnfs-ff-v1-1-5f502cf25401@kernel.org>
In-Reply-To: <20260904-pnfs-ff-v1-1-5f502cf25401@kernel.org>
From: Rick Macklem <rick.macklem@gmail.com>
Date: Fri, 4 Sep 2026 12:04:18 -0700
X-Gm-Features: AcwNN1V2wDjSC17yCpg7eSOGKcXz3tfvatnp3nZxtq7bt_YHqBfzxNWlSSrFAsw
Message-ID: <CAM5tNy7Yjk=mm9rq9YUuYF6LEd2v2tp3p3unDxgEv8xU4oXO0Q@mail.gmail.com>
Subject: Re: [PATCH] nfsd: don't offer flexfiles layouts when NFSv3 isn't
 being served
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Tom Haynes <thomas.haynes@hammerspace.com>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Benji Wiebe <itsme@benjiwiebe.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 4, 2026 at 9:50=E2=80=AFAM Jeff Layton <jlayton@kernel.org> wro=
te:
>
> The flexfiles layout driver hands out a deviceinfo that names this server
> as an NFSv3 DS (flexfilelayout.c hardcodes da->version =3D 3). With v3
> disabled, the client can't talk to the DS: it loops on v3 NULL calls that
> the server answers with PROG_MISMATCH, and I/O hangs in D state.
>
> Skip LAYOUT_FLEX_FILES in nfsd4_setup_layout_type() unless v3 is enabled.
>
> Reported-by: Benji Wiebe <itsme@benjiwiebe.com>
> Closes: https://lore.kernel.org/linux-nfs/c734eeb8-8486-4491-bb4d-b9656cb=
affbe@app.fastmail.com/
> Fixes: 9b9960a0ca47 ("nfsd: Add a super simple flex file server")
> Assisted-by: LLM
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/nfs4layouts.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index 22bcb6d09f70..cef4d40c89a2 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -127,10 +127,12 @@ nfsd4_set_deviceid(struct nfsd4_deviceid *id, const=
 struct svc_fh *fhp,
>
>  void nfsd4_setup_layout_type(struct svc_export *exp)
>  {
> +       struct nfsd_net *nn =3D net_generic(exp->cd->net, nfsd_net_id);
>         struct super_block *sb =3D exp->ex_path.mnt->mnt_sb;
>         expfs_block_layouts_t block_supported =3D exportfs_layouts_suppor=
ted(sb);
>
> -       if (IS_ENABLED(CONFIG_NFSD_FLEXFILELAYOUT))
> +       if (IS_ENABLED(CONFIG_NFSD_FLEXFILELAYOUT) &&
> +           nfsd_vers(nn, 3, NFSD_TEST))
>                 exp->ex_layout_types |=3D 1 << LAYOUT_FLEX_FILES;
>         if (IS_ENABLED(CONFIG_NFSD_BLOCKLAYOUT) &&
>             (block_supported & EXPFS_BLOCK_IN_BAND_ID))
Although most ffv1 servers use NFSv3 DSs, it is possible for an ffv1
layout to specify NFSv4.

rick
ps: I don't know how you'd check to see if the layout will be an
      NFSv3 one. (If the server only does NFSv3 layouts, then I'd
      guess this patch is ok?)

>
> ---
> base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
> change-id: 20260904-pnfs-ff-485ac21042a6
>
> Best regards,
> --
> Jeff Layton <jlayton@kernel.org>
>
>
