Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 766951C5499
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 16:38:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786811940; cv=none; b=d4e4ylM4DNpH0gqJzQ8bCngIzQNRVkTrFNv2Es4mlKizrfTeY1Lwy346PVsnY7AiJgyBEkd+9Chkm1sMXoH9pSJxKHy5Uly6xamTO/7fDIJRW0V8Sr6XoQHb5SkOTYRCvbv5/YzyG9GowF3uMHYFX8xTXPpRYMC+AuOtumFNf84=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786811940; c=relaxed/simple;
	bh=ZzZ+EWw5jl7xSiewhtG5mDulSAkzr8DX+hGfNYoIBcw=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=g/Oh7OvD+sde7QQdMrXc7RzzmjIMVOEuSHfcWXQESfETxrlWahX6XdzMazciKO2RE3fSmd+oRQzpdpkl3+q8YYTbSKJTWKeDECH9c7zqKSTDnoZFe/XqtVXKjtY82ggvjTdSus+7RDxILK/WpK6vvbObj/3QTw3trk/XUEyjM7I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Im1pawYR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Im1pawYR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6EC3F1F000E9;
	Sat, 15 Aug 2026 16:38:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786811939;
	bh=FzshlagmqrtypTv2u3sOpRJweBWiwGbxnw9OmLUS2GU=;
	h=From:Subject:Date:To:Cc;
	b=Im1pawYRk5FG53Z5WrT8tgKntHn0urtlTY92lcoHKHadKS+ZX6mc4GZEvoYcUDY7D
	 0E64ntwCJtfptPHvDFVctWkw5+rihZnXjkJ6ACI/hgT4HkmDXV/9A+QYU11CsBynoI
	 Bv/y7GnCHPIScs7kXyIbo/LVrdG4AMIuoupPTgMjXytmJGLVlkmN0/MwMV4qN1VUxO
	 wM+rffYFs/BspqlyQHEXh0RFFcoLYJTSDCsWMwKo4Bg7UD0uH6o+Uj60mDc8emPcaR
	 N0zoL9SbvIKByzDeKNNCazPlV2bUG28Wo/OqIMFxaV7LC81InQ6DyU1/IZW5E46rdO
	 GjN1Umv3Vox7w==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v4 0/8] NFSD: CB_RECALL_ANY fixes and a meaningful keep
 count
Date: Sat, 15 Aug 2026 12:38:48 -0400
Message-Id: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3XOQW7CMBAF0KsgrzvUHqdAWHEPxMKeTBKXyEG2i
 UAod8emqkRVZflHf57+Q0QOjqPYrx4i8OSiG30O1cdKUG98x+CanAVK3MidkhCYzDCA8Xc4M1+
 AxqtP0H5JQsPKbmsU+fcSuHW3l3s8/eR4td9MqWClYU1ksMF46suJePj0bWwgcUzOd6XSu5jGc
 H9tm1ShfmeohRmTAgkN12SkrGptt4czB8/DegydKDsmfGdwicHMmB22FRnUufeP0e+MXmJ0Yep
 Ng5UmaZX+w8zz/ASQnluofgEAAA==
