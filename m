Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794419038;
	b=bjfv/R7YtvZ/Yy67R7g5IYzYsFMGoQowCruCSqDwR+kqLR8q8W6v53JhMYn5pkXHM6fm
	 virBRMFOrFcINXaPgP5d3YQ2Ekg1DyxmzunYJbjQH6IDD+EKfpfjtnjGizCmanneNHy3x
	 TKl6QTb2QLtnExiC8WBg6/LgWFM3p1TkK9kAQhnZI6+kd6v+sD3jtaPMHUEAax7k8XTbO
	 fHrBRR43AUZxkH0N+Tp2QXiFI7mOWwE7n2lhTF32mU8e4t5mDFE8eNNrhS6czeyTvk7Ae
	 CXIXVoT2q8nv7FvAQaLM5hLQugaT8P17KhCtzSjo/tRDL5eS3S7l6eJAviNK1E6SKkQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794419038;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=nQn85x3JQHkQQKwEpWsI1/qsQ2c7IvmZPFPokBkw+YA=;
	b=ZalFHJ1N7beicTfIuWAWuiiAAjD46KIenm62Q3Z7CmbHxTj6wxib9kgPLhZFCpNAQQMH
	 MxwseZrGzN9Yz81iNEZQT7tc6m1JRL7ArgS4s4JaOTSxY77pmMomFwzpSE8DeZt1U+xnS
	 1yYFcC2dHS1l6qvvoKNTmYw6I1I0LNUYJZc/B/Xe0NcdlfEi3wCO4JWPp33XJWuS/9oPv
	 sV05s2ZHotUA2CHvoNfqjhBDDjNrwnKwsYSaQB6tfDeYyWTYuqOJ39L33tWi6Yeoz8QWp
	 ZXHIgGhmc+djLu5eLbEV8YtCdN4pSwiMTVWoJCGhfzIpX+w3x4h0dKtCfQVavyYTbfg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="D2/wsrtk";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F859606A334
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 17:43:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=D2/wsrtk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A08F71F00A05;
	Wed, 11 Nov 2026 17:43:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794419037;
	bh=nQn85x3JQHkQQKwEpWsI1/qsQ2c7IvmZPFPokBkw+YA=;
	h=From:Subject:Date:To:Cc;
	b=D2/wsrtkFDNMKAP9Awy9+gvoHJ8GkaYRdR76kjJyIy6PRLMhwWwWsFbR6RJxihulw
	 2nHynI/fq65n6/f5S97HRXFkLqwK5Scqeh/d7BWc+e6AauH1RAhPGUdeAE/7vjjyOT
	 kvR1JbqvLvJQEvb59MVEdRyQj4JwQM4cJdNBKJXrlmS92DdYUSUa1EZ22bV8kY2ZT1
	 N4FuFO+/AHY4hxvHqb3i1ioY4vxTgUEI34wGLUDk8dJKFDNKgXM7vUFrvAzSCchM2F
	 8VChH5yexxF8de8ThGmt7/vfZ1WP+Ejo6QsW12U9IX/bNlwPX7wQ0SroOC2jRactOx
	 17iZlpCg1y86w==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v2 0/7] NFSD: Apply export security when a compound crosses
 exports
Date: Wed, 11 Nov 2026 12:43:40 -0500
Message-Id: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22OQQ6CMBBFr0K6tsqUQNCV9zAsaJlClbRmpjYaw
 t2luHX5Jn/e/4tgJIcsLsUiCJNjF/wG6lAIM/V+ROmGjYUqVQNQVjIhBYvMUskKShjqylgDrdg
 enoTWvXfZrfsxv/QdTcyGnNA9o9TUezPlk8H55C0PMiJH58ccmRzHQJ99UIKs+tudQJbyjE3dt
 EqBRn19IHmcj4FG0a3r+gX16cDH2gAAAA==
