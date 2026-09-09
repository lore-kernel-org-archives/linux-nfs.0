Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7687F55D882;
	Wed,  9 Sep 2026 14:11:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788963100; cv=none; b=RLburTCb0rStikXeyYNlDnoKtcZKXny6dyflrEwxXQhGTHBuvvKfkbp1SBdNQ5kUeb/TBVh+Fix4xcY4TKifpmtTFFhZQBsJPNKbqewEVrZbZxKZ8PPxjJqtsDyD0sys3uYsF4N2v8IxNxGyLCVPtcwF31he3yo0Jx0HusKQKEI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788963100; c=relaxed/simple;
	bh=tRwaTQimLd6eGE7ImLxFJ1HKcqfP6Yn3Y3qF/ymXPvw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=UZ93JC5+1qAI05n7BS+dhLQySEt+0okhIzqDE+J1CWV3f1FzZw/xgndft0ZWq5mMT16nOOEIVQMpQTDtJ1CxIDBfZQ2cRVRU5Gk2O8HT5jjQy74fH6V7vjRDyV1aLqSwjZDV+58IE0ThF5hN8X1yAbi2gP89fQL0gmQ1Z4i0I2Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=n0uNeOzQ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="n0uNeOzQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9AF781F00A3D;
	Wed,  9 Sep 2026 14:11:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788963099;
	bh=4ji3RhL9WeK3LjyjqzmSB/Da4XA+vDhbClieLz5uYaU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=n0uNeOzQ2lVP4aEdhCKW31ZcSs80k2l33b8WMdVg2OHELVc6AxG2LSs8l0+piugrN
	 HCHbi0zBLKXXjwPGZ/xMuwXwDPNfWvumZwak+Wir6HKszZUjjuzBJWcRbZ1ElPq7O1
	 arxRWkmDeTsAjEL40kqBAMd7iloP7Ey6LfhPHzkKMDakGrdfrtainLue+rszk22Csy
	 jHZ1BeeXmsHPMsILRRSoczlhkRUsTLrVIk0rsM2HX2ll0zeGjSJDXpVO43PRm/7i61
	 P8PwNqyPKRNh3aZA0WsCWxMl0jyCUUuNy2dewl50xxTbZZnrD/1b7nC//ivZzuDYSp
	 O3dwGQTiSj22Q==
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org,
	linux-block@vger.kernel.org,
	Mike Snitzer <snitzer@kernel.org>
Cc: dm-devel@lists.linux.dev,
	axboe@kernel.dk,
	jlayton@kernel.org,
	david.flynn@hammerspace.com
Subject: Re: [PATCH 3/4] nfsd: fetch direct I/O alignment for files handed to the filecache
Date: Wed,  9 Sep 2026 10:11:35 -0400
Message-ID: <178896306557.22359.10853351140425933199.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260908163448.30841-4-snitzer@kernel.org>
References: <20260908163448.30841-4-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 08 Sep 2026 12:34:38 -0400, Mike Snitzer wrote:
> nfsd_file_do_acquire() fetches a file's direct I/O alignment
> attributes (nf_dio_mem_align, nf_dio_offset_align and
> nf_dio_read_offset_align) only on the branch where NFSD opens the
> file itself. The other branch, taken when the caller supplies an
> already-open struct file, stores that file in the nfsd_file and
> leaves the three alignment fields zero.
> 
> [...]

Applied to nfsd-testing, thanks!

[3/4] nfsd: fetch direct I/O alignment for files handed to the filecache
      commit: abf2077ee32058e60d3f49ecab265d3c4bd953d9

--
Chuck Lever

