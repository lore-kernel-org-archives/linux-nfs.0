Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.182
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793296069;
	b=TV/eWdfmKnkXqI6FVeIMkMv7T2E6zFJjlhIF8T83OUdOtLpoe+h65upapGDo2ZroKAgk
	 mnHMnIDSQWmBUA8WzXN9YeL1p7st080L9WVsFH4eM+w3sh9T/DHgmv86nA+XF3XnPh9ad
	 vX8uzANqNa60qMl46sD5oB2vNgQQZMY3YOJdKAr7ZLrlFviR2wCKiNUlndamCtCkxxSYY
	 n1krbe4FqOP+ht6d2i7ahSIwF12G6W1fyZRisnpKhm8BcBdCIaxtHd7yUUOeYFcbVDveW
	 WRlADFAZvObQV9hdIT6JOMuvijuuHCOcTMQ19GtFGIR2f1mXtI808x8+5nYZVblIplw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793296069;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:To:Cc:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type;
	bh=YtZuSZ+g775+4gNgncIQEf9lnwNLs5cNsigMBo9gc8o=;
	b=hNzTFNyC9dtuqdmIfxf0fozgSG8mLtdJI2b2tDXBYQSxdQyjS3Il4vZwEzL3QJrmqJha
	 i0GjY0G3RpHzDC1x9YXJTajFZ4ELayJ0C2Ymbcmi6ZCW7dHtMEhviIQJAhTbDx0JxFtQt
	 gA+FuOeYMEKwyJykPfzkGk8dUFdumuG5wBiCHyHhsWlsua1rsmuQPr4TzdMsmHLXSbfIZ
	 h9jaedb/7A9O1g0g/Xh4F79ttskiec6WB0OmqTTI2O4YJvDnvOyzYmHQEha50z9KDYE0x
	 AKkUxoGdXv1AcR42oHx4CJWnjS/gb2ocWUx32rf6sdh/QMApGPm8/0brxR11MmeDqCw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Ds+WsqlG;
	arc=none smtp.remote-ip=209.85.167.182
Received: from mail-oi1-f182.google.com (mail-oi1-f182.google.com [209.85.167.182])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE110606A31C
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 17:47:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CE110606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Ds+WsqlG
Received: by mail-oi1-f182.google.com with SMTP id 5614622812f47-53ec2cc397aso1601674b6e.1
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 10:47:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793296068; x=1793900868; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=YtZuSZ+g775+4gNgncIQEf9lnwNLs5cNsigMBo9gc8o=;
        b=Ds+WsqlGgktp7x1Vvpf7UdLimbAqyFLYsP8uKoMQcOE0xQkQVSRIFhOKNQ2V4Jw5NH
         C8RFp1nUpxT2K7A9WF5OJILXNlcLw7fdvEBf4HhJuZiCvXwjr8hT2sVB9o00Jbl5bYds
         DHD0Sb9DMGbDWGKWQnO0srGBQOq3zuqsmHC12/Hdv2RoTYq1MDq1tJBpRjKL9jiyXAfu
         upDqhrTPQ01deupZusdy4lgTaSs1SbicN7ChknmHFx6IYxxgicHEXYohNdTphXQC6ppR
         3zV/UsDZ+9FPAXF8bVWLcVeV+ecTHoMZcJvwVWx6iTG/Vm8/VqBly9XBI8XksFmJxCkm
         5xOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793296068; x=1793900868;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=YtZuSZ+g775+4gNgncIQEf9lnwNLs5cNsigMBo9gc8o=;
        b=ffQjQ/4iF4PlEsUkpuHnbWT7cu55HsJUckzSN1ngHMNUb742RCFAQi32nwMfX+19ww
         3Np3JyjjHDNdUz+Bi7GhJW+dEn+R4Qsffn94bky6nDmAVBS/qGX0g+aCqpoddgtoZipf
         c4cMi/fFsUvcsmkwmaa2tJQ77wF3roytLI7Wan8WbvAhwaNLkujOXjH7N59oKiR2nCaM
         +y1Ts6iqHjiHUBYY+11u8SYfIHeK+8PGUVIHI9OYCbOGlzSYfreudCowioKMfmsiC3mf
         N5EKAAyZW2XVrNZPqVa3QS7bMpK1+w5jrrViBmIq330VJu/iz/rBqw1YLkArpATrrcwu
         dlNQ==
