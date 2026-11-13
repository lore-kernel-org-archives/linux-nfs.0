Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794565648;
	b=wGXOSmHdhh8qsfnSzFWdw8ZIctdEYiRY3B2DquqcRIJol/uTnslM3oZ+0xdZ6vHxiYZr
	 DQ4hUXiMP8c8sRdXR+4DWjT7tZq91Bhrp+U7TTJB4htmCXaMoe2pPBf1+M7lIFbxkNOqZ
	 AU/WaUFmzmW8jOCm9AJAcKnyjqi2oMl2D+luT4WihDSqajQ68WrKfQlLK8jAU6S7lnBhb
	 v99m1qf9b6nmhO8Tde9oGZT2Q0vBWs3ivQJp4yix89kul5wkFSa1WCJ9AKWEi9yEWNYa7
	 HAaR3Itcl2zd9nPImMN2r9+JWBXK40ZKcHK1QVU97azWGWq0WGH0BTBzBpCwuKCEb6w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794565648;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=TXY31nY7nMCHyiOZTp7Dn0JSWYPda+tFg8CPAdTq7II=;
	b=M2RM5cKemJ0/ZIg8KYHPNQtrkkBho7IHNXzu+WkpKL86WERKw32eF7ahEu6MiStlRrOB
	 TgNTmIcIw2TeR6psPDsAobn3uEjUaZpwyXalm7LfOh2ARgdJpcKYzRiDAsdMOMilXMwne
	 vbF6T80LnzKGK3bMlUUcqCAvXNlSUU5SpgqUj1FKIynlVec26Dw6vTlXsTm2/UYFPqcBo
	 k7d3BK6TKpuXpp87v3w3NkdGNo9J54iXUXrsKN9G/whAyxbZ2n1lTLOkfJ7hzZ5dO5elL
	 HeL/WdemcV8h4T019rrmo2dblPZKzgFjq+/6qw9ycgmXj9jsGU3OWOuK6dgP6NIWacQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=N7Ff61ik;
	arc=none smtp.remote-ip=209.85.221.46
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 550D0606A336
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:27:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 550D0606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=N7Ff61ik
Received: by mail-wr1-f46.google.com with SMTP id ffacd0b85a97d-48fd2e38825so516943f8f.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:27:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794565647; x=1795170447; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=TXY31nY7nMCHyiOZTp7Dn0JSWYPda+tFg8CPAdTq7II=;
        b=N7Ff61ikIQ27nXVrR+i5fFuiFp+kpNCkSJ8kzzwXsWXF8oHPQYaaEtIn2sVJ/R61Yt
         eN/EgbWtaqyPzsaKr2MVnoSj+msmKBheiZS6yCjGNfIw7Nev7hKixHBvdeyifMwCAuyY
         p4HuC2pLhsdw/6s4IDRTQYVk2XreSuuUeA2/lEtpnIKw65+UPm9cBNCU3JmsoFXsrPGj
         WUoovGImF4s4dFS6xRIsBa0e81egoKAVqgb5m7AbWjvbiu6rsFasaFfPaH+ik5AAKzYn
         61DshIaK40jfv3WiwMjZKKDrEIOQNGX/IDgIqQj4sI1tIu9ZETTA/xF/QESgBcPouNO3
         9yyg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794565647; x=1795170447;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=TXY31nY7nMCHyiOZTp7Dn0JSWYPda+tFg8CPAdTq7II=;
        b=1U6y8a6oSQz5FQgTFtNB8hxo7bybRJY6GU6TQOMHc6BuiaXsx5uXrA6WbdLZfN3EcG
         Mrwux6tE/XrOgliy6u2SiKbvhaEJR+o0Q4J8S0I6ISfzzywWcwEYRjiR4Oz4NkpMokjE
         hTJ/DRUopPdHUlkmaxzQDhjeZwKNhxVMRXXIWpeFQVUEYkN5XkGmbz0YI2xtH3I25X0S
         tJ8/SwBVxjMrGbh1CK0tfRIyyHHVPMuDD0sA8mSXxs4soT+UqE3uz53DftVmE7znWbkN
         KgA4PzknAER0mjJWBaIMi/4DAnP5MeZRrKqqCe7CqtxBnakrndqmkYrhEKdRMBf/rgjf
         c8xQ==
X-Forwarded-Encrypted: i=1; AL+hErEirZx/DYPulU88wz8Sr+OLDZdzx/bU/pHK509Rqqpnyrv7dspF+7I4hYs4QmBn2/6hq2oOBJrdWdE=@vger.kernel.org
X-Gm-Message-State: APuU4Z/Yik32qH2nCAV5BbQRexksNmDbKIriBdqVt8dwwlZ5hy76pGuc
	S9QV46VxSzhld/iZjGU9XXld1ySe4fIrUqS7ppVe11Gv8SzS1l4TXTiu9IDNjLnlAYEt
