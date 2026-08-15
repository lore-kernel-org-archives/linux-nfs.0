Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35FD931F9A6;
	Sat, 15 Aug 2026 16:24:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786811068; cv=none; b=VNCHhaebRwiMvD5BzUXA3I9hrxGGZZELqDKJhc2ntdZdY2qy83JivVyg196HcXOegVeasFFge199cYaXtsZOEfSEjS3O9URhU79EzNgdBOt4vsm5zMD19IYkCVDHmVwIzG51y2L0VdRA7S8ilvX2qjPVUMpju6KwKg0xD3YvmyQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786811068; c=relaxed/simple;
	bh=kc8zZxv0VfLRY+ifLDgh9lmYz15u/A6sjxP3KUMxr/k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=cOegCmEx9ePDc0awY5gChSwnFqET0kkKEbdMvzf4rr+9sP7HBxufdGxFEOF+RDzmhaK6zybRzSBUmK6VJTmsU+3PAnmaChFzT1dXAOzCm/NFPthieOWG9fJex/LZRM29HiWXX+kQoIYHua8M1rzVW6THZLU6hcUn6upjTOsg8nE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=B2rfcXKr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="B2rfcXKr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 16C6F1F00A3A;
	Sat, 15 Aug 2026 16:24:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786811066;
	bh=bSalfCuzVJoxxs2u+auw36MAS2Npe0OrXB0dFXOX7Oo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=B2rfcXKrK4XS/2nEhzNzWvS+qXs+grsjXdEL7aSAiVvANV6t24Iab99gBEnNBkVtp
	 l0Kvkfoxzvk5SjwTpFX4ZZCYN/KIpBW2gXfYFFznPvXfHvZEYFvjqnQ2H3urGB/c64
	 nf4dTK8E5Czdusk28fix5m6/yarzQm5IlTXLJQtq38x2eTeom6EAPYqxsOn6z6n8+3
	 59q+MawxopdUKBSI5ZLQvtFoAbuyr0RqPHsMi5NkDQUCWsR+JqMmzkDdhV5hxwXpPA
	 fL2If6u7Eo24bRlx5tZx5BmSlHOTWPpOCPb17zSR6yctuUZ75XduBu0UsdjdRUaqok
	 5071odSVZljfQ==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	Ameer Hamza <ameer.hamza@truenas.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com
Subject: Re: [PATCH v2 0/2] sunrpc: don't strip a uid's groups when the mountd group lookup fails
Date: Sat, 15 Aug 2026 12:24:20 -0400
Message-ID: <178681105303.93379.12774054259768112149.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260814221953.108837-1-ameer.hamza@truenas.com>
References: <20260814221953.108837-1-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Sat, 15 Aug 2026 03:19:51 +0500, Ameer Hamza wrote:
> On a server running rpc.mountd with --manage-gids, a transient
> name-service failure makes mountd answer the auth.unix.gid upcall
> with a zero-group reply, which the kernel installs as a valid
> positive entry.  Patch 1 records such replies as negative entries
> on the classic /proc channel, so the credential keeps the groups
> it already carries.  Patch 2 does the same for the netlink upcall,
> which has an explicit NEGATIVE flag the parser does not propagate.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/2] sunrpc: treat empty auth.unix.gid replies as negative entries
      commit: e865ae50d85a5585eb29cd67dfb0f776da1aa0c9
[2/2] sunrpc: honor the netlink unix_gid NEGATIVE flag
      commit: 76427d869120552a1a82e1f1488d9f8311827d84

--
Chuck Lever

