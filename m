Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDFB3311C38
	for <linux-nfs@vger.kernel.org>; Wed,  4 Feb 2026 22:06:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770242761; cv=none; b=umPR8Uk3jyXYJLIlUDe5sc9KPekGBYH+YRgSiyBf2oH2YA8Uc21KKejVvIbn3l0mTOxZst4CfhBF88KgZx6bohtvSxTGnr7Cps5606AVGz608MIT/Hq+FWSAW3uovRY2fuAT7riBykbzQVG/Qmp+aHPxB2wM0I1V59EpHqhrK1A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770242761; c=relaxed/simple;
	bh=E2UkXUcSjdFnyJlDwLcfQmeZ9dyGhEcZrJXArwhgwig=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=o788z3qmsysqHh8yUxbiMHvCja0w469m013DKLl+I/7GM3qeiVh5L6LYTOzJf5/K1j1lTPyPQTtIdV9Q3Gl32E2b0Hbtlr769hvIeGdZ6q3zTtrU50a9SOrk/Tn99XgV7LbHCAOJvszfLqJjBUjJrcTsjWH4XHSYbtT0J6k2C1A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=uQBXjGe6; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="uQBXjGe6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 209CFC4CEF7;
	Wed,  4 Feb 2026 22:06:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1770242761;
	bh=E2UkXUcSjdFnyJlDwLcfQmeZ9dyGhEcZrJXArwhgwig=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=uQBXjGe6tBILIIfkIxuPbc2B/qe/8Wkan2mKUVjt0cMszqjiiBpnvJ0aZgkZCT9WU
	 1zdhR/xdsGuvl/8qjBq+BcedPeNTrzDWW1y+ztescknGUiJcyU2i4E6yX7dyedNM3k
	 HvLgsBE2QijfPzWzTELbVnWQmwZWFL4axoqOeAwKd6/9q9AwnH42A8mDJ/s9U/oPwC
	 W0AqVQCI7QeZtZ4MfAD6jbHCnfD5Slwsm0kd1IMuMXWaGSMsqdTRr/1vnQQguP4ekF
	 DXrAlEFIoMCi7abgsIMFY93qHlM7S5wRXfDbvkhCg4BLB7qA9REcpIpdon1AnwoVTv
	 OWBFMepJOvN4g==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com,
	hch@lst.de,
	Dai Ngo <dai.ngo@oracle.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] NFSD: fix nfs4_file access extra count in nfsd4_add_rdaccess_to_wrdeleg
Date: Wed,  4 Feb 2026 17:05:58 -0500
Message-ID: <177024274638.126550.5570313022933600659.b4-ty@oracle.com>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260204210807.4134644-1-dai.ngo@oracle.com>
References: <20260204210807.4134644-1-dai.ngo@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Wed, 04 Feb 2026 13:07:43 -0800, Dai Ngo wrote:
> In nfsd4_add_rdaccess_to_wrdeleg, when there is a race condition where
> fp->fi_fds[O_RDONLY] is not NULL, __nfs4_file_get_access should not be
> called to increment the access count nfs4_file since that was already
> done by the thread that adds READ access to the file. The extra fi_access
> count in nfs4_file can prevent the corresponding nfsd_file to be freed.
> 
> When stopping nfs-server service, these extra access counts trigger a
> BUG in kmem_cache_destroy() that shows nfsd_file object remaining on
> __kmem_cache_shutdown.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] NFSD: fix nfs4_file access extra count in nfsd4_add_rdaccess_to_wrdeleg
      commit: b4ae2fc4d1344fe20f431baf00f8256fb3bbaa87

--
Chuck Lever

