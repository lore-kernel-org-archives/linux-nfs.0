Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794256649;
	b=Ed2r8hCBB2EawpcaDMnw592RahZYFe/kNloJ4aqeM0xNYm5NRauJEzCoDboApvScxLZK
	 gBehkRpCq3rFnze+Y6oN9qIBzr/x91+GYUkdyBK4UYz5m3oGeu+aHllMtBz+lEJRt/4od
	 vURJKmUX8ZTJqlhPBP3UvODP7KoSU5zPKd8zxdy+7XzwU0ZqoWligvYOo38sxnCIZpFF9
	 qSY5qLrZOl6f6zyydhuNf2TlgC/c/5Lzs5x3hq/aTzXfW6+L60N2rCQnh0Asajy8uz4pA
	 VkWSW0neZphy5UXeRr2Lw/dLmh47ZLTBCSYYsWLnoFcO9Ndh++asKA+ndLYohM1y/4Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794256649;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=tsXqv021D7xDJLBYEcDly17IxW8mw4G6+Z2raCWr8GY=;
	b=Tzrd5L6hVB5y2S47gIfTf22Sb6VSfJdF/AB3c97Ck+mlFpsfoNWM7TpkAJFq0VYnAMNn
	 pUZaiLTsvKC8jsLb5Yv2DvHDlZ+qtVBj7S9HvAxCBxqoJRQufHzCZzM+tMXrHb+Y7H9jt
	 xDp9m1D9d/v/0qercl2q7riPHF1T5hvW3ezLNiAIWlYGqvGH545VKjwGDOAZbmgVw1GvG
	 I0PK0FJ2ECS51s+60S4fJGVwkLlY6jMXx+QH/+CeWRmztRWL6dpKRS1VAccd8UEMOEes6
	 Z1yfAI+gJCNiXX8AacsfWzTDB5LvJeEs8CmVC7Tg4UVj6fhSkA7VhgRVI2O0j/E7lNw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MuxuvId3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76025606A321;
	Mon,  9 Nov 2026 20:37:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MuxuvId3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 11FDC1F0089F;
	Mon,  9 Nov 2026 20:37:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794256649;
	bh=tsXqv021D7xDJLBYEcDly17IxW8mw4G6+Z2raCWr8GY=;
	h=From:Subject:Date:To:Cc;
	b=MuxuvId3oTkDxdUIk1M34q6oow2B8ASSxBWhH4HLJWsy8qLEze84iLZ+hLqSU1z94
	 0iqyYMO75vVRxSHRDF54zw/KcDiaPBO9f+7HpKb22SC1NFdJdoyxeFirEBw75SGt6K
	 fO8I5C6GEJAoCqMNCuGmhhK7pPRlbZk/0TpXX7V46VckBxXwFRaNBXRuosjZR/g2zY
	 NFk4kF31RaQ1atzzBkSUIjcu0l3U/5sMye8jDuEIR3jbF9cawN4AlQc/hpdABOG0VE
	 eLT+jbL9Jkw0DjsLX3ngi4mW9ykTRz1dkBG71cK7iEVKAal6nWfGJq87BGHSaEQnFa
	 3TA5ihhCO+TZg==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v3 0/8] nfsd: more delegated timestamp fixes
Date: Mon, 09 Nov 2026 15:36:41 -0500
Message-Id: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/4XNQQrCMBCF4auUWTuSTCSkrryHuEjbMQ3WVpIQl
 NK7m3alC3H5P5hvZogcPEc4VjMEzj76aSyhdhW0vR0do+9KAwnSUgrCjgd22DboONmUAiZ/54j
 G2pq0oLqRGsrxI/DVPzf4fCnd+5im8Nr+ZLmuf8ksUWBrhSLdGaNJnW4cRh72U3Cwmpk+Hf3To
 eKYg1JaGtvUVn45y7K8Ae8/JwkFAQAA
