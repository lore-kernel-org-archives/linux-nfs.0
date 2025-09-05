Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CF1636CDF6;
	Fri,  5 Sep 2025 14:25:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757082330; cv=none; b=bLgNLYXxeAbtMBiir1CR62IUQjcm3Xpjbt0+Zdq4sXEWMmAYsfKFlEnEXOxcK3Z0OrVUgVhd6SyYMVRqvz99nBLpBkzL5OPyXKiWlckInMZbE7l1Qurt9SeLv/fTLuLNK5Quhjfj1XdHSjH/KaToS49EA3vWUmt9UqLBPtTQSlo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757082330; c=relaxed/simple;
	bh=S9K36lpwd8spj6yIkAA1HzhZwJLWmbtPSWwtnv3FdHA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=GfFK1PjWlLo2WK33lBUbAohm1tRWtt1B2XV9GgvlqWsXCDzWt6YshYpQTQ4Cq6Y+FHqDf945UGsANIUKcV4Ps/Tutww2XSemOLTANSSPzigTC973vgEpDTHSsNdYZB6HaQCnKi+4qaEp+RZ5eZ2OIs4NuxbpbvT54gBJoUPWg8s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=t1iRWSLC; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="t1iRWSLC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A9C1AC4CEF7;
	Fri,  5 Sep 2025 14:25:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1757082327;
	bh=S9K36lpwd8spj6yIkAA1HzhZwJLWmbtPSWwtnv3FdHA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=t1iRWSLC9I+G/JcOtADnLTxljQBpRLUHfVM8B74IM8oB/58rpdMGVMQYNXGOjJtaw
	 /c2XvZ13FtBd5RimefK4FiuLwEYE8ru3URCLUfcSF8aCWyucqwhvU0eGa1WmXvN3QS
	 VC9ONUaVb0Eo9oyC7hUBA4neyE1c1rRj5VP2HOfq/Qx4uIPQw6nUzKmfpT0PNionUR
	 ZgdRtXylzSWaim7X4wU+Fy2tu7nOU6ztmi8Culw+JHegr2ULHeT6GU0ddvcPfuVxEv
	 3i5cTV8kW51RuXWtyzc5kAdEKiU/bhSJVcb2sXZp54mB5JCDKQs76QmqceIcbffQVk
	 V9dzFDdykHvCg==
From: Chuck Lever <cel@kernel.org>
To: trondmy@kernel.org,
	anna@kernel.org,
	jlayton@kernel.org,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com,
	Xichao Zhao <zhao.xichao@vivo.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	horms@kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: fix "occurence"->"occurrence"
Date: Fri,  5 Sep 2025 10:25:23 -0400
Message-ID: <175708231358.5825.18214278635184867174.b4-ty@oracle.com>
X-Mailer: git-send-email 2.50.0
In-Reply-To: <20250812113359.178412-1-zhao.xichao@vivo.com>
References: <20250812113359.178412-1-zhao.xichao@vivo.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Tue, 12 Aug 2025 19:33:59 +0800, Xichao Zhao wrote:
> Trivial fix to spelling mistake in comment text.
> 
> 

Applied to nfsd-testing, thanks!

[1/1] sunrpc: fix "occurence"->"occurrence"
      commit: 0537ff762ce5e18676e9e144456ae7cdd3f4410c

--
Chuck Lever

