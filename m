Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.219.43
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795140444;
	b=5QtWy6HtAQf0e+8a8GAIPjxozQ03vJai64yc/e1ivxvDqG/4G2mKcs6g1UpWkQMSp83C
	 uj23j6Qa4mP0w1lQXBc/u4+e1FiIVOsP+eNmd1x4Wml7xv0h64NpaP203LU2ohNC0tQxm
	 CTKKPIi+zucIzVrnNcmSnbHjvb90CSeaiPIaKzeK4EJfc+WEU+1RXxC/uJUc1Dql7tcMa
	 3UDhZ1lBPYQJXZgXq2yj4WtXmf0iunuPjozFZPVmoFmKFgsuNrt05ZIhBo6S84HmUtMKH
	 8EusiFyemR5zUn83JPujfUvpglSKqXNUQNOD8uSkvLCfAlUV/VreKfWJ23AESHVP8vA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795140444;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=hDx+3ef29Cqeb19P1wrP4Jxu4NbJSoAn5O0Zy1TjVKI=;
	b=nUCD5RGbgcFnOwBfwSJsQPpg/SnaoWx4n8wRZoB5nDXFa49oUOrWcXv4GDAX2+02r6Mq
	 4Ut8p3kD0nMYN/EYmeuxoaKid6ur+K90jKRiBDFPq/d21RtMD0dKX1OWdx84Y+tb8Wkoc
	 WtRBLMwUaM7QVMzkQCkNlRz0+yLbV4QdCdOMoeHmSORBJ82W2NBmUgvUNcZtND58AzxYe
	 O3YuhMSaxMbkc0olZ5mDwyMmbBgs8aDXPByb9uGGsXo5OUyPhdNVcy8ie6j+G3G4lamTO
	 Msq3eALFzM6YZi6HH2KAHkc9esdjYL6JRsbR2a8RWDX8EEycn6bVO1dk8jH4AYhco8g==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=zr8fkb5i;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.219.43
