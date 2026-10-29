Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793281275;
	b=ZZRfk6Xt7YWUoH/dAbSHHsq8jDwKaLtcSHAhfzF4nKwcv1tEjDz56MkWKSJk25piJzkn
	 L9s6X/oh9dD7NxWMMIXEn8Aen506cKdQVCXJaTiBDhDVuc59ZYZQp3VjaMd6Rm6q+YKrj
	 IcraSHln+JPgVxJXswUvry9awRsm4zxQKtHD4Mq7DZP0JuwlCRDCQX+2rlQU4tk3EMQiO
	 yIDAKx68s49dj+IHqzN7nNBpMVtP63cL2WS2r4YNSCe38JK9apUIklcGk4xEB0ss9P7pq
	 +5+LOi/sjI9/rTmw7fwrv9lfw9wKX0NGznFUAMOZnNFtWlpzeVuQav7+iXWRrqcDvHw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793281275;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=fu4vcCSr2nK0B1nChh3q5mW+Lmt5l3i3I5vcG8NiLaA=;
	b=4g1IfavrVKlGa/naR09v8CRD+joqOh0XSoGnK8dRe5kGg94jwGB6K3TkX6NF9MHZyN5/
	 Iwq39S75WpnYvFyYxLBLWbHT94rsR8MaCz7TagPGydhrm17QARK7NogYdwi9YNzkM4NGl
	 zreiDG3u29DePqVlPvVAZaNHWc0EgciJRfbyRAtoQvWBLUuSqN/Tlb5mPnV9d6pBtbe4c
	 DDp1jGbyM9dViP6lpoGO5MvfSwqaT5sXt7kz3xdEk1vv1Kg0KAmfuYI+WCW+3nAH5p5H+
	 jSzEG98eVZqYsf6IYIVIkq8GTpYTuoT7kZVSAmmYUtzWIyrawysYnelceDyztEmNj4A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aVXBXcu0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0695606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 13:41:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aVXBXcu0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DEADD1F01825;
	Thu, 29 Oct 2026 13:41:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793281274;
	bh=fu4vcCSr2nK0B1nChh3q5mW+Lmt5l3i3I5vcG8NiLaA=;
	h=From:Subject:Date:To:Cc;
	b=aVXBXcu0EBeXkxbHWLJ8Lc4sWIS8vnDm0Bds2pTCSbq1bv6tGFBBgEkePfnT0ESHu
	 WYVBCihDP94pz3HVZypKJsEqSH1n0ynKeOC4eyY05883ydgb8S3BKW/5ZisGiF4iCo
	 NGhp+I5PkrlmQs3j4W2nb2yYbeR1qsZNJlJ3j4cp5+q3lWEfUNRASNviQuV1Nd7hE+
	 7ArIFyeo04B5Ziin082J17uVncXG/R7oQCEeYIdmHa6AJ1qUe66XR2VAk1kUMXODFY
	 gu2n7HeCPDstaxfiirdXXd4a66U+I9fFm1D5v00fO37s831YSjvfgsOhPn0nDFtYXv
	 QDQFdV7N3xdzA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 00/10] NFSD: Randomize clientids, session IDs, and
 COPY_NOTIFY tokens
Date: Thu, 29 Oct 2026 09:40:58 -0400
Message-Id: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
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
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMywrCMBBFf6XM2sE0hfj4Fekij0k7oqlkohRK/
 91El+dyz9lAKDMJXLsNMn1YeEkV+kMHfrZpIuRQGbTSplf6gtmmsDxRii3EQdAbE7UZwumsFFT
 rlSny+ivexj/L293Jl5ZpD2eF0NWOn9vk6XFMUQIWksJpgn3/AvXRsWOWAAAA
