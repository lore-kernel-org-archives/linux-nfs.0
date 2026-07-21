Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EAC7373BE4
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2026 13:56:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784642216; cv=none; b=PJvtxQ07Trs1BJKv5NjZCkQ7zezcRTXs7oh+fju6wV2zMNYzFZiXXaah3umU0N4iRdUcqpPqjAhQcJkhVgPhwQC2UAKlIsOkzRvcIfZondiARF7nYYCHJcLkpnhJme5d1N5Rz7B+sOZt+5PoJcZWPCfjPBeCwhhp65zrEY8zZgY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784642216; c=relaxed/simple;
	bh=DfJMtxIlSpRwloPkGg8AB5POHQ24aqMUhwRKy/jbKYM=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=qKgCgwmSpqqOeKlJFCv/W5f1SFbClaDg4CRVrTPZSdNsvLIFjwf9ojR29GtLp7zqFHC5uSQU3Ujm3f6BR8YVRe6KhgFtIpauKmdSvyncJ7jn1/GHhOVjpJhiOzaokPC8InpKym7IvkrbFdOOYSbciC383jtdXEw1uT/0k4HOSqo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iZX3uJAK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iZX3uJAK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E8D601F00A3D
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2026 13:56:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784642215;
	bh=KE9fOivz3QCv7k7kU66xifI56H6J8rFE90uqSkwu+YI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=iZX3uJAKHwxA+MF5VMILuNRGwodMDeh31JWmfWoH+DYDkRQRFGmJkwUM8yig3Mvrw
	 abYYrgi/JuwmkeREW3Z+XSkOJk8krj5u0jcoVzpj9kWE/ni3/cRL7KA1hVpLhjbqXN
	 6XGoTCuGM5y27KkB+AJuwyT5lvq1BCioEmEwf6/Vl87CCHycPbEWqTJnvzbBnjwnlD
	 LOfTzDWJWndXBIa4QvYa7/eqyzjtoLgK0R23cMW3636I4vp7EFgMWAqfGcgbSyngz+
	 IeRFQKPUPRM5X6RPqNLKu/2eokqEGcQGfG5PAgQIIOtPoIODw9cnJzFH4UICLSELo6
	 QFb4Ec2vJQf/A==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 085D6F40068;
	Tue, 21 Jul 2026 09:56:53 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 21 Jul 2026 09:56:54 -0400
X-ME-Sender: <xms:pXpfakqJennr_Oi0ezrsrDmTTjh68N_NJWC_bBTlM96MTIDRQeXD5Q>
    <xme:pXpfalfES2j2HeezDOuz_Tc9J6yMDxsccshFy0EF2pJJaQsktNfAHIO7ZbrXleK_b
    ccxVIYentYyvq6jV0AoSvyW3beVeBRJiRZW5La9-kDEd4ofQhadgw>
X-ME-Proxy-Cause: dmFkZTEP4h+IYUV8Eml3elQvF8+7HHSU3+OCrlO+BvNn1WNPVeNYhrMKCkSSy6vxUb+ZMI
    yEympYp4604daOsFUW6ySnPbhlyVX0c8wTieBtbE9Uoh/awpbQ6QzCV7oDEA3nPuQEEr89
    gd1QPe++jggednr4lMjPiiAuzsZ+bAjT5s40nPaJj7vGRKEgRvSMXgdJJO9WRac9a2RjaY
    EuzZVXKpzCGCEciH7f829SoVcoenQu2+whXbu0BPW5IZlUiyFl3ANCJpH74aFmkoBGE/vs
    V0D3PPq7nQUOueKqOtMpz/3J6L1MX1GVWdvN8CZbl1GRS7b0fT9QJHg+6LdAIgZEN+LLK8
    Knbo5wGsjdNfIBHtqeyTyEAJkwri3z+9q99k6eCBCjunWfPxwthn9nodRdM4PeC6UzB/bj
    L/DPfizcrgY1PdaTxzY7BTrhOSSN4DLkBOHC3yKJk4wtFeypPwn5I6Klm7F2fscetl8x5i
    RfOUYvf1p0l3WNiB++TmytjrsDOFUjjCKpeSpGRFeTvBPqM9cs+/SsoJlhbZ5+VJnIc3O5
    0k1r6RJdZrClDCkQJgRDpNIrIy1O4JrscnIjMWmD0qXOF/+7HG1senuw6etexkMgcEC+li
    hp9RbrQbOutYJB8iLJBgPG3bheMNA6i8BWCsyBA5tbp0WzBui/+b2GWTjFsw
