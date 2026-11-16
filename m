Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.128.50
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794859646;
	b=Az7eYDX35mj2t6vdngxBYozL0AglATxW4aq7dEQ42Hbo4BzdoNl398niSfm2Wiq0yBIG
	 +ZYwNkVG7JPunTLLBSoFMdEctoFWMS2VaHSh2icSb5jKQTY0c+nPRK+y+cm8iK4ELXx8e
	 RQJN37zZX+4UtakAbSSIWMBWbS9s2mGKJBZhhFxHxLILzSCbmZVf1GSM4WcWwot6VFSbz
	 Z/4I0lnHtG7hfoevFwsYo66ZWT9bq2aY6uhj3sz44oruckoup6tlDnafaEUVXKmw/L+PF
	 U+5qIdS+uMtlkyzEb2Hfx1RXQbPfpgvl5hbWGiE1TFlYYtEH/Ds6VMhl7cGzQQ2g5cA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794859646;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=EZDAQV8yhgMyPQgwR3U/5djFDS4+SZxlS+9+Esw/bYc=;
	b=r2Uo4j++eJSZlipqScWCQ2MHtuXoZMT2qaOwm4QHPr84pPJJCvnTBAh4eZQt7kEdSQLj
	 yMnJG5X/epd8DUfo/80pVFy7kvVrnXyxVrxGiJ5pM3fuyfabUBRBMFrCMlLP1NznQxCpD
	 YMFEzkU7kpqZy3JNqcudCaB3Tstg3xOsPnAkPsm0OxrJqKF6Bl5/lIhUxjVrmYHedYbHV
	 Z/5PpQ4LuoZKwGLkdpOcmhe9B2p11zRQ3g/C8M64CioURkwbl8CNtaDtmrC7bVPwmSVJj
	 IE9/E99D5KvxOCX0zHguve0zW0rY2VdS0N/CEuv7C5B03I26ERbJ/29uENj2ZxdfRbg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=XFDBy0c2;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.128.50
