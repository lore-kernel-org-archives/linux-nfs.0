Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 714743242D4;
	Sun, 11 Oct 2026 16:48:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791737312; cv=none; b=I+viTdD1vW60KgXAQNi2tAsrjsneeri0BxxDrk6aHxtb7J/q62napvNk1DW2GrZp6eFNm2LiR8HPKMBRlv0jkx5Ai5khW7XI6ercW3ViYXOVzDSWx7fmW8MLbtcXfO3X3gTbozrpqVw2kQvikis7YNzWHljXiNgI8FwjXiMg/Aw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791737312; c=relaxed/simple;
	bh=ceX0y89UUVz9U7ls50mCoBmp0+WIsJO5QLMcqyFZxiU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MnwGWRhALiOc6VPZtidKnXfa7QqxHArpPXM6bL+3FYrHnYA59m5djtJSD5OgmjeMbJzLZL7KHnYS89h9C4vS0GSra2vdVC4hJCUbiEOVofJVZd/02SSvwf+wobgxPktZOgcqvRa+oKw9wk4NL9rXSqO+hVSPp3VcRHEZSOMys50=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YSE0TfPv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YSE0TfPv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3C47D1F0089B;
	Sun, 11 Oct 2026 16:48:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791737311;
	bh=Q7tT1SDl4YdX5RcbkRRYcjRQ9SlIxlFUt/7U8GBNUto=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=YSE0TfPvHTE8eFd/U7b7CmXyTF7T4QLyWA+af3bSbF7R5+Gm4YWLeHeVpr3Kfc1xg
	 CiTMXU17T9Veocs88CybRG+LLVd5Y5wrV8ypQ7Tq8gyGG9ms98Us7ieHwP648qVg+2
	 699v+ufySBdJ6jCf93qjOTO/n85qR78aPWUHehsVh2r8J9JeFYw3rSF9bBuJeYwLvZ
	 KXZjavP18GQHj+6fKi+70MMELFt9w5FLYe0coCbwOKzujmcHHakkj2XCzZXsVjamj8
	 DhqyFq8N4P8byKau84DFMqWUD6cJYnCc347uo7uhm4nlDB0Owo5GNiIRRnX3/iL5we
	 6p74sA1BkcYBQ==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	regressions@lists.linux.dev,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Lubos Rendek <l.rendek@proxmox.com>
Subject: Re: [REGRESSION] 7.2.4: nfsd sends CB_OFFLOAD with all-zero stateid, async NFSv4.2 COPY never completes
Date: Sun, 11 Oct 2026 12:48:08 -0400
Message-ID: <2026-10-11-1-daily-reply-0001-nfsd-cb-offload-zero-stateid@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <7cc824c4-632d-49df-ae5e-cfcbb5bf76ad@proxmox.com>
References: <7cc824c4-632d-49df-ae5e-cfcbb5bf76ad@proxmox.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> Since 7.2.4, an NFSv4.2 server-side COPY between two exports of a Linux
> NFS server never completes, because nfsd sends CB_OFFLOAD with an
> all-zero stateid.

Queued the fix for 7.2 and 6.18, thanks.

-- 
Thanks,
Sasha
