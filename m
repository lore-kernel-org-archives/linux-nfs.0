Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661447;
	b=cprRb67552UyU2JR5otWyB5Xs7Trr39Jhp1pwRapVEiopeD0IoHTRvIW0o6BATbdFvW8
	 E3r4I/9CNCwrGrGTOFazcuHkXXnOHG9QzPQl7bxxk1A633IPiXko/TmUraqVhyyH5O+ry
	 SMozq0tmBXF+FktukHDHX9hKHg4RoIAzm73whO+66Yg9gXDPo9u3Tbv41xDsue2IZ6S+U
	 Rk2bDRAc1DNSxI1xeWSivdG1FW3vnjX81GeqZwvOasikB3wrs4ziExoIJ7XjMWV5CG9iT
	 IBJE432kQYv/D8fCHRoDGunI5Myk8R8R2drRRWBNFiRyFLQ4zSt18qPgFKISqLWXPvg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661447;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=jmFaSxEkxznu2joKRb4CtLIuI9acOjlBj4phgIO6eYw=;
	b=1dcwGfXavhy2hiPz/fopmWznHhFhB0X0zadjlN+44xe7c5+ZurCKajTRkU57IE+m1b4n
	 bRmH/iDd3Zc8kWCt1s71PIQrI7HTXwaweoxgexum3XVbpfGpVP+Z4Sj5UtW37wZluVob5
	 Xa0POjVK6aaSJgbbDr5OibVMpV/rd6c+SpKYlgfQPThZASM1iwp7vqY++T7GPClZfIrxW
	 2JFlZcrr1+R6nbbI0osKCD/4EnAr2EggnUpUc0FcQOHR+TM69YxOtF/jGXyx07NySpzZx
	 unlRWiDKZ3gnbRORSgS6uKq2tnsba2gb0hdt6RIoktGq01Q9QDEOdrTlLhZRlkpnz1w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Uq//O83y";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56BD6606A323;
	Sat, 14 Nov 2026 13:04:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Uq//O83y
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 64B7F1F000C4;
	Sat, 14 Nov 2026 13:04:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661447;
	bh=jmFaSxEkxznu2joKRb4CtLIuI9acOjlBj4phgIO6eYw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Uq//O83yckPl8vOXt6Bc5q+ZyVZY4qQBBhRv1J9JLebKgNU5ceZzhurztTOW5DrAd
	 zfzs4HQmFb9YGJjmDtcxKBj7yu1B1/Rt+kAnsgqrjbYGXQx/6WZu5oZBMA4a47YM6E
	 vANzyXh4CyCnG/3GxhlzD2mhbxERzTvUGvtsCtyOUEHdyooDZuvmgQoyOeD6JPloVc
	 jNCzylTQJ6BzxJ80Al9idnTCEUSUVZuZlaHUd3eAe4MQJDf5bdSw+ufDSFi8ELd0hw
	 vRjMIenjc/xng+l2uPAiI9tepuJgl1TxCOqH8MuZFjr46jl/c7HFGZYfzbP3V0RlnJ
	 mxXAEvyBWx8nQ==
Date: Sat, 14 Nov 2026 14:04:01 +0100
From: Christian Brauner <brauner@kernel.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
	linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH 00/12] fs: take freeze protection for writes to backing
 files
Message-ID: <20261114-tragen-joghurt-wucher-ad0ccbd68f25@brauner>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
 <avhUn1Hb5iT6zBZp@amir-ThinkPad-T480>
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
In-Reply-To: <avhUn1Hb5iT6zBZp@amir-ThinkPad-T480>

On Sat, Nov 14, 2026 at 01:31:27PM +0100, Amir Goldstein wrote:
> On Sat, Nov 14, 2026 at 11:47:07AM +0100, Christian Brauner wrote:
> > While testing the pseudo filesystem series I noticed that zloop, the
> > nvme target's file backend and the fileio backend of the scsi target
> > with fd_async_io=1 call ->write_iter() of their backing files without
> > taking freeze protection. So their writes go straight through to a
> > frozen filesystem. ext4 complains loudly:
> > 
> >     WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0
> > 
> > Loop doesn't get it right for discard and write zeroes. Those end up
> > calling ->fallocate() of the backing file directly. The fileio backend
> > does the same for UNMAP. And zloop records its write pointers on flush
> > with vfs_setxattr() which leaves freeze protection to the caller. So all
> > of them modify a frozen filesystem just the same. Fix them too.
> > 
> > Looking for more of the same turned up a few simple ones. coredump
> > truncates the core file, overlayfs stores its uuid xattr on mount, nfsd
> > truncates on OPEN and the BPF xattr kfuncs modify xattrs, all without
> > freeze protection. Fix those as well. The ones that need more work in
> > their subsystems I have reported separately.
> > 
> > The fileio backend also frees its aio command in the completion handler
> > while the filesystem may still be using the kiocb. KASAN catches ext4
> > doing that for direct reads on v7.4-rc1. ext4 gets its own fix (cf. [1])
> > but fileio should hold a reference across the submission like loop,
> > zloop and fs/backing-file.c do.
> > 
> > [1]: https://lore.kernel.org/r/20261113-work-ext4-dio_read_kiocb-v1-1-172a88be803c@kernel.org
> > 
> 
> Claude says you missed another one.
> nfs_local_write_iocb_done() does not end_write
> its ended too early right after submission.

I know. There's a bunch more. These are the easy ones.
I sent individual bug reports to susbystems that need larger changes.
NFS is one of them, so is ksmbd, ecryptfs, ima and so on. :)
