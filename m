Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 587D617A586
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 01:40:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787449226; cv=none; b=FgQLITpeMML5PfVY8lYzP5QzjcsLhf6e8H7UoHVVGP4KYvhN20jXe3PiRtHAg7C89AIRo2qzsRlaeFG4smcqk6riNhJab0cSMUSXTYjBKBgnVqh9gsU4T3pUZ//fiXf8F8Qu0vByVPkRNfSdbHgxHI6vdVPnaUCr6Q1DPjPs2qE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787449226; c=relaxed/simple;
	bh=C8iVh/AHH2pHaCElMfdjO/k5D9GblrEJLFXWX1o9IMk=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=No/aVlKRjW47hmrPi7Ylbexr9n6FbOPTYbID4HBoU74r7m6w9zLsQwcVDYfO6Xn4AbJ0yHLivX1uBIPAkTdWdPM5LdF5IIUZWSUXqavBdyuAKNOmUoCwl/vkp8wNQ/X0v9NvdbBMVzEAvN1CI74Aep8SXn84x6yUmD+pluDol7Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jb0zs+b0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jb0zs+b0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E9D31F000E9;
	Sun, 23 Aug 2026 01:40:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787449225;
	bh=Cs674TYlUZQMacqda5Axvy2nKRGCQUCJCRILXO5oVB0=;
	h=From:Subject:Date:To:Cc;
	b=jb0zs+b0r9ClibUyua/BmrMBi3TzGjTRAeua6hdReRrjveIT+pWzmL5lo3okGDIcV
	 VRj1gbXRmHkcDp5qNE2XC9OXA2/0mHgdtoJOpQhZy5LjKfgWPc58FgU/DcwslGRdlq
	 0KLt/5gFHoKfQrbvuUlPkyjBl4aXwsXfVCINIwO3QEORXsJRZ+7GieRPU2dC6QvZa8
	 mhEjYNHWx9kzMygVPM23B0J+a6dMOMWZGVeDHQRNP7HOX4AjpkU3gI1+p75ARKFwgI
	 7pJ2Kk2Uj4DFK/koGwjjt8PciosQ3bfBE1tkzHqaIhu/Z0b2ck5mWFalY9o03Ng06D
	 u01iWKsVJUt6w==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v3 0/2] lockd: Fix two teardown races in the block retry
 loop
Date: Sat, 22 Aug 2026 21:40:14 -0400
Message-Id: <20260822-lockd-retry-blocked-uaf-v3-0-761661eae60c@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWO2w6CMBBEf4X02Y0Nxqb4K8aHXrawSorZLURC+
 HepPp7JzMlsSpAJRd2aTTEuJDTlAy6nRoXB5R6B4sGq1a3RttUwTuEVgbHwCr4CRphdAmOT8Ve
 tOxs7dazfjIk+P/P98WeZ/RNDqbra8E4QPLschhoFHM85SYSCUij3tTKQlInX+m7f9y8Eu2oyr
 QAAAA==
X-Change-ID: 20260820-lockd-retry-blocked-uaf-68f6b50098d9
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
 Shuangpeng Bai <shuangpeng.kernel@gmail.com>, 
 sashiko-bot <sashiko-bot@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1924; i=cel@kernel.org;
 h=from:subject:message-id; bh=C8iVh/AHH2pHaCElMfdjO/k5D9GblrEJLFXWX1o9IMk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqik+A6AtfQ47EpJQeNk5wSGsUw2aTQnQFCOFs4
 nJRP9RZP6+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaopPgAAKCRAzarMzb2Z/
 l73kD/9euK17iiQJGR7hjRDc8rF4Dl2MbMfuYxdb9VoHeLC5yiI4ttzql5+JI6fyUJiKIvjFDRk
 /KaF05r1QnaxKCDWVYJ6xDb2jhfSHQJ0rX+N11JuVM75ptUijrpaYnPUYAqFDN3YarVgQu1x2hn
 fCqLGxYhHSr+8M3xEtWvgNTwMKUAIFzOXcAg6ihzyq3nc4Ypp/eGmWRS7LH+aObVg7QtYRFaRRq
 CEbIGK2zaV4hV8FOzrskctiMkWPlDhN1F3+deJcR2OFI6FdEX0+SYvTaPEWHGK7H+l7awVb+HDw
 skU/IIv/yuyshg9zAoA3+egqfJsukocB0q35n8ne4F0wULGHWE9+4CBYnI0JV1LbnXm73RzX3pf
 y0t9wsWH94OXaDDqcX2/qyhxglhOWosKocph8/tRwwZEjW+h//JnRPkUob2pWCd9ICopI6173cF
 iU5TorQMnNFyzdxVQNZ7RAyH9ftum4SIS4XfzLt7hkVGG6xxiJ+Kcj36Rf4uzvsymHzm+HMFPcw
 ua2BFzpNOcZA799ayPRVEMBD0TpyZtEUWRP2BoFGXxjk/wdojzD2X0aiaGAFyt7f8iVjb5AbiXd
 qfNvU4TFUqSR6QLKyvk6bHfs6JK1gWzt4JZvVfF1beGaX2WFKN/+i1t2+BBCsliA86qZ40U2TXE
 7CI76wz9cZQq5ag==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nlmsvc_retry_blocked() is the only path that operates on a block with
nlm_blocked_lock dropped. Both defects live in that window. Shuangpeng
Bai's KASAN report catches one of them, a block freed while the retry
is still using it. sashiko-bot flagged the other while reviewing v1.
The retry re-queues a block that the teardown scan has already
retired, so the host that block pins is never reaped.

Patch 1 fixes the first and applies without patch 2, so it can be
backported on its own. Patch 2 is meant for mainline only. The race
it closes leaks a host, and closing it widens the f_mutex hold across
the retry loop.

v2 added a B_DEAD flag that makes nlmsvc_insert_block() refuse to
queue a retired block. That appeared to repair the second race, but
it doesn't work. Every caller relies on that insert to take the list
reference, so a refused insert lets nlmsvc_grant_blocked() drop the
last reference to a block whose file_lock the VFS still has queued
on a blocker.

Signed-off-by: Chuck Lever <cel@kernel.org>

---
Changes in v3:
- Split the fix in two. Patch 1 is the block reference alone.
- Drop B_DEAD. A refused insert could free a live block (sashiko-bot).
- Serialize the retry against nlmsvc_traverse_blocks() with f_mutex.
- Link to v2: https://lore.kernel.org/r/20260820150831.3291262-1-cel@kernel.org

Changes in v2:
- Add B_DEAD so a retry cannot requeue a retired block (sashiko-bot).
- Link to v1: https://lore.kernel.org/r/20260819162247.2970703-1-cel@kernel.org

---
Chuck Lever (2):
      lockd: Fix use-after-free in nlmsvc_retry_blocked
      lockd: Serialize block retries against host teardown

 fs/lockd/svclock.c | 33 ++++++++++++++++++++++++++++++---
 1 file changed, 30 insertions(+), 3 deletions(-)
---
base-commit: 01c2994ccb0197cb44b0db89aacab460110f6347
change-id: 20260820-lockd-retry-blocked-uaf-68f6b50098d9

Best regards,
--  
Chuck Lever

