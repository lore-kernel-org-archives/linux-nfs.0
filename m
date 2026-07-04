Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7DC43431EF;
	Sat,  4 Jul 2026 02:05:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783130741; cv=none; b=Wqj8d9WriHBezR6YK7AXZju5PRo72o01Hv36+inqqLnWUnnH1eb0eKMvKevofeO1vCsL0BU6BxOR185UtKBcCRyxKRkNsGnDYjqfCBsuRcwkS4L1l6+d7bwZM7Q4R2k+dOmsRqRJthxEdsYzCzW8eSYq6wezrE86vnukCLutXsk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783130741; c=relaxed/simple;
	bh=+MZspb6jd4NigXbMKEVUSzPCyi1i15734/YNShGq9MQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pw8o9M9nfKcSFIx0h0LwHZMkhPPXcnFSM3utLHcigCU7b/h+/VxKApkdzlE+624tqEBkY1e2Gv3Gjd42y1hD5UXBtCblp1cbgwheGiPOnyJ3TR8QN0NLw5cmdWEK+FwHhtqLLepgrIJynPZztHP/VmLjeYuLSpRBhcefmzjMPUU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Q8JFdaXy; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Q8JFdaXy"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E79BE1F000E9;
	Sat,  4 Jul 2026 02:05:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783130740;
	bh=9WM2YU7j6aR0eN08qNnm30jRmphyDgOmQCl47Pwzp44=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Q8JFdaXya6+gkUnjqcPfJ/NdSb0n+ZEWE4VMNWxjxQ20GJOYGkUiN2LsZkzYjKFkH
	 VGpQW0TDDO3vx2+Pe8e25LXyH/JjlG7j7of1CufT/vrWW4YCnUrvZzsZFXnRHJo6EQ
	 Y7x2e7tzmopPtfLomoAsCMLfS1C+oZ3OGH0QT2F6oo+1OXs7/XI4yNStADtQ7x6gXx
	 8roVetGIldApXJddDH2aSknhb7HR8SCHOoT8RdmEzVJk1aA+2ouQ3ac2LlMkZmofAk
	 T80AudWVCwB8qiQVRUQWESKe7XXG372yeMCy7cjHNweQTjF6HN9HKVHvyuMJlUodEF
	 KGGepx2T7gK7w==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-nfs@vger.kernel.org,
	Jeff Layton <jlayton@kernel.org>,
	Chris Mason <clm@meta.com>,
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH 5.10.y] nfsd: reset write verifier on deferred writeback errors
Date: Fri,  3 Jul 2026 22:05:07 -0400
Message-ID: <2026070315-stable-reply-0013@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260703034048.1602590-1-cel@kernel.org>
References: <20260703034048.1602590-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Thu, Jul 02, 2026 at 11:40:48PM -0400, Chuck Lever wrote:
> From: Jeff Layton <jlayton@kernel.org>
>
> commit 2090b05803faab8a9fa62fbff871007862cac1b7 upstream.

Queued for 5.10.y, thanks!

-- 
Thanks,
Sasha
