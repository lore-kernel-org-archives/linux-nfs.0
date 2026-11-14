Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794664496;
	b=yP7+dX7p3iS9wbCgHDGUVq641Nxxuk2mFjKYY5pVOZUEGPJPgHF3JhNF97/3CoYMLmkz
	 Mkq6PTiBvZej2Q7RcD4E3BMaK0Q4dY1uE9P5s2Cp7jFS+A77MVAT8FC1J5mAt5koodxSV
	 uvnF6lvc3i6BeIdqtBPQ7MlwpZPAnx8iU9ztXMhLIOXld3hcsq7ZXagWl+aw+0VL7pmoL
	 69kh7tzIJsjqTukSFSS6/72hnMvigQDcQi2MB8T71IhbCQbo3x0KQHs/x1CYU2SvZNRGM
	 x7GO+SINOfsK/gmYVQZ6j7XTw2oqpM+kJc0pW8SySimJPmOF+nD53MbtgY5XqDo1kHA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794664496;
	h=Received:DKIM-Signature:Content-Type:MIME-Version:Message-Id:
	 In-Reply-To:References:Subject:From:To:Cc:Date;
	bh=I6J+1H3vQpLdJ7UVpJ/tC85ye3HYuCATNIJGMbrXQJM=;
	b=q1CZ4i+mmH7K20AAIyHJtswA2VFZqxHuZuIbP6uRX8Q+KFJx0jzV2Yhix46Fjl2JCCl1
	 R7pNlnSnqt9uX0l6qz1gP1UYlDEGVC4IUZugkDAH7fomc7aK7vAybU0eT9w5hpPJ/Rqwe
	 MyyEwtr9yM2uaoEwOQvp1Qbf7d3CMvZtjij/CdVYSYlhGtNRwvEfhUTma+iVrKVQ+uwdX
	 lZwDXr+SHhCpllkAJ8g3gelLMj84PnqRQKCRqjKhV6Swhh/A2YQe6EVIJEK4UinR10QzZ
	 ZDmwhaiI7GaX0Ro7FirDObnlgbuEz0vwSYZYDNtTZZZIvSM/xAT12hQtnfT3s188zsA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gm28Ha6j;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 604C3606A32E;
	Sat, 14 Nov 2026 13:54:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gm28Ha6j
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AC8EC1F000C4;
	Sat, 14 Nov 2026 13:54:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794664496;
	bh=I6J+1H3vQpLdJ7UVpJ/tC85ye3HYuCATNIJGMbrXQJM=;
	h=In-Reply-To:References:Subject:From:To:Cc:Date;
	b=gm28Ha6jFbZAVZELeCoAiv8yQmKhg2t27IzqaM5E6DHf1m/iHwaa05oOee2NvjSBl
	 kc6ZaW7X7pNIXQAoh9xnp9MBMni3b8MRxZdEx/eTPDoUQsu/YruOICy0eelWOEyqgn
	 3P8g8niOi/8NoL9V5UYuZAEp6DyvrAtH4YeuzU3fc3guDfP87KZmI3TI0lTfqozu4+
	 ZpGn4biS09ByqImLH4ZYYUNpv6w1MO+E82dAPetup0Rc/sR/ssg0FbIV+aiwW6MIcv
	 EBQr5L1AgJXIgzU68vHxaHLJx8/fkvXF+Z3xx/GTGkbG1HInFcXsLmVQOWzwu1EgJY
	 hMWqsgyXoIXvw==
Content-Type: multipart/mixed; boundary="===============4078380530865713043=="
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Message-Id: <bf4a6d1a8af90f3fac8754638a5f9b02fb40c0a066237181d456a25ac7f2c606@mail.kernel.org>
In-Reply-To: <20261114-work-loop-pseudo-v2-4-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-4-98639a2286fb@kernel.org>
Subject: Re: [PATCH RFC v2 04/42] fs: add SB_I_PSEUDO
From: bot+bpf-ci@kernel.org
To: brauner@kernel.org,linux-fsdevel@vger.kernel.org
Cc: jannh@google.com,mason@kernel.org,josef@toxicpanda.com,hch@lst.de,linux-block@vger.kernel.org,linux-kernel@vger.kernel.org,linux-nvme@lists.infradead.org,viro@zeniv.linux.org.uk,jack@suse.cz,linux-scsi@vger.kernel.org,target-devel@vger.kernel.org,driver-core@lists.linux.dev,linux-mm@kvack.org,bpf@vger.kernel.org,linux-security-module@vger.kernel.org,selinux@vger.kernel.org,apparmor@lists.ubuntu.com,linux-nfs@vger.kernel.org,netdev@vger.kernel.org,fuse-devel@lists.linux.dev,linux-efi@vger.kernel.org,xen-devel@lists.xenproject.org,ocfs2-devel@lists.linux.dev,linux-s390@vger.kernel.org,linuxppc-dev@lists.ozlabs.org,linux-usb@vger.kernel.org,amir73il@gmail.com,linux-erofs@lists.ozlabs.org,linux-kselftest@vger.kernel.org,brauner@kernel.org,alex@amutable.com,ast@kernel.org,andrii@kernel.org,daniel@iogearbox.net,martin.lau@kernel.org,eddyz87@gmail.com,yonghong.song@linux.dev,mason@kernel.org,ihor.solodrai@linux.dev
Date: Sat, 14 Nov 2026 13:54:52 +0000 (UTC)

--===============4078380530865713043==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

> fs: add SB_I_PSEUDO

TL;DR: Nit only: the fc_init_pseudo() comment and commit message claim pseudo
filesystems never hold device nodes, but devpts and binderfs do and must clear
SB_I_NODEV; the wording could mislead.

> diff --git a/include/linux/pseudo_fs.h b/include/linux/pseudo_fs.h
> --- a/include/linux/pseudo_fs.h
> +++ b/include/linux/pseudo_fs.h

[ ... ]

> +/*
> + * Common initialization for all pseudo filesystems, mountable or not. Their
> + * regular files are kernel interfaces. They don't store data and pseudo
> + * filesystems never hold executables or device nodes.
> + */
> +static inline void fc_init_pseudo(struct fs_context *fc)
> +{
> +	fc->s_iflags |= SB_I_PSEUDO | SB_I_NOEXEC | SB_I_NODEV;
> +}

This isn't a bug, but is it accurate that pseudo filesystems "never hold
executables or device nodes"?  The same wording is in the commit message.

devpts creates character device inodes in devpts_pty_new():

    init_special_inode(inode, S_IFCHR|opts->mode,
                       MKDEV(UNIX98_PTY_SLAVE_MAJOR, index));

and binderfs does the same with init_special_inode(inode, S_IFCHR | 0600,
...).  Both filesystems are converted to fc_init_pseudo() later in the
series, and both have to undo the flag in their fill_super callbacks:

    s->s_iflags &= ~SB_I_NODEV;

This works because sget_fc() ORs fc->s_iflags into sb->s_iflags before
fill_super runs.  A filesystem that has device nodes and relies on this
comment would not know it needs to clear SB_I_NODEV, and its device nodes
would fail to open with -EACCES from may_open_dev().

Could the comment say that SB_I_NODEV is the default and that pseudo
filesystems with device nodes must clear it in fill_super, or could "never
... device nodes" be dropped?


---
AI reviewed your patch. Please fix the bug or email reply why it's not a bug.
See: https://github.com/kernel-patches/vmtest/blob/master/ci/claude/README.md

CI run summary: https://github.com/kernel-patches/bpf/actions/runs/43599461726
--===============4078380530865713043==--
