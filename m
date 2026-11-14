Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794664501;
	b=cLGcvge92KiX02qJXq7uxyR91ydJhYBePS75pKy/BcgvyWG0Mvc8dn9ki/8lU6dNV/qt
	 Fo55TModoHknaWL6aiBzxaKXfhTq0pt3GBnPWfQI9x91xFRdjGc04GqatfDKKD42DUqJw
	 m5pkkpjj6qb+kKEtrqzP5unnEkHArMzJvH9jIymZsJHRk73uq9mlS5JrX41JCkdThkP9y
	 C1GU/S5jMfYS0BoTp6D7A8AQFrtc+6wvALCiPc3s2tOarcy1NaMTjKqPLLigVBzG7eoC/
	 8DYaV52B19AxPBJFNGhfcVDf4h5htYV4sf8FFaUJe67Zxp85D+RfQ8L1QvQS+nxe9jQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794664501;
	h=Received:DKIM-Signature:Content-Type:MIME-Version:Message-Id:
	 In-Reply-To:References:Subject:From:To:Cc:Date;
	bh=Xi+Jp34UVw8n6rWUcn3QcZPlSKYiPMqX7yCNJrzL8oU=;
	b=V5R/exzs30werKTVaB6ZQc3TTKRigA6AvPUuUBGkEjUzmYfhFLBhm7eo+ZDi9HLGCmqj
	 2NKSL3pWWn6Yw+wKvZEWD6ofmstErSLauaEeMF88x0YZblQnbV8zVEnH2ou6Oe25aOuuS
	 OoewL4srl9D025D5TkE+J0RCBrRp4y7MVfhRXoerGAtL6NVj/rSIaPBI32Vbj0KB0RtpA
	 ekG2pMVTSe4lVtDE98jviAgy9LbNQ6XA/2eE3oHNdCqXN5lIYK47C6Fc0JsWHRhNi2thF
	 R0+ALYwgRdX8JcW23gHIYtu0K65Hrp8tfE2eHDChoyoVeP+6DjW9QsMMZfcCS6lnW8g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bfkXAKnv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 918CF606A330;
	Sat, 14 Nov 2026 13:55:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bfkXAKnv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E36F01F000C6;
	Sat, 14 Nov 2026 13:54:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794664501;
	bh=Xi+Jp34UVw8n6rWUcn3QcZPlSKYiPMqX7yCNJrzL8oU=;
	h=In-Reply-To:References:Subject:From:To:Cc:Date;
	b=bfkXAKnvyN3NrzfYhrVigeGIKvr/8evEe0tQ8KwSyEafhDf3+AXVoqojleCZ7/Qdh
	 2b013ZilynaxVntPTxgtS9Fyq3b+7yXhPeXkFfQ9ONM2J9MEOM/JQ3B/znTjkCUpqc
	 r0tlhXctgE98kfAt1ITbmi9H0tApXPCL2XTcrVOM5qnz/NrX0rxwji+SmXMUOe8YHy
	 kRbhgqC/kLnhpgS61Qu7Lfu7BuXDWJsHjF+zOY5u5KKN5rR5uvcX/zOV7QTiz8dq9Z
	 GTd5PKapaf6tpFoOvo6qdgngRWS5W1FIZVvnJWAJ8F5DAYQTkJUN/Wbu5kFv6IHajV
	 XPu1vrQEYpCgg==
Content-Type: multipart/mixed; boundary="===============1687560790659556623=="
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Message-Id: <df03e637354be695652a787563af21ac77b4c61f813ae4491a3397a91df7688e@mail.kernel.org>
In-Reply-To: <20261114-work-loop-pseudo-v2-17-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-17-98639a2286fb@kernel.org>
Subject: Re: [PATCH RFC v2 17/42] securityfs: use fc_init_pseudo()
From: bot+bpf-ci@kernel.org
To: brauner@kernel.org,linux-fsdevel@vger.kernel.org
Cc: jannh@google.com,mason@kernel.org,josef@toxicpanda.com,hch@lst.de,linux-block@vger.kernel.org,linux-kernel@vger.kernel.org,linux-nvme@lists.infradead.org,viro@zeniv.linux.org.uk,jack@suse.cz,linux-scsi@vger.kernel.org,target-devel@vger.kernel.org,driver-core@lists.linux.dev,linux-mm@kvack.org,bpf@vger.kernel.org,linux-security-module@vger.kernel.org,selinux@vger.kernel.org,apparmor@lists.ubuntu.com,linux-nfs@vger.kernel.org,netdev@vger.kernel.org,fuse-devel@lists.linux.dev,linux-efi@vger.kernel.org,xen-devel@lists.xenproject.org,ocfs2-devel@lists.linux.dev,linux-s390@vger.kernel.org,linuxppc-dev@lists.ozlabs.org,linux-usb@vger.kernel.org,amir73il@gmail.com,linux-erofs@lists.ozlabs.org,linux-kselftest@vger.kernel.org,brauner@kernel.org,alex@amutable.com,ast@kernel.org,andrii@kernel.org,daniel@iogearbox.net,martin.lau@kernel.org,eddyz87@gmail.com,yonghong.song@linux.dev,mason@kernel.org,ihor.solodrai@linux.dev
Date: Sat, 14 Nov 2026 13:54:57 +0000 (UTC)

--===============1687560790659556623==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

> securityfs: use fc_init_pseudo()

TL;DR: Setting SB_I_NODEV on securityfs may make reopening AppArmor's
inherited .null fd (e.g. open("/dev/stderr")) fail with -EACCES, which used to
work; the commit message may also be inaccurate about device nodes.

> diff --git a/security/inode.c b/security/inode.c
> --- a/security/inode.c
> +++ b/security/inode.c

[ ... ]

> @@ -64,6 +65,7 @@ static const struct fs_context_operations securityfs_context_ops = {
>
>  static int securityfs_init_fs_context(struct fs_context *fc)
>  {
> +	fc_init_pseudo(fc);
>  	fc->ops = &securityfs_context_ops;
>  	return 0;
>  }

The commit message says "AppArmor puts a .null device node into securityfs
but only ever opens it via dentry_open() which doesn't care about
SB_I_NODEV."  Is that the whole picture?

aa_inherit_files() installs that dentry_open()ed file into the task's fd
table:

    devnull = dentry_open(&aa_null, O_RDWR, cred);
    ...
    replace_fd(n - 1, devnull, 0);

The fd is not O_CLOEXEC, and its f_path.mnt is the internal mount from
simple_pin_fs() in aa_mk_null_file(), which never has MNT_NODEV.

Opening /proc/<pid>/fd/N, or /dev/stdout or /dev/stderr, resolves to that
same path and goes through the normal open path:

    do_open() -> may_open()
        case S_IFCHR:
            if (!may_open_dev(path))
                return -EACCES;

may_open_dev() checks path->mnt->mnt_sb->s_iflags & SB_I_NODEV.  That bit
was clear on the securityfs superblock before this patch and is set now.

Can this make open("/dev/stderr") fail with -EACCES for an unconfined task
that inherited the .null fd, for example a helper exec'd through a ux/Ux
transition from a confined task?  That open used to succeed.

Should the commit message say that this reopen path is intended to fail, or
does .null need separate handling?  The statement that "securityfs never
holds ... device nodes" also seems to conflict with the .null node described
in the next paragraph.


---
AI reviewed your patch. Please fix the bug or email reply why it's not a bug.
See: https://github.com/kernel-patches/vmtest/blob/master/ci/claude/README.md

CI run summary: https://github.com/kernel-patches/bpf/actions/runs/43599461726
--===============1687560790659556623==--