X-Change-ID: 20261029-random-stateids-c66f263d7800
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2900; i=cel@kernel.org;
 h=from:subject:message-id; bh=h0NewL1k+SPIjCHlcCDrbbcD2HaAS3ozQEmHHclJFnM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq40zvwlXSowrgZfy+TUhON5D3hY9hkhz9Q4lNP
 +SzJSl4fF6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauNM7wAKCRAzarMzb2Z/
 l8H0EACSH1sa+YcAMOVRUNixeStUfMcdTeOKAlPFoRgDLFr5tv7hpLL7I2GjE75JVGa2ylu/VtF
 P7NEKcRZXLuOYLwjmKio9a7lWH/sYVH6z75/EeRrupmofJFN3XDF6eHiAgWqkdTY2g32z6MY6sZ
 TPov1QUbphA2rZkwjOaLeRDVES9M7WyxH88X2e1XxZr+SUmJ++SnvplQ0ISAvUM4Iq/ywiGosYM
 jBumWL6oIdSeq9J78/l+DGHlYzG4XbyVkvDCkwRTtwz+ju7VuqSdGBftqjf+AU+MI1OVR0qOfGQ
 x7FBsLbgTuyC7kuCs30DhvDpDAFztopBeZQHUSXnyiNLYaJmT4UDeLlkKCCZ5eRDl7HJBoK82OB
 oIZ3gTv+3dD8NH9A4BAB2IIdpVaVJ3GjKZDAruyJG0+EaM4FjSAJjL07qp3SNZIFhl8vXtncgbL
 6vpGKa76mQt7Lmht+9ylg8A4aDNyqM+4evP1sK37Qoie1arK2LPIXxbBor1rRX2n7W3c3RQp+EP
 d+Hcq5obYHHPSgjdCTpBNr4RLYR4GqNFd3DiS4ajWH8StI1h096OoK79H17ADkzeTh/Fgjn+/l3
 MZxwBEtI74eND67/RyUL/NsrSx/CGOhMRL3uBkZ+cRsjkBzJ1h5nLmFol1zLRzbADKO3qWpuKkj
 1j4l0qfzLPv875A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD currently assigns a clientid from a per-netns counter, a session
ID's sequence word from a global counter, and a COPY_NOTIFY stateid's
so_id from a cyclic allocator with a fixed clientid word. Each of the
three is a bearer token. NFSv4.0 resolves a presented stateid against
the client named inside it rather than the caller, and the errors the
protocol mandates (EXPIRED for an unknown clientid, BAD_STATEID for a
known clientid with an unknown index) let the two halves be searched
separately. Under SP4_NONE, nfsd4_sequence() does not check a
credential, so a session ID alone can reach another client's slot
table. Adjacent counter values let a malicious requester find a
neighbor's token in a few dozen probes by counting outward from its
own.

After this series, the clientid, the session ID, and the COPY_NOTIFY
token's clientid word are random. Predicting a live clientid costs
about 2^32 / C probes for C clients of the probe's minor version,
and a session ID 2^64. An ordinary stateid's so_id stays cyclic, so
it stays cheap to search once a clientid is known. RFC 8881 forbids
reusing an "other" value for a different purpose, and the cyclic
allocator is the non-reuse mechanism clients rely on.

Tested with the new KUnit suite, pynfs 4.0 and 4.1 over loopback, and
pynfs-based probes that confirm the three tokens are unpredictable,
that a LOCKT denial no longer carries a clientid, and that a
COPY_NOTIFY stateid with a wrong clientid word is rejected. A
same-second restart loop confirmed STALE_CLIENTID on RENEW and a
clean shutdown with live COPY_NOTIFY state.

---
Chuck Lever (10):
      NFSD: Serialize forced client expiry with state shutdown
      NFSD: Check machine credentials before expiring a client in DESTROY_CLIENTID
      NFSD: Make nn->boot_time strictly increase across state starts
      NFSD: Give each client a display id independent of cl_id
      NFSD: Generate the clientid at random instead of from a counter
      NFSD: Stop disclosing the conflicting lock holder in a lock denial
      NFSD: Destroy the COPY_NOTIFY stateid IDR at netns teardown
      NFSD: Put a random word in each COPY_NOTIFY stateid
      NFSD: Fill the session ID's sequence and reserved words at random
      NFSD: Add KUnit tests for the random identifier generators

 fs/nfsd/Kconfig          |  16 ++
 fs/nfsd/netns.h          |   9 +-
 fs/nfsd/nfs4layouts.c    |  10 +-
 fs/nfsd/nfs4proc.c       |   2 -
 fs/nfsd/nfs4state.c      | 308 ++++++++++++++++++------
 fs/nfsd/nfs4state_test.c | 591 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/state.h          |  16 +-
 fs/nfsd/xdr4.h           |   2 -
 8 files changed, 867 insertions(+), 87 deletions(-)
---
base-commit: 19bbac00ad1cfa28e9127488f161ffc2ac03fad4
change-id: 20261029-random-stateids-c66f263d7800

Best regards,
--  
Chuck Lever <cel@kernel.org>

