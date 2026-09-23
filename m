Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C87A3EFFC5;
	Wed, 23 Sep 2026 18:26:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790187967; cv=none; b=mKYp1gvwrP+tEbor+o0kcnD1rWmWQDbXyGtkddRyGBeBfREupBAJ/dmGX0HKmm5HtciaefRKPuyV1xOUoP8nzJvp0CfAiDHpn0kIMQ8xNWSNe0d9ty3sWhVQAsJ+9v1/emV5NHLr1PTiHRsvHl6kpfPKb/ppErPUTZnPnOuF3WU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790187967; c=relaxed/simple;
	bh=h1F5Qgj9S2NfS1texjEehs3tHEbP+gFk5LrSqGMoBRM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=HyJpDt2XszV58IG87t6IdHpPc3agiWLCKXr2qK+hePifKZq3rvx8kjYIxa74c5Xex9UcOlSYAiKppv7OSd3BRSM3rMjJiwHhgdyzPh8Dx4YYzL7kSJaHQVRUjPftegRSY2ZChXUawSYVw0KFvhaJMjF/9aSng9X6oR24Fk+FOaA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XcXErM/y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XcXErM/y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2BF0A1F00898;
	Wed, 23 Sep 2026 18:26:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790187964;
	bh=Zh0B6TzQY/mb80HlgH/uja4QiOdUkBnRjI4CGmBAp00=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XcXErM/yYoGVTBz+3NPC0u+Au1Kwi4pnKzGP1W22gsCj5mamsc0IfIZCpi3MTakFw
	 lz8vYRHWhOff54TRVzOL8rV2GylduSNif3izfyxEMZz832AkR+VHgPdn/0hKH5ce0j
	 4wJ8wBRjlPoyMnxH5qRcw62LVWTXm57LXUvCag853pF2GJNW7nHrlLu9CpDGRxETl4
	 QDWG9NNV6KWTYxcsTg3h+nU6a5EI86z77fzcc8HgT866vkYM4iLJ30AUk9lGkvAVb9
	 9rALGOmlkwqeM9Wjqbae6W3nyzk5SuUSEQvUnmEUsnJhekxA2OkEx5TPA+oD+PJvh2
	 dFG6AEkyUViIg==
From: Chuck Lever <cel@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Shuah Khan <shuah@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: Scott Mayhew <smayhew@redhat.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-kselftest@vger.kernel.org
Subject: Re: [PATCH v2 0/2] lockd: allow setting ports without setting gracetime
Date: Wed, 23 Sep 2026 14:25:58 -0400
Message-ID: <179018794940.493305.12255012898503736006.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260923-nfsd-testing-v2-0-bfba431122c8@kernel.org>
References: <20260923-nfsd-testing-v2-0-bfba431122c8@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 23 Sep 2026 11:30:49 -0400, Jeff Layton wrote:
> This version fixes some selftest coverage gaps that Sashiko pointed out.
> The actual bugfix is unchanged.
> 
> This patchset fixes a rather silly bug that Scott pointed out to me in a
> meeting recently. You currently can't set the ports in lockd via the
> netlink interface unless you also set the gracetime. This patch makes
> them all properly optional.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/2] lockd: allow SERVER_SET without a gracetime attribute
      commit: 06ed8fb285705890e83b7e199141a9f488286bb9
[2/2] selftests/nfsd: add lockd netlink configuration tests
      commit: 12dbf3be3c58e190c4173471d79ba0b19178447c

--
Chuck Lever

