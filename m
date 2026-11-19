Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.42
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795117028;
	b=4oiiP8xUV9DD453YlNMCyGgXcyxmh6UzJCKb/r18rBUIGHiCMlRGRzqF9StQqCRBkAfH
	 4Tv6MC1njeD/HSPzWoaDMivYi3SdNfXYI0gBivjsNvEcG5fVSxe4mysUfzQiDCcIQWvMP
	 ZAPC9zNn4sru+ftyCZqvBq09uj5MsoY5jJrl8HIldolcRb1kgbswksHPh1mp1fzyCbs7N
	 DVSXH6tzV09bqc0Ab4xAzRSflKl5UzjXpFvYt1H8XNUsRlYoS2zY4frT5akyszTzQLOHD
	 aYXMyYxJc04p6+8W+Sezmcymk+Gh9V3+OiO0bc3WqlOI/aKgrPfIATxJYGlWkijzJIg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795117028;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=vs2p+NKw9cBxSHvLMTQ1TCNiiuqtzY0tMFYF/M3imDY=;
	b=ESC5jLObMejzElQHsvgtQ64FzXt+rOQSuWW215EsWP4WotvfCoGYSEakWwBKGmw1aj/q
	 311bhySSVZlhAIvJSW06wUu0moJvp8248NmEyP0mxDA33n7P7RY0c3HcSnVwWffvmw4op
	 N0pHEt/YBefau3TDtnKVpxjuvOLhR0xyvoPABS44V5ZYr8kSW43Lk40POIacdHlZ8fNIA
	 haYQB7jEOCUnNj0cXYBlQgPXuZWkd3AsL/R769wLL9BBSf0HByeVP8NZapuSMYWsKSe5Z
	 P7rp47OVGuHShUhX5SuRJZhgjW7DAAlTJuoKo/eQb0a0CvyvNrVl84aoRv/qOY3eaEA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=J2P1rliW;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.42
