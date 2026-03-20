Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0489C35F8B2;
	Fri, 20 Mar 2026 07:53:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773993236; cv=none; b=rVeHBv2XBG17gNefKJY1sFIZ5MmtUb9YHvA5Y1GzDPpoeqwrwWG3lu8bUL30+euef/DnTtI5sBaLDMzBddJu7TwZyuFDOtuQanr7Wsj9lb2Z7ZAix8oLIkI6Cay8aKo8lVU4+THv4ailqe+w8s/ojLrXDTMS5phGes/c+LurcKg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773993236; c=relaxed/simple;
	bh=3RFvoi5Ht5aX49NW/Q/r7sHDm6oU7s0JuLpK3Hhp0tI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=upMdPuOTgu5Q7/pNZunlhztO0r7eggPwC8LJNu1370XUIuouyvzK5GdrqZOTEVYW6duOiHIhURxxyLRacWYTwHUwM9uk0u2TGW5egoTb5z5++t4sqUwIWgpYBErys8KSeInHbW7xWnHWOqRipsDondBMxqJMOT6NKFNty6lGs/I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 8E26A6732A; Fri, 20 Mar 2026 08:53:48 +0100 (CET)
Date: Fri, 20 Mar 2026 08:53:48 +0100
From: Christoph Hellwig <hch@lst.de>
To: alistair23@gmail.com
Cc: chuck.lever@oracle.com, hare@kernel.org,
	kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org,
	kbusch@kernel.org, axboe@kernel.dk, hch@lst.de, sagi@grimberg.me,
	kch@nvidia.com, hare@suse.de,
	Alistair Francis <alistair.francis@wdc.com>
Subject: Re: [PATCH v7 5/5] nvmet-tcp: Support KeyUpdate
Message-ID: <20260320075348.GC14616@lst.de>
References: <20260304053500.590630-1-alistair.francis@wdc.com> <20260304053500.590630-6-alistair.francis@wdc.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260304053500.590630-6-alistair.francis@wdc.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

>  static void nvmet_tcp_free_cmd_buffers(struct nvmet_tcp_cmd *cmd);
> +#ifdef CONFIG_NVME_TARGET_TCP_TLS
> +static int nvmet_tcp_tls_handshake(struct nvmet_tcp_queue *queue,
> +				   enum handshake_key_update_type keyupdate);
> +#endif

Can we find a way to just avoid the ifdefered here and just rely on
compiler dead code elimination?

> +#ifdef CONFIG_NVME_TARGET_TCP_TLS
> +static bool nvmet_tls_key_expired(struct nvmet_tcp_queue *queue, int ret)
> +{
> +	return ret == -EKEYEXPIRED &&
> +		queue->state != NVMET_TCP_Q_DISCONNECTING &&
> +		queue->state != NVMET_TCP_Q_TLS_HANDSHAKE;
> +}
> +#else
> +static bool nvmet_tls_key_expired(struct nvmet_tcp_queue *queue, int ret)
> +{
> +	return false;
> +}
> +#endif

This is a pretty clear candidate for IS_ENABLED().

> +	spin_lock_bh(&queue->state_lock);
> +	if (queue->state == NVMET_TCP_Q_TLS_HANDSHAKE) {
> +		/* Socket closed during handshake */
> +		tls_handshake_cancel(queue->sock->sk);
> +	}
> +	if (queue->state != NVMET_TCP_Q_DISCONNECTING) {
> +		queue->state = NVMET_TCP_Q_DISCONNECTING;
> +		kref_put(&queue->kref, nvmet_tcp_release_queue);
> +	}

switch on the queue state?

> +	ret = nvmet_tcp_tls_handshake(queue, HANDSHAKE_KEY_UPDATE_TYPE_RECEIVED);

Overly lone line.

>  		if (unlikely(ret < 0)) {
> +			if (nvmet_tls_key_expired(queue, ret))
> +					goto done;

This has extra indentation.

