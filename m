Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332662;
	b=chHYsdjhvIdeoWEkEqWQmo7eWgQcrbsxDDKAExHTfTfb+0kci+9aS/IWsCohCxwAfoTH
	 gsDigz5c8nbqFPIdxAJwkA4fucwpHt2pvySiYSLB21VP67Z5NqOgp6Ut0/d7HlLbP6piE
	 qOluX9MDdjbLDjOoahPmL37z3/kZERDcb9YjaQ9OuQV9wTFzyNMXRXBLDcbnY3godBdh8
	 ZN+JLJJRLIxirdtEn1ZjaJUzyqPriWdedPb5dAaEIP0E7Ej478iB0mnjSIQGuop0/EKSS
	 8fRXfrbyzn/a26Dia9ZRD6G5pmoew3vKIxn1+KR8XZL2fGhfEBpjC9I0R3Y0YsG4UcA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332662;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=s57cApSxjBxQZ4yzuXwW5pk0xGS3v8xStQODpVofrio=;
	b=ZgQWpdpJEIdEbIULYBKMVq906XuXs81mS2nB6l3xv+ZLB1fTpTForZiSFOMv8a2AF1KA
	 /91BLYgqio7zfaUuCy9R/IMsPlLebmv4WjBHQUn7F9eUMf8gbxfSopGj39L83dN69HmP6
	 wRs3HFqOmd5NuBhECVScYkCwvg4yIiF356pWj5PfGZrSGv4E9WN2U8IS4IoBUrHeHgpTk
	 CT2J3l3IQnVT1hyoyFqlZx5QNGnlSpDME8/tcK/zmqZguC6AcE1SUOm40uk4RPFHDpN7f
	 wva4R7nYk3xhyCjHhqqjD88qUHIlp8SKR/MF6EWY5CWhL63mC9Evs1OOY9scMrtPdFg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ad2bHmpG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5FFE2606A33E
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ad2bHmpG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2816B1F0089F;
	Tue, 10 Nov 2026 17:44:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332662;
	bh=s57cApSxjBxQZ4yzuXwW5pk0xGS3v8xStQODpVofrio=;
	h=From:Subject:Date:To:Cc;
	b=ad2bHmpGRj1ceSRtgeNQnOiXd7ZxK1x9rtBpJuPcaYFN6egMHTVJwO1kxu79syzhx
	 vJUjDhgdkeKGyPiRVgp6OzkWZtjXXtrWVyQdguNMp75uCgNy7HkL+i9xcNnwoF7CkN
	 4IHeY5dn2IHBEfHtgLkOCYnfZiFziEAT3HMohbVJXA2ftIcdi7uu9biJo45d/ZrljX
	 PUlqz1OaoqNQDYMsEfVD0fv5CZ5d3T+CQxkm5XiZNi3wzQCxcGmrmWEpOvsd2ZUkDz
	 5WoZngaddISWKFX8Tth+/0Z4r2EXSIBs9iFuqXGe2nz8FeqQd4bb88pu+0v5htrz/6
	 ERnOwD7o4xVeQ==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v2 00/10] NFSD: Randomize clientids, session IDs, and
 COPY_NOTIFY tokens
Date: Tue, 10 Nov 2026 12:44:07 -0500
Message-Id: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3WOQQ7CIBREr2JY+5WioejKe5guWvi0aAXDx0bT9
 O5CXbt8k5mXmRlhdEjsvJlZxMmRCz6D2G6YHlrfIziTmQkuZMXFCWLrTXgApTahMwRaSivkwdS
 Kc5ZXz4jWvVfjtfkxvbob6lQ0pdG1hNBljx5KpHHce0sGElJyvi+VwVEK8bO+mqqi+n9gqoCDk
 kelamVRK325Y/Q47kLsWbMsyxdAZVxp5AAAAA==
X-Change-ID: 20261029-random-stateids-c66f263d7800
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3339; i=cel@kernel.org;
 h=from:subject:message-id; bh=9GVeFdWhu92Yc9sFmsZGyoguZCziiIluYjF1tQ5yvlA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq81fs1PZtJQbC7XX0/55bAfhdum5bLmkY3zyQl
 rigQqzX+s2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavNX7AAKCRAzarMzb2Z/
 lzX6D/9jrAvbq2pHqVCXBunOR/TsK+PM+ofDfqzkfyzn5abWgSsX/+45NzUyM/ZcCB3W8wU+G4b
 eOyV58OI5sYUS8caQpGSRcWDwk7KASz3UFeOZlnty1hjhnnUkGFiDnNsq6BtqAxNfyzineKF2T6
 y2R0IJZae7xqHQ28ZiSrwNjw9uoa/6yn+ESlC7mvfUNFeNRwDAPG7cesVdAqvW908AwYdJJz5R1
 3sKd7O1gwtbGW696UGBbPLcENJeGtewLWKkYgRazM9TqsxkghaCLf+J+ssYF+n9+LE6UWy7clEz
 iJ39pwRanatWWKgXdVP0NXFmm64iJYdk6htqYhDznSisj4v7+t8o0iDn0MUWiq/bi0soyEke53o
 yMiUP6qRRzA6Of+Ibtv9U/zdq+zEI6XNTkSOFyCEDthnH9IvwRayvwId1hC/Y/6614ZJvm2tb04
 EpbMJS09TvCkkgxVeU9GbUNqpx8rbWPLelGgr/Lc3M6CPMdzPn4v5heT7ibU9pzS6/wA3DN7nxI
 ORkFjqRKat4c4+TIRmZGfFOd+420yYcbTHDlyteVDElvXgVv2gVN0DwouNcXmoEhPN0cHQ4gLrn
 NmmSpQZv2IBaIQXi3IOOpMbBTh2wG59fVHnhCS/E5f5bAuF7lwnWeTPbQUbExEJLLnMr1JSnte9
 p0j0cbyUe5wJGPA==
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
Changes in v2:
- Re-organized the KUnit tests per recommendations in Documentation/
- Free the KUnit COPY_NOTIFY entry if idr_alloc_u32() fails (sashiko)
- Link to v1: https://patch.msgid.link/20261029-random-stateids-v1-0-8648878fec8c@kernel.org

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

 fs/nfsd/Kconfig                  |  14 +
 fs/nfsd/Makefile                 |   2 +
 fs/nfsd/netns.h                  |   9 +-
 fs/nfsd/nfs4layouts.c            |  10 +-
 fs/nfsd/nfs4proc.c               |   2 -
 fs/nfsd/nfs4state.c              | 313 ++++++++++++++-----
 fs/nfsd/nfsctl.c                 |   2 +
 fs/nfsd/state.h                  |  45 ++-
 fs/nfsd/tests/Makefile           |   3 +
 fs/nfsd/tests/nfsd_state_kunit.c | 634 +++++++++++++++++++++++++++++++++++++++
 fs/nfsd/xdr4.h                   |   2 -
 11 files changed, 944 insertions(+), 92 deletions(-)
---
base-commit: 6ab6af61dba3facd7684c303763bb15da8a959fb
change-id: 20261029-random-stateids-c66f263d7800

Best regards,
--  
Chuck Lever <cel@kernel.org>

