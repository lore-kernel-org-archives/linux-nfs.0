Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795118752;
	b=GcAHYwxUDauTA6ArSfmKLnxKAuCfutIEQBmCRwrv+fh5i7XpNg1YEdK3U9J8wUDlNllv
	 YqNwOFAA/H++cfOgCNASXoxLJfBniyIf5exfL4VC5t0+eFxMZto0nUf2SPOSIzFnKi1X2
	 rOGn183hIhrYScN1kG1nunzNQIJRCTAm/qsbg6aMEtHOBVNbmqUJRI2xoPXPIYjKrGHSc
	 F11tmcA4mlzrM2c1RkUq6bqHuWytRvc+SFZCrD/kKAR789zfPj8K2ElGo2QWqyQDBidQg
	 rGUVWCEqmEJmVssq4gedEuAaboLGERD1d/PX6IltkOuXjEKuRFKZeKpnUKE9i+P5nQA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795118752;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:Date:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To;
	bh=VEkqpd2RoxZ9GRJkgcd4TxF/KKNHXP8mBeFHzci9J80=;
	b=VKFRxre2Rjz9QzbSlna4H2QDB/lT7IB1YpO8R8gWAOfKER6pqCMUEx3LnSx+ENljRhc/
	 Rrpr/iDghjRwv0qqIHvxvC1TEkKrqgIHPsECvE1ewARR+e0wornNu+NscqBR1xLn0CKZm
	 mnoXM44N4As3Xgq7Z6becR0Z/5uE4kUlUrpl2Djjfrz2PecHMC4vXnK81pNiZCsK1TMVK
	 MY9zriNw3JmU76KNOMVxlYntPSpDRAOnHgijyW8G1WG74Vy4sNa52e0u+07/iQ8O2z/na
	 Oa2QACf70EGsbfDCP/wtfgWn+MI6FzCxJvHpMs+r8WmvrDcmINemgMGGcmMYhGnxOMw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=U8kap+ui;
	arc=none smtp.remote-ip=209.85.128.42
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9ACDF606A32C
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 20:05:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9ACDF606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=U8kap+ui
Received: by mail-wm1-f42.google.com with SMTP id 5b1f17b1804b1-4a2d6d01ecbso733655e9.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 12:05:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795118750; x=1795723550; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:date
         :from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=VEkqpd2RoxZ9GRJkgcd4TxF/KKNHXP8mBeFHzci9J80=;
        b=U8kap+uiMZ33ZZ7fx3ualzidBqymKwK1L+aYTWKFPrQdqccOtZLLGbr5/LBFP6Ry83
         7Y93SNsln6Fbf+K8GJHPn8iYNAK8PAbHPbrZkhp3bbpPul7MXXJNjDuEVyL0s7Xdm9KB
         ugPt9d6PP/fSws8kfJLYG3bZtDhSD+aFVZ7t6e4C1XvkRKD962qnZeQEJo36cqsBkZBx
         QaWqBC5VHKG/iDQWqlOgIXeb+4SsDudqOTBkYTqqJV9IkCf02pnu+xW1b1Mte4OO1qfQ
         +OzXdUMRH31yEHgOBDXoiu/H57ArVbXCbnNv58mZE9PQKYtD8lS/VBC0aNTSWRCn8pUl
         pGsg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795118750; x=1795723550;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:date
         :from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=VEkqpd2RoxZ9GRJkgcd4TxF/KKNHXP8mBeFHzci9J80=;
        b=OYXYcBCeFUJ+2E95CrPJFhysC6UKBMWdSLk52SDt3Tg82sq8Nk+zs9BU0yEcVl/oFM
         z3Lz4nVMPPg3qkv6szM/zvjIpBG7CvplmV5mP5BzXz166uLLjnTfv0XBmDpketOydLUM
         Z4Alvz8q20d8fyG8isoXY4IOEZMAe0frNFc8bhgosqrFTHvmEd9FLzyoNgUf6g7ZjT7L
         q/ib4oZIqmhoWg8oRH812m6URw4yG6e24VyoR4mMo5aW1KOlCj5wBxmfGptpCe9XTj+n
         hB/TKnrJgibodQTO5dgUhQOPPXKoaqcdrj0xCMhYAb3fXxB6mshJtGnUDC0v+ATCeJFb
         3tLw==
