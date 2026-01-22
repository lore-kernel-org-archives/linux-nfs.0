Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F17AB30FF29;
	Thu, 22 Jan 2026 22:04:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769119482; cv=none; b=HwZ2kSBEly7vAvoGZAzR98kadIwQTo0tdhvmo8HVZf4cbID+ZuBOVrcPZqRpbEIE7VP+t6cKmuPUIuJRelU9PsHSHiHcQKLwEU5aTfidVjcf/Y5jHO8fP2MaeA1osTePoJT/GfcUOp60PGZ+nQHOyF+H0dMiR1P6kHvVKSUB1gQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769119482; c=relaxed/simple;
	bh=gYV+1uXjBuVLLKT05D/6On0kOkZH/jo4MHQ+ujFmeSo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=qXpBSvQuZSV/h6Tg//wepjDZcZuRBQlY0eYTDRGSXkkDEwyFzr6b8wCAhrv9nRTltMjDQGlVEbH9r1XGwYwxx+m6eI/ZTMG78EFkLdpt8LFAJCZwUK7+FYNxf0WJbiWC0LYTkHt/8Meis3Z4+LbMiwbt1ZZfuDLs23HDsEdPm+g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QyGS6Vds; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QyGS6Vds"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1B600C116C6;
	Thu, 22 Jan 2026 22:04:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769119481;
	bh=gYV+1uXjBuVLLKT05D/6On0kOkZH/jo4MHQ+ujFmeSo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=QyGS6VdsvAsVKPRScUfLRq0K55bUS+mJTyzhgJDw1Se4vYFwyWCi2zfsd/eCNmyHV
	 uvHkUkIQuqo2UcW8s5PsW7frKzgWkd5aNetoopYh5MfjkLKkYZHYOnl2zW1Tu7soeu
	 AoB8N+hP16aApLOlMYqOD8pP3V++XAMzPSUv/i+vLAHU16cUKxywqLmOjAVSCgfvCV
	 tdzQxkWLxdo3W8XLv/cK9q3DQaAd3X8Ki2ow8DnGvA7zAHJmDRcgK4MC138/5yZEg3
	 Z7qeprccjWTFMXaRyTIkHOdew8LM8vlPdaVfsQo0QYD+QyXDL4enlpWQJkRGegONG0
	 g52CoIYPJ262w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/2] nfsd: move delegated timestamps to being runtime disabled instead of compile time
Date: Thu, 22 Jan 2026 17:04:37 -0500
Message-ID: <176911946777.1143362.852891163114456306.b4-ty@oracle.com>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260122-delegts-v1-0-40fbb180556c@kernel.org>
References: <20260122-delegts-v1-0-40fbb180556c@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>


On Thu, 22 Jan 2026 13:59:14 -0500, Jeff Layton wrote:
> The delegated timestamp code seems to be working well enough that want
> to just always enable it. There is a chance though that some clients or
> workloads could still see problems, so this also adds a debugfs switch
> to allow disabling them at runtime.
> 
> 

Applied, thanks!

[1/2] nfsd: add a runtime switch for disabling delegated timestamps
      (no commit info)
[2/2] nfsd: remove NFSD_V4_DELEG_TIMESTAMPS Kconfig option
      (no commit info)

Best regards,
-- 
Chuck Lever

