Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.50
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794698411;
	b=zOeIMpRLTILijisSBlBpMhGDUtjec29n6B3GfgtFIpikF+l1oKqDHlOiOQzE0/5Y4YAf
	 tjcwMEUI1jCa4HYLISYpX95HFlMMd/F2kEYRY3U4JVjcSsCjR4c/f/jPfax3jR/6Jf07R
	 XfI1Bu+vGid+GG9dyE6idJ4UuialATEZEP9iSV5eGjtrkAGg8FZ3yp9ThjhewVusYWA2D
	 el23i60+QQ03ANYwcVOAuA0Y4qG6AHQ5d+ae3XS45K2lBJrRIvkP/ZWts3AdqYnwVJPFL
	 VhK5qj4w4j9paETJ4CIFE3KF29ix49B5cJ9SXwKSJIF+CWfl1k1AhNh9/1TLe+7ov7A==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794698411;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=98mXXJR5XCg4Z4S2yqrizowpYg4fQiN0pgPOU/BiUFY=;
	b=A3IJRZCYWhlNwx3ov7rmj2C5N+mlZuGY9QGtpHVWGAbj5l2WYFBvVM4QZzjTTKWGmcFj
	 zO+Ac+SRhuIYeOQOwvrPBEZYdDscjssWHtfPqibQ/eN6+1GUcOsIR2peWAwoxSU+jzt4+
	 v5jIjYG62XvLQwMW5gcTx3QZFNIfVx1u7Gh2Xb222OWvpabqf2L204aJZb2AjwXZRkI1Z
	 sofP2McTivNHnbr+6t14D78PmnHG4LTZb7Qx4U/6Fqj7zgQKbGhUdT6qdsXNFvJCa6AjH
	 QSZFleSxup/0Q7fA+jTAZBus5ahowFihTe30hd18D42HDvhi8nAp/Olw96qFrtPZaHg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=bZ4A5V+6;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.50
Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02F27606A338
	for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 23:20:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 02F27606A338
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=bZ4A5V+6
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-6b70192ebceso4502085a12.0
        for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 15:20:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794698409; cv=none;
        d=google.com; s=arc-20260327;
        b=WuRb0KE0cAQ+9e19hhSZCqlkNG/C3s8HSfUVN51EiXIQSp8SLYeEUkS/gKAAPbRnRj
         o6h5eHVxbjRvKwblSIb6n5BXKW7PGBbPzO97PXK3l5rWALr29viH2ZYXtODiJPNF/kjo
         enZBHXyHqgPoGucTFVcwU8uGluFtA4fCKYoVnI399EfxE/cIePFTQHghPpH+A5DFu0DU
         PdaKTekln4KhjqKE6IELO27CeRVvFHIrNrJzcYywAR6ZYmgw9lz6Fri3OA7zFN9OS2YK
         2WzbcqfpK27gyKbF2qurywFqjp/989nKpnvCIrH4aeAhX99QniL6EjQcxw3ZNb3goUh0
         SUWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=98mXXJR5XCg4Z4S2yqrizowpYg4fQiN0pgPOU/BiUFY=;
        fh=nY4HkEJvJFPyFaOse5j9RzKoP4qZQRrYVwQ9ayoXzaQ=;
        b=QWKmsOBq2IB4lprsppvKLRkudlRPT23fiUR4I0VuEZkwpPVSN2TZwZmzE7Q36NKIHW
         TfRtnNUGl5NrN0OpyCWqfvuM2ck9K6NoNHJQM1xAjyv1Mniqv3smf4jVyQkTTEWkLD8u
         hdS3oTMfkuDH0cwG4/mPCjVZ7M+08As/ke8xzOoJyHQDu/fs5wUYV6XSj+MQBvJrIf/x
         Zr0aVXfprK0unOxlrD+VwzekPk0ecDG2IFghCvUyNZM389Yx+LAPo1gF2WG8RVeVlSBQ
         jEWNudojS1VWOg0At3PB2Lv9+Xkg/OsvYX6xT3yVsAiiL/WZDJ1fx2A8398B5HRXVdvD
         rZWw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794698409; x=1795303209; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=98mXXJR5XCg4Z4S2yqrizowpYg4fQiN0pgPOU/BiUFY=;
        b=bZ4A5V+6Vs4HKIPLNbCXlaoHg6GUiZAgPE1CoHup/u8F9XnmCFMSb6naMqQFAl++mw
         +LZR0jt78s/FhrwMU+95xN0Ho10rZ/g9p6M/dfGpr9SfvlaOXM2WfiTCtO0CejnyefhK
         5gg17lDjyCI6S+pTTK/DIWzHtcTY1JHkLI4t/I/Teu6/Lgz9A0oKfkx231Ay53Fdu4Kp
         zCo0ecwmPzO3ZOIddRCFMjOjLH94BU3oXsC8cOhJgJSeLFwZkZlFyxo1cq6JVw7hHb6A
         21NW8PziNlBat7d4DfM9UgO0YIScpglsDnmQoGQNIOQhlOx3hw76q6t8+8jTPfBn24eS
         FVGg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794698409; x=1795303209;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=98mXXJR5XCg4Z4S2yqrizowpYg4fQiN0pgPOU/BiUFY=;
        b=N1pd/VKRaubFV6LEuQKLJGvYTRFal/4A4zA2WQtzOiefNXI60vAn9aEUH8fSmsEzKV
         nBIwR0Lk1SNQyqJ0OXAsci7Hf/1lwKYrzX2nEFIrm5stHKJpMiA4tGRNEPumGiYNZKwi
         VtTCX00H2enbqkUnIqu5sNTCCVEH+KVirWYK3AjCPq4mHQcmFMo5F+QPD0sCwS3V8+0x
         3vmEyUs9ng4ulWZQrdToi8G8GNdPcxgdF6oy6j8WecBFuuP3VIRuttBFPqxmb2dvBV7h
         gOGR/fQLNul4qnLhgE7OQJKgVJ5TNcttDBq5T/NFQEZuAc28PG0xi18I/y51bwjlAsHO
         CanQ==
