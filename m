Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC55B5964F2
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 17:35:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788888935; cv=none; b=NU8KkY/TXc0MToLCNJRu+bhhSlB9VLn4H5LtblGXUpGjEIOluNLlHyCdw3jbFn4ZYUBjZj7f0+FOylPWWgPMcbUTW/vUwvTVY6z4hQ4BqFdS/XYIOtc8KrSTbnSCp4nps1zsx3dsyNw1otnx58L9rrAjOGNuc+MXwbeJC9TyXRw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788888935; c=relaxed/simple;
	bh=6EanbETDgQqF0G9daYFwJg4H/tVN2fqkZPXa0Fvu6yo=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=l73BDyRwiG+x8s8+QJJst1Objj/tjZPjgipsP1gc/+DM45D8Ewrns5EuudlEUdnkF4DLN6pcO5JLl0oHL/q5o5Fb3/ZF5thOuzbCIaEr0Zba5lEPmEFshNM8g7BLBxyTa7FZNk0ap3gkiVL8l+hdh6jKQft6VJoZdKn1y3G2loc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SKOW6M1s; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SKOW6M1s"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 39FE31F00AC4;
	Tue,  8 Sep 2026 17:35:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788888933;
	bh=4Ek62X6jLcDvYvkQdE0QRdRQ+an4rGznH5sNIHfSRgQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=SKOW6M1sHoytJ3Y3BjSJY1imP3wrXtWhIf2qSCfRRZMQnoCZi8DxdGuiw+kTisKt8
	 2dqvxY3eXYnCb3O/8w5ClSshp8k4P4g/JsUsyDli1ECKN05WM4Gmi/PZhF+i/t0yeG
	 i3EzSzBdFMzgW8xhV0JMEb4DDwT45U3u0MbeLkCOVrlX2wyAZePr1LrSy/KPAH9UNb
	 wbHU42kAqZk0ivsGzaJYlq/Xf3C2QK6O41KMexCHJMfL1gT7AIDkbOBCFV4N489Viq
	 axn1shR+8c/n20tZuKUS/1IPGVVxU8lZgUHAS59XL5aAi//OYGwubGUkzxFgJf8doV
	 T0K/Clh/VzyNA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3FEC5F40068;
	Tue,  8 Sep 2026 13:35:32 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 08 Sep 2026 13:35:32 -0400
X-ME-Sender: <xms:ZEegaoygM8CgNQrhlYdB73OTy8jRV1jPGP7w1FtluThOjdzeY7qWJw>
    <xme:ZEeganH313z7ULjNH47xMZEjGReYcK9nr6MUoEsja_rbXmbjcFl-H4wuuCXVkMk6X
    R2XoqHoCsoTpx3lGnIaG9NxA1dQUWj8MWQQt5efkW663z0qmyZh-t5F>
X-ME-Proxy-Cause: dmFkZTF0S/zlk2PR2MXbyB2WRLC6fxdti1RkNnrqEwtrXwiC7OpAV35IQznJa/9B43/ntY
    Y0tG6HkdGfgQFT5D/oafuRbXy7JTxgELSKoPZE5iTdhhnthNaspNQES/AVhUMO+HvXL+zs
    XsBuBz7zCvN0qJAdpql1thKV0SCBKOECDp+1ctu5Hc3Th69w1eJHc+KbJHXPMl69jF5isR
    BmCCwvaxg/bDVwhI3gK6RAVeYxPOmqyJhSpdIUWHbrvdKkImkIS11Kw2S84BufuM8kejzL
    gqDaqOgRdoMGCmje6P8MxIl1L1rQGxoRO6g/cCO8+K9UEkIe/ws//qisCLc8TDl2gTRPsI
    5hJBCBi/2jbg+RikjPLAQp9MWsVVYkc9HMWCpwOhxKNHwCoCWVhhohgnuOyHmqIFutTPyn
    z3L48tIu5+dwB9SnZYXEOTdov6UNydBsT6TimA/LrJEHDo5LALuZOv9DqcP4prU3XY/SWX
    hrmHDwreuOgyPx5b1eguURODNrp4m9QhppSz4bpXBvCq+z5Vf3kxrcA23E+IGluT6Eatzz
    CghWn7rL7CALDc3OzYU798DfRAeu8IouRDIDyG0jWP8Nm6gdrv13xLmg/BtLJt9VGzGJZG
    ZytcW9WIf9yKUBdtvzf3Rkr/SidUfqV8njxkh1dtP2fMd6kE3YMkmaEVbGhA
