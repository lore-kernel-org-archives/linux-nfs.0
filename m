Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794658799;
	b=VWy/CcAqOtGTtNajuySqQ73viZ+3/dj24oZC9OKEodrXkZYWpBbF3vgWGhtXAAWdvm6C
	 UG/JsuXmoy0NmklK5IzAXFhw1KlxE/Vndpycfo+zdElYtUGGGSxMXx0Gs/PmizPl8U8n9
	 Y4HabxbmjGzcGYJkwcYErttCpyCyqRTUqGDvc52J4eyovY4lX8xjCuZxhYIMeBWAJxigE
	 Yo7d4w9YAe6kXKrOesEmxhEraRDUwdI4z6ciYJNLJcL2Mxvf8otCShjlJzXlldc7rqHNd
	 Az0tUT5f39/Gjuf1uikfe5Uw7D1gN5Xz2PzQvhIZNULEeIXiCiZdn+QrFZbN9gkRSMA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794658799;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To;
	bh=nkM3J4QAu8kIsGHpB1EKb0NRF0JxtY2T/gqGpQ/nt0Q=;
	b=5f1gg/4H3WYdT3v14bBgi0T3FJ5f/f6LiC5EjP98U+Po9ZUnrRFJ06YqUy2ylV0LRuOI
	 LhlIYYhEovBPZpJLPMnhJqsOZKKDFw4uNeOt9acrNQgKkA123jNdFHF+pKO92W+OIfdvl
	 btoBCb1TLxf90rMknR+yH/8YrJTOET/KgdXdSxOvXuuagCkjfOuXyIONj0w/f/u7OlT5i
	 n+WeesPVD6efvDUlGwKPCBCDiWDY0kpHpdIkzu/D3p7cmTkePJQpe4OLKrj9phimBbGKR
	 u206Ye0lzq+UeBylb498aQzln8v2xSi3a1xIjMpfmd7B03fPtmJAQLkHeU3qOlLB3Cw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Zvg2B30u;
	arc=none smtp.remote-ip=209.85.218.44
