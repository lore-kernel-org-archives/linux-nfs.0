Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.48
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795438859;
	b=g/lNaADc54JbY8dMSoxovjl7RK8LT9sUTjeX4djcXHWttS6Vai1ZpmaTI5z8Ik6R2zR0
	 okyU6nBfID4f5G4i8qQyAzjDQ0IjBmvzO4AjbOhUsHSHvv9zoVHjUDI62De8AKnQE72Ch
	 PgeecCYniqrLL78HX+FkNOQOuYjnNIDa96L/2zm8+DzFaoc1QP3QNDiGyfPqrtRF4ItmF
	 NhgLoDPp9h0USVlbIM0NIyLPu9ciSboWxB1FyknRMYZ/EfNCgZ3p8BuQdr0tHf6HJu3eL
	 jR2wKF6UP/KN+L/lsXfHTqlw49zZhRvPgTCu0t+MuXsrYds49CyzvaeQzfuU+rhA+YA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438859;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=AMCJ5wbvnIEodr6Bx3XwSyi7m8Nqsc1HfBhVMog/o3w=;
	b=3oMZBTjjx6qFyMNDO8r8jhH1MOG40MPdlxmFqbznXdwyOaklz76nwGoJW8OwqrqJOohp
	 x2H8yjP6fCl53r5ShMSkIaoGLjXjWcT2XLWc4ldUnOKVQg21okYG4h+2k75Gr85zZfhFf
	 Answeyt2MT/2sPCLwhVHi7smnrMRewRvPVDj1fLqiqAUHnTP4LJzkP9rfLiJJJkL13Yux
	 c4MA5rtPn169RYaMMDPZ03ncFBN8wWBas/DRik3+tXAetViQEqrEnBu91j7PYjJNcxEzJ
	 N5V+WIDHMfNnoY0iGPYAmOktNruI+cHHsI2XBa8ijTzWAZyeTTBXQrQm5Xa8d/o5ToA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=kkson++k;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.48