X-ME-Proxy: <xmx:pXpfatHuVl7ktxnvIObta9v2Gkuk4ygq4zmi0ZQginBexEMRSkmXMA>
    <xmx:pXpfaqH4CZXv4ukUag6L6zUGhUWUVmN9JK_pMdxAjQxr62LWkC6wkQ>
    <xmx:pXpfaiP-bKdMK1Rs9TLMNpfWitOJfliKje-hPmdQrVauQ2UBcuEl1g>
    <xmx:pXpfahEokeLIWoogbqeLJunHooaAFofqMUh8Ag8hdUTcXgRu_aj6hg>
    <xmx:pXpfahNfTP1l_5wBZAUrUo7TKMa9bRTEJo4yoItCikfaawvOpGPvT8kQ>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id D4DB0B6006E; Tue, 21 Jul 2026 09:56:53 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Ac-oRgenOPC3
Date: Tue, 21 Jul 2026 09:56:33 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Message-Id: <9a005347-837e-4a0b-b2a7-972f3cb59052@app.fastmail.com>
In-Reply-To: <20260708213610.19001-1-snitzer@kernel.org>
References: <20260708213610.19001-1-snitzer@kernel.org>
Subject: Re: [PATCH] NFS/localio: fix nfs_local_dio_misaligned tracepoint
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Wed, Jul 8, 2026, at 5:36 PM, Mike Snitzer wrote:
> The intended focus of nfs_local_iters_setup_dio()'s call to
> trace_nfs_local_dio_misaligned() is on the middle segment being
> misaligned, yet the @offset passed in was local_dio->start_len.
> It would appear this was a cut-n-paste bug from the preceding
> nfs_local_iter_setup() call that passes local_dio->start_len.
>
> Fix this by passing the @offset as local_dio->middle_offset and
> calculate the start segment's offset rather than assume.
>
> Example traces, before this fix:
>
>    python3-32744   [006] .l... 132946.352360:
>    nfs_local_dio_write: fileid=00:33:1286 fhandle=0xf1f7c10b
>    offset=1048759 count=1048576 mem_align=4 offset_align=512
>    start=1048759+329 middle=1049088+1048064 end=2097152+183
>
>    python3-32744   [006] .l... 132946.352360:
>    nfs_local_dio_misaligned: fileid=00:33:1286 fhandle=0xf1f7c10b
>    offset=329 count=1048064 mem_align=4 offset_align=512
>    start=329+329 middle=1049088+1048064 end=2097152+183
>
> After this fix:
>
>    python3-32744   [006] .l... 132946.352360:
>    nfs_local_dio_write: fileid=00:33:1286 fhandle=0xf1f7c10b
>    offset=1048759 count=1048576 mem_align=4 offset_align=512
>    start=1048759+329 middle=1049088+1048064 end=2097152+183
>
>    python3-32744   [006] .l... 132946.352360:
>    nfs_local_dio_misaligned: fileid=00:33:1286 fhandle=0xf1f7c10b
>    offset=1049088 count=1048064 mem_align=4 offset_align=512
>    start=1048759+329 middle=1049088+1048064 end=2097152+183
>
> Cc: stable@vger.kernel.org

Do you have a fixes tag for this commit?

Thanks,
Anna

> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  fs/nfs/localio.c  | 2 +-
>  fs/nfs/nfstrace.h | 5 ++++-
>  2 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
> index f42b6112a613..63c38dea50cc 100644
> --- a/fs/nfs/localio.c
> +++ b/fs/nfs/localio.c
> @@ -446,7 +446,7 @@ nfs_local_iters_setup_dio(struct nfs_local_kiocb 
> *iocb, int rw,
> 
>  	if (unlikely(!iocb->iter_is_dio_aligned[n_iters])) {
>  		trace_nfs_local_dio_misaligned(iocb->hdr->inode,
> -			local_dio->start_len, local_dio->middle_len, local_dio);
> +			local_dio->middle_offset, local_dio->middle_len, local_dio);
>  		return 0; /* no DIO-aligned IO possible */
>  	}
>  	iocb->end_iter_index = n_iters;
> diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
> index c70debb88aa1..2e1932962a81 100644
> --- a/fs/nfs/nfstrace.h
> +++ b/fs/nfs/nfstrace.h
> @@ -1772,7 +1772,10 @@ DECLARE_EVENT_CLASS(nfs_local_dio_class,
>  		__entry->count = count;
>  		__entry->mem_align = local_dio->mem_align;
>  		__entry->offset_align = local_dio->offset_align;
> -		__entry->start = offset;
> +		if (local_dio->start_len)
> +			__entry->start = local_dio->middle_offset - local_dio->start_len;
> +		else
> +			__entry->start = 0;
>  		__entry->start_len = local_dio->start_len;
>  		__entry->middle = local_dio->middle_offset;
>  		__entry->middle_len = local_dio->middle_len;
> -- 
> 2.43.0