X-Change-ID: 20261103-verofess-2-3101d53cfc18
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
 sashiko-bot <sashiko-bot@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2819; i=cel@kernel.org;
 h=from:subject:message-id; bh=4nlU0uYMonqUXeUP0gSolh7wH29hU55CjNd9ZPIv+ks=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9KlUdEYTUJ7fs4t7cPWuj5noOpBCnVeLWCyu+
 L5aN1sMfTaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavSpVAAKCRAzarMzb2Z/
 l/fGEACAt/6NV8ZVMK08Gvlrg+w+XP6WKYj9nM2iW5UPeSAj65RKoLEirYUvWNRObJKHZoY/+KA
 7246yGNd7kE2AhJrDkURxkl8imfYFoTqkv4Sw5+Qi69bU0JDubwzFHRuUs7obtEKPirXcgMaOiM
 pF0BsodgrZoLzSlXLehSShTULs4zpcpWL8M2taOAFG1tRK9LDCult0hbxDluHHPMA8IxXb5aGKz
 mfa62g5uqPcBe9IDfCZpjAuifNZusjYpLKxc/Vpid4fiIg0u8yxPsg0YW3JUEHEGy3uiQxr/zDY
 +Y+W2pDyHhfnycgPCKp58vQTMZ8DOEtJbzdnt41exSgpurx49XOAw05fDVFezCR4x3HQWwwSiPd
 fV2T8PQ20blMnOB0jmVN7rNCRyeC5/a0sBNoqBOeHil/5R5b+YZ141G7XScPlJg31sshVjUKxsm
 6uvgqzxTcYTUq7w4kwwUFp9GhyqD4QfNcMRX8W0hYDciRO9CXOKtsAcdrOEBUju6lYkHPrHXqMi
 wrXLX1lUrMpuvNuuc/+0B30wX/WsN0mPufZcemSwFI5c+Bhr22nbG9qjetlbW2XaEHfBHf7Nn3Y
 LnlesXmTs4VBaVh0BvTqeGploegs07qLDScpdozgHvvtgj8Ic6fBy/nm3VOx6ikNvafMEu+4/zT
 OXBOESki3Cb6bmg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

VeroFess reported that a compound can move the current filehandle
into another export without NFSD applying all of that export's
policy:

  https://patch.msgid.link/20261103013237.1174538-1-coderzeng@gmail.com

fh_verify() is where NFSD checks an export's secure-port setting and
installs the credentials its squash options map a request to. A
LOOKUP that crosses a mountpoint, RESTOREFH, and the saved filehandle
that COPY and CLONE consume do not go through fh_verify(). An
operation that then uses an OPEN stateid, such as READ, CLONE, or
COPY, resolves the stateid without calling fh_verify() either. The
request runs under the previous export's port policy and credential
mapping. The requester must already hold an OPEN stateid that NFSD
granted after a full check, so the exposure is a client that keeps a
stateid across a change of port or of export options.

Rather than repeat fh_verify() at every crossing, this series makes
the crossing path itself complete. check_nfsd_access() gains the port
check, so a check added there covers LOOKUP, LOOKUPP, and the COPY
source alongside PUTFH. nfsd_setuser() runs after a crossing and
after RESTOREFH, and once for each side of a cross-export COPY or
CLONE.

---
Changes in v2:
- Install credentials after PUTROOTFH and PUTPUBFH (sashiko)
- Name COPY in the comment that PUTROOTFH carries
- Apply the current export's credentials after LINK (new patch, sashiko)
- Skip svc_xprt_set_valid() on a deferred check (new patch, sashiko)
- Name NFSD_MAY_BYPASS_PORT in the __nfsd_lookup() kernel-doc (sashiko)
- Correct the failed-decode comment in open_handles_wrongsec() (sashiko)
- Link to v1: https://patch.msgid.link/20261103-verofess-2-v1-0-9e6568221beb@kernel.org

---
Chuck Lever (7):
      NFSD: Check the secure-port policy when entering an export
      NFSD: Do not validate the transport before a deferred flavor check
      NFSD: Defer the PUTFH secure-port check
      NFSD: Report WRONGSEC from PUTFH when OPEN uses the current filehandle
      NFSD: Apply the entered export's credentials after LOOKUP and RESTOREFH
      NFSD: Use each export's credentials for the COPY and CLONE stateids
      NFSD: Apply the current export's credentials after a cross-export LINK

 fs/nfsd/export.c   | 24 ++++++++++-----
 fs/nfsd/export.h   |  3 +-
 fs/nfsd/nfs4proc.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++--------
 fs/nfsd/nfsfh.c    | 49 +++++++++++++++++++++++------
 fs/nfsd/nfsfh.h    |  2 ++
 fs/nfsd/trace.h    |  3 +-
 fs/nfsd/vfs.c      | 20 +++++++-----
 fs/nfsd/vfs.h      |  1 +
 8 files changed, 154 insertions(+), 38 deletions(-)
---
base-commit: 1ba84639d05b57a0cdd182966e64b4942fbe82ac
change-id: 20261103-verofess-2-3101d53cfc18

Best regards,
--  
Chuck Lever <cel@kernel.org>