X-Change-ID: 20260810-recall-any-keep-count-f50c2ae1b792
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2915; i=cel@kernel.org;
 h=from:subject:message-id; bh=ZzZ+EWw5jl7xSiewhtG5mDulSAkzr8DX+hGfNYoIBcw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqgJYaWThLY/vx5NiHvo41ZDSZ4aVSXUhmD9kwS
 /8OhOIu0RaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoCWGgAKCRAzarMzb2Z/
 lz5/EACwFJPXSuBkYHQe+PhZNyYVNEuATRss6J6Oj683l5DHdbB6X2Xrm5aABic1IXxEt5v5ZJh
 kDy7lPUcnNCftmTUP4eheU0U7a8kzk3j9XpsPZG8HGyUJmBlO4HpOVKVoZsNzQzRMqtY3JGBLpk
 5BasgdRLogNdZM5svNmRivQBhYIwU1TuwsogGSkA7Mwri1RsOg0WUeC/WOWFBnhtqtzWUbD6/i6
 0F+VQmx+IIRji5UQtek6kC+ydjbmIEvRr7ny0+sNheINmZ1p/jxzgEbc8SzkOQpHpfkf5AVwEnC
 hGIqwkOd1RbWqUdvcOHcUC4Z4oXXi0ozxkI7JScVGydoF4ePHCilGJJ9/Exv0ClmvKzhfQFPF8I
 ifmeN54FKUuTi9GHIBIhUxRkrblhknM3sxF4OtT1HyqEp9rEBtG1hzqm2ntaemY1GuWVpXgdTAl
 HvN930m6PZ4oR54BCpd2m4x2TmF1Cd43X6RcqHMtyhP9zoP5iznacmk5bNt3UIZtQgBDb39axsr
 PEdn60Cu2rAbYqvxs3B3sLZQsfQ/Y6jDrx9t/uqTI2zypVqQKY3gR9jPcfzldnGiv1UGuT4qX86
 W3p7ST84gdytXdwuCyTBwD5DtebHgKHnBFtokcshfd2HJP6TNP7EznrIq4wXFZQuQTzWjzAvDe4
 T5PTebEzyMr7j/Q==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD currently sends every CB_RECALL_ANY with craa_objects_to_keep
set to zero, as RFC 8881 Section 20.6.3 does not mandate any
particular way for a client to choose which delegations to return,
if any.

NFSD intends CB_RECALL_ANY only as a signal to return currently
unused delegations. To date, only the Linux NFS client has been
deeply tested against it. That implementation ignores the
craa_objects_to_keep value and returns only one unused delegation
of the named types. Therefore the fixed zero craa_objects_to_keep
value never produced visible misbehavior during our testing.

However, a zero value can result in non-Linux clients giving back
more delegations than is necessary to relieve temporary memory
pressure on the server, which needlessly punctures the clients'
delegation working set.

Change NFSD so that each CB_RECALL_ANY asks a client to give up a
sensible number of delegations instead of all of them at once. To
handle the accounting correctly, it is necessary for this series to
split the current state shrinker mechanism. The patch descriptions
have those details.

---
Changes in v4:
- Avoid a divide by zero when max_delegations is zero.
- Collect Jeff's Reviewed-by on 5-8, given on the v3 posting.
- Link to v3: https://patch.msgid.link/20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org

Changes in v3:
- Count delegations per namespace so each shrinker reports its own.
- Give courtesy clients and delegations separate state shrinkers.
- Record the shrinker's scan requests and discount the count by them.
- Scale each client's CB_RECALL_ANY by its share of the scan request.
- Reword the keep-count rationale in the commit message and comment.
- Link to v2: https://patch.msgid.link/20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org

Changes in v2:
- Drop the gate that skipped clients holding a single delegation.
- Cover letter rewritten to give performance rationale.
- Link to v1: https://patch.msgid.link/20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org

---
Chuck Lever (8):
      NFSD: Do not send CB_RECALL_ANY to NFSv4.0 clients
      NFSD: Count the delegations held by each client
      NFSD: Name directory delegations in the CB_RECALL_ANY type mask
      NFSD: Send a meaningful CB_RECALL_ANY keep count
      NFSD: Count delegations per network namespace
      NFSD: Give delegations their own state shrinker
      NFSD: Pace the state shrinker's scan requests
      NFSD: Apportion CB_RECALL_ANY recalls among clients

 fs/nfsd/netns.h     |  17 +++-
 fs/nfsd/nfs4state.c | 239 +++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/state.h     |   2 +
 3 files changed, 227 insertions(+), 31 deletions(-)
---
base-commit: de7051270554f99559f9b6bcf3c4fb695c7c223d
change-id: 20260810-recall-any-keep-count-f50c2ae1b792

Best regards,
--  
Chuck Lever <cel@kernel.org>