Received: from mail-wm1-f50.google.com (mail-wm1-f50.google.com [209.85.128.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 072E6606A339
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 20:07:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 072E6606A339
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=XFDBy0c2
Received: by mail-wm1-f50.google.com with SMTP id 5b1f17b1804b1-4b79502c27aso32098775e9.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 12:07:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794859644; cv=none;
        d=google.com; s=arc-20260327;
        b=Cz2UX6D8KfwYS65GODj+bArC+ElXUkI1SQr1wzoLnp202qmPKSWX9dKtP1+SpZPdtX
         pOL7n6BUeQNfTp8pHKYXjvZd90DHtgjXeQRA/1myx0RaCSwFD6Pn/b5ki1/8WPqo/gVr
         t7A7JoyivxIGm237IKH+Ljf3BMmejFLiPFZ4cjNlbWyMRD2OxXIMXGQjB1ONswT3fEcA
         38ezQY3ZTAJpkjC6s71ELIOeKXpJfBuWuSSv+Bl5s81OUV56AjqxbrF16q7sGWomi0q0
         HPe5EZmdPGEn/6JLDnuRwv7vLAy3dCQxSZu3OhZ0rQxFkHelgVeZ7P5tVXNNe6DzC2bf
         PnkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=EZDAQV8yhgMyPQgwR3U/5djFDS4+SZxlS+9+Esw/bYc=;
        fh=0QC10ZvP6ji+fD+RAUNIUdDS/KHLwile1LoDKvjg5vk=;
        b=OceIP2tefQQcXc/+nUCfSdxf5oIkkzpblYTkvMOTb8Pi9NYbS9xEse0dq7m6F2Bri6
         4nceI+FAXNxhlqqQUD1m5MphkJI6RMJa/Ju4VxGYHPjvWogoG2ZOGBWWzW4RaD0bah2z
         Yz0C1mZxhhRyh5cYuhqO0yixJWR30ORhGHqrdEXDmb5IM+nKyLE/oK90AYMc+FPeAhIX
         7BXt7bWmWR8KzvCWrHoVtVnq8YUhpcq3V7OTC+phVf4p2RE9pb3d9P9QQTxuKnoE6bfR
         TCMeUeP3ZlmKcQcyofqVyNz6j59CZ+/WG4GtPmHdN/HTrArStV4tdrSY/kSLvoznh6Ag
         3K3A==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794859644; x=1795464444; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=EZDAQV8yhgMyPQgwR3U/5djFDS4+SZxlS+9+Esw/bYc=;
        b=XFDBy0c2q6nTYiJ4dwLENH1mguXX/IcFF58gOeYQArjps79P1XpkrhGZpUclTyZwpS
         r/ZYwRoOG8WhRg+8JvLZN08T5FQLHs7jA/CzeQCQsJeulI93s02F+iYtli/pBjYHG+CR
         W2MoU0n/+grSPpLZW83MAsn9WQiLh5CCwtBf/0GxLqRHC416IFZ4i13TeIFhLxmbz0il
         NPxDzLDOL7N17VVYsTOL0jDLDvB5woBcjlvcU+oGB0Wrnz6q9rCc3VHuwmdjl71ac6+n
         fuvYHmykPJU4vuSvTSKMetyKY9BqLddb2of0qXOJ87q21uNxSrudqkhk+T/+cyqihyd7
         2YNg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794859644; x=1795464444;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=EZDAQV8yhgMyPQgwR3U/5djFDS4+SZxlS+9+Esw/bYc=;
        b=UXg2dU0jTeVHwDb+Zf7q5Pv1Ws7Mq4gy97XfjYBc1vWY7JMXOumRFqMyyzy3/H4vik
         3sXyj+Z0aEFNmjo4g5c0WubLFXt+AOeUst42ofP92zN/FbRzTmdwq2+cImcsVLz3B2Sg
         Wv9NMunko4M1ghWycQCeHKw4KzhBQhoPsPl7LMvi2XGzMa0/TcHoXCjy1jzHma3r+H5w
         Z5cvieJO8TW21HQmRWdEyOx6BrGH0RHsAeFqb7Hg0EesEWWGNygZHe3N8Dk2jxj8Z6a7
         Iizp58iAu4jK55UbFwkHtmVwoki75oqGtv4uJ8bT81DIKP9ufOAVw7E3ZIKq2RYt6gcP
         f7wg==
X-Forwarded-Encrypted: i=1; AL+hErF4ZYZGm8gZxk+vQW1BGST/9nPHaveiPAptP1JE3HFi6asY7l8o3Bg/kBlkKI+qk9vMVjTcLHaSPfE=@vger.kernel.org
X-Gm-Message-State: APuU4Z9rI3sndiN7KDoEeEydzo6Cvp8lPJs1E1vfnE6AEC+NgJ19aKM0
	P19XWADIXo0EMxuQdrmurnIgUgw7DtBtQ2Orrb8LKdaky8vjs7UcptvkHGPNLRq3xkL5Tpz1EAZ
	b/R8fKXqRAcyVrEp3Io5DwP/qmZ+/sXk=
X-Gm-Gg: AYBFou0rDIljqIkpvGGlYH2HAIYrFj9ldgndRXiQu9BhLDCrr2Aa4OaDAcU9JMrbSaB
	Wyek14fljyCwlRklL3zTLQhwZ4jgse6mGL5gWR2O8twtZsqHbz5w3EmCTOAt3bG1dm64JSIp0zf
	xX+4sK2HOjkhVhQp4X7P7k9V37ykvEkG+e2KIfY4c5Dlbe6hx6b1G/m0NWbf7pu4scuNKBsRov/
	jLg2kvUEwhuddZkPXJuuXKlQ8ghitqnje7HwRBmEzkMkzEvpFsoQRI9oZXevs4+ZYghqDCNszOx
	/ycb4tBrHKZeoHOzo9folVH4aWK+qwUMBu2nDVwmDwoJx7HLy5xCN+QVUqblT5V8wqaYMaDo/7O
	RDxeLi2w/8AUYysQPLUeMwmhz68QqNgQMjUMDKfgsT3qcscgJBUCaz9AB+ZzePIgK36bu3XvD+V
	j/bfO3w7lyckBXj2rIfg==
X-Received: by 2002:a05:600c:506:b0:4a1:f377:5c6c with SMTP id
 5b1f17b1804b1-4bb55a5d6bbmr165067875e9.10.1794859644313; Mon, 16 Nov 2026
 12:07:24 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org> <20261116-work-fs-frozen_writes-v2-13-ecc4a2aac40e@kernel.org>
In-Reply-To: <20261116-work-fs-frozen_writes-v2-13-ecc4a2aac40e@kernel.org>
From: Andrii Nakryiko <andrii.nakryiko@gmail.com>
Date: Mon, 16 Nov 2026 12:07:13 -0800
X-Gm-Features: Aa3M54rpWiCplKeR8o5TX-NbYGDID_36BWk-3VAyUzdEoXSYZ7J-t8pfWvm9Fcc
Message-ID: <CAEf4BzYANM9vtQ8L9-rJPQC-tTcw3YUGsw=qnCaoym3+EU=DBg@mail.gmail.com>
Subject: Re: [PATCH v2 13/17] bpf: fs/xattr: take freeze protection in the
 xattr kfuncs
To: Christian Brauner <brauner@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org, 
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
	linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, linux-nfs@vger.kernel.org, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 16, 2026 at 3:13=E2=80=AFAM Christian Brauner <brauner@kernel.o=
rg> wrote:
>
> bpf_set_dentry_xattr() and bpf_remove_dentry_xattr() go through
> __vfs_setxattr() and __vfs_removexattr() which leave freeze protection
> to the caller. BPF LSM programs call them from sleepable hooks such as
> file_open where nobody holds it. So a program can modify a frozen
> filesystem.
>
> The hook may already hold freeze protection or locks a frozen
> filesystem would make us wait under. So don't wait for a thaw. Fail
> with -EBUSY if the filesystem is frozen.
>
> The _locked variants are only used from hooks that run inside setattr,
> setxattr, removexattr, unlink and rmdir. Their callers hold freeze
> protection already.
>
> Fixes: 56467292794b ("bpf: fs/xattr: Add BPF kfuncs to set and remove xat=
trs")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
>  fs/bpf_fs_kfuncs.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>

LGTM

Acked-by: Andrii Nakryiko <andrii@kernel.org>

> diff --git a/fs/bpf_fs_kfuncs.c b/fs/bpf_fs_kfuncs.c
> index 35ccd98a4de64..7f61e2efa08ba 100644
> --- a/fs/bpf_fs_kfuncs.c
> +++ b/fs/bpf_fs_kfuncs.c
> @@ -295,9 +295,13 @@ __bpf_kfunc int bpf_set_dentry_xattr(struct dentry *=
dentry, const char *name__st
>         if (!inode)
>                 return -EINVAL;
>
> +       /* The hook may hold locks or freeze protection already. */
> +       if (!sb_start_write_trylock(inode->i_sb))
> +               return -EBUSY;
>         inode_lock(inode);
>         ret =3D bpf_set_dentry_xattr_locked(dentry, name__str, value_p, f=
lags);
>         inode_unlock(inode);
> +       sb_end_write(inode->i_sb);
>         return ret;
>  }
>
> @@ -323,9 +327,13 @@ __bpf_kfunc int bpf_remove_dentry_xattr(struct dentr=
y *dentry, const char *name_
>         if (!inode)
>                 return -EINVAL;
>
> +       /* The hook may hold locks or freeze protection already. */
> +       if (!sb_start_write_trylock(inode->i_sb))
> +               return -EBUSY;
>         inode_lock(inode);
>         ret =3D bpf_remove_dentry_xattr_locked(dentry, name__str);
>         inode_unlock(inode);
> +       sb_end_write(inode->i_sb);
>         return ret;
>  }
>
>
> --
> 2.53.0
>
>
