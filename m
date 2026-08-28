Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3733379EC1
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 23:51:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787961070; cv=none; b=KwIELNFivm2Mw9Tc6Xoxj4ue9FKActbwZCP872sdGjjH9jppM5KZrmGOTdWfW13lswMpGvD7LTmwZds5lFFzLW6emqmzj/UZNAfPKPI1QzXVSHmvgonSRmGBLsl/uglHGuRXF/wHwgzK3M2M1JbJ3otMXDMYQKsNNhge7sxtUU4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787961070; c=relaxed/simple;
	bh=VruaEEWLDUxgscjCImqJfGun1/4qPJGyjPvYP8eZ1oQ=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=dtV5ZhZJYjjFEkMNejrJf8qpvmYtIJg9iMBvyeyPuTmwdBeatPsUXX59zV5xHdvHgbSrKbGamlo4JsaeHFzW63Q1m242k5NpswCXqbTZot6tGeea+SEsxvHTuYxA5a0mrXgwHsyo/S6wJp9Tr/4tE8y4f7bFyHjYAoO0iwlZtuA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=gYhHFWEP; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=TadBkkfB; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="gYhHFWEP";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="TadBkkfB"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.phl.internal (Postfix) with ESMTP id B91B4140013F;
	Fri, 28 Aug 2026 19:51:06 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 28 Aug 2026 19:51:06 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787961066; x=1788047466; bh=rx6WZRh4bNt0JAT+Zu50ne4MqaRmiOhtFds
	OEXggZH8=; b=gYhHFWEPAQsHyoBDtB7oZN5mXT4b4cO+q5yGhZLof08b6N0Hedl
	C4GGcU1dK4A/zw8peAodVlZZvgXe6eCbYHIyY1ExoFM9Psh7IZPPBkPlAFwygr/B
	rtlF/nvMagy5Hw0EblMul6UU64LCxeVslXZwPXm9ltObCbMLU0QYazm2mEl7THF0
	qg/0kggzWX7apZ/Q/prfQigp8oWPmQ6v0yv2WGLsIRtAD4ia4b4xp3IP/wSULEok
	zITCw34tyjGaVpmJOsE9WVB0IOrQOp/TSqWneysLrKbhg4nn3Mxx+cR8Ib+zoJ5d
	Wp0QgfbDgK5bM0B8IsJNfj7kTQXaYNAbkCg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787961066; x=
	1788047466; bh=rx6WZRh4bNt0JAT+Zu50ne4MqaRmiOhtFdsOEXggZH8=; b=T
	adBkkfBipOsp1iF1K3pl4PNLLceB2THBFXY0Rgu+lqijhhwihuasGG+j11MaTg/O
	BO+Pa+2g+Dt0WJ/zHMdLe/Wnjlcxqrhpukmxj1AwBVGaC6k/UCg84ztoRDoTr0Jk
	Jq2UVMEpc1TauYqShegZJHKX1YIcCEbbOZ3fs0FiFB3PPFv0WHdI0hFiY1giqLRV
	aPgNs9Q7ck04YPSmaOdGK1aWWcVLONaXJzAYOROjTu2UCVPV9dQoZ5iCKeqt+GCJ
	9HmNwqxqZWu/+/W0zEko6MivgNz0n0RYaoIgHaErqu4S8f9udDTB1WjYy0F7j5fF
	OBXcD7nh8uQY+dVTU36cA==
X-ME-Sender: <xms:6h6SagheNnRWwMcZiQzZTgP6BS4TOS6g2CSTfTi5335_uITvaT4WAw>
    <xme:6h6SarQ9z_HwVGxR98y28PpXBvcP7VZSxU5Ss8Hh4eBj-PinoRkBAYet7WniAoqWw
    pNgpjcOx-o02zDWacP2t8QwNoRYy50eJnxnOv7xwBtAGVqlT88>
X-ME-Received: <xmr:6h6SaqXZ4AvphJjponcInWNsp_MJjuMZ-3nzEpMtcLzbuzdDe54xPsM_Omo0Oc574vsrrUjHh9KL1rPKA4hc8DpbP1vEgK4>
X-ME-Proxy-Cause: dmFkZTET5WQHtF0KpKbhxXFvJO2QqunJ/U1lIRzIvmaXL4ngjikUO/mVRxw2a2KPhYzAW2
    sdcF+vR5rE+GZ8tdS8VXecIecjvg+tXj1pshYHzCNUsgDLuAPNlunj9Jz/XofM8Qx9rjoN
    qaJ2uXV2jDq1/vH9AUfBIY1ScbqT3/Gr3PitISbziitib8KBkNZMQuEFm841+WmzhkQPyL
    cVLFTbPN64TbfEEFnFLOxINYLHxSsrTPoYbdrgZw149LnaQ6riruLf3PjBVzmsAFbbAQ5P
    4EtOXhRVSptzRPqLP8cOc2g2z0eHvv6Xbd3jf6+1JJB45Vj79bNulYN3/Yhd8BNqAFoEWH
    AOWpz/QKc+yQrSQP1XyhomkPjgVEBT8wjZpA34CyMx1dYlcWXxDN5JxPinrpIcMaEkPHp+
    4CgytfcWidX6twXe2PEWSkBrve4ikN9odeItGSWTN4i7+5Klk1pZcQ5Tb8iuZEg5DXm6mE
    D1DvLiucz7D2c5QlqV7cvX42vHWLIPXRHiZQ2NcJXPrK4CZkFqJFkFkrRA0QxkbwRvAurA
    3CyXPkBYW1CcZIsK8ogXksnHUp1wn/2T/OeTNEDS+XPq2bABk/e37zE4jz6Z6cSF2Aq5Af
    Q0fZDzTnkcwe3Zul5zumkA4jW/SUu4W3FeAXCsPjRos81/0LvvcQ50SrdlQQ