Received: from mail-ej1-f44.google.com (mail-ej1-f44.google.com [209.85.218.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3170C606A330
	for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 12:19:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3170C606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Zvg2B30u
Received: by mail-ej1-f44.google.com with SMTP id a640c23a62f3a-c40e30c26a4so402487166b.0
        for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 04:19:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794658797; x=1795263597; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=nkM3J4QAu8kIsGHpB1EKb0NRF0JxtY2T/gqGpQ/nt0Q=;
        b=Zvg2B30uBzOFFo54OpfHCzqSK6TOyxTRmwNZV7t2nfrBwunaCrRH+5tI09/jIosXZS
         GdYk6iMfyO0nJ3moVzjaSKnXCCWxcV1Ye+R/4YjiwdwGG8ofIv4PWH24MjP/VV4CkNiq
         nSM7j6UNEdEDdNWpjUjn43q9YL/wt1IFltOrsPhL2VYrn8g/yyR7Uz6PFelA0j1tolIT
         QTqiv37OCVMy+5oEwlNBsw2cKiejzgZGAC7AZW2QPAu9cR2dMcfIteYf8vq02JyCIN53
         /PYiFz/vA+fp7KPo0fCiRfu55fCeLd5qLFIcUMGbAUVH1mkivaDzQTprXnn5n1PDT9pn
         6ZTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794658797; x=1795263597;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=nkM3J4QAu8kIsGHpB1EKb0NRF0JxtY2T/gqGpQ/nt0Q=;
        b=YuHIJ6JhDArAH/GN8B3Haw2yAXIkfcGnOgZHebDgS69mEHtprtntPo7W6d0h5kCorw
         7UhGJuGO6c3YMOcaXgNwoDRy7UnfZyFQqPgXGZdbBmRtFd5XiO6FMUzRBRd2Htpkju5o
         Uj+hEnOikgyiq/V/XgLwVVvaAXBDQNgwrIv/+rFX4JpRqiTrUgX1nvqzKQHR/+5AoZ6A
         5qgXzCZ9s/ep74ayh2eiM9MVLpYugvXmHwjyogXanGZ8VF0wJS4fHE8vqfPcAB3UfZ1i
         s5rw0PVbpKFW6yarcX9fYEY3dkeakRLd5c97NKGqni0ZO4VBoguUoMnNfv6r8gLP5NrR
         wzGA==
X-Forwarded-Encrypted: i=1; AL+hErFvNSekW4Mbx9bnoBVZe8tRPVBMTGIPp4iOgH6a/lda+ClMbh5/CGRTHXGAkRGE1wq1hgVNRNqjUWU=@vger.kernel.org
X-Gm-Message-State: APuU4Z9ubkDMhY+Nzo/kzEdZ5GNX1/tbcT7Daxvb6Y2Cyb7lNCfCTmpm
	G8BZW4w5wCPF4qqqc++6S0vRLvRWQUtfAa4QiIXXErUw88l1EzEQEJe2
X-Gm-Gg: AYBFou0DptP3uuBi1xAZOZOR+dZ0cG8HJPQ4GQXQoiZpyesieVdzId440Bu0cJrNrxE
	VY4/zJ4QwnfjM2753JyQbU4Rn4DTrRdeaP18KhCmuCDAuoqEex1FQIZtYSHoY7HaU4vbs586fot
	7YrHLIIBGMQcm6jE+UNt4hWidt0YfyzqyvtPVn3U4ogRycvOZjEoW4MbbiuROBVqHXUYEeyMzA7
	0gBhahUZB6A0zNVoa5O9o7s/czpRKLE76+VafsZJm9t79Ty3WLTUCVt8BPAfl+GNV2Q3zy0/rRL
	a/DmwwKyn2ioxHooLd42LiMPwqDtDa4BIrQZ/GcUGa1KoLvuIlQz8ECwgMditTcGpC5nmffNaaP
	sfJqzvqbVLzzbVTmn54MLAEQ4vc2u4uv8ewZIxcs7okO2pizNb9f4pdDggDD5pgns4jYQ5n2sL1
	eqrv/CyD3wVL/+5+r+fONfwbpT/bvqJgO/RK2aOw1c9ou672dRBTrjuRHVMMcb+qHmjVnvOwV+z
	E732yBY+eKVl3rsTbIqSa7MpFQWkXU0KRt2CMNAOfb2w13BJfgJnqFUyc7VHkjgCkulbjw40BEA
	BJSkJfotvUIMYMaDwAdNIZwGyurh3rPmEuPnycFanVSXJzcobjecPJNHmJH+g3BVz+XLE6lsRc7
	KsOHZNACNs8kJ
X-Received: by 2002:a17:906:1001:10b0:c41:4512:560d with SMTP id a640c23a62f3a-c5096387b02mr309942166b.16.1794658797424;
        Sat, 14 Nov 2026 04:19:57 -0800 (PST)
Received: from localhost (178-84-201-199.dynamic.upc.nl. [178.84.201.199])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c5095b5ac2asm211518966b.55.2026.11.14.04.19.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 14 Nov 2026 04:19:56 -0800 (PST)
Date: Sat, 14 Nov 2026 13:19:56 +0100
From: Amir Goldstein <amir73il@gmail.com>
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
Subject: Re: [PATCH 10/12] ovl: take freeze protection when storing the uuid
Message-ID: <avhR7DbNbVDCyPDO@amir-ThinkPad-T480>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
 <20261114-work-fs-frozen_writes-v1-10-f5ae61c898b1@kernel.org>
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
In-Reply-To: <20261114-work-fs-frozen_writes-v1-10-f5ae61c898b1@kernel.org>

On Sat, Nov 14, 2026 at 11:47:17AM +0100, Christian Brauner wrote:
> ovl_init_uuid_xattr() stores the persistent uuid in an xattr on the
> upper root. That happens after ovl_make_workdir() dropped its write
> access to the upper mount and before ovl_get_indexdir() takes it
> again. So a freeze of the upper filesystem that lands in between lets
> the mount modify a frozen filesystem.
> 
> Take write access to the upper mount around the xattr update.
> 
> Fixes: d9544c1b0d9e ("ovl: store persistent uuid/fsid with uuid=on")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Thanks,
Amir.

> ---
>  fs/overlayfs/util.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/overlayfs/util.c b/fs/overlayfs/util.c
> index 521717209b2e4..67aa7b71e9c83 100644
> --- a/fs/overlayfs/util.c
> +++ b/fs/overlayfs/util.c
> @@ -829,8 +829,12 @@ bool ovl_init_uuid_xattr(struct super_block *sb, struct ovl_fs *ofs,
>  
>  	/* Try to store persistent uuid */
>  	set = true;
> -	res = ovl_setxattr(ofs, upperpath->dentry, OVL_XATTR_UUID, uuid.b,
> -			   UUID_SIZE);
> +	res = mnt_want_write(ovl_upper_mnt(ofs));
> +	if (!res) {
> +		res = ovl_setxattr(ofs, upperpath->dentry, OVL_XATTR_UUID,
> +				   uuid.b, UUID_SIZE);
> +		mnt_drop_write(ovl_upper_mnt(ofs));
> +	}
>  	if (res)
>  		goto fail;
>  
> 
> -- 
> 2.53.0
> 

