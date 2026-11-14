Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794693291;
	b=ivX6Xb5FAMgBdbwk7GUKEfiEY40kgWQA5ndwuMbevK5ubtsCCrUciHgZRgnepPMSNwZt
	 s4tP4W+h9708MS43ZnA1HfhOje3vLSpldfcY0qFokow17EktIt6xLqAyzD4/qrRvTqTdf
	 /CBC1+zBT29mQ1SojVCoZUGtUcKeW9GYvxQOU4v81ArUmuLqhiWPLerqk2dO97ybws80A
	 kYkxi6DMcJY6qBQ/x3UGSOtbeAOoFbXsl5LFde0RrgB99NDLSXzOfi3cjRT1CDGu5LIMu
	 sOb9z9aE2Qja7KAWlwKTbbJKy3LGz8efbo2iKqIlySkus0Hg4enB5tNYvnIjReXS9pQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794693291;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=MU5XNgGhJm4qGtdrFglh8iv5ciWWvcUh9TpKkyBJYjo=;
	b=1mtuoLG3H58nd7ImEukPs54W/uWXxguugKyZ/zt4CqZxWTwx9UgLMbXLmEcGtfRm0VRz
	 jnZBMK6xaRtm7sIIrd/DaV6nktGWC/yhC4EcTL4h7zXED/tC6O72+8mTSPkhTktRCPsys
	 TS57uKsc/BE9pdtStD5SyjO50WUjJ2lbbl9q8GWEE8dLHDjRsPYlDtQUPN/7uI0Iysbde
	 6mC5lCmeMfdyhWUcyyvnqMjXHWWYlmtDsDZkWKUUfq53LuCd7SOChXKyqBlPLXdSYkqY8
	 /I+ypS9/tR07P/zYb+Vf/Y+kxJjCM04bih1zyEwoOFvn/CiNBmGc4H2lHLdY7j64ejw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FIy92zB+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E1EB606A323;
	Sat, 14 Nov 2026 21:54:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FIy92zB+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2BCA71F000C4;
	Sat, 14 Nov 2026 21:54:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794693290;
	bh=MU5XNgGhJm4qGtdrFglh8iv5ciWWvcUh9TpKkyBJYjo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=FIy92zB+Q6XXV11Bx9r1d6hblgiehsd1O2WYa4ANqHuoaMNzzpTo/kyfrrl5vWJqU
	 ntQlUQLehZaQBgb5PHB5XgsgvcpzvDKacjzaPI1D0mhsgTUlE44bsX7wUuFZlbKEVy
	 2bf9iGRkxrODGLkzXesChHlOpfKM10Ar21sYj0wFzavx9W02CRh/nVciBf1lbn33of
	 RFNAI7U3T2zGoe8QK8NctZ4IPimWP2/h2Wjo3dajkFGo7hKnMdTyDdQrkd/NIOxJeq
	 4KueXIk2XzkN6Oe+3U49dByhB2/gIMk6xuZPod2J7aymfou+3hjeBLx6QqpqyydE14
	 fsnMkL8jCu8lw==
Date: Sat, 14 Nov 2026 22:54:42 +0100
From: Christian Brauner <brauner@kernel.org>
To: Chris Down <chris@chrisdown.name>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>, 
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, 
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
	driver-core@lists.linux.dev, linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, apparmor@lists.ubuntu.com, 
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
	linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev, 
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
	Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org, 
	Alexander Mikhalitsyn <alex@amutable.com>
Subject: Re: [PATCH RFC v2 17/42] securityfs: use fc_init_pseudo()
Message-ID: <20261114-wohnprojekt-rational-ersetzbar-b338c88cba70@brauner>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
 <20261114-work-loop-pseudo-v2-17-98639a2286fb@kernel.org>
 <20261114120555.cbfaf8ab8a92fb25@chrisdown.name>
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
In-Reply-To: <20261114120555.cbfaf8ab8a92fb25@chrisdown.name>

On Sat, Nov 14, 2026 at 12:05:55PM -0800, Chris Down wrote:
> Not a big deal, but userspace can see that node too, as
> /sys/kernel/security/apparmor/.null. Opening it by path works in current
> kernels and fails with EACCES after this patch. Now, I don't know of
> anything that does that, but selinuxfs gets SB_I_NODEV cleared again in
> the next patch for the same kind of node, so I think we should do the
> same thing here. If not, it would be good to have a line in the
> changelog saying that opening it by path is meant to stop working.

Yeah, seems fine. Though, afaict aa refuses every read and write on
.null in aa_file_perm(). So this change only moves the EACCES from
read()/write() to open(). But I guess open() failing might be an issue,
idk.

I really really dislike this device node abuse on for both lsms. It's
sketchy as hell.
