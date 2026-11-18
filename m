Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795045944;
	b=SkZbMiaXNwj+PKqn/9MpuJsaBc6sHXz9XVfgQ89XIC5+VyWm1cfBvK9twERT3NW4fE2R
	 Fay3iLhhr9Mnw7vY4s61nHCoMh0a7B6M/mrj3N6ko9NzUD/hgz92iy+k9iplu9bdJ8ijh
	 CCVBN37PDy5vLoma5nmBhktLehzbjZAqiKeP9BwgSdFW5FR47yWlM5aooTFAZp5KRH8vZ
	 xbHup/A5uewCkpx1LVHqqcpiRKQYbMK/HKgPcDdgV1jWCbErWNAdF8EdfAj5vioeo0A7T
	 /hDkYg6JNJ2U1PZBSDKwsexhsukE+AnxJBvkJi4+94NxqovsFe9zWOAEM60U7CQ875A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795045944;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=YKdVs9D+ax7qdcO60WNL2/JpggVcFsh91ItE3dGMV50=;
	b=C1rbsZAu6Jvx8GjL5G0A7ukkalHFbUG6d1tl7L8/b4aNTSBRfxHhu78IJN5AyNERbD2n
	 Y9uBhKtfPFTw6J9CipBfK6lK//kzC0Nmi1E4xyv9PIg9BIqfwr4bozpS4RMb5eKchDGUv
	 3+Z1m+OPImsGwEnmzrZSyFdRo4+/AiOsC0GB3TTzwZCovn4CPmETu95fIQkgML0Wy8qkC
	 N+wql+NRnVx1ehd1Y0wPUhatZvdcz0jzD8CKHYOLmdDaO+RfROAToWkRoOrNIGn+Vx8aB
	 U5aqqdpjGvOXI8VdH/nx02dGSMc4weUJySwmaGSJkyqzwmHGQQl6My23rTRlFwljMKw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XqC1qN51;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8628F606A325
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 23:52:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XqC1qN51
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 351C51F000C5
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 23:52:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795045944;
	bh=YKdVs9D+ax7qdcO60WNL2/JpggVcFsh91ItE3dGMV50=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=XqC1qN51YcY2CZ2J/kYalTHxQtS/Q5z35WkwcflrlZF8eII24Ttc8LpN2IGs7QIH/
	 di2L+SvDtZMjV1FXmdqy6mmi9tU3HpBdew+OyKnhsXwGD4U/tv2+L84YKSnit59xse
	 zbcW6/t7oOy1+b2hul8sUfhCwWQlfoO6Rj3pFOH0ARxRsHfOumwdN63tdULZ6PBdZd
	 gCfA6RWJfXk9XUAnqulNBKHB/Fj9h23M6Go9LXmfxv/yNhjQ//JC+MeCUPmWo1gipK
	 Mq42zUeSOEdyq8pihhejOQKocicYQFYFKm2E6rzWYgnSEiJqLEmfSOpWYPpx825Ud/
	 DiZGre0dYcLjA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6B3FAF40067;
	Wed, 18 Nov 2026 18:52:23 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Wed, 18 Nov 2026 18:52:23 -0500
X-ME-Sender: <xms:Nzr-ao2MmzwVPTcn-q4W2WoNup_CuOuj7h5w4jEcNVUNAk8Dn5djTw>
    <xme:Nzr-at5ZDELHlpHr35nZ_RETsF6ueTJjnNc81RvcpyCqdf7VIpACOKt1Nf_AmrPqC
    JX8WFEFRc1MVqGv58OYeVZec7GedhyctwAGEDbQ91EiizmIbcjbEFJ74w>
X-ME-Proxy-Cause: dmFkZTFN7gJhcIVvi26vDH15KVIQI0Ac44bP1B5vBjWYOPHDMBZGT+FC7W6MjsCH9fGnpL
    T94KcstVNYMbSATj33ZdY142l0c4TMeJT0z3eNfmfNwHR9jj4jtpzFc1y6ZDzmZQK3W45A
    FrLpx36gAcTl6MQjzrqbW2wA8a2+0+dUM3t64RaMLn8B5YG5YKUJZbgoRx1UwkWVSe3U77
    oMvS55Feswqi3Dr3c6Iz5ScKkXpSj1Y4U0J7H8GKWqj+W2OEABRS8Xcp4kbE2HFY9KHLRO
    VyzjKii6KBkWo2q1r/1mkak+IimHkHDlzdimK53Ae7eVjmvpjLSzS4KVCusYWuc7kXNGBP
    BNrVbR4WyXpVJ9T/8kBZT9NqH2u/eR59GnK16H1Q7KQb2zECir/uP4vr2M7GeMV96yqVk6
    PSSZGJAEbeSB9B2EVsUMuCgvpbNZlZXFE+WnA8u81Nj9Bygz0iLVuSOkdVtUjJDZrj3Ljo
    FbZvapoNtG2m0NdyHyOQOD/vRlgoACbuKbWARa4yylbyh/EmkdRpaqTyUE+Es6X576CK9x
    GBtvWE9VqGFFYg6mtL6XnbgEumyNfFztWrbNJjSevigX2g3AOsni0PTTzYw1VeCR+F0QLI
    c85RZsqcFfLezqIVl2ibtSN3EWX1/AxQkxNv0hjmf5+QFwoFZxFDrVz/TPuA
