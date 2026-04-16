Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3248D3B9DA9;
	Thu, 16 Apr 2026 13:07:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776344854; cv=none; b=NkAORj0caRJWVPjFOr3V+0lrWhMAKQORsRGoknS5SoaMImO39vXBEeTaX8P224P2KRbw0az/T3+HbenvEXdUW4N3hUelOC1A3Iz0E1Wxnc/YVhV4uo0Qv2UhJartsa7WIeybSHX2aSkm5X8ClnUnfLz5NbvDgOj2TwIaAuJFhjI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776344854; c=relaxed/simple;
	bh=RGR6IlEqqpx/s8nsqEXCWO4lq2ztrH/pNohj84WOIyg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=LGeNSTBRMIu4BIvUZ5XcYiIqRdenE2qMKPl6A333wx/4s4xQdXkMRzc4gOdEdexeCM7jJZVr2klMCLbtx6fI8tEao8Gek1/vLnM8yH1KsZJ+g064EMXUqNJlB9D2/6GLNySOHx0lr67IbXN4D4JZHQvDQvyqnwacrsrzfrgVxHU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CzAs7Sbw; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CzAs7Sbw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AECD9C2BCAF;
	Thu, 16 Apr 2026 13:07:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776344853;
	bh=RGR6IlEqqpx/s8nsqEXCWO4lq2ztrH/pNohj84WOIyg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=CzAs7SbwQrDdP5LCSfO/4gW/2qXtErV9fwwNpEDqonWYUo1srfmpbU06AtrtIji3D
	 cHH74WWVXTIXnWkTV4G9RNIzrifNP5IAfcaMbTNlOf6f9tOwAeG3mCnFnx+sIJuJsC
	 h5kiN7Iy54irw7Ux6h7Xih+CDNPVTVH6Weh6adW8TJ79X1APpf3XeOij239tt//YYL
	 Xx8odjofMJ1HpaB5BRZ+D5twCW2zNd7gvhNeyyNx2ODWE/IR5WrGwNcZFyWSbDOHTY
	 ega3a7GHNP8fjVeqm/ZwM1Om4G/zzRsB/Me9LxR/tyDW/UQGmnkNTNwDLg2ly0Dd+U
	 HTA2JMtVgmXyQ==
From: Christian Brauner <brauner@kernel.org>
To: linux-fsdevel@vger.kernel.org,
	Dorjoy Chowdhury <dorjoychy111@gmail.com>
Cc: Christian Brauner <brauner@kernel.org>,
	linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	gfs2@lists.linux.dev,
	linux-nfs@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-kselftest@vger.kernel.org,
	viro@zeniv.linux.org.uk,
	jack@suse.cz,
	jlayton@kernel.org,
	chuck.lever@oracle.com,
	alex.aring@gmail.com,
	arnd@arndb.de,
	adilger@dilger.ca,
	mjguzik@gmail.com,
	smfrench@gmail.com,
	richard.henderson@linaro.org,
	mattst88@gmail.com,
	linmag7@gmail.com,
	tsbogend@alpha.franken.de,
	James.Bottomley@HansenPartnership.com,
	deller@gmx.de,
	davem@davemloft.net,
	andreas@gaisler.com,
	idryomov@gmail.com,
	amarkuze@redhat.com,
	slava@dubeyko.com,
	agruenba@redhat.com,
	trondmy@kernel.org,
	anna@kernel.org,
	sfrench@samba.org,
	pc@manguebit.org,
	ronniesahlberg@gmail.com,
	sprasad@microsoft.com,
	tom@talpey.com,
	bharathsm@microsoft.com,
	shuah@kernel.org,
	miklos@szeredi.hu,
	hansg@kernel.org
Subject: Re: [PATCH v6 0/4] OPENAT2_REGULAR flag support for openat2
Date: Thu, 16 Apr 2026 15:07:12 +0200
Message-ID: <20260416-abgraben-seeweg-a44ce660957f@brauner>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20260328172314.45807-1-dorjoychy111@gmail.com>
References: <20260328172314.45807-1-dorjoychy111@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Developer-Signature: v=1; a=openpgp-sha256; l=2157; i=brauner@kernel.org; h=from:subject:message-id; bh=RGR6IlEqqpx/s8nsqEXCWO4lq2ztrH/pNohj84WOIyg=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWQ+uM++wXB/S+Hvp5l/rigkRrF0TPIL6P15cr/RvNQpM /QUzkjXd5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzkjjLDf4eZR2wq2503fAzq /GWqvre2dffiM/cq/G2aL5n8OqWz3J/hf+KxvnNrrPo65qRG+AmXfZid5cS+6G6OdJBWUnP8rJi rzAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

On Sat, 28 Mar 2026 23:22:21 +0600, Dorjoy Chowdhury wrote:
> I came upon this "Ability to only open regular files" uapi feature suggestion
> from https://uapi-group.org/kernel-features/#ability-to-only-open-regular-files
> and thought it would be something I could do as a first patch and get to
> know the kernel code a bit better.
> 
> The following filesystems have been tested by building and booting the kernel
> x86 bzImage in a Fedora 43 VM in QEMU. I have tested with OPENAT2_REGULAR that
> regular files can be successfully opened and non-regular files (directory, fifo etc)
> return -EFTYPE.
> - btrfs
> - NFS (loopback)
> - SMB (loopback)
> 
> [...]

- I've added an explanation why OPENAT2_REGULAR is only needed for some
  ->atomic_open() implementers but not others. What I don't like is that
  we need all that custom handling in there but it's managable.

- I dropped the topmost style conversions. They really don't belong
  there and if we switch to something better we should use (1 << <nr>).

- I split the EFTYPE errno introduction into a separate patch.

---

Applied to the vfs-7.2.openat.regular branch of the vfs/vfs.git tree.
Patches in the vfs-7.2.openat.regular branch should appear in linux-next soon.

Please report any outstanding bugs that were missed during review in a
new review to the original patch series allowing us to drop it.

It's encouraged to provide Acked-bys and Reviewed-bys even though the
patch has now been applied. If possible patch trailers will be updated.

Note that commit hashes shown below are subject to change due to rebase,
trailer updates or similar. If in doubt, please check the listed branch.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
branch: master

[1/4] openat2: new OPENAT2_REGULAR flag support
      https://git.kernel.org/vfs/vfs/c/0b649c4d70f7
[2/4] kselftest/openat2: test for OPENAT2_REGULAR flag
      https://git.kernel.org/vfs/vfs/c/d7dc36df8fa7
[3/4] sparc/fcntl.h: convert O_* flag macros from hex to octal
      (dropped)
[4/4] mips/fcntl.h: convert O_* flag macros from hex to octal
      (dropped)
