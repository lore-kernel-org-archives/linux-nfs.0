Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793997652;
	b=MpQ3VCb/+RrmAFVl0PHm5vw8xGvEtfm07pCJatP+FKCMYiTd7m8pA0YpHjO546/QKobA
	 NY6OabmHdih3MBrQ4RviDKjTwY6nJWnoT46/PEoY7oRj1nrTlODyD2qqzxWgqtwzSaBFx
	 sxFADbXlmdVuCRgp0ml2hmfK/2V+ep0bUke9hIzBGX69vCilx/YptkA+BviWpPEsxNC3G
	 THOx2RrtN+WhlbfKv6c5yJPdFQtZecAkskbq3gVcPkspeM4vTHcB8mN+EGC6ZKXZ4WMl5
	 AHIkbDsqtwsFP6OEryCoAV0cHnLiLzMyz0WNfmjVzh3y7a0OjVPIT0INMeWdZfexwew==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793997652;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=iXFMD8bNJXl3WNfiWK1Luz5NKRL0I4G3hoBjtxJzpjk=;
	b=bNXxLAtdh+XeryWZF9gQyKzyFd19MB3Hx9Ggi583aPqsjCXqwXh0COK4BAoUKodrwwO4
	 JWWny0/0psBR/q3sLUAEvBO45P3JOY1RbfCU91Fxd8VXQe6WrNKeybO+Pv/aqQ6AnSKlr
	 J9PWyBb5KnmH1J743PdIL77DVO3TlazsFakuNwLO9i8lVFlqJKxIVGtLgfQU4p0OPGBL8
	 LMovP6K5lEGekxIpICU+E9flAHzAMOdi0LCwecBD4qKHS/i7AKUNZvcEXSczfXjdmzamn
	 ebuTA9pzLRXr7dyvWMn/yUZXsCjV8OgD+U3filU/b3MylKdgxQBnfP0nuynzF+7g9Sw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SI61XZ76;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 603B9606A329;
	Fri,  6 Nov 2026 20:40:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SI61XZ76
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 45BB01F0089F;
	Fri,  6 Nov 2026 20:40:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793997651;
	bh=iXFMD8bNJXl3WNfiWK1Luz5NKRL0I4G3hoBjtxJzpjk=;
	h=From:Subject:Date:To:Cc;
	b=SI61XZ76FMat+huIvV+GsHp3vaxoBXFyJ0yZQCLLgh2xi/SgF32JScHijnjhCnLvg
	 TxQpwmPLIFQlEZ7mR1q16Ebdb35Irj5rFMMsYq2HZoMddxcTDzphh4tbfO6jra74aJ
	 AA96ufF3IrH00G5cPI4YUQ23qmRTVwUVlX10m+ubT9uhJGaZ32jEhh+cQDhkbBm3Cd
	 jp3PQh4GGTvRAxdhKYAHzoLNjT940O8r0Ro6xxv12ehVDOw49KBGaEG1y/WmqLD/v1
	 +Tb24w/RWt3XbIcvu9wrOKd3EVkn3G/n9wI9goVZl7mxVbt1DJ6Xzif6sW9Wa/zhuj
	 G2uYV+Q8gJp6A==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/5] nfsd: more delegated timestamp fixes
Date: Fri, 06 Nov 2026 15:40:26 -0500
Message-Id: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/4WNQQ6CMBBFr0Jm7Zh2SBpw5T0MiwJjmYhgpk2jI
 dzdygVcvpf89zeIrMIRLtUGylmirEsBOlUwTH4JjDIWBjLkrDWEI88ccOgxcPIpKSZ5csTG+5a
 coba3Dsr4pXyX9xG+dYUniWnVz/GT7c/+TWaLBgdvanJj0ziqrw/WhefzqgG6fd+/kcvlfr0AA
 AA=
