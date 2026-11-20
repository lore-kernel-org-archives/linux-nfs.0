Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795177976;
	b=b/oun2MBBWPQuFmYzpM57TVC7a4fb/3BC4xn7WAngcaE2B6xbJPpxLbcd5y50KZ77SEB
	 P/l+TQD8ZibqA6bIUzt/Y4ng6RmukZ6KrCHSJelEGTz64kqoGDoJRLQWlN02xgYfOziCT
	 u+gpTcshy8txkldhRfdBx7hvy06yWsTYIMoOyZGGqAYV3LwNw51TN9HiRRUAa74eFvBTC
	 VgWwgUCLW9ahHTdgKS5Jl7RHvGtZ93gYZvpCDHGv9Di5rrk1p9wY8UrDT3FycnIbUwnTt
	 MnL9dxqa3lo+eRdmc/fzbCUYE2U4m6crYY44+DZLVJYcjAAwY5dk3VuiTzN6lL6ER7g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795177976;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=EDpVY0aGzqBT374TIqs271yPZfzR3UZ/l7e+Hpa3g1Q=;
	b=5Z6rGYqCrFN79tk6nKb3PbXN1RaWYcs/IB3b4EmLsxSaRxl3hYRymcAG9mIicV/ORSTT
	 7uwXSbZijYePigqamU0bZLRbV4CtT/nggcmY7Z2R1UQtBfPQoHYUqFvg8OROffhkuMyTo
	 v3YXhSIxJ2EkitUDCFrNgBkWDV/QS7MOqxPFGX0L9Tc4kktlntPKYNphikzaVnTpf+ZXV
	 9viP18OsHM5N3Y7MfPETHvxSXagugCFSFFXnhgMjbvTwxtLY0iRcw4WI8y736Em8Xg63j
	 tHXAYUPPkoP5+LzA+Z279fwqnKYOL9XCfgFvZ9d11vNvcl6evFMW3Ptc89kxzbRb0wQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Bq1M2Wbl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 801FD606A325;
	Fri, 20 Nov 2026 12:32:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Bq1M2Wbl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2CBED1F000D0;
	Fri, 20 Nov 2026 12:32:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795177975;
	bh=EDpVY0aGzqBT374TIqs271yPZfzR3UZ/l7e+Hpa3g1Q=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Bq1M2WblwfHBV1H572oyFU8Jg8cpNSAJSxJ+fEpHf2I7qWHXLU+oasVdkAuIxSJie
	 jKhfQDH530HH6VBk15LgJCY2pvw7EqF0BhPBatbe+Mn6P5JYsRNDjfHQCBQ80xaMrN
	 U2DyoIgYFn22O+pcFswK9TSYy6F9ni4krGEUzI81HVk69GwdSouxWMej+SyUBzfGQ3
	 u96WQnEElHgzQ2njUE7exwQpHgzIhz9wS5q4xXQhMCoXtRR40gHJ3Xg1JbyEVQUg/e
	 z32TkXC2gNKMuzAk5tiDwPM6bK4O8zP9G83TsIxw7Zf0wQ6rZjejwK3E5rtbRe5eJN
	 94T9rR8oeckhg==
Date: Fri, 20 Nov 2026 13:32:49 +0100
From: Christian Brauner <brauner@kernel.org>
To: Zhiqi Zhang <zhiqizhangg@gmail.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>, 
	=?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@digikod.net>, =?utf-8?Q?G=C3=BCnther?= Noack <gnoack@google.com>, 
	Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>, 
	"Serge E . Hallyn" <serge@hallyn.com>, David Sterba <dsterba@suse.com>, linux-fsdevel@vger.kernel.org, 
	linux-security-module@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] ns: skip namespace_init LSM hook for internal namespaces
Message-ID: <20261120-karawane-geadelt-jubel-318c60ec1a2e@brauner>
References: <20261114141323.19029-1-zhiqizhangg@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20261114141323.19029-1-zhiqizhangg@gmail.com>

On Sat, Nov 14, 2026 at 10:13:23PM +0800, Zhiqi Zhang wrote:
> Skip LSM initialization for kernel-internal namespaces.
> __ns_common_init() gains an lsm parameter, and a new
> ns_common_init_inum_internal() passes false.  It is used by
> mount_subtree() only; user-visible namespace allocations (clone,
> unshare, setns, open_tree, fsmount) keep calling the hook.

Thanks for the report! I wrote a different fix that skips both
namespace_init and namespace_free for such namespaces so the two hooks
stay paired:

https://patch.msgid.link/20261120-work-ns-mount_subtree-v1-0-06337377f94a@kernel.org
