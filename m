Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.215.180
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794686759;
	b=1hOAfR7U25vh1lESt6l5MjMv2Je422RXkC40YiYd9NjVwQRu9RrUH/cCm4vJxJwt5fDZ
	 09MlJIvepTSgMcri9M9YmoWBLEu+ekQcRfg+atRNBill3bamcLG60ryruD8ZpKoI1Hju5
	 zNWgPiRgSxt+04jxAGoXzhLgvttZ+Qwr9tEvb6dxHstIIcNz9e18LPM8JcuEukbDDmwbe
	 cTKsd8CjBApHyl2tiNUqXM5MRskhKneAOLZElBpcANEg4Sw+CQhI13gPmwMXCwOw8vl7u
	 vGdhN8snhDnooIh5vXMScTY6EfCg0BUQsBcR/QFqnVtyx0dmhhzD4meUgyFT3MjoyFA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794686759;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Date:From:To:Cc:Subject:In-Reply-To:References:MIME-Version:
	 Content-Type:Content-Disposition:Message-ID:User-Agent;
	bh=cEK0v6G1yB2cz/8630PKsjvi8Z78P9QyctaIU0ylRW4=;
	b=JLNQy+5Yisqbdy9oW7ee3u0xDf9pkIl5nN64zLpdTxJ1iZHA6ngHOvS3y7PsNjEurCaR
	 TvfnQcl64jb/g1BDiZVPCJPX7+oQP75PyZye/AHP6d494603Q4hUkQxy47YdCSmcqadQU
	 sG/903YmIYVNhjD6xRYms1HmPe34vmtYBni2exOoKKspm/2rX0CaWTe6Vq/ikGbmh05XF
	 rWw2wb9DzuJ72204Vr7VGB4ojp4ZRyf9oAkQUh3qlYr+skcjXjCTTue3mEFreMeetIW47
	 NuTOY/b63E+pt9Dx9e946rg11doGTcEpFDegQWsYuhrH3PYG4wLaGsz5UwmiWq+9ODw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=chrisdown.name;
	spf=pass smtp.mailfrom=chrisdown.name;
	dkim=pass header.d=chrisdown.name header.i=@chrisdown.name header.a=rsa-sha256 header.s=google header.b=t4xxtvlP;
	arc=none smtp.remote-ip=209.85.215.180
Received: from mail-pg1-f180.google.com (mail-pg1-f180.google.com [209.85.215.180])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35CC160A2601
	for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 20:05:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 35CC160A2601
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=chrisdown.name
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=chrisdown.name
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.a=rsa-sha256 header.s=google header.b=t4xxtvlP
Received: by mail-pg1-f180.google.com with SMTP id 41be03b00d2f7-cdb75699c7cso835201a12.2
        for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 12:05:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google; t=1794686758; x=1795291558; darn=vger.kernel.org;
        h=user-agent:message-id:content-disposition:content-type:mime-version
         :references:in-reply-to:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=cEK0v6G1yB2cz/8630PKsjvi8Z78P9QyctaIU0ylRW4=;
        b=t4xxtvlP4RAICjpBIWPIkESb6EJJVOcRd9+LEytv251d1ZQsfD2pYblwETMOf/zroc
         BDzAo5elUgpAiRA0oYEfExHYSjjGywxztBxThvGs665InMbo4S8LytfXKr2B4Cw2IX6x
         hCl30XcWjOl3zGKKK0Vny1KN9lt2zjyLiPz3U=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794686758; x=1795291558;
        h=user-agent:message-id:content-disposition:content-type:mime-version
         :references:in-reply-to:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=cEK0v6G1yB2cz/8630PKsjvi8Z78P9QyctaIU0ylRW4=;
        b=rcqiCGig5uJ15t0CiR2JJZVaufyBZ4ozXqG+IRx+rQ6mjspmywad//47YO6paY3bgk
         RtXyiIm0xXslq4IVKFd1zlkaMRVKXwjF7fXEobrhNIrEotWUD6wktPx0kE9gEMtr0cVX
         gscuB8d770JymaDu+IY8eDojiVS5FxHEgRHqCtmAxj2rrjBhUFDfPOvmBHecJ8UPxKk6
         qsTDpd8htjHg76qVVqiXq6TwkjN+PZxz37/8GQEv4t/3ZpTRjZ1xthm+mf/Im59D4eOs
         +/t6r6xHV1fi00sdyr7wueQj02rRFFdEFs1kO3acmVP+T8x9LVFx6JcZgJN+Mci7m0TN
         GD3w==
