Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19DB8455617;
	Wed,  7 Oct 2026 18:08:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791396499; cv=none; b=G3JB5oPrMYqeQjW4NZSXBos80/5wdyI1NBW2yNk3TE1JRnrZ5p1VhVUy7+6hfT0SifAfBte5hVdSZlslNZkols0SUiokFpxxcfSYm5U8UNrVsC4DVdTPOCIgpSZt01maT2k28wKb9234lssH+NOWj0spFjyxZk0G25wgD3jVCuo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791396499; c=relaxed/simple;
	bh=TmS+OE03I4r2lXVvBv4ojG4eh4BUXVdq+iGbvyJvd4w=;
	h=Date:Message-ID:From:To:Cc:Subject:In-Reply-To:References; b=k8z5cQT4Ec0Je4RU91WpmapBzE6WaQk+9X21ADTli55ety0vaq6Iho4XXdyFBztRtouOJrCmd3qvGIDtUe7Y8vi5DJw+9BQUwzbuQdjanluxq9+kt+RMiZhxq+EP41RSOTzLc7wRrdOzfSR7gGoQAljwilJaJnMRDIphDXNcA8U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=X//tjLZb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="X//tjLZb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 655631F000FF;
	Wed,  7 Oct 2026 18:08:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791396497;
	bh=TmS+OE03I4r2lXVvBv4ojG4eh4BUXVdq+iGbvyJvd4w=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=X//tjLZbQDplWvJRhnSdSL2UhWdifJ4wJaFODlxCuzvYz/+Akv23sxqQE8V78DvqN
	 162+O6e9qMu5sFdcdcXZZL03ic/m/2qLjbo2ImpqG4x2FytQ8iR1oQ5vUzPLkW7ioC
	 ES3+OaCD4oXTfvMWHn9S1j50LgrK1g/nPbfdVtIg8vakQ/E9lNrQZAF4FtV78/ugMv
	 XV3Kcu6yiksfqM0Lsf6pAgLuTeg15A5RdD+ZjRv6nj+7znnE4Q8RMv6MaNiVEq/2qM
	 3LmAXTX0mlQXhGlXZNwJk2IslmLww5EqMjQBNTwC8gNYEb6vou5HgGI/j8mUMG9oGO
	 lCfLhkWiVWAng==
Date: Wed, 07 Oct 2026 08:08:16 -1000
Message-ID: <2706c8dfeb894491c83bda2953b12f81@kernel.org>
From: Tejun Heo <tj@kernel.org>
To: Pavankumar Kondeti <pavan.kondeti@oss.qualcomm.com>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>,
 Trond Myklebust <trond.myklebust@hammerspace.com>,
 Mike Snitzer <snitzer@hammerspace.com>,
 Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>,
 linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] workqueue: Fix NULL current_pwq deref in mem-reclaim helper
In-Reply-To: <20260928-wq_mem_reclaim_fix-v1-1-0dd37125cf47@oss.qualcomm.com>
References: <20260928-wq_mem_reclaim_fix-v1-1-0dd37125cf47@oss.qualcomm.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

Applied to wq/for-7.3-fixes.

Thanks.

--
tejun
