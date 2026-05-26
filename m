Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B07F3CC7CD
	for <linux-nfs@vger.kernel.org>; Tue, 26 May 2026 13:37:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779802626; cv=none; b=h5V9G/atqwP1uHJhoiqWtNYN9WoQT9nv6RxPN0HWaBv/teVBpoQ1+YFprqOHO7P4EJHEwqx+pCjigQ9pRHrWu+sQiFuzGAaN4zgac0Hxnq+YPhhmIcoDWxNc9lPXD/NP456kV8mz8BjxF9P9VSGukxhaEBHHk2VirE1oKlwnrLc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779802626; c=relaxed/simple;
	bh=yn2sHrxK1H/ppcx99GGA6WheSr2RiHBDQ8A5w7iLgR4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=q85TzMmU5S131EBmMNP/aQEicWudmMdSoTPiROWggsaqnsq340/7o5nxRnGh8Rc+XlWlxDELgBKrAiOG6drVVIvUPM7AkKwI2cGhewM53sKcJmRktz/kLjwsJGKgTs2un3CHfbKgtcrv3BJH0C4DEHV/1xdG2gzW19RxWaNnJIw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OVix4QBl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OVix4QBl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2A6F31F000E9;
	Tue, 26 May 2026 13:37:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779802624;
	bh=4/J1f9/phOgsH/ipTZsx2NuXN0/cmw4u7BpD4FS2x40=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=OVix4QBlD6juS1SD2N+haHKrWa12HeQH2RNHeml1liy6iglOHKrSP+533g1k/h1YA
	 aV/4vpvF6VG1sbAQmIM10PixtK8RuFcwR7kqofBAibJMCdJMf7+C9YuBl/8SU1MJAa
	 8SPzCYrr21ucBF8aHYev/ehCVxeHOglepK8dp6mVNFGPQUXqOxNVmhAhf+84SancwO
	 5vlm2EKEzvg4ykPfZpYh1kJv4osJZqmS1SNKyEJdB3sLJk7PuJdTmuvKeJVYDuF3Bn
	 l4bSuahOYgDrAxTbcHsAkkRlFYK7Dtqm/T+B47w9cstzA5hOp7/UGDbWK62niyA9gH
	 FRHbnBAscX48A==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	Zhenghang Xiao <kipreyyy@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfsd] nfsd: set SC_STATUS_FREED in nfsd4_drop_revoked_stid for delegations
Date: Tue, 26 May 2026 09:37:00 -0400
Message-ID: <177980261417.33125.9531553145341006369.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260526104554.46262-1-kipreyyy@gmail.com>
References: <20260526104554.46262-1-kipreyyy@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Tue, 26 May 2026 18:45:54 +0800, Zhenghang Xiao wrote:
> nfsd4_drop_revoked_stid() handles FREE_STATEID for admin-revoked
> delegations but does not set SC_STATUS_FREED before releasing cl_lock.
> revoke_delegation() uses this flag to detect whether FREE_STATEID has
> already processed the delegation — without it, the freed delegation is
> added to cl_revoked via list_add(), producing a use-after-free when
> cl_revoked is later traversed in __release_client().
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: set SC_STATUS_FREED in nfsd4_drop_revoked_stid for delegations
      commit: a1da502807b6b63963f2b1064df76e0a58fb3479

--
Chuck Lever <chuck.lever@oracle.com>