X-Forwarded-Encrypted: i=1; AL+hErF0P/t6C5W5v6Nhx5z7GFNWYKvqBIUdjFA8uoYWNR2HnrsDQAQxBJV1mIqPYpwbZnn30xqoNmfnlMk=@vger.kernel.org
X-Gm-Message-State: APuU4Z/E4Nhlq/2Yka2z/jKFMflAUvHOwCr9GSQyWGFBu7pifWf/3bWR
	1TVNczm7X5fYn5MDuh9cnXGLOqfiOUCXXb1tERdqdqFwtYzBt7q+T0/y33cvXnPi6Ks=
X-Gm-Gg: AYBFou2jE3/Tyz/MRYQJgO8BaR3Rgs5gkXIv1BdmOwzoTPPFrkCQY7qaeq8qpbz95tS
	97i3QneNOxJkpwivNGwUvE1BkvzApP4mW6bRKrPxCJ6L6iORIXWjZVXBu0WmO1CgFgTnvar6NYe
	GV6su3LEGG9/xi+jn1ZeH2pgo9uAHNoy1l9fsHNBAePnBXGDb+hlXDZe+zHhYaqORkFhH8ThUBp
	YhUyZzSkqIDz+0pMaG48uTejPLi/+SrjBucqV9L92T2Oy0vEwE7vtkU+2DKLCsngip9fnJHXzTG
	iSTbgNBIEPMxyBB0qUIf5c6TYzKhuJzCZQB1EfOd/HA2jRfZMxbmGByRxI6kE9ZRipVaTT3jmKa
	NJgjKwAaYxQJ8DteTr4UxHP8/R7OeJKN9/M0LuOD0pSQ/IugZCgt/UxYsLEywvp+UWzrX9tJuMt
	MrCJYMBWipVErupcMVWsaTK6Ihmw5COrFd4RTLuhwcDO4/2QFfPyfL1POzY2FF9aBDIEM0dSnR/
	DRMrBVpUNejCCB3bF8lYcFZ1h5Nu/tv/WaUt+q0qucDpOUGWNAfvoAROXpywTOVppxBeDUQ0rpu
	rba28Vg9z3ddqTXTyJHuaf7D2+coIuMy+tvBLdLWDfo4WjGwg6skKlG2LOS1bLSg7XCTKttLxqh
	rXXFvcCrCqXHj2KzyI9ak/qJ+uJqvm3TWwS43QR8xhu/f5CF+lu9uZwoVetMqFijfPfdxSYcvuE
	6UANfPAsa8PHqFiIGPO3T7XTi2wN5QwdNdy+rFWJ4nFamVmp2/bc9vl3Xl
X-Received: by 2002:a17:90b:3b8a:b0:3b0:9f53:e8a8 with SMTP id 98e67ed59e1d1-3b1b0b5f2c1mr6192503a91.52.1794686758572;
        Sat, 14 Nov 2026 12:05:58 -0800 (PST)
Received: from [172.22.0.2] ([64.16.22.130])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3b1b266d873sm4654869a91.1.2026.11.14.12.05.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 14 Nov 2026 12:05:57 -0800 (PST)
Date: Sat, 14 Nov 2026 12:05:55 -0800
From: Chris Down <chris@chrisdown.name>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>,
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-mm@kvack.org, bpf@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org,
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org,
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev,
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org,
	Alexander Mikhalitsyn <alex@amutable.com>
Subject: Re: [PATCH RFC v2 17/42] securityfs: use fc_init_pseudo()
In-Reply-To: <20261114-work-loop-pseudo-v2-17-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
	<20261114-work-loop-pseudo-v2-17-98639a2286fb@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Message-ID: <20261114120555.cbfaf8ab8a92fb25@chrisdown.name>
User-Agent: Mutt/2.4.3 (cc9e3943) (2026-10-09)

Hi Christian,

Christian Brauner writes:
>AppArmor puts a .null device node into securityfs but only ever opens
>it via dentry_open() which doesn't care about SB_I_NODEV.

Not a big deal, but userspace can see that node too, as
/sys/kernel/security/apparmor/.null. Opening it by path works in current
kernels and fails with EACCES after this patch. Now, I don't know of
anything that does that, but selinuxfs gets SB_I_NODEV cleared again in
the next patch for the same kind of node, so I think we should do the
same thing here. If not, it would be good to have a line in the
changelog saying that opening it by path is meant to stop working.

Once that's fixed, please feel free to add:

Reviewed-by: Chris Down <chris@chrisdown.name>