X-ME-Proxy: <xmx:6h6SanRXElsFOaGx9dG-s_ke8dhCX5nbaRNSbePK_93QhQkhuw9TMA>
    <xmx:6h6SaslIBsANDXfc16P9zfEwZEN5Rcn9WuL8x-O7eJX8xKDnJKH63w>
    <xmx:6h6Sal7zqiG6hKoGgjXRR4M3Y9SQpG6EZusALcjV-7l_ThpfQPgBdA>
    <xmx:6h6Saqhu8j68jB9CkPzrnq8LkZeNlsb1RF6rKBbAGafMI0-JhKCdnw>
    <xmx:6h6SaiFJxtuZERSZI6YlcMFUufxJ0Dt9YxYxZGK1GeSSKmtbOi25Lite>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 28 Aug 2026 19:51:03 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 =?utf-8?q?J=C3=B6rg?= Sommer <joerg@jo-so.de>
Subject: Re: [PATCH v1] NFSD: Return NFSERR_ISDIR for NFSv2 READ and WRITE on
 a non-regular file
In-reply-to: <20260828231841.282003-1-cel@kernel.org>
References: <20260828231841.282003-1-cel@kernel.org>
Date: Sat, 29 Aug 2026 09:50:59 +1000
Message-id: <178796105977.3510150.14963526293219258706@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sat, 29 Aug 2026, Chuck Lever wrote:
> Commit 0ac903d1bfdc ("NFS: NFSERR_INVAL is not defined by NFSv2")
> changed the status NFSD returns for an NFSv2 READ or WRITE of a
> symlink or other non-regular file from NFSERR_INVAL to NFSERR_IO.
> RFC 1094 defines neither an INVAL nor a SYMLINK status.
> 
> U-Boot's NFS client follows a symlink only when READ fails with
> NFSERR_ISDIR or NFSERR_INVAL. Since that commit it cannot load a
> boot image through a symlink exported by a Linux NFS server: the
> load completes with zero bytes transferred.
> 
> Solaris returns NFSERR_ISDIR when the target of an NFSv2 READ or
> WRITE is not a regular file. Return the same status from NFSD.
> Other NFSv2 procedures continue to return NFSERR_IO.
> 
> Fixes: 0ac903d1bfdc ("NFS: NFSERR_INVAL is not defined by NFSv2")
> Reported-by: Jörg Sommer <joerg@jo-so.de>
> Closes: https://lore.kernel.org/linux-nfs/apE90ZRZB8IW_AiS@jo-so.de/
> Signed-off-by: Chuck Lever <cel@kernel.org>

Reviewed-by: NeilBrown <neil@brown.name>

The only places that openSolaris returns NFSERR_ISDIR when the object
might not be a directory are in rfs_read(), rfs_write(), and
rfs_write_sync(), which is called for rfs_write().

So adding this special handling only for nfsd_proc_read() and
nfsd_proc_write() makes sense.

Thanks,
NeilBrown


> ---
>  fs/nfsd/nfsproc.c | 19 +++++++++++++++++--
>  1 file changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> index 48541ef7644f..09d360839825 100644
> --- a/fs/nfsd/nfsproc.c
> +++ b/fs/nfsd/nfsproc.c
> @@ -40,6 +40,21 @@ static __be32 nfsd_map_status(__be32 status)
>  	return status;
>  }
>  
> +/*
> + * Because NFSv2 does not have an NFSERR_SYMLINK, Solaris returns
> + * NFSERR_ISDIR when the target of a READ or WRITE is any object
> + * that is not a regular file.
> + */
> +static __be32 nfsd_map_io_status(__be32 status)
> +{
> +	switch (status) {
> +	case nfserr_symlink:
> +	case nfserr_wrong_type:
> +		return nfserr_isdir;
> +	}
> +	return nfsd_map_status(status);
> +}
> +
>  static __be32
>  nfsd_proc_null(struct svc_rqst *rqstp)
>  {
> @@ -238,7 +253,7 @@ nfsd_proc_read(struct svc_rqst *rqstp)
>  		resp->status = fh_getattr(&resp->fh, &resp->stat);
>  	else if (resp->status == nfserr_jukebox)
>  		set_bit(RQ_DROPME, &rqstp->rq_flags);
> -	resp->status = nfsd_map_status(resp->status);
> +	resp->status = nfsd_map_io_status(resp->status);
>  	return rpc_success;
>  }
>  
> @@ -271,7 +286,7 @@ nfsd_proc_write(struct svc_rqst *rqstp)
>  		resp->status = fh_getattr(&resp->fh, &resp->stat);
>  	else if (resp->status == nfserr_jukebox)
>  		set_bit(RQ_DROPME, &rqstp->rq_flags);
> -	resp->status = nfsd_map_status(resp->status);
> +	resp->status = nfsd_map_io_status(resp->status);
>  	return rpc_success;
>  }
>  
> -- 
> 2.55.0
> 
> 

