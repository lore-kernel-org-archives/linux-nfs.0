Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.45
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794850650;
	b=pfMOVQYuL/ZjDahnRJiDSLXVwUY5ZHi3JToY++QMgJ5Q6ZGdqx8qwNcSz8yAHLegPiTQ
	 Bl3x8IeHVP7Q1FOlk7bWN2YoMbHxSt6Oe9Wly1DYJ+XXDKN+PTemYXpfbBol0OZB4FS3s
	 V9wx7clNY2D0GVZ6WDuyY7ZII8RWTf8bZNMhQMwSZAn1BaBbBPiCd3Qp3JRO6N8xHs1/B
	 pSyymvlCFTfsh7cAIAPzMCaw/qf2X0d5Fa1v4dvjUnLkdUdQlpTQjCfNyvL52KEfNiRju
	 FUIvB916vlrIkFIJWg/REs4wbHpVrGXvZBjKRwRgw1P47n1woSgUvG5Ptn2HvaXOu6A==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794850650;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=ASqD7yYrxwRTXpvky24aSldHzEJHTNv4OUWKJ01NHN8=;
	b=ma+zMhCbYHZHZV6cWly8b2foz40M6Qclq+SJbN/XLf1xAeVlt/zsK/KLvw8DrkBOoOKy
	 AfMImtqknRz/a6IHuVdIeeREm69IrZknbExK8DWVmnVpzcD0gDEjHiswAZrC74iyIICTB
	 b85VjM/cSNlE0qP0HhYkaq/EOJ2GTE4dydd2lM0f994J9/ETOUcBWWu3FMp3W/CUES+63
	 XBLcwGjbClMV2y9G4ClGO62s39h3GbFkMbymogMpfjQDcXe7kgHKW4w+zgpHCwSd6j/pZ
	 YeUfH7sxnewYau+aHad/JwAoU+1XYdsI3xzCZhzP3Jr5dCCsX+9sdlO7wd3CFtrFu9Q==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Wda5m4T+;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.45