Received: from mail-qv1-f43.google.com (mail-qv1-f43.google.com [209.85.219.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B62C606A326
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 02:07:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8B62C606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=zr8fkb5i
Received: by mail-qv1-f43.google.com with SMTP id 6a1803df08f44-91ebf4cd218so2125436d6.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 18:07:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795140442; cv=none;
        d=google.com; s=arc-20260327;
        b=PboGDpGo9ER29EVQJptmIWZQ2h3Srt/N4iuNZvyJVMfhyS1p7FFRjy/+IjnG4fYf7x
         Tbd2FlWkcnkcxtus4uq7ObO0Ui+5+gC0Zz1c0lZ1GtbWz7Hk4EP9G+PE7ZfwSq0sHTOx
         RIVP0S2o2IzVn32azPL70dvsHMgxl5HqvvMHxGShnQpcQNygJJlPFp+sRmQuqzJQKKBE
         xvu+gbBkYvXtQgr3lXgVxv0iDSTdga5kh1eOAuxyge1PpjRu4E6Zmx6MR8YrM1iLkPAf
         jYgnWNGIlc/TThbt1Y17uIKk6dPc1aFnO0iK86m7/OCr8K/k9NENgHtm46IOp84OwCb5
         guLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=hDx+3ef29Cqeb19P1wrP4Jxu4NbJSoAn5O0Zy1TjVKI=;
        fh=crNn2ipWfNW7aJkVJIsMRSU0u1aGLBrcw62DN1F4X5g=;
        b=MUWRFJaEDshWL1wez9hfz8W1ql3l2bl6+zmUzCxpDLjzAy9izmOvosoBLy+9TUJJYi
         uNAx10XcsPc10w9osEVxqtlwEkpgUokQHfcdC8bGPzW/++zLyMb8+s77pyp1a+dvYXqj
         FfpiCilw0k2Z35QO4d7PN8wlpBTh07rHhdn1sCjAY3Sf7hm5WFo5jklUaPHfUDRyXSp1
         MNWnAGBs81s9QmUsWpbdhlD9JtEn1pcX5UzRrePe/O6tAJYjixG18uS3PhDUn6FuEsAt
         2Uozi/xVskPWcn5Jqk56wL4+oVZDvQq4T4K15r17RnqF7BcZdOMH8PlFi71/qRGvu7gz
         qaYA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795140442; x=1795745242; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=hDx+3ef29Cqeb19P1wrP4Jxu4NbJSoAn5O0Zy1TjVKI=;
        b=zr8fkb5iFA5tOJKD9Rew/fwEuZfwcr9/wKTLaYKfTTh0zX5puG9AMdSy4nbvreen8f
         PZF9j8+mXU0kJLn+dFvSPZfAAjrhr9R5xC1v+ezAYo+zc56GgxP4+kr0jG+/VTTeP0jQ
         Mv3mP7HEzX86vYpUnoe5pM2UYL4juFbShSXgY00xGI9B9Ws8044ZhnGF2arKdYoBnTK6
         8OwAANa61uOQv862Ofu4zX6lhsUpr0mE8dhIiUu4fhULv6cY+uiKMiRNC/Cm84Y2BtyP
         N7YT8MgnsWJuRUqTv9Kdni+uEs7w4UnmHzqu1LsUxqqvF+l2TK5kPXphpSb0Iu/6NVSF
         exYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795140442; x=1795745242;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=hDx+3ef29Cqeb19P1wrP4Jxu4NbJSoAn5O0Zy1TjVKI=;
        b=KNWiFm049IU5VmQE+3ppS+rnfeXuj1mJwHb6KJlyF0NyCaWn3RvwLfPa662pV6JZFc
         farqZNCa+xvqyrslcbRRItd6xulgXlFyDIzoOpGwUTPmyM/VUqIN8MOB/4TJJguM3Jhg
         dnLhYnJ5lqmFBAStl8+6uPOpyNL3nlnIBva9ZVY1cgZpAy0vIP9zfykoxpgdZOLZeGbk
         qGzQ/ZfKbGdStXOqoJ+xcvbV5Ru9HIjtYJeg7b5tN7IANjr410efrUaBbhkneTOpJuWZ
         87ORrz/8vM3E/pLvYIH1vLCkhjqhcvwBMnullMtBY0ZD6fZT0kKM4wGa9jx/yS/cQaNU
         pZgQ==
X-Forwarded-Encrypted: i=1; AL+hErF8mudey07pzFCq4ZXfnEt/yw1FXEFhXiB5JlRK7Z00zqw2WvacMv5eEyMBI+zBwdz5nCqBaHlwaDw=@vger.kernel.org
X-Gm-Message-State: APuU4Z+HgAinoincqjKc67NRvQuauTEvt84D2FdvxafZeEt13tHsLwDU
	yYZ3YFkNLFH/RCmsL6oVzIQrjUC1gOzI1gVFLdRJ4CEIP5YRoKdgTZ4fKwQ29apVfSuqxCekvMD
	gwB3xxuurXJ3GJ9ydMcgzfxrluV/U3wg=
X-Gm-Gg: AZFdTZerhiExxyFxZfd/fyBfrBGzXhiHy651aNEPuG0sLhysc8nh19tEH5jfwPwr0UP
	iE+5XYDpPmmVAjYbYAxkvzQ4edVkHWdmAC4hKrZooEb9IZWnyK6fGeletvNqIgHiLQNU/m3d3po
	quF2ikvdpskfvSf2t/WokKORszFpn6f6QQMm0Khok0SPHro14psaRILUIqJ0v+KkXGjlSjQZjVD
	V4TS1ObYxUxVFgqmsf4CVVXgSrbBeyguIA5ZCNSSCjb0EAltt3tMLl5vNyg16mesm89TzlIvHiW
	Y2cOkaYuQwS3y4QWv5+mejoEwcidnoRC/mS8stZFd8YSQNE3kc3W894TyZ8Pgr9G6qCPyRrbg/x
	9KWS0Kb/k/3zq1MR6hXmdcrJedHSYy7T4zrcmGFg7QFl+zrdkajkiocOg8gUUokZx0X6WvmYNCp
	kkxdtSpJHWqPAT5tiRzw==
X-Received: by 2002:a05:6214:8605:b0:91f:808:3ca3 with SMTP id
 6a1803df08f44-9213497c81fmr31805746d6.1.1795140442286; Thu, 19 Nov 2026
 18:07:22 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <CAMcAce-ytH2Xt_0+1fKXzxy+a8fi0Md-4SSoLZ1RQxKQoLq-tw@mail.gmail.com>
 <av9Wm6HQ-DIgFhfw@krava>
In-Reply-To: <av9Wm6HQ-DIgFhfw@krava>
From: Yingke Xiao <inkxiao12@gmail.com>
Date: Thu, 19 Nov 2026 21:07:10 -0500
X-Gm-Features: Aa3M54pd38stwrQ1r38JPH4RJjMwQ2y84tlYNALUI9495C_JMN3Wxjb92Ofc62I
Message-ID: <CAMcAce-LRjmaKoQcsvkU4L+JHWfoGNKx8xFsxiwEADcgQ1m6dA@mail.gmail.com>
Subject: Re: [PATCH bpf v2 1/3] bpf: Replace DECLARE_EVENT_CLASS names in raw_tp_null_args[]
To: Jiri Olsa <olsajiri@gmail.com>
Cc: bpf@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>, anna@kernel.org, 
	linux-nfs@vger.kernel.org, steffen.klassert@secunet.com, 
	herbert@gondor.apana.org.au, ast@kernel.org, daniel@iogearbox.net, 
	andrii@kernel.org, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Thanks for the review and corrections, Jiri.

Dropping patches 2 and 3 as requested.

(Note: Patch 1 [bpf_lsm_release_secctx] was re-submitted as a
standalone v3 and has passed CI.)

Thanks,
Yingke

Jiri Olsa <olsajiri@gmail.com> =E4=BA=8E2026=E5=B9=B411=E6=9C=8819=E6=97=A5=
=E5=91=A8=E5=9B=9B 15:05=E5=86=99=E9=81=93=EF=BC=9A
>
> On Thu, Nov 19, 2026 at 02:18:29AM -0500, Yingke Xiao wrote:
> > btf_ctx_access() strips the "btf_trace_" prefix from attach_btf_id
> > and matches tname with strcmp(tname, raw_tp_null_args[i].func). Because
> > each attachable tracepoint typedef corresponds to a DEFINE_EVENT() name
> > rather than its DECLARE_EVENT_CLASS() template, three existing entries
> > in raw_tp_null_args[] never match any program:
> >
> >   1. "nfs4_inode_callback_event" and "nfs4_inode_stateid_callback_event=
"
> >      are DECLARE_EVENT_CLASS templates in fs/nfs/nfs4trace.h whose
> >      DEFINE_EVENT instances are nfs4_cb_getattr (:1455) and
> >      nfs4_cb_recall (:1518). fs/nfs/callback_proc.c:50,106 pass literal
> >      NULL for arg 2 (const struct inode *inode), and TP_fast_assign
> >      (:1424, :1481) checks !IS_ERR_OR_NULL(inode). Keeping 0x200
> >      (0x2ULL << (2 * 4)) sets ptr_err_raw_tp =3D true so btf_ctx_access=
()
> >      assigns SCALAR_VALUE to ctx[2], rejecting any pointer dereference
> >      even under if (inode) and matching existing raw_tp_null_args[]
> >      0x2-nibble convention (0x300 yields the identical SCALAR_VALUE).
> >
> >   2. "iptfs_ingress_postq_event" is the DECLARE_EVENT_CLASS template in
> >      net/xfrm/trace_iptfs.h:108 whose DEFINE_EVENT instances (:130-148)
> >      are iptfs_first_dequeue, iptfs_first_fragmenting,
> >      iptfs_first_final_fragment, and iptfs_first_toobig.
> >      net/xfrm/xfrm_iptfs.c:2025 and :2051 pass literal NULL for arg 3
> >      (struct iphdr *iph), requiring mask 0x1000 (PTR_MAYBE_NULL).
> >
> > Replace these dead template names with their DEFINE_EVENT tracepoints.
> > Verified in QEMU on x86_64 7.4.0-rc3 (iptfs_first_{fragmenting,
> > final_fragment} and nfs4_cb_{getattr,recall} flip from LOADED to
> > REJECTED) and 6.12.118 (nfs4_cb_{getattr,recall} flip from LOADED to
> > REJECTED; iptfs_first_* absent in 6.12).
> >
> > Fixes: c83e2d970bae ("bpf: Add tracepoints with null-able arguments")
> > Cc: stable@vger.kernel.org # 6.12+ (nfs4_cb_*)
> > Signed-off-by: Yingke Xiao <inkxiao12@gmail.com>
> > ---
> > v1 -> v2:
> >   - Correct sender identity and Signed-off-by with real legal name per =
DCO.
> >   - Remove drafting notes.
> >   - No functional code changes.
> >
> >  kernel/bpf/btf.c | 11 +++++++----
> >  1 file changed, 7 insertions(+), 4 deletions(-)
> >
>
> patch is mangled/broken, can't apply it (check Documentation/process/emai=
l-clients.rst)
>
> > diff --git a/kernel/bpf/btf.c b/kernel/bpf/btf.c
> > index a123456..b234567 100644
> > --- a/kernel/bpf/btf.c
> > +++ b/kernel/bpf/btf.c
> > @@ -6605,10 +6605,13 @@ static const struct bpf_raw_tp_null_args
> > raw_tp_null_args[] =3D {
> >   { "bcache_journal_entry_close", 0x20 },
> >   { "bch2_journal_entry_close", 0x20 },
> >   { "fsnotify_bump_event_seq", 0x20 },
> > - { "nfs4_inode_callback_event", 0x200 },
> > - { "nfs4_inode_stateid_callback_event", 0x200 },
> > + { "nfs4_cb_getattr", 0x200 },
> > + { "nfs4_cb_recall", 0x200 },
>
> seems correct
>
> >   { "nilfs2_transaction_entry", 0x4 },
> > - { "iptfs_ingress_postq_event", 0x1000 },
> > + { "iptfs_first_dequeue", 0x1000 },
> > + { "iptfs_first_fragmenting", 0x1000 },
> > + { "iptfs_first_final_fragment", 0x1000 },
> > + { "iptfs_first_toobig", 0x1000 },
>
> llm says:
>
>   =E2=96=8E Only iptfs_first_fragmenting and iptfs_first_final_fragment p=
ass NULL
>   =E2=96=8E for iph (net/xfrm/xfrm_iptfs.c:2024, :2050). iptfs_first_dequ=
eue and
>   =E2=96=8E iptfs_first_toobig always pass ip_hdr(skb). Since the old cla=
ss entry
>   =E2=96=8E never matched, adding those two would start rejecting existin=
g
>   =E2=96=8E programs that use iph without a NULL check, even though it ca=
n't be
>   =E2=96=8E NULL there. Should we add only the two NULL-passing events?
>
> jirka
>
> >  };
> >
> >  static bool is_raw_tp_null_arg(const struct bpf_raw_tp_null_args *entr=
y,
> > --
> > 2.43.0
> >
