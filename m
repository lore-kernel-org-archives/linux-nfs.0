Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 08B031C5F11;
	Tue, 10 Mar 2026 22:30:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773181835; cv=none; b=tIB5JnfWdTyYJmXAC+NFTFnwt3gcuZHntp50Ykxi4yGoLjMM+vPFbDRegGRtWJEMV7H2JTRPyOIIrJdTARKtrd7BiUifHeTJSz491o6W5IXnkEyu1mjzGRVFdfgurVsVcIP1ifh76hhSsP2AUJVePBHDWOCzN42wbkxqkUoOC+Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773181835; c=relaxed/simple;
	bh=tb58vpxzJlIZRd9WgyWRFH3D756RDtt0dYG80U6plL4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=FfDDoW8eZT8XO3D+Mq/X8Hx6CDli4etqdgjhc/Y4HhdigwrCci2QIVeJqt1R83vlCk7y0Yd6UizeyPtgXbXkWW9fY3cxr4ZcFf+JCZXwoQBiTPn4KBZwnfxayizvXcvfouxh7SWtu/o11B6Q1zSGPKXzQXTzFAntlqW2V+28W+0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ubALhYsp; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ubALhYsp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 104CDC19423;
	Tue, 10 Mar 2026 22:30:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773181834;
	bh=tb58vpxzJlIZRd9WgyWRFH3D756RDtt0dYG80U6plL4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ubALhYspnJZgUCO0Bhpsqd1pTOSqEgS3NbTnp+e62N5Axz7vas+mSfFlyXZfcYTN0
	 D750XcLbp1f6kvpuQgDU+vQmbTSXf/0IJ//PVbS38UjAGUrPc4kAVAEBl5UUyXZ0u9
	 nk9+pZ+b5TrOvE126c+biBQOIUTWFUm35DIdImiJnhVmx0cXlKNS/EFWsesc02yk4w
	 GKSW7cNlMpWXXZr3+2fqn7Zm/RMga1wvnD+9EKdStnsT7XyECrCOOftlNmr7g6xgXY
	 MqLajhKkU0OkZaJiRFNGQiIX8xP23rtkeWlkdumTSAbsPOjJl2RuFWpfpFPW0Zn1RG
	 SHEgPuXtmi9JA==
Date: Tue, 10 Mar 2026 23:30:31 +0100
From: Frederic Weisbecker <frederic@kernel.org>
To: Christian Brauner <brauner@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-modules@vger.kernel.org,
	linux-nfs@vger.kernel.org, bpf@vger.kernel.org,
	kunit-dev@googlegroups.com, linux-doc@vger.kernel.org,
	linux-trace-kernel@vger.kernel.org, netfs@lists.linux.dev,
	io-uring@vger.kernel.org, audit@vger.kernel.org,
	rcu@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux.dev, netdev@vger.kernel.org,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org,
	Christian Loehle <christian.loehle@arm.com>,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 2/2] tree-wide: rename do_exit() to task_exit()
Message-ID: <abCbhzZT2We5tJA3@pavilion.home>
References: <20260310-work-kernel-exit-v2-0-30711759d87b@kernel.org>
 <20260310-work-kernel-exit-v2-2-30711759d87b@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260310-work-kernel-exit-v2-2-30711759d87b@kernel.org>

Le Tue, Mar 10, 2026 at 03:56:10PM +0100, Christian Brauner a écrit :
> Rename do_exit() to task_exit() so it's clear that this is an api and
> not a hidden internal helper.
> 
> Signed-off-by: Christian Brauner <brauner@kernel.org>

Acked-by: Frederic Weisbecker <frederic@kernel.org>

-- 
Frederic Weisbecker
SUSE Labs
