Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794830419;
	b=1PtcXJGFiup97ZeLwMLQ5c20u9r3eyG4/8CmJqGZWtvuJd5xnN9ShaLPY1saDZ4ca41l
	 JrJjaKK9zbgliXnyx3KmSxg0jq9ZY8791g98Q5HwLa8ySL1A6DEXhdSDeVVxK2leWU+hP
	 bk8DKSVbdQ1tfTt+b/UMV5XUdKFIAO3iysm1EijG5qUIWC7Ip+FzeSJQCk5lL+HVdtCBD
	 xvaucbrPl6PD/wSPOpzaiugZwPYZcZFOF+V+b56MxOpHe73M2ObGONV6nYsBge/cvD1jP
	 RZT8t08JbnwETdx47Aqwkb/JgTpipLpby61IvAS5FV+fZm/qcUOMFovBx3Qy0qmQVAw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794830419;
	h=Received:DKIM-Signature:Content-Type:MIME-Version:Message-Id:
	 In-Reply-To:References:Subject:From:To:Cc:Date;
	bh=ewJeUaksgXnSPjHwujvoiDsCY2620AwnIo92RczcOPg=;
	b=BAgKG+PmbAf1Nhz1nqOv96pU7TJlA9cGHWmALI3lqAuFU8EbJiTnl+wJo5x7kMj9nYD/
	 WHw7X6+Dc9EQodpjlCsnRoLT2d9uRBWBwhtKNKvp9VbWSxNA3nNqk0LYPH4C4kB6dv15T
	 ipAWr7w5VImy9cLfISP19wzUWuQ8fy5q0iqEYOEsnEKLdNQhTtjn6nAGYC5ySNrg9XDp2
	 DES0HYVZy79Iz0OC5GN0rt9X6/KIFe+5iy24p9Jy5l0hALnINJUZm7ZxzxM5mnw3lusei
	 kLxB3NzAOPnuRGK1BoGuyVknO8Ei6UnKK6MBnDrtATW0aHvkLj9qagajvebsDqDgX4Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NGs9hgRo;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC5FB606A31C;
	Mon, 16 Nov 2026 12:00:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NGs9hgRo
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B1241F000C4;
	Mon, 16 Nov 2026 12:00:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794830419;
	bh=ewJeUaksgXnSPjHwujvoiDsCY2620AwnIo92RczcOPg=;
	h=In-Reply-To:References:Subject:From:To:Cc:Date;
	b=NGs9hgRo8Pm53dwqOowj804JfWGt9pNSxyXsA5ZbufV3wNEO1pXrEV/P2nYSJ6s0h
	 RkTVtrJGGRLTAc/i5stGgdH7MoEG/RRlQzCp8xsSKAlYN1LFViwB+sXdk4YoAbt7yZ
	 PR7EK3GRWabIulVC1l0sYiPb/s/WJh1GIS+NuEi9fxzz0zXVvfrqLfrCezMd74ZtjC
	 IEP94sDVVDwuNz+mWo090jAlScdWhDl8h+8NtgR+BEvWRcqbaBD+sHm90zfAZDrFLE
	 Ium0YC6BRRHbiChOy1fGM3bxcnzkJeY8LsKxgOeIXXUZU9bjQC0KNhILzz6Uz/yD+e
	 WluvUktyVhSBw==