X-ME-Proxy: <xmx:Nzr-aucFhKcYCwXXDc_gwbDNYgHVHv1XXNYQDlYu4YovHu9RcuzgoA>
    <xmx:Nzr-amAbmIxqvpJzZZS4MjLHvcvLXsQt1gli7n0lu8rfEBnJ7tk_yQ>
    <xmx:Nzr-ap8dHa91g_aW1NbV4FCS_2GwHbkzS4aOz3ewE_MPiSeQKlpwvw>
    <xmx:Nzr-apLELDdoRUH4rlsQ3qfFYfkG0emS9NUwdRz74NY-F697AkqCoA>
    <xmx:Nzr-aqjxLRF8WIHl8GSzfuZlQry_tqQAD3WjH-VLX4MNgnhyRYzQAUu0>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4550FB6006E; Wed, 18 Nov 2026 18:52:23 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: Ayo9TARvgBrk
Date: Wed, 18 Nov 2026 18:52:01 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Mike Snitzer" <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Message-Id: <9ed06167-ca76-4156-95f1-814430ff8ca0@app.fastmail.com>
In-Reply-To: 
 <d416d82b18df69d694484ca649c43e8ef5066ef7.1795024981.git.bcodding@hammerspace.com>
References: <cover.1795024981.git.bcodding@hammerspace.com>
 <d416d82b18df69d694484ca649c43e8ef5066ef7.1795024981.git.bcodding@hammerspace.com>
Subject: Re: [PATCH 2/4] pNFS/flexfiles: pace writes that have no layout and can't use
 the MDS
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Ben,

On Wed, Nov 18, 2026, at 1:36 PM, Benjamin Coddington wrote:
> From: Benjamin Coddington <bcodding@hammerspace.com>
>
> When a write has no layout segment and its file's layouts carry
> FF_FLAGS_NO_IO_THRU_MDS, ff_layout_pg_get_mirror_count_write() returns
> -EAGAIN.  nfs_writepages() and the O_DIRECT reschedule path resend it at
> once, so writers spin for as long as pnfs_update_layout() has no layout
> to give: while NFS_LAYOUT_BULK_RECALL is set, while LAYOUTGETs are
> blocked, and for the 120 seconds after NFS4ERR_LAYOUTUNAVAILABLE.
>
> The check also tests a bit on the layout header.  Once that header has
> been freed, a new one starts without the bit and the write goes through
> the MDS.  ff_layout_pg_init_write() has no check at all: when
> pnfs_generic_pg_check_layout() drops an invalidated segment, the rest of
> the descriptor's writes go through the MDS.
>
> Handle both places the way ff_layout_pg_init_read() handles reads: test
> the inode's NFS_INO_NO_IO_THRU_MDS bit, return -ERESTARTSYS to a killed
> or exiting task, and honour io_maxretrans on soft mounts.  Mark a
> refusal with a new pg_nolayout descriptor bit, and have nfs_writepages()
> and nfs_direct_write_reschedule() wait a second before they resend,
> after the pass that was refused has unlocked its folios and requests.
> Writes marked pg_allow_mds by nfs_writepage_locked() still go through
> the MDS.
>
> The test is ff_layout_inode_no_fallback_to_mds(), which
> ff_layout_pg_init_read() now uses too, and the refusal is
> ff_layout_pg_refuse_write().  Emit the MDS-fallback tracepoint only
> when the write does go through the MDS, and a new
> pnfs_mds_fallback_write_refused tracepoint when it is refused.
>
> Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in 
> pg_get_mirror_count_write")
> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
> ---
>  fs/nfs/direct.c                        |  2 +
>  fs/nfs/flexfilelayout/flexfilelayout.c | 66 ++++++++++++++++++++------
>  fs/nfs/nfs4trace.c                     |  1 +
>  fs/nfs/nfs4trace.h                     |  1 +
>  fs/nfs/pagelist.c                      |  1 +
>  fs/nfs/write.c                         |  2 +
>  include/linux/nfs_page.h               |  5 ++
>  7 files changed, 64 insertions(+), 14 deletions(-)
>
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index a3c6e8f4ea06..e6a2c6436b44 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -626,6 +626,8 @@ static void nfs_direct_write_reschedule(struct 
> nfs_direct_req *dreq)
>  		}
>  	}
> 
> +	if (desc.pg_error == -EAGAIN && desc.pg_nolayout)
> +		ssleep(1);

