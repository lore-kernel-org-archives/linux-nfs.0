Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80B8F3EA66
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:40:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786646451; cv=none; b=dRPMT4FwJ+vZx75mdQgXlhfyYQVoFd1NV0+VDCz93xo2nUHBKhQnxzbjhzKazPcjR/5Ele7I/ojJNr9am9gC2qN4XnAXhdBYvTHlbYAtE8tmv0aAkD7YqtjPY9sAvit0cQcUAe6xUJRww7rUDIcJR+hQfKjenueOBr7zzu1zuHA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786646451; c=relaxed/simple;
	bh=t5zipk/N/1SpQiUHJWwZsM4wRUBxq8F6xaA37j75Gx0=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=OuDeLQkxuxCNqc1z0GNc1tQkMiSJTc/1Atuv4I3Yy+XLEJHlmxcI7plnnlXxfJKFvHhGL4NTF0b5hUBaJj4xcxHFNq1OH6PXIBpFlC0q5NuirGRpzDM2017Y27CeRjK4CGouIW/jZNpgC/6SCNKF+mTlZwZZByaDrJesmUnIoR8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Jo+QwpVi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Jo+QwpVi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 80DF61F000E9;
	Thu, 13 Aug 2026 18:40:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786646450;
	bh=w1FotSVmG2rPaLK13Yf30i75TkSFPrFF0xvePOOr9rc=;
	h=From:Subject:Date:To:Cc;
	b=Jo+QwpVi5ii3bW2W/wmEGOJ1EKUK9a8JxkoG+/8v9vYqW/70c+XvKtwdsDgwTuc63
	 N5KhVOeQiXnydyrwhNPE0sw/VmH4f7E294h7PT7pPKZLHcRBGhWFQOa7P+9337Z+N+
	 fxWdM/cke2mp5xiIvFDJUa6EHYbpRZezT5mPJa+x74+HXNDBBE09VYZZ+WZ1eX0jLH
	 XnnAwfT8Q/nvrox3fRiXrBFxoDGWR0VZopb5+ZEmu/hj/FAove2y5b1EkmvBOM+FpZ
	 cZKsOB1Fv8uPwefYq1ziIWOMNm7qZ+IbGtWH6b+Bz3QsBpSSWCTDahWf45YgQ6ZWWm
	 PO/aoUeECHLtw==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v3 0/8] NFSD: CB_RECALL_ANY fixes and a meaningful keep
 count
Date: Thu, 13 Aug 2026 14:40:29 -0400
Message-Id: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3WOQW7CMBBFr4K8Zlp7QgthxT0qFuPJJDFETmSbq
 Ajl7thUSHTB8o3+PL2bihKcRLVf3VSQ2UU3+gzVeqW4J98JuCazQo3femc0BGEaBiB/hbPIBDx
 efIL2SzOSGLutUeXfKUjrfh/en+Mfx4s9CaciKwtLUcAG8tyXE8vw6dvYQJKYnO/KpHcxjeH6a
 JtNUT0zzJuM2YCGRmomrTd1ZbeHswQvw8cYOlU6ZnzV4DsNZg3tsN0wYZV3/zTLstwB+DJwiDc
 BAAA=
X-Change-ID: 20260810-recall-any-keep-count-f50c2ae1b792
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2678; i=cel@kernel.org;
 h=from:subject:message-id; bh=t5zipk/N/1SpQiUHJWwZsM4wRUBxq8F6xaA37j75Gx0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfg+ikXAbFjaXwfrTEzAduneFWXZj/7mDjEK8u
 vblITvs1tCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCan4PogAKCRAzarMzb2Z/
 l3UZEACioJ791dV8d+gdRXNocx+JpDZ4F3ubf8DrWUaLh/YDYGOJHvq/WYL9WCDLBeOL/gq1sQv
 wtzgZMqA2NmoryG4xXcBGI7n4sHs7KZd2AeMSY99s+qmGqZKA/V8pez/4Q9t9Dg1B9A5TG1bapQ
 5UVWA6jnV4+GQ9F077cuMjOjwFErIDSjotuCaBAlXiIusASjXr39f9ydP6ZNr9vhLTYHxAUhRSJ
 4MtAyGIqr63DrjmR27JsM8M3U7NBxS+SXe/T1FOyZaFCHsZCUg4tIIEFd3HcMi06yocMfVXMvsa
 pH3rvbq5tf2axB9HBUznvRf3Sic6cHnwpnaAJ2MyfSx2Bg7hBI8MAgQ7XHk4GaF3CqKbczJq9Bw
 3vRIOA52nmJqDO+oBaGnYYwvbGc7AjLyrdprQPgqp0P1X4TCil0iN/idED0kLZqyl4jsvFnBlwe
 zzqan7S9+tbH9NViB75dcVw3ZZvrj0ggaZK6SYLo/hg+XgoywkAS1nwN+BacAsDGrHw2ZFEbAKm
 sp4tQuOsnCgYDKw3Ddio5BWUGCRcOswBYJLF2LzgAMUKRvhrrdzsysJlCQHUINrRCxh8WjHn93q
 2C750S16p3Jep4T4lz5tsQ9+tNh/fimjmhLVsJ22a/KH2tMLoC1uhyraJtb1rzi5ymndVJZgkmw
 N1QNoUibmWQE98A==
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
 fs/nfsd/nfs4state.c | 235 +++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/state.h     |   2 +
 3 files changed, 223 insertions(+), 31 deletions(-)
---
base-commit: 1d479c6b53f684b27da84ec352b7efb97f7f115f
change-id: 20260810-recall-any-keep-count-f50c2ae1b792

Best regards,
--  
Chuck Lever <cel@kernel.org>