X-Forwarded-Encrypted: i=1; AL+hErGLI95bGIvoVEpBojeSW1nawtmspsNA7u8liRoHPD3yht4BQF1MyWYsWZorFX5ZqkKeQEmv3Qxg+e0=@vger.kernel.org
X-Gm-Message-State: APuU4Z9qM69UFXeNahnN0K7g5JRiKGVl9smzzbYQInOOPjstTFEwFbLx
	41gc1Ew14dQK2ylbN8V+fpJ7X/3H5cirs36RH9DpT5Umbowp6cboipUV
X-Gm-Gg: AYBFou2YVqtS2daTNEyrWPR2FQ1wovVfT6YiR2gXEt5INSvGrNQi7m3IBOGB1EKIiYG
	6zayaenQWeI1AaK4H+gHDu0opwW2MX70cku3lMLB2r7hWjrqbhJeIe4iQEufNYIP98xxeRW9Ffe
	6cZ6YrWzOf1hMXk1hrtvuR43OoR+WM8ctNppa8IATjeBorVCc/tJrmkjWFibA+YbtOodq7PM2HA
	mo5NhcrsqSzjFnaGoeb9YGkOtEeOMEr7M4LESSSttZaMJ0/OPA03aqN4BGaeEuVsMslt7jzI977
	drVT8fr2Ys1O5H6Pnc0pdc6o7SNjhJV/EQv2CLAUkxx/vINystWoBQbg94Ro5MtpL/cx/jE/SO/
	fQMMnkVM2iW2+w8U4ybybTgZ1gSi1/FqoeZp75wPV2gQ1gZhO0XsS40NfNAWsk8o7jFjY8k2dKp
	F7HTedQ8xaFhf9bRgaBYpau8zR9s0I6eTkekelBrwo7mokAvhbTjL8uYbplr76UBBBFWKCqzSN3
	MVwJRdBjGFJoEAErdIYwwBdx5RudoT2WrzA2NKT+oMv995fUSLOu645Aw5uTfaHenFw+VFVC7EK
	/5OHChEl3RAMOB6S
X-Received: by 2002:a05:600c:3f0a:b0:4a5:75d2:c104 with SMTP id 5b1f17b1804b1-4bb8880cde7mr12400535e9.22.1795118749858;
        Thu, 19 Nov 2026 12:05:49 -0800 (PST)
Received: from krava ([176.74.159.170])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb8849e598sm20190405e9.8.2026.11.19.12.05.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 12:05:49 -0800 (PST)
From: Jiri Olsa <olsajiri@gmail.com>
X-Google-Original-From: Jiri Olsa <jolsa@kernel.org>
Date: Thu, 19 Nov 2026 21:05:47 +0100
To: Yingke Xiao <inkxiao12@gmail.com>
Cc: bpf@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
	anna@kernel.org, linux-nfs@vger.kernel.org,
	steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	ast@kernel.org, daniel@iogearbox.net, andrii@kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH bpf v2 1/3] bpf: Replace DECLARE_EVENT_CLASS names in
 raw_tp_null_args[]
Message-ID: <av9Wm6HQ-DIgFhfw@krava>
References: <CAMcAce-ytH2Xt_0+1fKXzxy+a8fi0Md-4SSoLZ1RQxKQoLq-tw@mail.gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMcAce-ytH2Xt_0+1fKXzxy+a8fi0Md-4SSoLZ1RQxKQoLq-tw@mail.gmail.com>

