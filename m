Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4666845FFCB;
	Tue, 25 Aug 2026 13:38:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787665119; cv=none; b=FNbDDBtFe9BAFqZDmvwlIElWmPmgjMB1CxWbZWmFbLAGyTcQkylJGSxPb7ACRJmoESGeValyGn9kfScXz5m49b8swsUnEMRHuApEoSz2J6izw2NLl0W57Rh46+45bm+I1qVFsxiktmLFxIahU1SyfV/RnOIIY+75asK7zl0rAcs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787665119; c=relaxed/simple;
	bh=iJtjSw2Vwg/c85HAP+x/vjwyej8qNvJxnhB+uYXaoUw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=GZJdzAqvYBnzQCiKr0zmwx2FTyw1VZI11F3NgnjOGpffW5y+Gk7Rcifz8uWgT6uqnN1/j33DseNub+7b3rMhHeiATDDtu/CqVGVcOiICAlNN2BNRhWpPRyOza/NCqbQZi9IpvOlbH9iAqgOE5QeyiCzXWSlVrZZjzOM5ilxNP5s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=S4a6OBBV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="S4a6OBBV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 43D761F00A3A;
	Tue, 25 Aug 2026 13:38:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787665118;
	bh=R3vCIfEnR7Fn1bliRHmDtagvsnWJBvBE9+5RX/rPWCg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=S4a6OBBVJlBvq0uYS1ytMqnBoctnJqoz0T8zTtS5EnZddnGOPSzYP7pOhOnT6UPk9
	 YSHrKA1a/GMsDoX0NqrQmJrga8tDSN3nadcSjDrh0+12BlGadVH/U4rV/sQwXtUWEx
	 tHmokOEyYTKumS4V95pdXoVzaWNHTAN9gHbrZNp44kjzFAPRADq18DcHr39TckqlpK
	 4JLlgbRumOmYjguxCn4QFNzZcJ1pZMi0Rbjxj33oI2pNtYStYNx3xCnDY0HymG3IIm
	 DU9+yoVKduw2Mb8/oVf0Jji0l0fCc3KQ2ijr8/aZWO5xhqtHBeLecSt3oawNDCGoGP
	 0cnRhmpc6Nhwg==
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
Subject: Re: [PATCH] nfsd: don't modify a session slot when replaying its cached reply
Date: Tue, 25 Aug 2026 09:38:33 -0400
Message-ID: <178766510748.80442.7476523533813098527.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260824173641.3274260-1-ameer.hamza@truenas.com>
References: <20260824173641.3274260-1-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Mon, 24 Aug 2026 22:36:41 +0500, Ameer Hamza wrote:
> nfsd4_sequence() claims a session slot by setting NFSD4_SLOT_INUSE
> under nn->client_lock. A reply served from the slot's reply cache does
> not claim it, and that distinction lived only in cstate->status, which
> nfsd4_sequence() set to nfserr_replay_cache. Commit cc028a10a48c
> ("NFSD: Hoist status code encoding into XDR encoder functions") moved
> nfsd4_proc_compound()'s cstate->status assignment below the out:
> label, and the replay path's goto out was the one path that relied on
> skipping it. The test in nfsd4_sequence_done() therefore no longer
> identifies a replay, and every replay now stores its reply and clears
> NFSD4_SLOT_INUSE as though it owned the slot.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: don't modify a session slot when replaying its cached reply
      (no commit info)

--
Chuck Lever