Received: from mail-ed1-f42.google.com (mail-ed1-f42.google.com [209.85.208.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4609460A2609
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 19:37:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4609460A2609
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=J2P1rliW
Received: by mail-ed1-f42.google.com with SMTP id 4fb4d7f45d1cf-6b4bd3d98bfso129242a12.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 11:37:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795117026; cv=none;
        d=google.com; s=arc-20260327;
        b=s7R9KjIrH10sg/Tw4T/OiGfXMp0/tlhAHf2+aNuv9KiSqNzlQO79kmZfEY07fMYAsf
         1jG81jcMvi3tf7ie6Quk8qrFVAjiu8tfMFPqv0eAPvz21E1vqSChpFFA8Oe5lReQzgzo
         j1N8dlfNOBLaNTpWa4rBv+AFjCie8Ugx+1l0H3cq/C2jPJ5Fp2EaVZk4e6anCQqi7A28
         zdMkZiYj7Xc+fu9vN9tmPPbexFIIVAtYa5m3siDCyIpFTHc7URmt3LR6aaYDhn7Q2Qgx
         KBnHZgSkfUwNb6Irajm1pdB17DqX1Jhxbh5P4XYpnKM0IOqOb7BGNm2D57K2cODuR6Po
         fv7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=vs2p+NKw9cBxSHvLMTQ1TCNiiuqtzY0tMFYF/M3imDY=;
        fh=Uhen/Yx98MNS3ZQi68f7cHgHikXjs7ZBnVtC+jayry0=;
        b=IFJ6kUJ2BlYXXzIxO1tcIPdZunSiGAeFgHAudCwOdAUQP8cpmCHHHZVGjqUuUapCb5
         WjMSjSVX2Qm767r58T0KIbMq5m7UXN4ldUFem22qrsKh8sQ8oB6yYHvJpcBVNqqxNa7y
         KqrwYvlbjRlFx7/VEyxMo6o7dLGZEzA8TaEgurWd/oWFtarIjClRY8sKRZL0btq0TCqK
         nJd/pzE+cJeRCmyKZjM50EMJWrkv1f+3LWA3ql5svosiPpb75EVizrEnSreVe0n4gVaS
         20TFpbxE0htXx4JvJ5qvva1NuyhyoQphKhY4KwhS/mwcu7BSH7BiX+WBfhMPvfSME3wM
         mE2g==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795117026; x=1795721826; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=vs2p+NKw9cBxSHvLMTQ1TCNiiuqtzY0tMFYF/M3imDY=;
        b=J2P1rliWlWFeXXFXmXF+ohrZY4u8BY5guzLNIZE4zyZEFvv9XjVp6qSFQEuKBYS4gw
         tRHKICBYDX7EHD7dOjit9dYAF5zAZQoiMjaWziJZS+p8scKNzprADKCa9phj/1Tq5rLq
         AdLh58YB1IlCzIIphjpmi7F6IODiO1Lb028EXgDFuQRtiOTbHyBQqFgQJ2a9rTkXFmIk
         rIDw5jsAro28ug3nEE4pf9UY06m6dKeDy1GLSXALfX/FhKkPB24uxc9fzqALY5d5/0zY
         o3ELAOqepaHkRc8vyIjpo6spF9jSLJ5v2/RpEGLV7zg0pNxm6ebUphbxyHHPfV1Pvs4Y
         7KvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795117026; x=1795721826;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=vs2p+NKw9cBxSHvLMTQ1TCNiiuqtzY0tMFYF/M3imDY=;
        b=YcsWHxyhNB+9nTVIBwldCMRO5lqQu1JG/BfEn31DrTTqt6ztgc/N3XXaAZGUchSI5h
         o2akdT2PfimKomkutw1ed6RG7VPjCccLK7CFrgwEdW+NzYmeSNl1GlDRLBsYH1/0uaWh
         6Blr5Yyg4TnRs8WbrcepOghC9fgg6NU85LU0KVP/Tv3dVkH4h4pk2yHRn7QyvOLhnz2W
         gsE8j076gi4+lrsHELpqSN/PRYo3cX6mFxWId9L6kIohxBfD2pYijNz0bmqRz20xZBPq
         VRFSQJYmGLMxtVDmV/KtuVMGyHIRhokSekZgUzUGW2kywu2pxgjVBko/rmSaQu0oOePE
         osaQ==
X-Forwarded-Encrypted: i=1; AL+hErENwNK4JXLkQ6GrLsizpTqH+ygE0l5719ItcoVqxhavM8JrvcXMLzW2fAb4iVbXWmmarecdGQsWgjA=@vger.kernel.org
X-Gm-Message-State: APuU4Z+wAvMLun8dgRCNzcuAec41AYkxcIO3gol7Jglq7pAFHhd4+c2Y
	jZvYftWgzXwQcWvil7OnvY7G+g0jLezeaor2fMsmP67qtsWXLaFRIvRhZVcARdnHicXDbh+Q9sH
	BUCjeso/1ZCPne5l1qNQg+Zh6jSav+Yk=
X-Gm-Gg: AYBFou3QgNT0WEk5VBb7NPtYl3hc3RX1O7QuQ50feqRyd/FcnE0v33A3fc47LkerxJQ
	xyYld8tsqCKe3dZPZ3FRhAhuf4QmdzT2cGDGSUQhc+ZeVWzcAqYMeHIohPKgE6Bj/iDPUG6ZXHS
	QmwAJWWnejb88M8MZtYhdsWfdatm6UWfNYbF0WJd0SXtGGBn9AFNEAcrEz0935HnmFw9TB+82i5
	BXpb3GIndiX3tDScNqMNm6kMrgXvzR/KP++j5OgjyRs3xkKEDmDAQyZB40WZO99PRa6hf8YBf4t
	/tyAFhVy0eT59sNSXs1wGUQ09U44PrFvMkG0lPleMjOjd9AI0R5TC/K3MNDPyMaWjJ1enHMO5sv
	Qet0JdBxgyaWcS7EKNX1xgq6ZkRKNCeTzdKKeXixAaa17gtYpq5eCKTxafVrb+LHex43R3dE=
X-Received: by 2002:a05:6402:897:b0:6b8:8328:8e66 with SMTP id
 4fb4d7f45d1cf-6ba37d62a2dmr239724a12.7.1795117025446; Thu, 19 Nov 2026
 11:37:05 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261115180343.576773-3-koray.fra@gmail.com>
In-Reply-To: <20261115180343.576773-3-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 19 Nov 2026 20:36:52 +0100
X-Gm-Features: AclHuK-9kUyGBTzq0h8pZyp8mMZSXIXsu9pOi4Bu2Y5vLjqBJOsUk2EoN70jtkI
Message-ID: <CAOQ4uxiRFUqgUMvngvXc1nA7e_HMKSs+aXWVQmAEpcR7yQiQLw@mail.gmail.com>
Subject: Re: [RFC PATCH v4 02/10] vfs: add fileattr_has_fsx_mask()
To: koraynilay <koray.fra@gmail.com>
Cc: David Sterba <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>, 
	Sungjong Seo <sj1557.seo@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>, 
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>, Yuezhang Mo <yuezhang.mo@sony.com>, 
	Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Ronnie Sahlberg <ronniesahlberg@gmail.com>, Shyam Prasad N <sprasad@microsoft.com>, 
	Bharath SM <bharathsm@microsoft.com>, Sergey Senozhatsky <senozhatsky@chromium.org>, 
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>, "Darrick J . Wong" <djwong@kernel.org>, 
	Sean Smith <defendthedisabled@gmail.com>, Andrey Albershteyn <aalbersh@kernel.org>, 
	Pedro Falcato <pfalcato@suse.de>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, exfat@lists.linux.dev, ntfs3@lists.linux.dev, 
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 15, 2026 at 7:04=E2=80=AFPM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> Add fileattr_has_fsx_mask() as a helper to let filesystems check for
> unsupported xflags while allowing supported ones. Can be used in the
> same way as fileattr_has_fsx().
>
> Also make fileattr_has_fsx() a wrapper around fileattr_has_fsx_mask().
>
> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.4.7
> Signed-off-by: koraynilay <koray.fra@gmail.com>
> ---
>  include/linux/fileattr.h | 21 ++++++++++++++++++---
>  1 file changed, 18 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
> index 42b92ccdc583..ba7ed3b387d8 100644
> --- a/include/linux/fileattr.h
> +++ b/include/linux/fileattr.h
> @@ -65,6 +65,23 @@ int copy_fsxattr_to_user(const struct file_kattr *fa, =
struct fsxattr __user *ufa
>  void fileattr_fill_xflags(struct file_kattr *fa, u32 xflags);
>  void fileattr_fill_flags(struct file_kattr *fa, u32 flags);
>
> +/**
> + * fileattr_has_fsx_mask - check for extended flags/attributes
> + * @fa:                                fileattr pointer
> + * @allowed_xflags_mask:       additional xflags permitted
> + *
> + * Return: true if any attributes are present that are not represented i=
n
> + * ->flags or @allowed_xflags_mask.
> + */
> +static inline bool fileattr_has_fsx_mask(const struct file_kattr *fa,
> +                                        u32 allowed_xflags_mask)
> +{
> +       return fa->fsx_valid &&
> +               ((fa->fsx_xflags & ~(FS_XFLAG_COMMON | allowed_xflags_mas=
k)) ||
> +                fa->fsx_extsize !=3D 0 || fa->fsx_projid !=3D 0 ||
> +                fa->fsx_cowextsize !=3D 0);
> +}
> +

Every patch in your series did:

       if (fileattr_has_fsx_mask(fa, EXFAT_SUPPORTED_XFLAGS))
               return -EOPNOTSUPP;

       if (fa->fsx_xflags_mask & ~EXFAT_SUPPORTED_XFLAGS)
               return -EOPNOTSUPP;

It looks like this helper is not as helpful as it could have been
and you have raised this question yourself in the cover letter.

Effectively every filesystem that supports fileattr_set() already has
a defined SUPPORTED mask, so I think it's better to do the negated
something like:

static inline bool fileattr_supported_fsx_mask(const struct file_kattr *fa,
                                               u32 supported)
{
        if (!fa->fsx_valid)
                return true;
        if ((fa->fsx_xflags | fa->fsx_xflags_mask) & ~supported)
                return false;
        if (fa->fsx_extsize &&
            !(supported & (FS_XFLAG_EXTSIZE | FS_XFLAG_EXTSZINHERIT)))
                return false;
        if (fa->fsx_cowextsize && !(supported & FS_XFLAG_COWEXTSIZE))
                return false;
        if (fa->fsx_projid && !(supported & FS_XFLAG_PROJID))
                return false;
        return true;
}


...

       if (!fileattr_supported_fsx_mask(fa, EXFAT_SUPPORTED_XFLAGS))
               return -EOPNOTSUPP;


>  /**
>   * fileattr_has_fsx - check for extended flags/attributes
>   * @fa:                fileattr pointer
> @@ -74,9 +91,7 @@ void fileattr_fill_flags(struct file_kattr *fa, u32 fla=
gs);
>   */
>  static inline bool fileattr_has_fsx(const struct file_kattr *fa)
>  {
> -       return fa->fsx_valid &&
> -               ((fa->fsx_xflags & ~FS_XFLAG_COMMON) || fa->fsx_extsize !=
=3D 0 ||
> -                fa->fsx_projid !=3D 0 || fa->fsx_cowextsize !=3D 0);
> +       return fileattr_has_fsx_mask(fa, 0);

            return !fileattr_supported_fsx_mask(fa, FS_XFLAG_COMMON);

I hope I got this right.

Thanks,
Amir.
