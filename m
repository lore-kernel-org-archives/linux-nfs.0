Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1ABD194C95;
	Fri, 20 Feb 2026 19:37:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771616234; cv=none; b=lQ27JrukugS4hyleic8OmtpR3xs7PzvSW+BL9p0Yxqa43A594jRkmlOdPLQdcjCMUshJVeDQuCwiVTn0hkNHWMKtKxYiyczczMuB0ukggu7nMw71f/MsZ8ngxUAcyWvO/hZKtjJeL679x53aKUA8WDs2DqoqcpaRSRwH4DlWea4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771616234; c=relaxed/simple;
	bh=L+35oiwh9oFhBwDbcpKstXbNniaB7D0lGak01FeBh8k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=XOASxxgrvNx66Vm0Lz3R97cTsI/T4QhPidXeNy+f1chiKBUnNfcEcIexOeP52Nqc1JUWwsK2JB9mYmizrKQLe1aLZRoUSFExcHmz/5KBlFtH55TRB66ilcRtW7tTeW/4SDhSU8+WRsL0mxxx836w6nbXws1jow53pwRpw2O3U1o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KmNClSK+; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KmNClSK+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 74792C116C6;
	Fri, 20 Feb 2026 19:37:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771616234;
	bh=L+35oiwh9oFhBwDbcpKstXbNniaB7D0lGak01FeBh8k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=KmNClSK+tPW3ien0xcXGEVYrEQr4CxGqGXkXeJzMh9oPEQ5NLyatDyhAMc3LcY06b
	 JQ02s0uHvqArR8z6IKOJG/k7uBCk8Oi/kRlklOKdrJj12n/3KqjMiER/0a44D+TPAr
	 2P73uMEULvKIzr958JhGAeRJOtv+D9Et+nN82bEfgWDOwiL1dmWAhqER7XWGM2603o
	 I+9qS7DpQaNg/L3Kg5YLISZJfFf/mGD0sVF6t4ml1IXLIzbDlG5BugpooOOt8DWfs4
	 DTJhsqI0AoMitHka7TpDJu+P/vLBRwTBaiO1ACiqIcPOlNGZa7OpmXCNPRtny1gzhv
	 1tk3fzlfgNZTw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/3] sunrpc: cache infrastructure scalability improvements
Date: Fri, 20 Feb 2026 14:37:10 -0500
Message-ID: <177161622290.3877966.16867844436002593841.b4-ty@oracle.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260220-sunrpc-cache-v1-0-47d04014c245@kernel.org>
References: <20260220-sunrpc-cache-v1-0-47d04014c245@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Fri, 20 Feb 2026 07:26:02 -0500, Jeff Layton wrote:
> I've been working on trying to retrofit a netlink upcall into the sunrpc
> cache infrastructure. While crawling over that code, I noticed that it
> relies on both a global spinlock and waitqueue. The first two patches
> convert those to be per-cache_detail instead.
> 
> The last patch splits up the cache_detail->queue into two lists: one to
> hold cache_readers and one for cache_requests. This simplifies the code,
> and the new sequence number that helps the readers track position may
> help with implementing netlink upcalls.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/3] sunrpc: convert queue_lock from global spinlock to per-cache_detail lock
      commit: 8da8f32e9a2702259cdf97e2f8f492ef9c79db65
[2/3] sunrpc: convert queue_wait from global to per-cache_detail waitqueue
      commit: 802261d8b58dd2f41a52a0c92776e0fb45619efe
[3/3] sunrpc: split cache_detail queue into request and reader lists
      commit: 0eb3d9dc71ada02909e4dfe9cb54e703ec717ed4

--
Chuck Lever

