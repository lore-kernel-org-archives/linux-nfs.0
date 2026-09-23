Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 602233914EB;
	Wed, 23 Sep 2026 15:31:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790177497; cv=none; b=aK1vm+I5/EJow+SqsyY2EKXSAVRfsnbQRqmdW3sCO6T6zdJbbqewrkrt6b82CK0jbThrhisz7E5Qoo0T4qAZb6b1oerulnCMGqNrrHpp9YI8NIkIXz/JO4lyKzReEGxH20Cs/p15YQYLzCltoHIW4FRKCgYAa4VB6ZI7y1zOZY4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790177497; c=relaxed/simple;
	bh=vsXCmOg2Ny6L0Kl3Yj2M+1ng6nhumuoxehQqLwx/I1s=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=ovCRDZ8trWatKX7vtONRQYSUkayPwOu6WPAVfaEWVsm+coXz62F973jf1pGNs+GN8WwzhBlQRvprYXsr/ATWGKiHjPk3cBQZEy3F4XKBaSs8wfmfCZB6Zt7en5iNlSDsFZKrekhShU+kt9dF34E4VkUpv8LVWW8R3HXV3FF9L9M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SY4e6TUO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SY4e6TUO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 776651F000FF;
	Wed, 23 Sep 2026 15:31:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790177488;
	bh=Ivwlpww7xZ4ttQzWGAl+3jx4bWNQaerWATcCrXzgJ8M=;
	h=From:Subject:Date:To:Cc;
	b=SY4e6TUOOSC7NF8/m0Vs+YpWPIiEAM//xoFUodu04ueI0QoQ1S3lgIqLAEdktVN2d
	 WgV89+nryl1Mnx1Y43D6NVnDA0QYehyacwdYXXbBgDvGw2HsAFelNvii8Nn1gFoqpO
	 bOgN1rn5WrF0wBDGpYxtdwNXDapz/EIFidykB9mhnX8YZB21sZKe7cEkEMC1N2zz1N
	 0X46g6zwiwFrNklKnkzElchhcsfHvPJhw4J+kS9UWy4fVbdp9REcBr/CjAncLPAzP7
	 tzlDkBE+TKK5ROUQFwTUZ3hKaeTy2BT1ZlH9vX6SXmRqQ5Ibbw4wAJd8GyfLROox+s
	 12x9MBtYhGb9g==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/2] lockd: allow setting ports without setting
 gracetime
Date: Wed, 23 Sep 2026 11:30:49 -0400
Message-Id: <20260923-nfsd-testing-v2-0-bfba431122c8@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/1XMSwrCMBSF4a2UOzaSVy111H1IB6W5SS9KIkkIS
 snejQUHDv8D59shYSRMcO12iFgoUfAt5KmDdVu8Q0amNUguL3yUknmbDMuYMnnHOF+FVKrnejD
 QLs+Ill4Hd5tbb5RyiO9DL+K7/iD1DxXBOFuGUdleL9oYMd0xenycQ3Qw11o/DTKtOqkAAAA=
X-Change-ID: 20260922-nfsd-testing-00c12335047d
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1467; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=vsXCmOg2Ny6L0Kl3Yj2M+1ng6nhumuoxehQqLwx/I1s=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqs/DKaHz7r8rxQKVsuAvj0ADjprysezJbrxe9P
 /5dCumE+iiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarPwygAKCRAADmhBGVaC
 FfWND/9864v2kmnTitHxQynDHcKnMfHvSZKUtMOPfvCIC3SyCd2Ar8h2Wfk8UkqZTuCAsvISEMv
 W/oRoKJalg9OQN4LASkOL9Hi59ZbsNeQwWxF7ZY4Ofe7FANlTlcku+OVJWbmAS4tzXAWiokOlgW
 o49HWefCZG3SNRJWTY77VItmPoq8cyO7zh93uePtHZX7JLzzfizJ0Jq6vQMH5GdpBvDDhXqs/12
 aQdZebP2YeYRiLCvpVQGHrtSPGolZdyiH8VcDOWkAwHOxrOfauRLbLV88RtC9wX5d3opsNOW+w9
 gLNQdkn0D1Kqpf5mvf1iiyAc3AqLdTv0O0nlq0WBI/5AMQeG+BqBJqDw+P7I4vZoWYBF4TgjSeG
 ehTSKQjQA8L+DeKbxYnsPIrK0MbAV3Nh1c7opZURPtVjy33qrBktqrjKGVvj5ORIj2EBoJI1kni
 7GevOqyh1hC+8kEtgJI61Yrylz/W6y8T5CNLt+xIpgF429XHNc97VcMD5dMQq6pKm4UEL1brbP7
 mkdnpdK5eiaurKKJTjWYu1lFqP37LlSDNEoi51qCNqs0cOu4CDSiMCD9y+qDxCYjYStVp9Z1n61
 Td2Wg021lthgPbR2PAxFwxJcdzSnvNHeimMYrTRDzT4h25wUfh6RNb/Hv9FZUNtXo85LtZWDmRT
 oUUXZ/4d8ZbPhhw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version fixes some selftest coverage gaps that Sashiko pointed out.
The actual bugfix is unchanged.

This patchset fixes a rather silly bug that Scott pointed out to me in a
meeting recently. You currently can't set the ports in lockd via the
netlink interface unless you also set the gracetime. This patch makes
them all properly optional.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- selftests: split put_ports() into put_tcp_port()/put_udp_port() helpers
- selftests: attributes_are_set_independently now also covers a UDP-only SERVER_SET
- selftests: empty_set_is_a_noop and settings_are_per_netns now set and check gracetime too
- Link to v1: https://lore.kernel.org/r/20260923-nfsd-testing-v1-0-a793f54a4dd1@kernel.org

---
Jeff Layton (2):
      lockd: allow SERVER_SET without a gracetime attribute
      selftests/nfsd: add lockd netlink configuration tests

 fs/lockd/svc.c                                    |  50 ++--
 tools/testing/selftests/nfsd/.gitignore           |   1 +
 tools/testing/selftests/nfsd/Makefile             |   1 +
 tools/testing/selftests/nfsd/nfsd_lockd_netlink.c | 268 ++++++++++++++++++++++
 tools/testing/selftests/nfsd/nfsd_netlink.h       |  90 ++++++--
 5 files changed, 367 insertions(+), 43 deletions(-)
---
base-commit: cab95e6be3ba82bcf4c8be27c2eb20e55238aa41
change-id: 20260922-nfsd-testing-00c12335047d

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