Content-Type: multipart/mixed; boundary="===============1962703051549190966=="
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Message-Id: <56b5bed0bd75b5b0c7368009493734cda89f1ca37c0fc29c81ed65048cbfeca4@mail.kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-44-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-44-8cbbea1cf34f@kernel.org>
Subject: Re: [PATCH RFC v3 44/44] selftests/filesystems: add backing file tests for pseudo files
From: bot+bpf-ci@kernel.org
To: brauner@kernel.org,linux-fsdevel@vger.kernel.org
Cc: jannh@google.com,mason@kernel.org,josef@toxicpanda.com,hch@lst.de,linux-block@vger.kernel.org,linux-kernel@vger.kernel.org,linux-nvme@lists.infradead.org,viro@zeniv.linux.org.uk,jack@suse.cz,linux-scsi@vger.kernel.org,target-devel@vger.kernel.org,driver-core@lists.linux.dev,linux-mm@kvack.org,bpf@vger.kernel.org,linux-security-module@vger.kernel.org,selinux@vger.kernel.org,apparmor@lists.ubuntu.com,linux-nfs@vger.kernel.org,netdev@vger.kernel.org,fuse-devel@lists.linux.dev,linux-efi@vger.kernel.org,xen-devel@lists.xenproject.org,ocfs2-devel@lists.linux.dev,linux-s390@vger.kernel.org,linuxppc-dev@lists.ozlabs.org,linux-usb@vger.kernel.org,amir73il@gmail.com,linux-erofs@lists.ozlabs.org,linux-kselftest@vger.kernel.org,brauner@kernel.org,alex@amutable.com,chris@chrisdown.name,ast@kernel.org,andrii@kernel.org,daniel@iogearbox.net,martin.lau@kernel.org,eddyz87@gmail.com,yonghong.song@linux.dev,mason@kernel.org,ihor.solodrai@linux.dev
Date: Mon, 16 Nov 2026 12:00:17 +0000 (UTC)

--===============1962703051549190966==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

> selftests/filesystems: add backing file tests for pseudo files

TL;DR:
- Selftest: fuse tests may fail instead of skip without
  CONFIG_FUSE_PASSTHROUGH (-EOPNOTSUPP, not -EPERM)
- Metacopy test may fail without CONFIG_TMPFS_XATTR
- Minor duplicated setup code

> diff --git a/tools/testing/selftests/filesystems/config b/tools/testing/selftests/filesystems/config
> --- a/tools/testing/selftests/filesystems/config
> +++ b/tools/testing/selftests/filesystems/config
> @@ -6,3 +6,19 @@ CONFIG_NET=y
>  CONFIG_NET_NS=y
>  CONFIG_INET=y
>  CONFIG_SYSFS=y
> +CONFIG_BLK_DEV_LOOP=y
> +CONFIG_OVERLAY_FS=y
> +CONFIG_TMPFS=y
> +CONFIG_CONFIGFS_FS=y
[ ... ]

Should CONFIG_TMPFS_XATTR=y be added here as well?

TEST(fuse_passthrough_overlayfs_metacopy_file) mounts a private tmpfs
through setup_tmp() and then does:

    ASSERT_EQ(setxattr("/tmp/lower/file", "trusted.overlay.metacopy",
                       "", 0, 0), 0);

shmem_fill_super() only sets sb->s_xattr under CONFIG_TMPFS_XATTR, which
defaults to n, and CONFIG_TMPFS does not select it.  Without it
setxattr() fails with EOPNOTSUPP, the ASSERT_EQ() aborts, and the run
reports a failure rather than a skip.  tools/testing/selftests/landlock/config
lists CONFIG_TMPFS_XATTR=y next to CONFIG_TMPFS=y.

Alternatively the test could SKIP when setxattr() returns EOPNOTSUPP.

> diff --git a/tools/testing/selftests/filesystems/pseudo_backing_test.c b/tools/testing/selftests/filesystems/pseudo_backing_test.c
> new file mode 100644
> --- /dev/null
> +++ b/tools/testing/selftests/filesystems/pseudo_backing_test.c

[ ... ]

> +TEST(overlayfs_on_sysfs_backing_file)
> +{
> +	if (!can_use_loop())
> +		SKIP(return, "loop devices unavailable");
> +
> +	ASSERT_EQ(unshare(CLONE_NEWNS), 0);
> +	ASSERT_EQ(mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL), 0);
> +	ASSERT_EQ(mount("tmpfs", "/tmp", "tmpfs", 0, NULL), 0);

this isn't a bug, but could overlayfs_on_sysfs_backing_file() call
ASSERT_EQ(setup_tmp(), 0) like the other tests, instead of repeating its
three steps?  Similarly, usb_mass_storage_backing_file() repeats the
statfs()/CONFIGFS_MAGIC/mount() logic of setup_configfs(), and the comment
"Mounting configfs on top of itself fails with EBUSY." appears twice.