X-Forwarded-Encrypted: i=1; AKwUvBxbqY0SD3nrlFMCw1k/YZHqLvk7ghesHGK/Iaa8DGgXZaQkgTRc2cOZEe5s+dtpUOGis3bqTNvhe4k=@vger.kernel.org
X-Gm-Message-State: AFq9FYKeUfbnpoFrDaxoSDDLXwqJxiQRMyeZXUo1W0ytTGZCPqp4LcOT
	C5eaSM+MoTJvTzBHkOOsYH3hhjnPKPr+tUMG4E9jb+ES+vAHFT81Nk8eT6QwVPpV8YA=
X-Gm-Gg: AYBFou0dvCcMb/7D9ZcR0r0y5xaXBUhiCcJoSZVTZZ4yQvNkmSsdrIOks1l9oFae2ok
	69NcvcjxooPMMTx3CRWbC7WIR6Bqr+pLspAGeeazlSFlWlx5igqDiJQJkIc8wLHpnEm5r86xtM8
	ugBvnwyHnBeZBw8oeJNwWHdzSBr+6UqnA9xAIqPl/HOtmnl4Q1i8iDqKRvExJ8+jM3PEESeylTV
	3/Lnf9G8unxxLPxvqlE0POGwWeK0XyCcIQLq88HmU9RCMplcau9ZfKa9O2E0Fp+Bxc83h7q/BHN
	ygSgSCwL1+eqmJHIYSB6Fxq/u9gVhh/Mx/0yk17SurSJ6wAj8mGZyBeN6A73Xvc5sQP6+b0Pxwl
	dmu2JvNeNo9LONPYNZHKpxDYejzcq9/xVmDmLicikfJGjC3RHboDIIQcvJ4YGUXreA3GWmDSO0w
	eN1ZWLJBSv7LU3gQZ8CqFv04hiQ9J2G0he15PBIybAukLKAV818gSL1/LF6dkBB7bk+KKaIiDqJ
	PiCOEoZ9gcg4C0yTHk6S7fMVcyAOc0NQxiDu6eVy4BIdKImwo2wdE6Y3EcW5CRg2umFIoDf89kT
	2JA5CNcZM5BVP3xi9w4zAcWCO16unH0VwzW5KNh9Fi6w3hktOgt9
X-Received: by 2002:a05:6808:4f52:b0:53a:6769:c35b with SMTP id 5614622812f47-5638207f063mr5172478b6e.12.1793296067729;
        Thu, 29 Oct 2026 10:47:47 -0700 (PDT)
Received: from [192.168.254.51] ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a904a366e4sm66337fac.17.2026.10.29.10.47.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 10:47:47 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Daejun Park <daejun7.park@samsung.com>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 2/2] pnfs/blocklayout: report data lost to a failed
 LAYOUTCOMMIT
Date: Thu, 29 Oct 2026 10:47:44 -0700
X-Mailer: MailMate (2.0r6272)
Message-ID: <C429AC88-BE4C-4062-860E-E0AB945C588D@hammerspace.com>
In-Reply-To: <20261029064502epcms2p4465d31caeafe380380266d726846a28a@epcms2p4>
References: <f1a9f1337cbbb4039a29fb5808d8c2944b9a112c.1792157092.git.bcodding@hammerspace.com>
 <cover.1792157092.git.bcodding@hammerspace.com>
 <CGME20261026232757epcas2p444964cd7bba66ebaecad170a85048e3b@epcms2p4>
 <20261029064502epcms2p4465d31caeafe380380266d726846a28a@epcms2p4>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain

On 28 Oct 2026, at 23:45, Daejun Park wrote:

> Would it work to keep ->sync a plain pnfs_layoutcommit_inode() and
> check the file in nfs_file_fsync() instead? I tested this:
>
> 		ret = pnfs_sync_inode(inode, !!datasync);
> 		if (ret != 0)
> 			break;
> +		ret = file_check_and_advance_wb_err(file);
> +		if (ret != 0)
> +			break;
>
> With it, the first fsync() returned -EIO, the next fsync() and stat()
> returned 0, and close() still returned -EIO.

Yeah, that's better. It also lets me drop the raw wb_err read, since
nfs_file_fsync_commit() has already marked any older error seen by then.

I'll send a v3 with your change in patch 2.  Ok to add your
Suggested-by and Tested-by?

Was there another write before the close() that returned -EIO?  A
failed LAYOUTCOMMIT doesn't set NFS_INO_LAYOUTCOMMIT again, so I'd only
expect close() to fail if a later LAYOUTCOMMIT failed as well.

Ben
