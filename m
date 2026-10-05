Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9FB648CD48
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 15:06:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791212777; cv=none; b=Y7b6QfsnfkV3N6DdP0ky19OJEzMvq4lQp91Z6/457nv7yasxDM+qfZ3nc75eF0BniZd+QtFxG357W9PEVZdxcHZSCtlovkRSyalZatiQ3EHQiM+wssyxX/8ve/HCDX3JV5PC9J1Ped9Bbm28PLGL0kbqg9eEaqdD9sw0puqtpXg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791212777; c=relaxed/simple;
	bh=jwSMqb4ZSSneANe4qdP8Wbr8dfsR6DFEp0JDrtAv+Go=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=dP/pyWgXBQjpJhZ7MSlXzEl5ahPD1pbjJapnesvzSFyDhb+pLuV0PRttcma606cCacZ/TWAZvZRkhInDC2r1yULo+hPfjt5sMq/lQE4sElhbtAT5on/mUGH781JyGAmpyUyl7GGi3d5UvAMUQTQMou/t2HONyJMRLKxSNCtUJj0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dmFGx4ZP; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dmFGx4ZP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 222691F00898;
	Mon,  5 Oct 2026 15:06:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791212776;
	bh=DG4upcBm2cqeYhzF11nYaMUK7czEvD0p7FXbprG0BfQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=dmFGx4ZPxQk4GpYAxe3YEkcUKNI9iWRQis6tuYafUNAGYXa0zcdQ32z/fyKAaLs82
	 zN8tJB5a83AB9LO76JO+ZCd6pomoFsZsIJsOTJ1ZMhuLKT8PKC7CBlVHMsTYxbYX8o
	 xTUgD0E+B/Sp4udUybdFg8KBvdLlXJSy/8Nlgzfd/yKcabzLH56hvWY/ChqblWRZNI
	 UIGQ8DXK7oUgl/O+7Z4NOhx2Df5bc0NlGxsiZ7xogwgzDHpgLcgRdNMS6+3bmiTVRO
	 qrHPrmRPfG6eXqVaSNCrVSkJXUg36x01+74nZRaZdwfJNJNtcKFOwwOIspQk5R4kAR
	 lbkAlGTH5XY6A==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: preserve RQ_SECURE across request deferral
Date: Mon,  5 Oct 2026 11:06:13 -0400
Message-ID: <179121276798.31450.17139690359980952392.b4-ty@b4>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261002135027.72494-1-snitzer@kernel.org>
References: <20261002135027.72494-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


On Fri, 02 Oct 2026 09:50:27 -0400, Mike Snitzer wrote:
> Commit 319951eba0fc ("SUNRPC: Remove ->xpo_secure_port()") moved the
> setting of RQ_SECURE from svc_recv() into each transport's
> ->xpo_recvfrom(). But a deferred request is replayed through
> svc_deferred_recv(), which bypasses ->xpo_recvfrom(), so RQ_SECURE is
> no longer recomputed for it. The replaying thread instead carries
> whatever RQ_SECURE value was left behind by the last request it
> processed, and svc_defer() does not save the original value.
> 
> [...]

Applied, thanks!

[1/1] SUNRPC: preserve RQ_SECURE across request deferral
      commit: ed7e67821acbbf7508d816d78c5a2b062f5eaf96

Best regards,
-- 
Chuck Lever <cel@kernel.org>