[ ... ]

> +TEST(fuse_passthrough_backing_file)
> +{
> +	int fuse_fd, ret;
> +
[ ... ]
> +	ASSERT_EQ(create_file("/tmp/file"), 0);
> +	ret = fuse_backing_path(fuse_fd, "/tmp/file", O_PATH);
> +	if (ret == -EPERM)
> +		SKIP(return, "no fuse passthrough");
> +	EXPECT_EQ(ret, 0);

Is -EPERM the right errno to key the skip on?  On a kernel with
CONFIG_FUSE_FS=y and CONFIG_FUSE_PASSTHROUGH=n the test filesystem mounts
fine, and then fuse_dev_ioctl_backing_open() returns before any
permission check:

    if (!IS_ENABLED(CONFIG_FUSE_PASSTHROUGH))
        return -EOPNOTSUPP;

-EPERM only comes from fuse_backing_open_file() when fc->passthrough is
clear or CAP_SYS_ADMIN is missing.  So here EXPECT_EQ(ret, 0) and the
later -EINVAL checks see -EOPNOTSUPP and fail, and the harness records
"not ok" for a feature that is not configured.  Kernels that predate
FUSE_DEV_IOC_BACKING_OPEN return -ENOTTY and fail the same way.

Should -EOPNOTSUPP (and possibly -ENOTTY) also lead to the SKIP?

[ ... ]

> +TEST(fuse_passthrough_overlayfs_metacopy_file)
[ ... ]
> +	ASSERT_EQ(create_file("/tmp/lower/file"), 0);
> +	ASSERT_EQ(setxattr("/tmp/lower/file", "trusted.overlay.metacopy",
> +			   "", 0, 0), 0);
> +	ASSERT_EQ(setxattr("/tmp/lower/file", "trusted.overlay.redirect",
> +			   "/missing", strlen("/missing"), 0), 0);

Can these setxattr() calls fail on a kernel without CONFIG_TMPFS_XATTR?

The private tmpfs from setup_tmp() has no xattr handlers in that case, so
setxattr() returns EOPNOTSUPP, the ASSERT_EQ() aborts, and the program
exits with a failure instead of KSFT_SKIP.  The mount of overlayfs just
below already has a SKIP for missing support.  Would a SKIP on
EOPNOTSUPP here, or CONFIG_TMPFS_XATTR=y in the config fragment, avoid
this?

> +	ret = fuse_backing_path(fuse_fd, "/tmp/file", O_PATH);
> +	if (ret == -EPERM)
> +		SKIP(return, "no fuse passthrough");
> +	ASSERT_EQ(ret, 0);

The same -EPERM check as in fuse_passthrough_backing_file() is used here,
so ASSERT_EQ(ret, 0) fails with -EOPNOTSUPP when CONFIG_FUSE_PASSTHROUGH
is off.

[ ... ]

> +TEST(fuse_passthrough_io)
[ ... ]
> +		srv.backing_ids[i] = fuse_backing_open(srv.fd, fd);
> +		EXPECT_EQ(close(fd), 0);
> +		if (srv.backing_ids[i] == -EPERM)
> +			SKIP(return, "no fuse passthrough");
> +		ASSERT_GT(srv.backing_ids[i], 0);

Does this skip also miss the unconfigured case?  With
CONFIG_FUSE_PASSTHROUGH=n, fuse_backing_open() gets -EOPNOTSUPP from the
ioctl, which is not -EPERM, so ASSERT_GT(srv.backing_ids[i], 0) fails and
run_one() records "not ok" for the whole pseudo_backing_test.  No fuse
server has been started at this point, so nothing hangs.  The config
fragment does list CONFIG_FUSE_PASSTHROUGH=y, but should -EOPNOTSUPP and
-ENOTTY also lead to SKIP(return, "no fuse passthrough") in all three fuse
tests?


---
AI reviewed your patch. Please fix the bug or email reply why it's not a bug.
See: https://github.com/kernel-patches/vmtest/blob/master/ci/claude/README.md

CI run summary: https://github.com/kernel-patches/bpf/actions/runs/43858134663
--===============1962703051549190966==--
