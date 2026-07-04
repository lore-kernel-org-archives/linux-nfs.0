Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E79A1A9F87;
	Sat,  4 Jul 2026 02:05:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783130737; cv=none; b=Q95iLdSgCFyFPz4EOE3BL+bBSQ2BlsE3ze7Y70j1bioZTWr+35FPVHyu6xv1Xxw3r7Je1xlvBhc3SQckinVCli5L1XfzEFxvqgmV7r1kHqS6NfY6N1lZe8v3hIyAcxDhXtFWMg858bvostrEUSjBhNjhKxaAs3DfUEp7K8/xVOM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783130737; c=relaxed/simple;
	bh=mGc5L3O8KY5ZX0tu000v+QAL7fvN0fanvuVdCL1oufM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EVpWS4SWo7Z29YPhhFvvuKoJ0mh36oFbXP/TK3s02LMZRMX642lPO1qRCua2i8qpfLWhUD9GkRN0FmZMqiQXZ4X/DLFzNIfOdLLWmBasAzMrcLc08DmauCwlutJrsbQ/I2sZZGen2SBgXvQ/TrqExAxbSSzx25gGb62S7FTd6jM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JOaRPIWL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JOaRPIWL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C5CA41F000E9;
	Sat,  4 Jul 2026 02:05:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783130736;
	bh=buYEAbnU2KAgGiRcGlPsITftWtOBQCcyLUMHa8BQq/g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=JOaRPIWLJfV14ukJJizwEGEwyLdvFffPBHO5LgZ4yetoM2YcRO/6d8aFhJjEQzixA
	 DNOvX9P80zIE/0zznvrMLdEchTY+9wG2uq1YockSrS3+cdxmgaPFWVq1N/zRpZ3290
	 OR83/6Ksna90nbyBqG9Jb7K4ZdkpfUQkZbv13cP8FNyacWcPapjQcPxB6ik06CuulC
	 p53ISVeVJWKgnj1bSLr+t7UTN6iIACOewps99rqXNSv4rU3Xiimpv6mpfE8On/bBqe
	 An4QbAcoeDk+bhotUrOl+UzQuu6J+F/C/7lkcR2h8J5vk74YnEytUGxe0X1QEEWKfb
	 kikRLG7YhvFYA==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-nfs@vger.kernel.org,
	Chris Mason <clm@meta.com>,
	Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH 6.1.y 1/2] nfsd: release layout stid on setlease failure
Date: Fri,  3 Jul 2026 22:05:03 -0400
Message-ID: <2026070315-stable-reply-0009@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260703033243.1539871-1-cel@kernel.org>
References: <20260703033243.1539871-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Thu, Jul 02, 2026 at 11:32:42PM -0400, Chuck Lever wrote:
> From: Chris Mason <clm@meta.com>
>
> commit 30d55c8aabb261bc3f427d6b9aae7ef6206063f9 upstream.

Queued the series for 6.1.y, thanks!

-- 
Thanks,
Sasha