X-ME-Proxy: <xmx:ZEegasdAHkPsA5Yx2ZtvIwpjsZ79TBLjczf5lhe6mojcGB1eDAwdFw>
    <xmx:ZEeganjOde_LcpGutJFbSBwp_lm8g3Lw2lo4TroKYtMuBKrJVBe8qw>
    <xmx:ZEegakyIvpk4MrUqNFWgxcoDanDSocqU2InPv3fiAKVSe9rOmHVuDA>
    <xmx:ZEegajNv1MHqG3p_Ni5MAiNOMy0JB_E0ilxmhfwVnkIrn7d0oxDeEA>
    <xmx:ZEegalWhZy4PjnaYupZza1WL2i1WMAbAJ3i2LCc7rruN1CeE2mFYR6TY>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 2050DB6006E; Tue,  8 Sep 2026 13:35:32 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AEpWtzEVLx4J
Date: Tue, 08 Sep 2026 13:35:10 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, "Jonathan Curley" <jcurley@purestorage.com>,
 "Mike Snitzer" <snitzer@kernel.org>, "Jeff Layton" <jlayton@kernel.org>
Message-Id: <15ea408a-5e87-4a65-ac94-10e357683a8d@app.fastmail.com>
In-Reply-To: 
 <a906e6ed5bd3fd560ace313a6b64491e1da835ab.1788453839.git.bcodding@hammerspace.com>
References: <cover.1788453839.git.bcodding@hammerspace.com>
 <a906e6ed5bd3fd560ace313a6b64491e1da835ab.1788453839.git.bcodding@hammerspace.com>
Subject: Re: [PATCH v2 1/6] NFSv4.1/pnfs: suspend pNFS on NFS4ERR_TOOSMALL from
 LAYOUTGET
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Ben,

On Fri, Sep 4, 2026, at 8:56 AM, Benjamin Coddington wrote:
> If the layout for the requested range is larger than the size the
> client advertised in loga_maxcount, RFC 8881 Section 18.43.3 has the
> metadata server return NFS4ERR_TOOSMALL.  The client caps
> loga_maxcount at a single page, so a flexfiles server that stripes a
> layout segment across several dozen data servers produces this error
> today.
>
> The client has no handling for it: nfs4_stat_to_errno() maps the
> error to -ETOOSMALL during decode, which nothing in the layoutget
> path recognizes and nfs_error_is_fatal() does not consider fatal, so
> pnfs_update_layout() clears the layout fail bit and returns no
> segment.  The I/O falls back to the MDS, but because no fail bit was
> set, every subsequent pageio attempt sends another LAYOUTGET that is
> doomed to the same NFS4ERR_TOOSMALL.  Files whose layouts do not fit
> the reply buffer never use pNFS and pay an extra round trip on every
> pageio.
>
> Map -ETOOSMALL to -EMSGSIZE in the layoutget exception handler and
> have pnfs_update_layout() treat it like NFS4ERR_LAYOUTUNAVAILABLE:
> mark the layout mode as failed and fall back to I/O through the MDS.
>
> Fixes: d600ad1f2bdb ("NFS41: pop some layoutget errors to application")
> Cc: stable@vger.kernel.org
> Assisted-by: Claude:claude-opus-4-8
> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfs/nfs4proc.c | 8 ++++++++
>  fs/nfs/pnfs.c     | 2 ++
>  2 files changed, 10 insertions(+)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 04b1987115d5..e41c792a2725 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -9680,6 +9680,14 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
>  	case -NFS4ERR_BADLAYOUT:
>  		status = -EOVERFLOW;
>  		goto out;
> +	/*
> +	 * NFS4ERR_TOOSMALL means the layout for the requested range
> +	 * exceeds what the client advertised in loga_maxcount (see
> +	 * RFC8881 section 18.43.3).
> +	 */
> +	case -ETOOSMALL:

Should this be NFS4ERR_TOOSMALL instead of ETOOSMALL?

Thanks,
Anna

> +		status = -EMSGSIZE;
> +		goto out;
>  	/*
>  	 * NFS4ERR_LAYOUTTRYLATER is a conflict with another client
>  	 * (or clients) writing to the same RAID stripe except when
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 4f9c0f639014..c5d1951d5400 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2331,6 +2331,8 @@ pnfs_update_layout(struct inode *ino,
>  			break;
>  		case -ENODATA:
>  			/* The server returned NFS4ERR_LAYOUTUNAVAILABLE */
> +		case -EMSGSIZE:
> +			/* The layout exceeded loga_maxcount (NFS4ERR_TOOSMALL) */
>  			pnfs_layout_set_fail_bit(
>  				lo, pnfs_iomode_to_fail_bit(iomode));
>  			lseg = NULL;
> -- 
> 2.53.0
