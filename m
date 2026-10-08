Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4E2E4EE84F
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 18:18:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791483521; cv=none; b=dwZeEhHGxSq3UEO4AFPjaLhJYFxQvUQXufcFWgX2T4cV/05cdSctmIk3FJ5QMKT3Gh0e/ADUkjQy5TkKtTr1spukC7TevOMSdkWCHVX9UMruprkz4RyjzY9A/QDAavkF+Fba9OmzgfWAIUgKOpzrNTq4AaoSc2380U32VzKVb/w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791483521; c=relaxed/simple;
	bh=T+Yq1QDhqmClkehrimM6tz+b9uyP+CrFuxZha/wEgsY=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=QteJS24KVx6k3k4x5tNG8I2+yBuXitl58K/Jfo8PcjIcHSie2JMo2dwedmfoN5B16H2H/yZcDRP3vJ/8yPVTuHNI8hezsZ3ShJx2MvllVQHxdbOlQmHAqw+zXy8JW/DYicNCuRqlmNncC/pvMeV3pm7rVARmwHvIVfAEI2RCq+c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=l4Nd4SH/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="l4Nd4SH/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C39181F000FF;
	Thu,  8 Oct 2026 18:18:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791483520;
	bh=fk4l2DecKfMQankBdkCCJ2Nvu9KxGDWxMvIZWXojAgo=;
	h=From:Subject:Date:To:Cc;
	b=l4Nd4SH/FTEuB5FRxje8YxzBjb/KfeWpFn84Ghmvlevmo+1iwu0fbDKwZaVW58L3J
	 0r59TbW2GhvKvt1ndcELXuXtogZwXBWpHCACT2Z3wRj04zlWG0qgLlNcYLMMf0MoKZ
	 BYnCRZ47zmQ2PN2d5YWk8eMN4bNJLLfXtHZOHX+RtE0k9K0QcqYqs/jdGgg20wD35a
	 Dqdd8Tj8oeuff50fDrZktOathkSJCqqm10GvD7KBJmPtQUiwztVS60KqahXtYoxC1N
	 STtgQVHTw5qSaZ5jLY9EV80u5rMuYucNNs0Dez0E27mfR9PZjYrtbNeMTvEgxxKa+i
	 e3kMcAYkPpIIA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/5] NFSD: Fixes for OPEN4_SHARE_ACCESS_WANT handling
Date: Thu, 08 Oct 2026 14:18:26 -0400
Message-Id: <20261008-want-read-v1-0-e372262857c8@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQrCMBAAv1L27GJSQYNfEQ+bZNNGZJVsqkLp3
 030OMMwKyiXzArnYYXCr6z5IQ3sboAwk0yMOTaG0YxHa8wJ3yQVC1PEAxmXonXO2QCtfxZO+fN
 7Xa5/1sXfONQ+6IUnZfSFJMxdBb7vJWnEylqzTLBtX2/eEpiQAAAA
X-Change-ID: 20261007-want-read-3a08fd18881c
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2467; i=cel@kernel.org;
 h=from:subject:message-id; bh=T+Yq1QDhqmClkehrimM6tz+b9uyP+CrFuxZha/wEgsY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqx951KDDbJSBxocpfRjQH31YdXxuA4RCwhLw6k
 F8/RiEz35+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasfedQAKCRAzarMzb2Z/
 l7BZEACDHrdTfhW6438Q3KvN2GmXZe5TUvKclQQe84Xf4yP4KgkQJ0uSkqssE8E+M+xM/V3Fasv
 SWLLmsNHwUpfC/eEZB0soQUqDRnazdzAp7erf+pHQZGGdY4F9htsI2SIiMJ15dREHy/r03rdqji
 e5y/Sxcwd/3cS4seUujNeAGjw5/RaIMGtVs/8vkzp4iMGMcCOezc1VpnKU7VC02F6HPf122bQku
 uk8YnqwlfAjsJcSdtnbstg+YAnrZ7sTC2osfdHRZxgNggBkXzPBRNjlDmiAxAg9qiFJ+x+ZhZYh
 Dd1RHx76pE5VpJjb+NlvWenfkFqi3da5pJBTkohlQSOa07eZw0YV8FfjMCdm+XznLeDDVsFlpAz
 Amk8MRuyhfeReMgO7bAj2QsX4PPEiDaM2TADKcqlEcj9i4rh8570QlRInaL5k8gyJk/Hm8FF1Pj
 fg0nE0tYUkhAOohxgXc3mg+spPIhKl8s028dWnai15/NhRshKwsVa0kJZr5YqDL8aU3Oepm3onz
 A18p9Sa3OTWUvKCwdVLEHtLXAfZrJTdhC5dAXCJeTaQNeRobifdg45VKngVOfx3653mdjCaGzY9
 NxHhBegxXO5iWiDtY5X17JNeNsrsdyhP/ZFeAOjlwWmZZZDDFC7PWzvK+VIjr3QDusxQhsVYo7x
 VBQnPV7wBz31sfQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A client that uses OPEN(CLAIM_FH) with OPEN4_SHARE_ACCESS_WANT_READ_DELEG
to regain a delegation on a file the client already has open gets no
delegation from NFSD (https://github.com/linux-nfs/nfsd/issues/156).
The report carries no ond_why value, and currently NFSD does not
supply a useful one. nfs4_open_delegation() discards the errno from
nfs4_set_delegation(), so every refusal reports WND4_RESOURCE, and
the WANT_CANCEL and upgrade/downgrade cases in the reply code are
unreachable.

The -EAGAIN return of nfs4_set_delegation() is narrowed to mean
contention before the recall Bloom filter is mapped onto it
(patches 2 and 3). Patch 3 has no effect without patch 2, so patch 3
carries no Fixes: tag. The last patch changes what NFSD grants rather
than what it reports, matching what the FreeBSD server grants.

After this series, NFSD still reports WND4_RESOURCE while in grace,
while the backchannel is down, and for a want of the delegation type
the client already holds, for which RFC 8881 defines no ond_why
value. NFSD also still grants no delegation on a file after a recall
for as long as any client keeps the file open, now reported as
WND4_CONTENTION. Whether the reporter's client hit that policy is
unknown. Relaxing the policy and/or implementing access mode upgrade
and downgrade is left as future work.

The pynfs NFSv4.1 "deleg" tests pass 24 or 24, including the tests
that exercise ond_why and WANT_READ_DELEG on a read-write OPEN. The
NFSv4.0 delegations and writedelegations flags were run without the
five tests that need a manual operation on the
server. DELEG22 fails and the seven write-delegation tests warn
because NFSD grants no delegation to an NFSv4.0 client that opens for
write. DELEG6 and REBT8 fail in code this series does not change.

---
Chuck Lever (5):
      NFSD: Report WND4_CANCELLED for an OPEN with WANT_CANCEL
      NFSD: Report the correct value in an OPEN response's ond_why field
      NFSD: Report WND4_CONTENTION for a recently recalled file
      NFSD: Report unsupported delegation upgrade and downgrade
      NFSD: Honor OPEN4_SHARE_ACCESS_WANT_READ_DELEG on a read-write OPEN

 fs/nfsd/nfs4state.c | 128 +++++++++++++++++++++++++++++-----------------------
 1 file changed, 71 insertions(+), 57 deletions(-)
---
base-commit: 97bf905e837e345107c2ed3efb2e65108e081e0e
change-id: 20261007-want-read-3a08fd18881c

Best regards,
--  
Chuck Lever <cel@kernel.org>