X-Forwarded-Encrypted: i=1; AL+hErFfgnwEnZywLEU6YF9sBGziDoN/e13dc/Sb0B4j5IhPv8Ju8WMpSZPTUEtHhhO7d8InkKqahC5cHZE=@vger.kernel.org
X-Gm-Message-State: APuU4Z+fxjYt4IaqCxouBRNF6AFmupUQ+XGspqYUptg0XivyaOekD8hM
	ENpIsi/3f1q+N6/IGyiGJWGxnXVloW/N98ezR/sOvzYKecMzWCiRShND2UGlt5BuZsnk07OVZgq
	fUZ4E4xDEqOjkLTNCEnzuoGBOJnPQbmPzE9CgZIJzUw==
X-Gm-Gg: AYBFou0b1N6+IfHRVNZXqpXXWZy/7//WrZwiQc5G3GjdqshYESckKX2sWomPh3Pooh+
	DGu023ldEXaSSLEu7jUSbJXNk/H6hV/tv2ONkhVt5+fCguqCou3+5FgUEnuHg0H8a9tcZiW6rWI
	ayFCm96NLADwUSx3oCqZzF7Pa7V41Zu8fdUkQdCEazUcssKcb2W3MPspZNKnlN9N73LS3rz/cJw
	9AKiw353vSsdKUYirLn4UkDrwHHlkNga3v4sBDd06G2aT3zXa862DO5lQj9cv0z2A7xDLEJJx3P
	CHfOts5JK59x6CLYyZJoF34Ynmr25sLVNzda1/pHCVGcHN6ONTD0iCEKVZMdG60ArSU+wXqNA7O
	wD5L4pjAsEDvOI0WKMKqRu/Cu+2uhbpbFygxGNlf4IrN8rnRYu+LIeeRztOi/7MC3E+tbyA==
X-Received: by 2002:a05:6402:e10:b0:6b7:f00e:5e56 with SMTP id
 4fb4d7f45d1cf-6b7f00e5f37mr1542816a12.1.1794698409123; Sat, 14 Nov 2026
 15:20:09 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
 <20261114-work-loop-pseudo-v2-33-98639a2286fb@kernel.org> <20261114120557.4bc1eb6e57218cdc@chrisdown.name>
In-Reply-To: <20261114120557.4bc1eb6e57218cdc@chrisdown.name>
From: Amir Goldstein <amir73il@gmail.com>
Date: Sun, 15 Nov 2026 00:19:57 +0100
X-Gm-Features: AclHuK_YVxhIpv6JLzeNAX5mX5IHGfu05WS6uQ-TCKewxE3JKeci2PyA-UDMCbo
Message-ID: <CAOQ4uxhGxpBtMZ5kfuzR1tQAewiecoX7UjXQRo91QjJHH9T_Yw@mail.gmail.com>
Subject: Re: [PATCH RFC v2 33/42] fs: add file_check_backing()
To: Chris Down <chris@chrisdown.name>
Cc: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org, 
	Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, 
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
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

On Sat, Nov 14, 2026 at 9:06=E2=80=AFPM Chris Down <chris@chrisdown.name> w=
rote:
>
> Hi Christian,
>
> Christian Brauner writes:
> >+      /* Look through stacking filesystems at the inode with the data. =
*/
> >+      if (d_real_inode(file->f_path.dentry)->i_sb->s_iflags & SB_I_PSEU=
DO)
> >+              return -EINVAL;
>
> This looks good in general, but what the bots said about O_PATH files
> here is real. With FMODE_PATH this is reached for a file that was never
> opened, so on overlayfs nothing has been through ovl_open() to look up
> the lowerdata of a metacopy file yet. ovl_d_real() then does the lookup
> itself, and when that fails it hits the WARN(1) at its end and returns
> the overlayfs dentry, so the check passes as well.
>
> Only fuse passes FMODE_PATH, so it takes CAP_SYS_ADMIN to get there, but
> it's easy to trigger with that. From a quick test with a metacopy file
> whose redirect into a data-only layer points at nothing, registering an
> O_PATH fd of it with FUSE_DEV_IOC_BACKING_OPEN gives
>
>      ovl_d_real(/f, 0): real dentry not found
>      WARNING: fs/overlayfs/super.c:79 at ovl_d_real+0xc9/0x210
>      [...]
>       file_check_backing+0x308/0x5e0
>       fuse_backing_new+0x219/0x4a0
>       fuse_backing_open+0xe8/0x390
>       fuse_dev_ioctl+0x53a/0x7d0
>
> and the ioctl still succeeds. A normal open of that file fails with
> ENOENT, so nothing could have used it as a backing file anyway, but with
> panic_on_warn this is now a panic.
>
> Maybe ovl_d_real() should just stop warning when the lookup fails, now
> that it has a caller that isn't trace_uprobe?

Yeh I guess that this needs to be a Fixes for lazy data lookup.

The correct fix would be to teach all the callers to deal with an error.

> The check would still pass
> for an O_PATH file whose lowerdata couldn't be looked up at that point,
> though.

One observation relevant to this patch set is that a datadir layer has no
business being a pseudo fs and that can and should be blocked explicitly
at overlayfs mount time.

The other observation is that fuse_passthrough_open() should probably
check the backing_file that was opened for io in addition to checking
in fuse_backing_open(), which could have different FMODE and specifically
could be FMODE_PATH.

Thanks,
Amir.
