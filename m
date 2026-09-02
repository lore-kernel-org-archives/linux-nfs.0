Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7EFE24A0915;
	Wed,  2 Sep 2026 13:59:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788357585; cv=none; b=MyP1t4Pc7SSY6wPgK4gPRkKOlIAjsZe6jpwcssuLkutx9DdfEC30HDy7IQ4qINgAMuqu8TJFt669fDjgZQ4H60+N5gqK0w/qhoIcFf3xPlGs163ykcclPUsQm1OwwsmLeB+UX2wPBK0BJENgUiqyY79+K5/JfKNERxhoCZq6PHk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788357585; c=relaxed/simple;
	bh=UF7+JWjJfiZBKxZYEwiJvR1rEPN/TsJAZMrZ29KgOcE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ISCAtEkmctNozXlMK3vj/HNRV2UKzrNbjoBYDJwy9M6udv7u+ujp5udIS5zvBk/nGts6HX6CAWIAQ/GOXL9tZAqW8pA+hbqf1QbNPlZsNMwWQjs1HffuIVyPTu8dv638jUDP6hs9l6993C35f0+VMqgX1/aBIUQnLVbT3LJpdt8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=btcZLTPY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="btcZLTPY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C7F6A1F000E9;
	Wed,  2 Sep 2026 13:59:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788357583;
	bh=PuphFSC7VAMjp85LyxvriESmpHI+9IcgHqoIy3SrDVg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=btcZLTPYW0oBuA+vzca7/mRE9EOrZWeTRyYpbwmjPEWbs/tjuDdXa91fE9y7Lt3nS
	 dxAShpufQHz+zsK6xei/UgqTZEmvlcIWDuSsOxnbJYW0ctyf1I+TWY7xMDO1019hnL
	 IneJoM5YseQhyupEXj713qGoaDifKa0lP1jpdZBjXGP+r/20aZtnmbh/gpPGvYdtbr
	 BIjuOg+71oZ6qIPBFh8ee+3mFTEzzTWVGvObvOWJ8N53mx7V+tNfOWcptaDlfIDMwt
	 uDz39d4SdgzKee0FOSACWzebI3ADtgIO2BN2Jh5QW0wJJfpXx0gjKes9+iFLcSzoQp
	 kBGMBZI+JTcuQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Shuah Khan <shuah@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trondmy@gmail.com>,
	linux-kselftest@vger.kernel.org
Subject: Re: [PATCH v5 00/15] nfsd/sunrpc: harden the netlink listener set interface
Date: Wed,  2 Sep 2026 09:59:39 -0400
Message-ID: <178835756055.1975665.3585993273106020658.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
References: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 01 Sep 2026 09:39:38 -0400, Jeff Layton wrote:
> This version just fixes up some errno handling confusion that was in v3
> that Chuck pointed out. This version also drops ENAVAIL as a special
> error code -- we can use EIO for that instead.
> 
> Please consider these for v7.4.
> 
> 
> [...]

Applied to nfsd-testing, thanks!

[01/15] NFSD: cap the number of listeners accepted in listener_set
        commit: 196e48772ea60dc35adf57341e09e4bdf8f4212c
[02/15] NFSD: validate transport name in listener_set before serv creation
        commit: 85d7bca4afc7db07cedb612457fda195468cdb2d
[03/15] SUNRPC: keep the first error in svc_register()
        commit: d6c53650eb4aea422e6cf18b99428ff314ae7dd2
[04/15] SUNRPC: bound the local rpcbind client timeout to 1s
        commit: a607970b7003acf07157aae2f4c928af92b175d8
[05/15] NFSD: report listener creation failures through extack
        commit: 9dbaebcec682cc4c032c7a24ca4f04bdde287935
[06/15] SUNRPC: report local rpcbind calls that get no answer
        commit: f8ee183cb6123784cb4ffc2facb309d17bc896e9
[07/15] SUNRPC: stop svc_register() once rpcbind stops answering
        commit: 53fbfe00e9615496002b7e045b681fed45006634
[08/15] SUNRPC: stop the svc_unregister() sweep once rpcbind stops answering
        commit: 1ef5f3076a52482510c5afd4e816db33599f1341
[09/15] SUNRPC: stop unregistering listeners once rpcbind stops answering
        commit: e3d28a4c7f71946635ff6900aad6876e87332aa4
[10/15] NFSD: stop registering with rpcbind after a failure in listener_set
        commit: ce39bbabbe205b50b66ac935bd54036d86d86ba3
[11/15] SUNRPC: check rpc_sockaddr2uaddr() for failure when registering
        commit: 3349f8b6b9a938405275c232cf441fbff23d61b5
[12/15] selftests/nfsd: exercise listener_set request validation
        commit: 213294f2e2548c6d837cbc55ba0731c90a7a45e2
[13/15] selftests/nfsd: add a per-netns rpcbind stub and the listener round-trips
        commit: 61222d2dca7b03ecd3a590afed804f2324f4df82
[14/15] selftests/nfsd: check that listener_set asks rpcbind once
        commit: 3c9de315b3f85a67b4c54650c28ead94faad726f
[15/15] selftests/nfsd: check that listener removal asks rpcbind once
        commit: f56be2f4966b31fd60c379a30d8c83e89db7bc62

--
Chuck Lever