On Thu, Nov 19, 2026 at 02:18:29AM -0500, Yingke Xiao wrote:
> btf_ctx_access() strips the "btf_trace_" prefix from attach_btf_id
> and matches tname with strcmp(tname, raw_tp_null_args[i].func). Because
> each attachable tracepoint typedef corresponds to a DEFINE_EVENT() name
> rather than its DECLARE_EVENT_CLASS() template, three existing entries
> in raw_tp_null_args[] never match any program:
> 
>   1. "nfs4_inode_callback_event" and "nfs4_inode_stateid_callback_event"
>      are DECLARE_EVENT_CLASS templates in fs/nfs/nfs4trace.h whose
>      DEFINE_EVENT instances are nfs4_cb_getattr (:1455) and
>      nfs4_cb_recall (:1518). fs/nfs/callback_proc.c:50,106 pass literal
>      NULL for arg 2 (const struct inode *inode), and TP_fast_assign
>      (:1424, :1481) checks !IS_ERR_OR_NULL(inode). Keeping 0x200
>      (0x2ULL << (2 * 4)) sets ptr_err_raw_tp = true so btf_ctx_access()
>      assigns SCALAR_VALUE to ctx[2], rejecting any pointer dereference
>      even under if (inode) and matching existing raw_tp_null_args[]
>      0x2-nibble convention (0x300 yields the identical SCALAR_VALUE).
> 
>   2. "iptfs_ingress_postq_event" is the DECLARE_EVENT_CLASS template in
>      net/xfrm/trace_iptfs.h:108 whose DEFINE_EVENT instances (:130-148)
>      are iptfs_first_dequeue, iptfs_first_fragmenting,
>      iptfs_first_final_fragment, and iptfs_first_toobig.
>      net/xfrm/xfrm_iptfs.c:2025 and :2051 pass literal NULL for arg 3
>      (struct iphdr *iph), requiring mask 0x1000 (PTR_MAYBE_NULL).
> 
> Replace these dead template names with their DEFINE_EVENT tracepoints.
> Verified in QEMU on x86_64 7.4.0-rc3 (iptfs_first_{fragmenting,
> final_fragment} and nfs4_cb_{getattr,recall} flip from LOADED to
> REJECTED) and 6.12.118 (nfs4_cb_{getattr,recall} flip from LOADED to
> REJECTED; iptfs_first_* absent in 6.12).
> 
> Fixes: c83e2d970bae ("bpf: Add tracepoints with null-able arguments")
> Cc: stable@vger.kernel.org # 6.12+ (nfs4_cb_*)
> Signed-off-by: Yingke Xiao <inkxiao12@gmail.com>
> ---
> v1 -> v2:
>   - Correct sender identity and Signed-off-by with real legal name per DCO.
>   - Remove drafting notes.
>   - No functional code changes.
> 
>  kernel/bpf/btf.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 

patch is mangled/broken, can't apply it (check Documentation/process/email-clients.rst)

> diff --git a/kernel/bpf/btf.c b/kernel/bpf/btf.c
> index a123456..b234567 100644
> --- a/kernel/bpf/btf.c
> +++ b/kernel/bpf/btf.c
> @@ -6605,10 +6605,13 @@ static const struct bpf_raw_tp_null_args
> raw_tp_null_args[] = {
>   { "bcache_journal_entry_close", 0x20 },
>   { "bch2_journal_entry_close", 0x20 },
>   { "fsnotify_bump_event_seq", 0x20 },
> - { "nfs4_inode_callback_event", 0x200 },
> - { "nfs4_inode_stateid_callback_event", 0x200 },
> + { "nfs4_cb_getattr", 0x200 },
> + { "nfs4_cb_recall", 0x200 },

seems correct

>   { "nilfs2_transaction_entry", 0x4 },
> - { "iptfs_ingress_postq_event", 0x1000 },
> + { "iptfs_first_dequeue", 0x1000 },
> + { "iptfs_first_fragmenting", 0x1000 },
> + { "iptfs_first_final_fragment", 0x1000 },
> + { "iptfs_first_toobig", 0x1000 },

llm says:

  ▎ Only iptfs_first_fragmenting and iptfs_first_final_fragment pass NULL
  ▎ for iph (net/xfrm/xfrm_iptfs.c:2024, :2050). iptfs_first_dequeue and
  ▎ iptfs_first_toobig always pass ip_hdr(skb). Since the old class entry
  ▎ never matched, adding those two would start rejecting existing
  ▎ programs that use iph without a NULL check, even though it can't be
  ▎ NULL there. Should we add only the two NULL-passing events?

jirka

>  };
> 
>  static bool is_raw_tp_null_arg(const struct bpf_raw_tp_null_args *entry,
> -- 
> 2.43.0
> 
