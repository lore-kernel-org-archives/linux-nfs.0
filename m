Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794811621;
	b=gIa0vf1vLK3bcS4ApXyZxg05IsXsghIUKRjlW4j20AMP+b7QYNrIepMDixxfjO9vjSzB
	 UlrTDS+0SZoGwqRE5ogJZhv99n7/8yO2JVy1tk+rhieMDlS94OjrgzT3SiG7SQbvlXSP5
	 CBknp/o+D3QgFCZ+PurFpuY+c10Rej/DevHbwQQ0mol4fmxFB6crkSBak/ynwDzfqvTa4
	 AYXq2rxLrAGE2zdQsdwG3vAJm8TWOcD4HhLTIxwOK1A/Rcb0tGGe/E/JcgcJvYScwh4+7
	 vy3/TWDRYANz70KcNosox0MtzPg77o3/30OFxnVSAbGHHOZzGPX85vDMj/MxB1mcsOA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794811621;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=/SQB0s9m3nMGtRyx/o5sNyvuyYNHFqW/HgtMVBQxlv8=;
	b=ilL6tem7wRd9ScaCyxiCwFPmx7IsmTw6ZTK0770asyHuXutiY+9MAluTxV7QPsrSdTSy
	 i7QZm2WA7rUe3Q2L68rjrz3rD95X+2u36T1fiQVhcZOLsrI255pLuDmZbSLFz+Ch+o/Zo
	 bA8pCBUVOS0092rWQwJ1+ZVBEGsaS0mpWmVo6+uZCkW/LioPGCWqbhlETWkxH2ExmhKBm
	 OoaVYAgWl/nLb+SLDHnzT5fuEdG+nTVbHK2gZOBjByazRuScatIi60sUDUGYqS8oZ57lU
	 U4Mt+NInpMZDa8s3PAFODH5iZKQEpI8JHoXYUfZPz32CBKyRUd632//BwL/tmHzY7Xg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EE2A606A31C;
	Mon, 16 Nov 2026 06:47:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8EE2A606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 7D40E68B05; Mon, 16 Nov 2026 07:46:55 +0100 (CET)
Date: Mon, 16 Nov 2026 07:46:54 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Brauner <brauner@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org,
	bpf@vger.kernel.org, linux-nfs@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH 02/12] zloop: take freeze protection for writes
Message-ID: <20261116064654.GA2964@lst.de>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org> <20261114-work-fs-frozen_writes-v1-2-f5ae61c898b1@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261114-work-fs-frozen_writes-v1-2-f5ae61c898b1@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Sat, Nov 14, 2026 at 11:47:09AM +0100, Christian Brauner wrote:
> --- a/drivers/block/zloop.c
> +++ b/drivers/block/zloop.c
> @@ -514,6 +514,10 @@ static void zloop_rw_complete(struct kiocb *iocb, long ret)
>  {
>  	struct zloop_cmd *cmd = container_of(iocb, struct zloop_cmd, iocb);
>  
> +	/* A queued write still holds freeze protection. */
> +	if (req_op(blk_mq_rq_from_pdu(cmd)) != REQ_OP_READ)
> +		kiocb_end_write(iocb);

So io_uring, libario and cachefiles use the IOCB_WRITE flag on the
ioctl to make this somewhat generic.

> +	if (rw == ITER_DEST)
> +		return zone->file->f_op->read_iter(&cmd->iocb, &iter);
> +
> +	kiocb_start_write(&cmd->iocb);
> +	ret = zone->file->f_op->write_iter(&cmd->iocb, &iter);
> +	if (ret != -EIOCBQUEUED)
> +		kiocb_end_write(&cmd->iocb);
> +	return ret;

And then everyone duplicates this.  Do we want a little abstraction
for the above code + setting IOCB_WRITE, and then another one takes care
of the kiocb_end_write before or after calling into ->ki_complete?

Without that this is a lot of opencoding that feels a bit fragile.

