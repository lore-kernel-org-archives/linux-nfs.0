Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793396560;
	b=G2TZXh7DoqjwtCBsTH5NoY9lrJdnA826tDqucI2emclrkIl3tCDPLIg9AV9quhwtau7j
	 3jpOfmUlTHzBqG7Y0FL/dgLTifaST+tM+THK1Uyz8k2MjN/OqrcebW7m2jlJkdsK7Re0G
	 ERbTt8/xLTGSwv5brM0CHUNuYLt7JnroYo6GqGijeQ1MaKHjg9wJNxAYn9HwwjKsodqSg
	 zSCWmZLbJOC9t411p5KKxEn5GmIazqDLNcHtWYs6JCE7zT9+5S345dxZ5Tt0trquk6dKD
	 NDdgwmKRNf0lQqgkjMsV/MVKwuAzFr+KxCqjHsHYCYDsVLCZSgziSVvrvKz/f/BIIkw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793396560;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=G18y5GzZBVczGVERRlFFGsWmCmp9jImp2Rw6TnsgzKY=;
	b=xBawJScAQDdS5pbMUo9RZJVOYdtVG7Acno0Zb2zUGBqW+MXo66975esYu29tn8qyhL9N
	 BKvl/L6/zc3VkWIVGp1Je+9sfePgJlywANBbJmruFPEgcRd/HMXVhTZmpzlg3fjrfB2VD
	 xB5jU3RvaEDIcg/zFbX44v3PhvLlviMxh7jmzA7VwuVkojjJS/HV5eWyy5F7aUfhdVUhg
	 rSWUOAfSf+MY+8Lsl61rR2zK5E04voTL/1dJchQywOpdLpdyOFYv33m2LMDLlHqO0Kh/Z
	 SR0FDXRegvcqfXS9T0A1uTpVf/xl/HTWAz1S0IKigHVvXgdzyaLXDyCSO+l/hKBMb3w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YwoFG8YN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9AD8D606A320;
	Fri, 30 Oct 2026 21:42:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YwoFG8YN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A58971F00A18;
	Fri, 30 Oct 2026 21:42:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793396560;
	bh=G18y5GzZBVczGVERRlFFGsWmCmp9jImp2Rw6TnsgzKY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=YwoFG8YNo1u4rXhwwGhHMbRr8Ce9IMVSOWIL9GWGenaCI9vZ+F0be6DnAHO94DMPy
	 PErwryAr+HO7HbgUZh1ie8CEW0pRs9b3GT6e7sDNrpm9c89LIH/OvdbdpDcsdmpiPG
	 8DB6OhkxFmIZioA0syfmnYkr8QM703xRy6n46D7t2upZ4xpROEb6D7CswvpmvgJGeG
	 pnPs3xas6avmyB1WFQT97gkB8PP9cpOD5qMnEHnX9v/bBS4e2pRzPXpvhat1DBJ74/
	 ojDOE2idlKh3YV5ZvMdLAneK1mmj9wn11YHc7Xmh0aVzDAE8qv5sfiWdYIYQZ+YAn0
	 jKFaH/ixokKkQ==
From: Chuck Lever <cel@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>,
	Jakub Kicinski <kuba@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Shuah Khan <skhan@linuxfoundation.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: Steve Dickson <steved@redhat.com>,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-doc@vger.kernel.org
Subject: Re: [PATCH v2 0/6] nfsd: add new export options for controlling read/write iomode
Date: Fri, 30 Oct 2026 17:42:35 -0400
Message-ID: <179339654991.1228920.9483346450055055251.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
References: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 29 Oct 2026 08:05:13 -0400, Jeff Layton wrote:
> This version has the changes that Chuck requested. Most of it is minor
> logic tweaks for saner handling of splice reads, and renaming the
> options to read_io=/write_io=. I'll also be sending a v2 of the nfs-utils
> patchset. Original cover letter follows:
> 
> When we originally added support for the dontcache and direct iomodes to
> nfsd, we added global debugfs switches to control them. That was fine for
> experimentation but the goal was always to move these controls to
> something more permanent.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/6] NFSD: Add per-export read/write I/O mode settings
      commit: 2bf5cc5b0729b92ff62d7acffee4390326af1189
[2/6] NFSD: Apply per-export I/O modes to READ and WRITE
      commit: fa2dde080831509bd6e607e38f0dcfc2a798dc09
[3/6] NFSD: Document per-export read_io= and write_io= options
      commit: 427ab11f19e8ac820ee78e2bf424b39cc9637648
[4/6] NFSD: Keep per-export statistics across export cache updates
      commit: 23bfabf9641a2a7960cb335c1b97bfe0c15fb523
[5/6] NFSD: Count the storage reads of each export's READs
      commit: 0855f12a01e2374bdd179027041a44a97062b7a7
[6/6] NFSD: Document how to choose an IO mode
      commit: 8ab1a1c7d05dff67eea8c186f929b5645a20897a

--
Chuck Lever

