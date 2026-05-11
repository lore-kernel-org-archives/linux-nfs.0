Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5802E3BADB5
	for <linux-nfs@vger.kernel.org>; Mon, 11 May 2026 09:15:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778490944; cv=none; b=Bzr/NluNDRqHW17hfioe9ojzkiP+nJS7pp70TXKY2B2e1gb3/9VEEohp1rxePjAgqhrueeMwq2LHp2UwpAIKz/+zaV6Xp6cQpjbsBZoK1KQENy2+xwoh9Vm9dlLlRC7BMd3OtVb5BeV479Cp7ZO7Zv13fOpTcSdEo39EfwdMdtc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778490944; c=relaxed/simple;
	bh=S24DEVqLLodiJzgnWz/FoRSWsLR5bj+eVXU5sEl2GcE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=tQYDlTx8arlMt6meTXBtJorC6BEUIbtCjNSfMhEe1JNf7YpUkndZOXEhPD0MIFxc4blkpsgc41SPt7YHu0ZLU/n9F1knUli/SDEkmZJioEygw+o4fZRYV1R0YZ53bxvOefd5GXBeCzj1YwKtHYSwQIvi19sBO1J/cJpwXJc+gz0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Z5tL6nyz; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Z5tL6nyz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DCE56C2BCB0;
	Mon, 11 May 2026 09:15:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1778490943;
	bh=S24DEVqLLodiJzgnWz/FoRSWsLR5bj+eVXU5sEl2GcE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Z5tL6nyzfVIzc57p3dpIp9z7gdo1QPZ6G6YF/D2IuN4g5CKnY/J+r/9tvCWxEqzVc
	 j1o5MgOlWohKJU/MRpy9ya/zPYVGGmQ9cOSWD/Febfr83c4+avDcmwfZ05/PhEvSqJ
	 Dfe70CXENvS8r5lGk8dJaSc58xxGgtTrL3yjZU9g50q4kNNjwH59qe2HT4o4c6nDno
	 pdREd1BlpkuhVwJm4g2nogZ/WsZ5D7LIxgyITSSD7NF4bikH2apEKEkgGoJNVLgSXT
	 Asizqa5lepTMzYE3NLSiEENhJ2BO3An0uTACSAw1QQIzns0pJiaxcZ4cTKi78TCBgn
	 yhYUF/LiQfQ1w==
From: Christian Brauner <brauner@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christian Brauner <brauner@kernel.org>,
	NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/4] cleanup block-style layouts exports
Date: Mon, 11 May 2026 11:15:19 +0200
Message-ID: <20260511-zombie-habilitation-08bc00f1a404@brauner>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20260423181854.743150-1-cel@kernel.org>
References: <20260423181854.743150-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Developer-Signature: v=1; a=openpgp-sha256; l=1625; i=brauner@kernel.org; h=from:subject:message-id; bh=sd7570q5aKh6P8PBxA7+OYUd1+X1K3h/BNeSLoajSGs=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWQxztM4UiryanpupMEC/ekttl3BV7Z/nfFHrpmBK3qJy 8ftDD0fO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACayaB0jw7R7iULLkyWc0y7H Xtqe373qpadJ22me8iirynUBTA7xMxkZlvx4deOAXfdnNd5tvT4B/gVraqQfp8v2LbY9l28i3Vz DCQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

On Thu, 23 Apr 2026 14:18:50 -0400, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> Following up on https://lore.kernel.org/linux-nfs/20260401144059.160746-1-hch@lst.de/#r
> 
> Here is the current version of Christoph's patches that are in
> nfsd-testing. Christian prefers to see them taken through the VFS
> tree. Once the patches are applied there, I will rebase nfsd-next
> and nfsd-testing on that tree and drop these.
> 
> [...]

The branch is stable in case anyone wants to rely on it.

---

Applied to the vfs-7.2.exportfs branch of the vfs/vfs.git tree.
Patches in the vfs-7.2.exportfs branch should appear in linux-next soon.

Please report any outstanding bugs that were missed during review in a
new review to the original patch series allowing us to drop it.

It's encouraged to provide Acked-bys and Reviewed-bys even though the
patch has now been applied. If possible patch trailers will be updated.

Note that commit hashes shown below are subject to change due to rebase,
trailer updates or similar. If in doubt, please check the listed branch.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
branch: vfs-7.2.exportfs

[1/4] nfsd/blocklayout: always ignore loca_time_modify
      https://git.kernel.org/vfs/vfs/c/0d9ff5c4219f
[2/4] exportfs: split out the ops for layout-based block device access
      https://git.kernel.org/vfs/vfs/c/d5758c31a81b
[3/4] exportfs: don't pass struct iattr to ->commit_blocks
      https://git.kernel.org/vfs/vfs/c/61eb48f51585
[4/4] exportfs,nfsd: rework checking for layout-based block device access support
      https://git.kernel.org/vfs/vfs/c/da9baa5470dc