X-Change-ID: 20261102-deleg-cb-getattr-times-8aa926029b16
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2261; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=xFQLQeviQDXYIKn20H8XDm4+ItG3EiFqYRBs9erky8Q=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq7jtL+Q8VGoXXwkLHM6zDax09WEQxmhQ0AoSqR
 TaRudACui6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCau47SwAKCRAADmhBGVaC
 FcMpD/9L1oBAH0zhJwzPQNRo5zpQMTk6dKJZ4eEerNiKrmkdLygEUAwPXBTNttedz0ll4SzgiMj
 TUN1qwczUTA57ltRlwOZ7U5dNQ8uhQSLamsB6N36KDMaLrRuhP3rDm+LCh4bwVerjG1MZYrgGbG
 xmFC8+XgMBbqtAFzc05LnEZM5toMyothqqSZCk6us+THIDxnSO1oUQpAHaPfqZmX4AX73KGjHVE
 YVyHw/mdassrMKfSzpBMOn5RwUQLQD3M9hmiPzDxFav9q3c4Eh2RzFsZhjOqhbu9s2HvmBca+oN
 e2H5oxYd1tQRYiUTXNT4qGbZU/eBGO4DE/JRMmsm9Bw5c8QjZuMGu8jBcGHJvA8Jh+RCx2yxQXp
 abM5WUp3XziI/jekQqUsLRHwf1JX3NLdaXOnxRvttOpBIqoERwkpV5O7kLNjULfRcQKrnYr4pI8
 DLk2sAwFS9i0TiX8RJdlbvFpYdApkNUUxNSPblqrMNpnDey4Q3c74zZP9+mSvdn/fbk0v0yenuO
 OeDBvEoCZ3zYVF1Y2F6FkBqvt8+u6n8qHfLbF3V76rL5bFhlyySxdoBASW/2zfx43yd1PJTR7as
 8y3q16wwSUnkPWBS95BdJyzo3bNJzrEHs99/vRhPvWHw5iMcxLidA7OslYtA8UnBtmag6ydfC2N
 NPAWA2SSkpPSEzA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Chuck recently added a new DELEG27 pynfs test that fails against nfsd.
These patches fix the behavior of delegated timestamps (again), such
that DELEG27 now passes.

I also ran some tests with the git regression testsuite which turns out
to be very sensitive to timestamp bugs, and that turned up a few more
server-side bugs.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- "Honor delegated timestamps when change and size match" reworked:
  - set ATTR_FORCE when applying the holder's times
  - record applied times in dl_[amc]time; vet and record under inode_lock
  - vet SETATTR's delegated times in nfsd_setattr() under inode_lock
  - also mark file modified on a holder WRITE whose mtime didn't pass dl_mtime
  - always report ncf_initial_cinfo as the change attr for timestamp delegations
  - catch the holder's own server-side changes (SETATTR, xattrs, etc.)
    via a change attribute saved at grant
  - log, rather than fail the GETATTR, if applying the holder's times fails
- New: don't stamp over an applied delegated mtime at DELEGRETURN
- New: don't vet delegated times against an exclusive-create verifier
- New: mark the delegation written on COPY/CLONE instead of stamping c/mtime
- Link to v1: https://lore.kernel.org/r/20261102-deleg-cb-getattr-times-v1-0-ca0326d88623@kernel.org

---
Jeff Layton (5):
      nfsd: Report vetted delegated timestamps in GETATTR replies
      nfsd: Honor delegated timestamps when change and size match
      nfsd: don't stamp over an applied delegated mtime at DELEGRETURN
      nfsd: don't vet delegated times against an exclusive-create verifier
      nfsd: mark the delegation written on COPY/CLONE instead of stamping c/mtime

 fs/nfsd/nfs4proc.c  |  98 ++++++++++++++---------------
 fs/nfsd/nfs4state.c | 173 +++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4xdr.c   |  10 +--
 fs/nfsd/state.h     |   5 +-
 fs/nfsd/vfs.c       |   4 ++
 fs/nfsd/vfs.h       |  13 ++++
 fs/nfsd/xdr4.h      |   9 ++-
 7 files changed, 229 insertions(+), 83 deletions(-)
---
base-commit: d692f252c52b8d1b4bc7481554f314df31ed8249
change-id: 20261102-deleg-cb-getattr-times-8aa926029b16

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

