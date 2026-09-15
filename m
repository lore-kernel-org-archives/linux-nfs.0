Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9996534AB03;
	Tue, 15 Sep 2026 19:45:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789501504; cv=none; b=mOO2CuVy4Svd5BrVx+ksZUu8xeqLtCb9OrNaRRTHUGV5fWUK1ICW+CT2Vjz9o9raHPfNQYg+PYnSI3NatEPMn7HBd1DShKi5LXQ+dvHaGMCqkTeZIbVisSrtL4o9ut4FD5ohPmDGVEyKd/wYfhrPKyUtB15adzAMESrYbiANhA8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789501504; c=relaxed/simple;
	bh=JiY1Ux06iumYydaI0Z726KeWwjypfbajQ7WuDjwY62Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=eWKXPgFRcQNlbyJbPAES3zO+GTqB4dq3fQ2Tc6we90z3N4I+ada2xUfzlbv08wePKRV9tcJoLk2SaT4A1URoYMVYuQ5UTODfHfgquSz80KB8I5F3pBUm4faTOap+KEGoxy3yDTLlvo9gGPXrncVaDqWPktRdi56rnA9rdOtagE0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=G5JcrM9P; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="G5JcrM9P"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A704E1F000FF;
	Tue, 15 Sep 2026 19:44:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789501501;
	bh=mwcAcp8dKHIcVLbR1Sy5crPPZNPInwTc17fNJxNfqaY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=G5JcrM9PrajOvrqsFgUONEi6epP/pEryvQv8AB8cbkaHakvZHXXK19cAi4pezk9hm
	 i9rZJWfeF6TS9fcKv7usCHgqECqFqvtlJrGU9k9ZnqRUPGe0IRqBsya5oJLp1uJf/U
	 LZ3MW8rB2hfJnqJdwcsvYzyWXTpP5g0DXsEIGotN1yEYyMIq/KyIYJia9alW93A7TC
	 Hu3FXr3zV/+3dZLdgd0EWPDoTyPbqrROABspI/QXzfmb5fIvPADs1TA7RjsnK+e6wd
	 3MAuoqi8iApr0IrquWgqwrDXWqjjByxrYb1Z6WmeOz39uYw7HFucq17zWa0uNPxsaX
	 RhBStf5YyX85w==
From: Chuck Lever <cel@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Donald Hunter <donald.hunter@gmail.com>,
	Shuah Khan <shuah@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kselftest@vger.kernel.org
Subject: Re: [PATCH v3 0/5] nfsd/sunrpc: allow userland to handle rpcbind registration
Date: Tue, 15 Sep 2026 15:44:56 -0400
Message-ID: <178950149074.1556771.1876157080795591020.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260915-nfsd-norpcb-v3-0-3c60d49ade02@kernel.org>
References: <20260915-nfsd-norpcb-v3-0-3c60d49ade02@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 15 Sep 2026 12:57:41 -0400, Jeff Layton wrote:
> This version fixes a few problems that Chuck and agentic review pointed
> out. Original cover letter follows:
> 
> While working on the recent hardening patches for the nfsd listener
> netlink interface, Chuck mentioned that we could allow userland to
> handle rpcbind registation itself.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/5] SUNRPC: allow a service to opt out of rpcbind registration
      commit: 0b1f0103eab9ecf05d95f5061cc0058322bd61a8
[2/5] NFSD: add a userspace-rpcbind flag to listener_set
      commit: f66e0fff8d18320e0aad2492aa222783e2790494
[3/5] NFSD: honour the userspace-rpcbind flag in listener_set
      commit: cd5be08177a2b4bcb93f119d8ad8fb076c45a425
[4/5] NFSD: report registerable programs in the listener_set reply
      commit: d1b98fc668643dc4243176024e63f340a555d6f5
[5/5] selftests/nfsd: exercise the userspace-rpcbind listener_set flag
      commit: 0e02d8dcaca57c95bd51f5a0ffd4d258275c5841

--
Chuck Lever

