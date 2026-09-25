Received: from mail-pj2-f13.google.com (mail-pj2-f13.google.com [74.125.227.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25CB53DC85B
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2026 17:07:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.227.141
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790356056; cv=pass; b=oHL/KVYhykm1tkr1dD+U26J5Jb8V8qxLuu6272bUh6Cph3Ic6cPtPwx/hZOzv0YQLUr7H4w0e0QDnVZ6s3HPFQc55eHmNgWegq3fY1UZNh9dzrbAnz9H+beiZha9ENaqM4K9vlVGF0nrcAJuaRAHercVwt1BX9EP3VLw2XXI/SE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790356056; c=relaxed/simple;
	bh=Z/QlDjEqmTsvd8hmVsRhjPJAPZKduCsAshcn9SEcHsU=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=WSqAq1YzJOwhK9jI1NMFXeh+09KGnHeupi0JBfgokPtEpS2OWR0ViVaet8eUiRWSK4vDmBoydngZVvRcMPLHfVpuNZNhxMVwMmtdeRhAOOfA/HTvbopT3o5Gu4kwgJj+ses6UBx/Dw8XHudCk9FQp/+o1G8I8s8FkcQ6oDgIhlY=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com; spf=pass smtp.mailfrom=paul-moore.com; dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b=JQ7vBslB; arc=pass smtp.client-ip=74.125.227.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b="JQ7vBslB"
Received: by mail-pj2-f13.google.com with SMTP id d9443c01a7336-2d747f05ffdso5082735ad.1
        for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2026 10:07:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790356042; cv=none;
        d=google.com; s=arc-20260327;
        b=OCNpgE0dORD/zR8I16zXQrBdVvWSntVmszVA6DPUxbyY8W0IK7los3RSeHYhSeLzPC
         FRaJ7zfokny4m489LlNqn37jNpKXjsUfcYEDY4geik1SvqNK+wSX/YY3PGRjqoeVoA4c
         R1V6fWY3TL53OtIrtugIMMawmfq+yzyy0XoH8QF5wmGSKTK/8HYBENQ1C3gCqykdhabC
         FXrc68rizHHMJzrDV3gRtO67uoZ1D0ihozHOWEGxRH5MfgWNGR9twXQx5Fzy4+0pGGrj
         uSI6JV8OhPc68pxaWPRFILzJYeTTRH2g3nUIajougNES3jNL3noEqL+2OG53Cr88bh0J
         VydA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=8YwzIASUiQRwU6GfvzkJObDJseuyBEMVP7g4XrNm/58=;
        fh=eo8LHfwKeZCeQP752Bl0+GIpVaS0NG4tPl9WzxQDeqY=;
        b=f+6GrXnbsSW5plYI9Lic1KTyrwPYarsohJTmoLhHNXGKuJNid1SfJKAdZu3DrlmTK3
         GpCg2+m1vxwfRyHLij7RmiOxZ65ms7HiVDNe+KDphwCV8avHSOL6d91NcMiPlCyWmw1U
         Ml0YQj6+6ZIq9LSjb/vJ0pvsW2EokAd/bw4BJPxOnyFK+nxkhCXVYVQvWW36sck7aUAe
         Zm3cHHAPBXBSfQ6lxZZ7WXVDZpzdOsQbTrXqGgM5A8qdkNYGzWVkGHjz9ybkP8NOYq1T
         IqC5oAKsraHfjIIoFGGiL/xIgVAPyXrI0Y/gf016OloezvrzUICBm6V3hN57lWLN3FEm
         BnuA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1790356042; x=1790960842; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=8YwzIASUiQRwU6GfvzkJObDJseuyBEMVP7g4XrNm/58=;
        b=JQ7vBslBA75Oz3vhccuiegu2ZSCVFqSF0HyjC/3/vNzOkrP+yD6f4D4JjYMSYAoFrr
         wlg7Wmn6oEu7SXRotz0a67VZfHRO6XibZ9ZQ2iaB3D1nQj3Xnbu+DnvAmLPuwuabcTJk
         PXz37aU1zp89S9iK0/x3WEyWrQZ8hNLRiSYpSLIsFe52Q0ZtYHr08wUrk94pc3ENWlQd
         J+Tedgfpmw+/PX5h3yjumGEOqc+s3rcWYPx4Hn4luwZxasnr3NVcHxFxvCE/jfitgeBw
         +jOt/CmP2fD13Y486VYHbVYAPN3U4OMa+qtVuZhbWJD5jm5g1hu0o/Zq9FL93oXYU7V4
         vv7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790356042; x=1790960842;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=8YwzIASUiQRwU6GfvzkJObDJseuyBEMVP7g4XrNm/58=;
        b=xhusU7UF3IAlTNyjt50LBLou/Q9vxhj2lKHRjOm1ls4movUJ91UbouPhiSxyO+d/My
         dKNBJ4xFrhhvRgnIEV5LRMNVzO+qp2pgSkWAsXPmzgkfkSoEA0/saqxwaFs7RSXydm8V
         bjFlmHFQFKPtN1ZwwWfD3lPNaXvoFHZg4NtRdPCOczuqS7h3k4NG3JLP7KziRUCzRIVN
         NoosDJi1TERQvgmIsOAXro7Q3Eqir6e1G6FZmKm34nFt+DygF9rTV+D1q8mo2BoeVs5J
         i4PzXTxBAuA1voxfObMV1kcu80CR9hHscdtLkkmEX9zh/3ghG2jIKptTe3mW4TZ9DGPJ
         DEiQ==
X-Forwarded-Encrypted: i=1; AKwUvBwFUvcJdLbtkWIuTU/kugd1QDja8R1pGnQsRvTgagws7JNTOxaYSgp9MQBvvcDweVZHkXN7O7BxF30=@vger.kernel.org
X-Gm-Message-State: AFuF++kBawrWWT4PT/q/rtz76QWbfpGcvtYRHyH65uQ/2ygCeIdubm2T
	zfbUv/b7MlFBJHQJ3kcU6eZNIDbJG4A9bkdPcXP1xlYf8WG51D69bFqDNvgRpEUiSwdRV4pAiXj
	NLiWZcNkRX0hqsPofojFLF6XxHSuUlAK92gh3jj6o
X-Gm-Gg: AYBFou1nVDkmv9usR+cDTGTmXSARlVceQOcWyLFf7icIHdmvdfqRtwTpJ75m7nWMbo8
	293qUjj9xvLuZ8WwHNk+jQD1YAe8SJuHlOQ+f3U0JT0A792OJgdRdTIgzj56nJc0tVs5XQ3DzAz
	oLMvj0qZp9heEAH4b8+67yqCidbXX4a9qAj/TsTRFMvCZCVXtITusr+bzg/63Sp73sljFINwArh
	BAkaDQ8gUXPxpTjgFzNClMvhxkKS6m8XYLqFHJsIUaOTXEf/GTUtynXGmq4O6rzCn2T/jv3a/QI
	h5B3XnHCIHkicQ43L2mxtIlyY6Y/868X7ZxEjRQ/d+62T0OPJa/CqJMW2i6+b0ohGeFk7lnNQG4
	SDCxfhzIu9WGNRL3opAD5uA==
X-Received: by 2002:a17:902:d48d:b0:2df:99e6:9448 with SMTP id
 d9443c01a7336-2df99e695bbmr12902675ad.61.1790356042370; Fri, 25 Sep 2026
 10:07:22 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260924104831.1081137-1-caixinchen1@huawei.com> <20260925-zahnersatz-hielt-lerche-141893658522@brauner>
In-Reply-To: <20260925-zahnersatz-hielt-lerche-141893658522@brauner>
From: Paul Moore <paul@paul-moore.com>
Date: Fri, 25 Sep 2026 13:07:08 -0400
X-Gm-Features: AclHuK-PYyMWIn_xv6i13K6lF_3RP26uUOO_mtAnUMGHNcMrV5ydBitx8qn_ri0
Message-ID: <CAHC9VhSeXmOHvioZ12aVmnOtpP52-G=K_jS3K0fTSiCrDHStPw@mail.gmail.com>
Subject: Re: [PATCH RFC -next 00/12] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
To: Christian Brauner <brauner@kernel.org>, =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Cc: Cai Xinchen <caixinchen1@huawei.com>, gnoack@google.com, jmorris@namei.org, 
	serge@hallyn.com, corbet@lwn.net, skhan@linuxfoundation.org, 
	rdunlap@infradead.org, gregkh@linuxfoundation.org, rafael@kernel.org, 
	dakr@kernel.org, dlemoal@kernel.org, hch@lst.de, axboe@kernel.dk, 
	viro@zeniv.linux.org.uk, jack@suse.cz, dhowells@redhat.com, code@tyhicks.com, 
	linkinjeon@kernel.org, sj1557.seo@samsung.com, yuezhang.mo@sony.com, 
	hirofumi@mail.parknet.co.jp, cel@kernel.org, jlayton@kernel.org, 
	neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com, 
	miklos@szeredi.hu, amir73il@gmail.com, senozhatsky@chromium.org, 
	chenxiaosong@chenxiaosong.com, zohar@linux.ibm.com, roberto.sassu@huawei.com, 
	dmitry.kasatkin@gmail.com, eric.snowberg@oracle.com, 
	stephen.smalley.work@gmail.com, omosnacek@gmail.com, casey@schaufler-ca.com, 
	nanx95726@gmail.com, djwong@kernel.org, daniel@iogearbox.net, 
	linux-security-module@vger.kernel.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, driver-core@lists.linux.dev, 
	linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	netfs@lists.linux.dev, ecryptfs@vger.kernel.org, exfat@lists.linux.dev, 
	linux-nfs@vger.kernel.org, linux-unionfs@vger.kernel.org, 
	linux-cifs@vger.kernel.org, linux-integrity@vger.kernel.org, 
	selinux@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	xiujianfeng@huawei.com, lujialin4@huawei.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 25, 2026 at 11:33=E2=80=AFAM Christian Brauner <brauner@kernel.=
org> wrote:
> On Thu, Sep 24, 2026 at 06:48:19PM +0800, Cai Xinchen wrote:
> > This series adds two new Landlock filesystem access rights,
> > LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
> > which control access to file and directory metadata such as inode
> > attributes (mode, ownership, timestamps), extended attributes and POSIX
> > ACLs.  It picks up the work from the "landlock: add chmod and chown
> > support" series [1] and follows the coarse-grained grouping discussed i=
n
> > that thread [2]: instead of separate chmod/chown rights, metadata
> > operations are grouped into one read and one write right.
>
> This is mostly fine for me. @Michael, for the fs side of things I would
> give you a stable branch vfs-7.*.shared.landlock.path that you can pull
> once this is ready.

This is in my queue, but I haven't reviewed the changes yet.

@Christian, I'm guessing you will merge patches 1/12, 3/13, and 4/12
since those are the VFS changes?  Once you have a branch for that, and
we have all the necessary ACKs, I'll merge the LSM changes in 2/12,
5/12, 6/12, and 7/12 and then Micka=C3=ABl can merge the Landlock patches.

Are we all okay with that?

--
paul-moore.com