Received: from mail-ed1-f48.google.com (mail-ed1-f48.google.com [209.85.208.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AEAF606A32A
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 13:00:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1AEAF606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=kkson++k
Received: by mail-ed1-f48.google.com with SMTP id 4fb4d7f45d1cf-6baa6f27904so1399508a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 05:00:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795438857; cv=none;
        d=google.com; s=arc-20260327;
        b=fVhTsipyH9C9j6rQhRnNMGjPEHHzFwUQbLGxpHlMM8dQOpZSyGQpE9vGk2eSUh9Us+
         e0z/CqJZ77ahUuO81O1br8LwBG322sdaz9+QKR2wr4uxifwIGWO6tHODA1b6Nwck42MQ
         us15sjs49SgjKGNgx1ytaUZ2r5T7sS9sEa6w2tevCyfLeDg+Ts4qtNiZRVmmSS51+RiZ
         /+wOFHQUc253ugyWl5BQuViqdZp2tPlg5Slw/vmzVsbnSB/KH/D1QI8lJJp6oYx17vOE
         2FPU94s3FE71tdGxXeJ6XjSUC/XyROyD0Afbo/yQ3VfTxH5yQEVAVg5j8E+7xLBtCHOP
         inBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=AMCJ5wbvnIEodr6Bx3XwSyi7m8Nqsc1HfBhVMog/o3w=;
        fh=jZ02X8YwvIyJad0gCJEiC4jnYAWy9U2Dk4QZNT0ytUE=;
        b=HjNZcznqex88EhtxCnHiWqYl7zxB1ByqdCTz6hLsZJ7lUbuYHxwuUjeLg6Oworvye/
         DLmM34kUsbgqVhUOOulyi/35zvcqTwBVdHbs+9WdPQGJF4wxiR1XisK4s8D9gjkc3eUw
         AFLLxfV0E4xzSiYyiDEhkyD54DKHYW+3Pw4g9HSeRMTNMu+pBzCpXFlNI6GuH7xPunnS
         9jPzXnoN7kFHRh8XXYA+pKWF8mjNvz9HRTEL8Zm1EiGikxQRYh6pBn7SxatGZv20tjVl
         exN1vvH3kIDGEeVrxUCw/nGP5uuAmXKDnFq4yksROpS7pnUrHvc2/7fzlxLuXCSfXoxd
         loJg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795438857; x=1796043657; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=AMCJ5wbvnIEodr6Bx3XwSyi7m8Nqsc1HfBhVMog/o3w=;
        b=kkson++kiVuuq7GlVJEDUrQHu19KcH/nihH2BzgLa6gbrvy17AZmxY1D1w0dt2h46y
         /xXI9YCF3W8v6AnWEDT8Xid0rKVtto9xbQeFZkRGR+cb5Y8RIC0oMxupLBYaYJC4CQou
         6ZJgLzs7wocf6G/7L1QJdpNwS2lbDAistHwZiRuhKs46qZQI5UTzUa+r+vixCZl4Sxxv
         NpVQv5tq4rxjVYt/Ok4zCR0OsxODa6kreqGz8wEkn4nw5GUASkqE6hP4ExSDLRPowFf2
         0zimep72RFU7EbpYHdPGxIgrdpvUiN+7UnUUrPJ6dRIQHj227oDE5EmUxVXBkiebQasL
         M4cQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795438857; x=1796043657;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=AMCJ5wbvnIEodr6Bx3XwSyi7m8Nqsc1HfBhVMog/o3w=;
        b=rc6o5JP0ZvH2212s0t4erEkQ9baNEalhU8chcAkrWjHqsET6i7EIXu3fNnPlu9GwWY
         knpFv0TlKd0LMLUfXSH4YXveuXxdTJFo9fN5JDQGfxTDVOlcvdUdwSs6SW/IyPDHwbGP
         1AEPDrApVqKMDda3rxW0PaEUyxtTxGV8Aoftf05Kw+gkPtVqKwJPZH2SLoCspij9vY7y
         Et7Grmkw5O4jgwmhakR4XYDabzK8F4LZXMvoUENV/IdIeJm4o4L96tXj3p/nFy7SXeKT
         r3yKulBjp1qRZTz+7K0ufj2GVCt1B9Id4bKWfbuyrdb0DYDrxC08Cnm5e/ak5NmE+ljb
         amPw==
X-Forwarded-Encrypted: i=1; AL+hErEwyy5FpCd8JOV7SuWqq5DRP/TrR3CuMqnn9zuQXp7Dgn8VBEwDWH8OLvXr9VEhHOTjFsRdFHAOI7c=@vger.kernel.org
X-Gm-Message-State: APuU4Z+vscJFDIvgPsNdXMigXldUW/Gzfd2xwDlewiekU066DRJeLPly
	BsC8MFfnMAtJt4CohUSYTW1QEktPQp6Q4RF4q7VuPMBZpeLrmk1aQgiiXMpiV/sQknnoAXQtV21
	vjZKBtzrHTrRsZSQdGM01QrGqC3wUkpo=
X-Gm-Gg: AZFdTZdJkdH1tAV2LIQT5nev89Kc1niOIbOA9yjzbTj8CaxZZv8nE2ZoNQkkqJQasjF
	t2WSTRiEA+hKzY8z4XULkujU7u3aYyuJOoPoegndcEe+3Pq3QRLmVLP/Qyzf04xsecWDsqxI9tz
	xZ+vmTtq6JGu2U7TkW6MIRM2rBjBdWvTpM+Xo5BjHxszak5+fe8IWflMqL6eNhCjgQR0NwVMbIg
	dx3MgsDho+x6GV3cWnGvcj0wYIeXcbFj/i84Ifq9pHZ8uJXYziwEK2AzMxdnL4xjoNVVPLK95Hg
	l3BMx5ADSAhuObCxU03kUu+0OMuEIA35dCkcKqM4a1haUdjTUGvOlwV73JqpdvjQ41D9f9Zc1du
	yIGlyNvzTSgCWJZ8C6cGar22HvadhjfWyoCdSOw+htDFE/+hwPfcwPCCEnqLVroTbbX2bcQ==
X-Received: by 2002:a05:6402:501d:b0:6ba:659c:8ca3 with SMTP id
 4fb4d7f45d1cf-6ba659c8fb1mr5474446a12.10.1795438857096; Mon, 23 Nov 2026
 05:00:57 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261122000856.536902-1-koray.fra@gmail.com> <20261122000856.536902-4-koray.fra@gmail.com>
In-Reply-To: <20261122000856.536902-4-koray.fra@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 23 Nov 2026 14:00:44 +0100
X-Gm-Features: Aa3M54oIZEz33KQbWl8M_WOYBLraeDplxcWm8_8Bl8KeH9NFv_L8S3OGX6_s9I0
Message-ID: <CAOQ4uxgc6pP+_xvJMbqj6wOdGzS75Vn6x6i_vUfCJDD46DAA_Q@mail.gmail.com>
Subject: Re: [PATCH 3/3] ntfs: switch to the new xflags fileattr API
To: koraynilay <koray.fra@gmail.com>
Cc: Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jan Kara <jack@suse.cz>, 
	"Darrick J . Wong" <djwong@kernel.org>, Andrey Albershteyn <aalbersh@kernel.org>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	Lauri Gates <lauri.gates@gmail.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <dgc@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	ntfs@lists.linux.dev, linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 22, 2026 at 1:09=E2=80=AFAM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> Switch ntfs_fileattr_[gs]et() from the legacy FS_*_FL flags to the
> modern xflags (FS_XFLAG_*) fileattr API with masks.
>
> Introduce FS_XFLAG_COMPR and FS_XFLAG_ENCRYPT and add them to
> FS_XFLAG_COMMON (and add FS_COMPR_FL and FS_ENCRYPT_FL to FS_COMMON_FL)
> to be used in this API switch.
>
> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.11
> Signed-off-by: koraynilay <koray.fra@gmail.com>
> ---
>  fs/file_attr.c           |  8 +++++
>  fs/ntfs/file.c           | 63 +++++++++++++++++++---------------------
>  include/linux/fileattr.h |  6 ++--
>  include/uapi/linux/fs.h  |  2 ++
>  4 files changed, 44 insertions(+), 35 deletions(-)
>
...

> diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
> index 50be49f4c913..fde6fb2fe39c 100644
> --- a/fs/ntfs/file.c
> +++ b/fs/ntfs/file.c
> @@ -155,31 +155,37 @@ int ntfs_file_release(struct inode *vi, struct file=
 *filp)
>   * @dentry: dentry to report the flags of
>   * @fa: filled in with the flags of @dentry
>   */
> +#define NTFS_RO_XFLAGS (FS_XFLAG_COMPR | FS_XFLAG_ENCRYPT | FS_XFLAG_CAS=
EFOLD)
> +#define NTFS_RW_XFLAGS (FS_XFLAG_IMMUTABLE | FS_XFLAG_APPEND | \
> +                       FS_XFLAG_NOATIME | FS_XFLAG_NODUMP)

