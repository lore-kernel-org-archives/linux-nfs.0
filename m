Received: from mail-ot1-f45.google.com (mail-ot1-f45.google.com [209.85.210.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 52D884915B7
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 13:13:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791810801; cv=none; b=byhzk8QFQ3E+1Ox5dLPoDPLh9qqYtR5QtOJpBgwR1NUGC1+REYK/3VE045UaEx9gNWsUcq6zgsQnEoO8cgzlle4OBGw2qlIlI0UMi8w3sshSl2UcHE+gkav2UQ47hvDOXXn4xN6DC/0FS9pvmzo/qP5iBvWJNgQgJ4p9R2KCg9Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791810801; c=relaxed/simple;
	bh=icyyxOoZ3uUQvtxKLVLgqMPdhCEzOQs7yIU0LnfX49I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Nfxs5z4nNspotdf+6KIUGtZFugUd01wvs2XwdnQpHi5tAREsx6QDkK0niVqMJqT1jg4oCBhdBu1Mo9A6nTHT9QJB51k3v7Mo/G6VRZWDouMAUoXXcF3gp4siDITxncOTafVil1JMVhwuHtZlPENblLOx3Dq0nemP0o2210HUhEk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=cnzm8AcF; arc=none smtp.client-ip=209.85.210.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="cnzm8AcF"
Received: by mail-ot1-f45.google.com with SMTP id 46e09a7af769-8266c388b67so1703178a34.0
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 06:13:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791810799; x=1792415599; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=XvXKx9dmxgn9mBo07jTY0gfNqVtNo7qN48VsJhAxenc=;
        b=cnzm8AcFvWhzb8Z6KfqJ3yx9FW0TbdZPm3cdsjQUSa85WnMqjYdqIG4sHuusgan8O2
         eY+8rypwrvKQ+YITQZe2syb8aqWQq0nQT8kUeClCw2QlseHiNisryiJ6g49hDCjxrLVN
         XlwzUW0T+WZXYNr5uBl7RWVCu1qgrpNjzss4zm0THK4Ov2AIHFvKFsE5xOA4ANVkK4zp
         RjLrxYeCH7vlZGjSZURa+FHbCOGqjcT6Mue+Fkz259fAFSW5igBJrajGPd+EXDXwcsYX
         602YtSc2/VNGWFxZlyNLOfUsM20JYnRGeCSYvJNCgix/EVX9yeD6/H/sZzCtuMYSXl7s
         qAHQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791810799; x=1792415599;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=XvXKx9dmxgn9mBo07jTY0gfNqVtNo7qN48VsJhAxenc=;
        b=K+TRw6HhFM1h+wA6EB3r+0l1gSG7cd75U9V3yLD4BO5CEs2Xt9vLlhB+A5PbWfQCUX
         UChKmF3myWqEeJFIUR+ZwfWo9nJh/4BLP3E/EEk/bPXjTpmFDvn/X920bmMO5betsGFO
         /+c9UtufG4O571WlrGgqwY7yu6l5EauX35YXRBSblagTOd1MC8+KxmDCHSAIhk5shSfV
         UbERb0W+GWIFyPyZGe9CIiQLQao/JzOA5FfV17TLp0KVzDjbCp1zSZKv8MvNXdrRw9CH
         spUW4VLscljZribx61GID4bUGR1waCbPPdQC2NiVleHSVsInPGtv0rB9T/yJ2wRfvop3
         Zdbw==
X-Gm-Message-State: AFq9FYI78QPmw0cBR6CrLfbiXgngfJoE/Pl566qUPvLUZhv2Jq2/bdGs
	Y+P2/mrzWXF7nvgCx4vb8FphE9rhYg5wKrJ9EjOokj89Gk7DDNI4/KJDTmW+mYArS/Y=
X-Gm-Gg: AYBFou3II9qQ6+vxynMOsebWeBHb5d5jQ/4WwLUhpNPbc/Q0ku5B49OdGqao1xaNkvX
	/N+BNVVUcks3ODAN5QtuE6gPP/kUksm7vyihU2cNj7oQspSi+crOHp2Kk3UVQY5RpBoPN19zK4R
	4GNnvUdfKRp/LTLx5oadzM0/26A+CDfC9ZC7OCH2EPSRHjRpL2ptJvMV6v3LqolgXLUA4MDrPHu
	uNAcuUYHyTxI5Soe5wllt9bXJ5YEEsnRcOmDFIuD8y2+gKEJeO8j583RiGuIowrU1kRV6An9S0v
	gsNRhWZIag08b29/21QTn5xkjSnT5fWiWmvH/qyB24KsypOfEIUmRDqI7AD0q8OTKruFfHlpkl5
	oc5myvP7Yvxanae7D1qD7Ni6F542NhW32kQExMO5ak66CeEAw1RBgbJy7m/rS4UML81BeAkEpGD
	OXqwnnwFyrcxm9rizdJ/Gz8pkeY9nrieEdkUJV0F7b7sVutbLG/MI5OIAjNuf9QRMyQ2XE6iskr
	IjYe/1gd4VZNpsP4w==
X-Received: by 2002:a05:6830:6d0b:b0:81c:a8c5:633e with SMTP id 46e09a7af769-83095c2766fmr8799802a34.11.1791810799004;
        Mon, 12 Oct 2026 06:13:19 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-83039a46fc3sm10706573a34.20.2026.10.12.06.13.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 12 Oct 2026 06:13:17 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com
Subject: Re: [PATCH 2/3] NFS: Modernize the callback decode_bitmap() function
Date: Mon, 12 Oct 2026 09:13:15 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <9CCF4553-C2AB-48FB-A3A0-6ED96D50798A@hammerspace.com>
In-Reply-To: <20261012123346.123126-3-anna@kernel.org>
References: <20261012123346.123126-1-anna@kernel.org>
 <20261012123346.123126-3-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 12 Oct 2026, at 8:33, Anna Schumaker wrote:

> From: Anna Schumaker <anna.schumaker@hammerspace.com>
>
> The sunrpc function xdr_stream_decode_uint32_array() is already designed
> to decode arrays of integers with all necessary bounds checking. Update
> the decode_bitmap() function to call this and map the return value into
> something the callback handler expects.
>
> Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
> ---
>  fs/nfs/callback_xdr.c | 24 +++++++-----------------
>  1 file changed, 7 insertions(+), 17 deletions(-)
>
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 5a1f05469268..b6ecfb73d850 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -100,24 +100,14 @@ static __be32 decode_fh(struct xdr_stream *xdr, struct nfs_fh *fh)
>  	return 0;
>  }
>
> -static __be32 decode_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
> +static __be32 decode_bitmap(struct xdr_stream *xdr, __u32 *bitmap,
> +			    size_t bitmap_size)
>  {
> -	__be32 *p;
> -	unsigned int attrlen;
> +	ssize_t status;
>
> -	p = xdr_inline_decode(xdr, 4);
> -	if (unlikely(p == NULL))
> +	status = xdr_stream_decode_uint32_array(xdr, bitmap, bitmap_size);
> +	if (unlikely(status < 0))
>  		return htonl(NFS4ERR_RESOURCE);

There's a slight behavior change here..

xdr_stream_decode_uint32_array() returns -EMSGSIZE when the wire count
is larger than bitmap_size. That makes a well-formed bitmap4 of four or
more words fail CB_GETATTR and CB_RECALL_ANY with NFS4ERR_RESOURCE. The
old code accepted such a bitmap and ignored the words past bitmap[2].
knfsd never sends more than three words, but bitmap4 is variable length
and trailing zero words are legal. The client side already treats
-EMSGSIZE as success in nfs4xdr.c's decode_bitmap4()..

Minor.. any concern about that?

Ben