X-Change-ID: 20261102-deleg-cb-getattr-times-8aa926029b16
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4291; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=qaUyX0Ckat3OuXhwKU+UvTXNLVj5tmHyi5DQnEuwWtk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8i7xZ6c2IDNGQ9pTqUnQmk8jk41DyZEuroI5O
 d67HYH33aiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIu8QAKCRAADmhBGVaC
 Fc44EACDu68HbBnJcA/g6Kx+LFwuf549qNDrkNVTENQboW9FrggEYwKRwyEQqdqE5lKQogmBP/1
 OK5F2S3Hd3MKL/Jaj/sBO8maJ7xDQ6DlEopy6ByPK/BcCK86LAkeXb1V12pC6HCIt+rMnqDNl31
 0soakc5es809KMqd+KUbknqL+Al4+CBUpC0bZMGT6r5114Do2+lKlMI8Ly7PY5OhSwF4U7XGMIk
 WxmGzvYIx6/wsHgBl1ptghCf/wTIluVd5zd83F6zvswModDuWAddngpzWqtpOppnTQVEkQJWP3M
 04HxoZLDWJIIqIlhzDoWz9A5iuSExr26Jc2X9vU2+RFLwzYociEKO0CJgrbvWRv7GLyzEq79IBZ
 CKqQ1nhf5kcuaK3ffOJ02hEMie5B45lXwHJrIAyuGf/hruiqGRE8bc972XF8HvjgPxjU9kFQhMw
 74oZj5HbAf62w4ah0sJrHtRSuN2YipFm8EqN5nXGfeF2T98C4zyKt6cj6cMJVVNNHAbY1UIWqN3
 4cCRaWN5YM3I184k6S7DIEFs5JozEVvIWASavyeF4STq+mnFDpaBJVBIXEFAEnxzHYqS3bIxWXB
 YGVm2S/Ju1lH7Lw/SXneglVTDdAgGgC8nZr2q5/dsBti0GadrMzP7llrHosb2hwxaIblEd8iScq
 MZjZ7Pw8xW4ABGA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version fixes the existing patches and adds some new ones to fix
problems that agentic review spotted. Note that there is also a
companion client-side series that fixes some related issues.

The catch with this version is that we need a fix to
inode_set_ctime_deleg(), and that lives in fs/inode.c. We'll either need
to get Christian to take that one or get his blessing to merge it via
the nfsd tree. It's a pretty small patch, so the latter might be OK.

Original cover letter follows:

Chuck recently added a new DELEG27 pynfs test that fails against nfsd.
These patches fix the behavior of delegated timestamps (again), such
that DELEG27 now passes.

I also ran some tests with the git regression testsuite which turns out
to be very sensitive to timestamp bugs, and that turned up a few more
server-side bugs.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v3:
- "Honor delegated timestamps when change and size match":
  - record applied times from SETATTR too, so a stale CB_GETATTR reply
    can't move them backward
  - record ctime from the inode; atime/mtime from the untruncated values
  - move the vet/record prototypes to nfs4ctl.h
- "don't stamp over an applied delegated mtime at DELEGRETURN":
  - share the vetting between SETATTR and CB_GETATTR
  - set dl_setattr only after the holder's mtime is applied
  - test dl_setattr under inode_lock at DELEGRETURN
- "don't vet delegated times against an exclusive-create verifier":
  also set the floors for read timestamp delegations
- "mark the delegation written on COPY/CLONE instead of stamping c/mtime":
  - look up the nfs4_file for every async COPY
  - remove the now-unused nfsd_update_cmtime_attr()
- New: fs: check a fine-grained time before clamping a delegated ctime
- New: nfsd: check a fine-grained time before clamping a delegated mtime
- New: nfsd: raise delegated time floors after a size-changing SETATTR
- Kernel-doc, comment and commit message fixes
- Link to v2: https://lore.kernel.org/r/20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org

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
Jeff Layton (8):
      nfsd: Report vetted delegated timestamps in GETATTR replies
      nfsd: Honor delegated timestamps when change and size match
      nfsd: don't stamp over an applied delegated mtime at DELEGRETURN
      nfsd: don't vet delegated times against an exclusive-create verifier
      nfsd: mark the delegation written on COPY/CLONE instead of stamping c/mtime
      fs: check a fine-grained time before clamping a delegated ctime
      nfsd: check a fine-grained time before clamping a delegated mtime
      nfsd: raise delegated time floors after a size-changing SETATTR

 fs/inode.c             |  16 ++-
 fs/nfsd/nfs4callback.c |   2 +-
 fs/nfsd/nfs4ctl.h      |  15 +++
 fs/nfsd/nfs4proc.c     | 101 +++++++++--------
 fs/nfsd/nfs4state.c    | 292 +++++++++++++++++++++++++++++++++++++------------
 fs/nfsd/nfs4xdr.c      |  10 +-
 fs/nfsd/state.h        |   6 +-
 fs/nfsd/vfs.c          |   6 +
 fs/nfsd/vfs.h          |   4 +
 fs/nfsd/xdr4.h         |   9 +-
 10 files changed, 325 insertions(+), 136 deletions(-)
---
base-commit: d692f252c52b8d1b4bc7481554f314df31ed8249
change-id: 20261102-deleg-cb-getattr-times-8aa926029b16

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