Received: from mail-ed1-f45.google.com (mail-ed1-f45.google.com [209.85.208.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53A70606A894
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 17:37:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 53A70606A894
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Wda5m4T+
Received: by mail-ed1-f45.google.com with SMTP id 4fb4d7f45d1cf-6b596569640so140948a12.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 09:37:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794850648; cv=none;
        d=google.com; s=arc-20260327;
        b=cO2FBFxLyVfqxats9l+Y2Mj3ac5sGafpM4/4Pghnodhc1YsyZvaZdpa+Yxf6hmoCw3
         SlUs+ArZMVppn5h31pkPCXuTOWTyOnKS7HeqapiE2cslndsGwsx37ks1j5OhRmBkyPGF
         IS0Thn+V+bW4dJf1tfNDznu0p3GCCh0KvMyQtTIEgProamPIEw6KCVK6vNnBJ8phzgLu
         yEL/QkomsjdoWjcaPkFxKpnfcedVWhTytT/qjz1ZdJfMSxRn78QJXyLtNtI9BbHE1FAl
         2SLqFy4O9c3K5XVnx0uit1qJQi1xmgfhK1wJT+Zftp6HQD/Ttu9LJF5nD8c8p9RopIP6
         KW1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ASqD7yYrxwRTXpvky24aSldHzEJHTNv4OUWKJ01NHN8=;
        fh=qW/aAaDi8nsGPGMlpLVR8L9RpqL5rSNdRlNsyzRg94M=;
        b=EY77KUW4f3HmPdKAzA40u7Ev28cjtCk5hGNwc22N4oUx+svVSKwE8kd3MlfJ2NE3xN
         dTNeC5cjF9JpKo6JrwqEtjnCuPZSrM6isF5KO0prjmbHk2vOb66gs7MmKCHcJe1BHld+
         nP15q6oGffxzMBhs6+TAsXZ/yHbryCBvGpU6/F3FrZk9++mVc4RgwoRkKRrcXO9OHpmF
         p/J85gSyEPPMO493ep/da+7Awy15GVTvZ/UfnfdHTvyqQaHnkPAkNvrPOnn1N3TJ6zuI
         umd3u/KFjhM5HWBPzL0RSw3yHNdX+ltbD00WjsT4yTULtwfXBVoJxYp94tyG/WG0Q4+j
         dAnQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794850648; x=1795455448; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ASqD7yYrxwRTXpvky24aSldHzEJHTNv4OUWKJ01NHN8=;
        b=Wda5m4T+Og74YNLartpajMnAcctT7hnb5haqi9hjLlBRa67TYcEPjf80gw45qsgIx7
         FMobW/aC2ZXQsUmoaLilVLeaESS9ODytholTX6ZkGdI39Z50BqAMQuVm0upEGdU/eTIl
         KzXBiwaEJY7eqa6p49n+ZePGE0YUDeVtz78JPQJb7w7ae3zRsyAfYOAEtJq8eS6befDe
         ANfoXo4rOnrr9cTK5CEQbvEa19yD1CMimOfBL7pxwr0U+pGpN6RB970vgsC2xV+kB6BG
         DqloDFELm5xz1LM2zdKvbUwHIwogDmvmrNVDo81Was00uh+K9TR8cjrFQWZvFUjBWrt9
         3Csg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794850648; x=1795455448;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ASqD7yYrxwRTXpvky24aSldHzEJHTNv4OUWKJ01NHN8=;
        b=MfbyC8GiDvXK47v7xGiK/yQY8IlRUz5/FGNKHvVe5NHbOQ344uqGatCUi+h/emOKwD
         E3/J+ZiM8lcglVh21zdx9oggmfGzszb07qCdZxNroxIaM/J+yfphCbAs1kwyVzxxTR+H
         sSCcajpbQjMCkrXStLJqvc+7UQAmCfxLVh5kicGekw+NLKJfS70YDHC1YqPs7jQZJKZv
         VpXJJDkOc87iDyCR7TUFxFUaNVPbYhQ1JcoXz36KRJAr1JeCN58T19YcL73PoE1W73xn
         RVeDe1nFZGz/l+wvWkF+wsOhrtgwXyAz0n1gLZQ7hkmAgp/VvLSCLdQbUDAwIDUmV8Qg
         EZRQ==
X-Forwarded-Encrypted: i=1; AL+hErEvdUbOYt3UAobH+MOIwwpqDdOMwlczUzyOHUSoXG6LHSNtUEfI/6yc1ZWiXt50rFZKIGPX5vezti4=@vger.kernel.org
X-Gm-Message-State: APuU4Z8HnPApvHjRA6kCTwb/1srugp2bZ8uD7ggMGBXY47PDVlH8EUFf
	cx9QhKV89qLtjVG0j7BTE5m6EzXhCBCxTufqZhSJtI55yJfAybZefd1BiRIa6JOxY2ZoKgwgfjS
	vb/7sLwkWStIH9AuCBiLo3WtcV0KRnEE=
X-Gm-Gg: AYBFou3QFhzevT4h14d2LoyiAMC6osLbVGxkcDbCV0UBphPXWCHbMqsMR1Rq0506aYE
	v9s0+eV6W25y9dn4d7Cz1VDGC9YV/g8w2PQsUHKwnzk6fkDuh073KtymoeoAp2H8Pb43gxsQGrt
	JAaaSa0Lb+P9gZ5TMwfF7nq+Pq6CIDDfrtIqn8yZ/pgPYgULlwczjWAwWvWDN3/NaYZdYEdjc8i
	2PjO5M1NMZDBZ4hws+wALNaw0FFoCnyEJyKN/8oISaobdNer039+0ksvDpfXrCHUgJPn9f8sfQo
	dTZ+k1DQa4PDCI9QElTKls9BZg7chWMRGzv2l8+vyLm4w4PigW2YPytMNvnAGhDAWwT4vym4c71
	K1TVnAvCPqje3K2dfcdIQFKfIvlJktpDwLIqXbTl5tYtxIR7nV8Y0qQakWcCBLV+Qvf8h3w==
X-Received: by 2002:a05:6402:1598:b0:6b5:7250:d621 with SMTP id
 4fb4d7f45d1cf-6b859ae1a00mr134291a12.15.1794850647426; Mon, 16 Nov 2026
 09:37:27 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org> <20261116-work-loop-pseudo-v3-33-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-33-8cbbea1cf34f@kernel.org>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 16 Nov 2026 18:37:16 +0100
X-Gm-Features: AclHuK_sKnxFPAK3k65pZhjyZC94SJD4eZ9z2j_P12s3kyb9TMw6hurQcjyq55Q
Message-ID: <CAOQ4uxgPerkkG4ie0SyHVXaBD9VZN2wYfQpEAEi4hytn=ara3A@mail.gmail.com>
Subject: Re: [PATCH RFC v3 33/44] ovl: refuse data-only layers on pseudo filesystems
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>, 
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
	driver-core@lists.linux.dev, linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org, 
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev, 
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	linux-usb@vger.kernel.org, linux-erofs@lists.ozlabs.org, 
	linux-kselftest@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 16, 2026 at 12:10=E2=80=AFPM Christian Brauner <brauner@kernel.=
org> wrote:
>
> The data of a metacopy file can live in a data-only layer. overlayfs
> doesn't look that data up when it looks up the file. It only remembers
> the absolute redirect and looks up the data lazily the first time
> someone needs it. So until then nothing can tell which filesystem holds
> the data of such a file.
>
> But a data-only layer has no business being a pseudo filesystem in the
> first place. All it does is hold the data of metacopy files and the
> regular files of a pseudo filesystem are kernel interfaces, not storage.
> So let's refuse data-only layers on superblocks with SB_I_PSEUDO at
> mount time.
>
> Data-only layers can be added via the "::" separator in "lowerdir=3D" and
> via "datadir+" by path or by file descriptor. All of them end up at the
> end of ctx->lower. So a single check in ovl_get_lowerstack() covers all
> of them.
>
> Note that regular lower layers on pseudo filesystems are left alone.
> Stacking overlayfs on top of sysfs keeps working.
>
> Suggested-by: Amir Goldstein <amir73il@gmail.com>
> Link: https://lore.kernel.org/all/CAOQ4uxhGxpBtMZ5kfuzR1tQAewiecoX7UjXQRo=
91QjJHH9T_Yw@mail.gmail.com
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
>  fs/overlayfs/super.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/fs/overlayfs/super.c b/fs/overlayfs/super.c
> index 39d4d57dec230..719c2569dfeaf 100644
> --- a/fs/overlayfs/super.c
> +++ b/fs/overlayfs/super.c
> @@ -1237,6 +1237,14 @@ static struct ovl_entry *ovl_get_lowerstack(struct=
 super_block *sb,
>         for (i =3D 0; i < ctx->nr; i++) {
>                 l =3D &ctx->lower[i];
>
> +               /* Pseudo filesystems don't hold data for metacopy files.=
 */
> +               if (i >=3D ctx->nr - ctx->nr_data &&
> +                   (l->path.dentry->d_sb->s_iflags & SB_I_PSEUDO)) {
> +                       pr_err("filesystem on %s not supported as data-on=
ly layer\n",
> +                              l->name);
> +                       return ERR_PTR(-EINVAL);
> +               }
> +

How about we make this just a tad more restrictive:

                /* Pseudo filesystems don't belong in composefs setup */
                if (ctx->nr_data &&
                    (l->path.dentry->d_sb->s_iflags & SB_I_PSEUDO)) {
                        pr_err("filesystem on %s not supported along
with data-only layers\n",
                               l->name);
                        return ERR_PTR(-EINVAL);
                }

I could send this as followup patch, but since this version is simpler
there is no real reason to have the intermediate "only ban datadir" step.

Only the commit message needs a little more flexing to justify this.

Thanks,
Amir.