Nit: checkpatch may allow 100 chars, but this due formatting is not
easy on the eyes
pls break to RO line and indent the broken lines below (


> diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
> index 4faa40febf11..219e7c8eb601 100644
> --- a/include/linux/fileattr.h
> +++ b/include/linux/fileattr.h
> @@ -7,12 +7,14 @@
>  #define FS_COMMON_FL \
>         (FS_SYNC_FL | FS_IMMUTABLE_FL | FS_APPEND_FL | \
>          FS_NODUMP_FL | FS_NOATIME_FL | FS_DAX_FL | \
> -        FS_PROJINHERIT_FL | FS_VERITY_FL)
> +        FS_PROJINHERIT_FL | FS_VERITY_FL | FS_COMPR_FL | \
> +        FS_ENCRYPT_FL)
>
>  #define FS_XFLAG_COMMON \
>         (FS_XFLAG_SYNC | FS_XFLAG_IMMUTABLE | FS_XFLAG_APPEND | \
>          FS_XFLAG_NODUMP | FS_XFLAG_NOATIME | FS_XFLAG_DAX | \
> -        FS_XFLAG_PROJINHERIT | FS_XFLAG_VERITY)
> +        FS_XFLAG_PROJINHERIT | FS_XFLAG_VERITY | FS_XFLAG_COMPR | \
> +        FS_XFLAG_ENCRYPT)


Rule:

You cannot add a flag to common without carefully auditing all
filesystems that support the legacy flag.

FS_XFLAG_ENCRYPT can go into common but must also
go to FS_XFLAG_RDONLY_MASK because it's read-only for
all existing fs.

COMPR is rw for some fs and ro for others.
As with CASEFOLD, you cannot make it COMMON before
converting all casefold fs to new API so that each can say
whether it wants RO or RW.

I think there may be a way to deal with this easily since
ntfs doesn't need to set either but not sure.

>
>  /* Read-only inode flags */
>  #define FS_XFLAG_RDONLY_MASK \
> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
> index e40806b3a69c..09fc7e066485 100644
> --- a/include/uapi/linux/fs.h
> +++ b/include/uapi/linux/fs.h
> @@ -275,6 +275,8 @@ struct file_attr {
>  #define FS_XFLAG_CASENONPRESERVING 0x00080000  /* case not preserved */
>
>  #define FS_XFLAG_PROJID                0x00100000      /* project ID */
> +#define FS_XFLAG_COMPR         0x00200000      /* Compress file */
> +#define FS_XFLAG_ENCRYPT       0x00400000      /* Encrypted file */

This is a mistake of patch 1. the newline should remain above HASATTR
which is allocated from the end.


>  #define FS_XFLAG_HASATTR       0x80000000      /* no DIFLAG for this   *=
/
>
>  /* the read-only stuff doesn't really belong here, but any other place i=
s

Thanks,
Amir.
>