Is there any possibility that the sleep length would be modified sometime
in the future? I ask, because the nfs_writepages() gets the same modification
with a hardcoded "1" here and my worry is that if we ever need to change this
length in the future, we might accidentally update one function and miss the
other. Maybe this whole if-statement would be better as an inline function that
takes the error and struct nfs_pageio_descriptor? 

Alternatively, is there any way to handle the sleep directly in the flexfiles
code and not in the generic client since that's the only way to reach this point?

Thanks,
Anna

>  	if (put_dreq(dreq))
>  		nfs_direct_write_complete(dreq);
>  }
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 2b0a0af469fb..4eb12bbb7838 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -982,6 +982,45 @@ static bool ff_layout_pg_retry_wait(struct 
> nfs_pageio_descriptor *pgio)
>  	return true;
>  }
> 
> +/*
> + * Returns true if the inode's layouts forbid I/O through the MDS.
> + */
> +static bool ff_layout_inode_no_fallback_to_mds(struct inode *inode, 
> u32 iomode)
> +{
> +	return nfs_no_io_thru_mds(inode);
> +}
> +
> +/*
> + * Refuse a write that has no layout segment and can't go through the 
> MDS:
> + * -EAGAIN so that the caller resends it, or a hard error when the 
> caller
> + * should give up.  pg_nolayout tells a caller that resends at once to
> + * wait first, once it has dropped its locks.
> + */
> +static void ff_layout_pg_refuse_write(struct nfs_pageio_descriptor 
> *pgio,
> +				      struct nfs_page *req)
> +{
> +	struct nfs_server *server = NFS_SERVER(pgio->pg_inode);
> +
> +	trace_pnfs_mds_fallback_write_refused(pgio->pg_inode, req_offset(req),
> +					      req->wb_bytes, IOMODE_RW,
> +					      NFS_I(pgio->pg_inode)->layout,
> +					      NULL);
> +	if (server->flags & (NFS_MOUNT_SOFT | NFS_MOUNT_SOFTERR) &&
> +	    io_maxretrans && req->wb_nio > io_maxretrans) {
> +		if (server->flags & NFS_MOUNT_SOFTERR)
> +			pgio->pg_error = -ETIMEDOUT;
> +		else
> +			pgio->pg_error = -EIO;
> +		return;
> +	}
> +	if (fatal_signal_pending(current) || nfs_current_task_exiting()) {
> +		pgio->pg_error = -ERESTARTSYS;
> +		return;
> +	}
> +	pgio->pg_nolayout = 1;
> +	pgio->pg_error = -EAGAIN;
> +}
> +
>  static void
>  ff_layout_pg_get_read(struct nfs_pageio_descriptor *pgio,
>  		      struct nfs_page *req,
> @@ -1108,7 +1147,7 @@ ff_layout_pg_init_read(struct 
> nfs_pageio_descriptor *pgio,
>  	 * FF_FLAGS_NO_IO_THRU_MDS may itself be gone by now, which is why
>  	 * this asks the inode and not the hdr.
>  	 */
> -	if (!nfs_no_io_thru_mds(pgio->pg_inode))
> +	if (!ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_READ))
>  		goto out_mds;
>  retry_nolseg:
>  	/* Retry getting layout segment if lower layer returned -EAGAIN */
> @@ -1156,9 +1195,13 @@ ff_layout_pg_init_write(struct 
> nfs_pageio_descriptor *pgio,
>  			return;
>  		}
>  	}
> -	/* If no lseg, fall back to write through mds */
> -	if (pgio->pg_lseg == NULL)
> -		goto out_mds;
> +	if (!pgio->pg_lseg) {
> +		if (pgio->pg_allow_mds ||
> +		    !ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_RW))
> +			goto out_mds;
> +		ff_layout_pg_refuse_write(pgio, req);
> +		return;
> +	}
> 
>  	/* Use a direct mapping of ds_idx to pgio mirror_idx */
>  	if (pgio->pg_mirror_count != FF_LAYOUT_MIRROR_COUNT(pgio->pg_lseg))
> @@ -1225,21 +1268,16 @@ ff_layout_pg_get_mirror_count_write(struct 
> nfs_pageio_descriptor *pgio,
>  	}
>  	if (pgio->pg_lseg)
>  		return FF_LAYOUT_MIRROR_COUNT(pgio->pg_lseg);
> +	if (!pgio->pg_allow_mds &&
> +	    ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_RW)) {
> +		ff_layout_pg_refuse_write(pgio, req);
> +		goto out;
> +	}
> 
>  	trace_pnfs_mds_fallback_pg_get_mirror_count(pgio->pg_inode,
>  			0, NFS4_MAX_UINT64, IOMODE_RW,
>  			NFS_I(pgio->pg_inode)->layout,
>  			pgio->pg_lseg);
> -	if (!pgio->pg_allow_mds && NFS_I(pgio->pg_inode)->layout &&
> -	    ff_layout_hdr_no_fallback_to_mds(NFS_I(pgio->pg_inode)->layout)) {
> -		/*
> -		 * FF_FLAGS_NO_IO_THRU_MDS: no current lseg but the server's
> -		 * policy forbids MDS fallback.  Surface -EAGAIN so writeback
> -		 * retries rather than silently issuing the WRITE via MDS.
> -		 */
> -		pgio->pg_error = -EAGAIN;
> -		goto out;
> -	}
>  	/* no lseg means that pnfs is not in use, so no mirroring here */
>  	nfs_pageio_reset_write_mds(pgio);
>  out:
> diff --git a/fs/nfs/nfs4trace.c b/fs/nfs/nfs4trace.c
> index 3fdc013f56d8..93a84f546de8 100644
> --- a/fs/nfs/nfs4trace.c
> +++ b/fs/nfs/nfs4trace.c
> @@ -25,6 +25,7 @@ EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_mds_fallback_read_done);
>  EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_mds_fallback_write_done);
>  EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_mds_fallback_read_pagelist);
>  EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_mds_fallback_write_pagelist);
> +EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_mds_fallback_write_refused);
>  EXPORT_TRACEPOINT_SYMBOL_GPL(pnfs_ds_connect);
> 
>  EXPORT_TRACEPOINT_SYMBOL_GPL(ff_layout_read_error);
> diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
> index b5c89eeef2bc..94ed6b833a28 100644
> --- a/fs/nfs/nfs4trace.h
> +++ b/fs/nfs/nfs4trace.h
> @@ -2115,6 +2115,7 @@ DEFINE_PNFS_LAYOUT_EVENT(pnfs_mds_fallback_read_done);
>  DEFINE_PNFS_LAYOUT_EVENT(pnfs_mds_fallback_write_done);
>  DEFINE_PNFS_LAYOUT_EVENT(pnfs_mds_fallback_read_pagelist);
>  DEFINE_PNFS_LAYOUT_EVENT(pnfs_mds_fallback_write_pagelist);
> +DEFINE_PNFS_LAYOUT_EVENT(pnfs_mds_fallback_write_refused);
> 
>  DECLARE_EVENT_CLASS(nfs4_deviceid_event,
>  		TP_PROTO(
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index aa6d7b658d79..9a8731de6f5b 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -872,6 +872,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor 
> *desc,
>  {
>  	desc->pg_moreio = 0;
>  	desc->pg_allow_mds = 0;
> +	desc->pg_nolayout = 0;
>  	desc->pg_inode = inode;
>  	desc->pg_ops = pg_ops;
>  	desc->pg_completion_ops = compl_ops;
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index ec6b771b8dbe..005d4b795b80 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -693,6 +693,8 @@ int nfs_writepages(struct address_space *mapping, 
> struct writeback_control *wbc)
>  		nfs_pageio_complete(&pgio);
>  		if (err == -EAGAIN && mntflags & NFS_MOUNT_SOFTERR)
>  			break;
> +		if (err == -EAGAIN && pgio.pg_nolayout)
> +			ssleep(1);
>  	} while (err < 0 && !nfs_error_is_fatal(err));
>  	nfs_io_completion_put(ioc);
> 
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index d64332afc374..f9b22b990de7 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -125,6 +125,11 @@ struct nfs_pageio_descriptor {
>  	 * layout: the write goes through the MDS instead of waiting for one.
>  	 */
>  	unsigned char		pg_allow_mds : 1;
> +	/*
> +	 * Set by a layout driver that refused a write with -EAGAIN for lack
> +	 * of a layout, so that a caller that resends waits first.
> +	 */
> +	unsigned char		pg_nolayout : 1;
>  };
> 
>  /* arbitrarily selected limit to number of mirrors */
> -- 
> 2.53.0
