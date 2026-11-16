Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794835257;
	b=RNQMIb3w01lzLp2WACTSX6SQnebuI+4B7HYClxgieVBBTsg8S/kQiU+T29iB7HeA9GRw
	 kpuN6spCF3aWtIKEnUKBSbOFB9m2+v0CfrWH3UNysJYuDtyENI+Yl0uK16Zvayek2iXgG
	 Ws9PiS9jarGGGhgEikywgIa2749AO0YCWd0YCBkLTxMvnHZOxmUwjz1pGoDUO/Pz7gQk7
	 HH+Mx365UryoKQMSurrw/Tw7gHo/G4fGTDzMQkWvoSnRrib79nXApKR7SFMsn/tu/gdEt
	 UfoyIlJexR1GxRTZpmWKfSbiwk0JEl07Nt+VZaw6v2gO9zyBYYs1Jv8WjyyWQOtZgvA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794835257;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=Zwp/b2OseRP/BP0MRnYEMv10Xx5652k/ysAi77DyTUk=;
	b=NFCUE3XMe0UyCZhEGLrokSfcFWi5Iat1D+Qz+s3xnLC9zxlmzbF+1aEtCS2AUbAHMA3o
	 FPJVfzREblqlqgzoKdLbYaFdHt4sy5r0fwk93YdutF6npCpYKm0xcSxRrO1fU5ownOqZh
	 OZXf7aT5ouNYQWBaxprZALPMFrfBXHxnShhqF2SiCRqG6a7yccJTCFm4ZbjxteF69k7cz
	 +39vhbv6gPJ+oBR9hBDfUxNM1f6J4znWx9UhxnCtWlD4i9dtpNhjm7Swbo9OThejo+MnH
	 T44FTqk1YOmzJYMe7P1poalloVrewnUIB2mPjPL3JMq8OBl965HXPwL+1fDkooNXsnA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MhEMPzkS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1FA5B606A331;
	Mon, 16 Nov 2026 13:20:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MhEMPzkS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 287C11F000C4;
	Mon, 16 Nov 2026 13:20:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794835256;
	bh=Zwp/b2OseRP/BP0MRnYEMv10Xx5652k/ysAi77DyTUk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=MhEMPzkS8ELyUuZJvWfSoeeWuf7By4IL/aj2kb/a2OV4l4EgVqKXjiioyUz2RieNk
	 XgpnwYQk+l7IQUQIb2TJG9rqwlNZZd2t4tSSz2FIOFgSK4qv3MUw+KnfbEysg8x4iS
	 RMX98jFDrMhGiTX7izqJwsUslncHgd0fLN7Yyo0X4gX89YKFy614i608nuofc5428F
	 SfK4Vb1AO45G7cvMjjgv1ixrvwKqD7DXpAnyYbrMZDnbnAmpR0a9mRVyF+s9eImB9m
	 jgQn4Dmx1KWjFDTc0G8bS5OCGFot8PkE1fqYZHJngkkRDFtxZNJw9/svWtFGNRWRiW
	 sc42i9H1mtjtg==
Date: Mon, 16 Nov 2026 14:20:45 +0100
From: Christian Brauner <brauner@kernel.org>
To: bot+bpf-ci@kernel.org, linux-fsdevel@vger.kernel.org
Cc: jannh@google.com, mason@kernel.org, josef@toxicpanda.com, hch@lst.de, 
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org, 
	viro@zeniv.linux.org.uk, jack@suse.cz, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, driver-core@lists.linux.dev, linux-mm@kvack.org, 
	bpf@vger.kernel.org, linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
	ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	linux-usb@vger.kernel.org, amir73il@gmail.com, linux-erofs@lists.ozlabs.org, 
	linux-kselftest@vger.kernel.org, chris@chrisdown.name, ast@kernel.org, andrii@kernel.org, 
	daniel@iogearbox.net, martin.lau@kernel.org, eddyz87@gmail.com, 
	yonghong.song@linux.dev, ihor.solodrai@linux.dev
Subject: Re: [PATCH RFC v3 38/44] nvmet: refuse files on pseudo filesystems
 as namespace backing files
Message-ID: <20261116-geplagt-gemein-zufrieden-72c3817de2c6@brauner>
References: <20261116-work-loop-pseudo-v3-38-8cbbea1cf34f@kernel.org>
 <cb28f09c85a473a23f14c9bd6ef135950197c9fbf966c1f7055d791977d29286@mail.kernel.org>
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
In-Reply-To: <cb28f09c85a473a23f14c9bd6ef135950197c9fbf966c1f7055d791977d29286@mail.kernel.org>

On Mon, Nov 16, 2026 at 12:00:14PM +0000, bot+bpf-ci@kernel.org wrote:
> Is a prerequisite patch adding d_real_data_inode() missing from the series?

No. d_real_data_inode() comes from "fs: let d_real() fail" which is in
the base-commit of this series (vfs-7.5.lookup). This was applied to
bpf-next instead.