X-Gm-Gg: AYBFou1YomH1txg76gzu680ohInmJZrI/ldQYiCb686edzhzyG6SyHM0VJvd8hE5qAQ
	zXD8a+2zQkVNrksmJSRtgjHk2MOGuePc6iMGiCbZLhNLGeGK26mmCCq9HJu/kG5xsssdOjJYKVk
	pDENI469jiKPejjhRpteMLNv7Mn1Y3TN7I0J7yPdd17Uw55beZHFlj8hYoPeV7V9ANcoqYBAWxW
	kfn0B/6VXBC58zFjZ0lSqN9AiW+O1Y9noROoALRUNnVYYNyv3eJ4C0enbxfqTdYdEBP2r6dLnFN
	i0Fd3ecWPu5N9v6/VTTVo/knTdW37ZUqDTaB32DFi/WwvjcwAVIN4SRfWGF5YcBhRwQu9CZ15PM
	HrgeZBPFfFJ/gfFP+g2NkMgJFps5MtRyFyMbYXhG1zmaF0VNYHI9wEhyg/0eDtlCqkYG16rLd4V
	6IRNc9Pro6yPt4j2ZEUuOQLUhN6Xq0N4fLPAiHxPZ25o6d+S6N/TYo5UoE+wIagOIzW7JTYRlb9
	G/W5XAYxIVErpfPbIxWyanGGnLnmYdFHlluMtfP98qwtuVCBK4VGmr50MbDM9nyAzikCpfjHIcD
	j8V0qCk5xeDagje+W/eQg+WmRN7HVkUQhJuX6bl/IPDP3Wj2aD6VaPAYBmwJWKg=
X-Received: by 2002:a05:6000:4707:b0:498:c419:3728 with SMTP id ffacd0b85a97d-49c713ae367mr4463557f8f.22.1794565646661;
        Fri, 13 Nov 2026 02:27:26 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c5a32d336sm5077482f8f.0.2026.11.13.02.27.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:27:26 -0800 (PST)
Message-ID: <0c109a58804a2d782e549af6ad13e89532d9f9d2.camel@amutable.com>
Subject: Re: [PATCH RFC 40/41] erofs: refuse files on pseudo filesystems as
 backing files
From: Alexander Mikhalitsyn <alex@amutable.com>
To: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, Josef
 Bacik	 <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org,
 target-devel@vger.kernel.org, 	driver-core@lists.linux.dev,
 linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, 	fuse-devel@lists.linux.dev,
 linux-efi@vger.kernel.org, 	xen-devel@lists.xenproject.org,
 ocfs2-devel@lists.linux.dev, 	linux-s390@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, 	linux-usb@vger.kernel.org, Amir Goldstein
 <amir73il@gmail.com>, 	linux-erofs@lists.ozlabs.org,
 linux-kselftest@vger.kernel.org
Date: Fri, 13 Nov 2026 11:27:24 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-40-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-40-4c998976c6c7@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.56.2-0+deb13u1 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Tue, 2026-11-10 at 10:14 +0100, Christian Brauner wrote:
> File-backed mounts take any regular file as the image and the same
> goes
> for the extra devices of such a mount. erofs reads them with the
> credentials of the mounter so this doesn't hand out anything the
> mounter
> couldn't read anyway. But files on pseudo filesystems aren't images.
> Refuse them just like loop does.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0fs/erofs/super.c | 6 +++++-
> =C2=A01 file changed, 5 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/erofs/super.c b/fs/erofs/super.c
> index ce05557bd998..980d5fc2b576 100644
> --- a/fs/erofs/super.c
> +++ b/fs/erofs/super.c
> @@ -158,7 +158,8 @@ static int erofs_init_device(struct erofs_buf
> *buf, struct super_block *sb,
> =C2=A0		if (!erofs_is_fileio_mode(sbi)) {
> =C2=A0			dif->dax_dev =3D
> fs_dax_get_by_bdev(file_bdev(file),
> =C2=A0					&dif->dax_part_off, NULL,
> NULL);
> -		} else if (!S_ISREG(file_inode(file)->i_mode)) {
> +		} else if (!S_ISREG(file_inode(file)->i_mode) ||
> +			=C2=A0=C2=A0 file_is_pseudo(file)) {
> =C2=A0			fput(file);
> =C2=A0			return -EINVAL;
> =C2=A0		}
> @@ -835,6 +836,9 @@ static int erofs_file_get_tree(struct fs_context
> *fc)
> =C2=A0{
> =C2=A0	struct erofs_sb_info *sbi =3D fc->s_fs_info;
> =C2=A0
> +	if (file_is_pseudo(sbi->dif0.file))
> +		return invalfc(fc, "source is on a pseudo
> filesystem");
> +
> =C2=A0	if (!test_opt(&sbi->opt, SUPERBLOCK_SHARE))
> =C2=A0		return get_tree_nodev(fc, erofs_fc_fill_super);
> =C2=A0
