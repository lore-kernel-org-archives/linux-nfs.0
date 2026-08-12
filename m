Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F84B4562BF
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 15:00:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786546824; cv=none; b=VhVd/SFvsHLV9n0w38U4fCD7N2sbi6+7oSrWl9jjx8K1WMNHb96egCR/ajl6FhujQbeSQFRd3AtNkoDGCMa921YXfq84ODFOl2Y3sn7hCvlYndiYJuRXrpzq2/umsvq7Pli5hMmKbmdmJ6VErTzK8pxDciDloEGhdIG342i2uBY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786546824; c=relaxed/simple;
	bh=eok3CyhHlg6Ahjqls7XMFtcX0LwYiM2dmJeBtlXraVo=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=cEWWOw8V0NtobZUDixuS4P4SJcpP+KEknZBbagcXpHO+3TkuP5w6DMHpo2nH5r6vEVEIho1ZIIuIh+kx415Nf0CGU272w93M5LsS39IkhsNJ11d8531ynDf97iS6aPVI69nleTUJCL2d+ysup529NmdmV9ljfaausbTVxQVt8l8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZUGbaVNw; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZUGbaVNw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ECAA11F00A3A;
	Wed, 12 Aug 2026 15:00:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786546812;
	bh=0RgjFZ/+AqApvNwZTGZ9wWOaE8LWx4eqd8kc3vpCzYI=;
	h=From:Subject:Date:To:Cc;
	b=ZUGbaVNwHLCLyoQ4OGB9lQQFdd3PhdsdTC+PiHwT7Zpf3NFgISGImTRSjE0tTEWcm
	 e/k4bXHLfFTogqUFklEWlK3DdjxB0K92ybklGCEnW3Q0hjjCQd4MnrURVzzhxaMKm1
	 ySONxe1qFgMLS3eVRgjBgFrzUY3Rs4XejMIiKruGI9cSbp3Z7wfyB90EFU82LIwv6z
	 Q+CzsCW8dwr1g52K5cEhlQGzSwA0bnYdWkDGaaVL3dy1GhGAO+5VPYjqOAsVGWjEaC
	 CxLyZ2qouk/XvzVZzeBUaP9hAXmgSzek8YYR3lo+pPa9w9+ST264e1+MrLpLJN7MbO
	 REDQ2CvOJSaPA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v2 0/4] NFSD: CB_RECALL_ANY fixes and a meaningful keep
 count
Date: Wed, 12 Aug 2026 10:59:54 -0400
Message-Id: <20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3WOzQ6CMBAGX8X07GpbfxBPvofh0JYFKk0h3UIkh
 HeXYjx6nM23k5kZYbBI7L6bWcDRku38CnK/Y6ZRvkaw5cpMcnnlN8EhoFHOgfITtIg9mG7wEao
 LN1Kh0Fku2frbB6zse/M+iy/ToF9oYpKlhVaEoIPypkkng+7oKyohIkXr6zRpLMUuTFvbKJLql
 yH+ZIwCOJSYG8X5OT/p7NFi8OgOXahZsSzLB+APfwDwAAAA
X-Change-ID: 20260810-recall-any-keep-count-f50c2ae1b792
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2104; i=cel@kernel.org;
 h=from:subject:message-id; bh=eok3CyhHlg6Ahjqls7XMFtcX0LwYiM2dmJeBtlXraVo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfIp0XrnZVNPJQdlppvL58Tf6zYMKNDslhWops
 1TpQ/K17diJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanyKdAAKCRAzarMzb2Z/
 l0QND/9y8Ejg7On2/q+QwEVeNjmkc1AcR6A4PsVernOUM6CKJFFhmQD26z48mv8hGAObkxZ11CO
 1/xXCFWVdTyI2nMQmC7G3W24X0X3hawrDCpr0Z/bzIrV28P7VPTSjgEr02lNe6wL4Gb26kgcajJ
 JxmdERhbffw5KJTC0IpYK97tWBka86R73rgKfF0WASi8X27cvBvL7aS/jFtxxd5hTlrBOevn9Uc
 ZCdXP+4FcFbnprdPG7urhUgCiEa+eFFp5mPVteYADeK2Mk+BBDm/7EHOK5IizPEt1oNwgyWWxNw
 6ryuQ10mGF16SPhSnAvbbVQxBSlETlpaODXwf4tYhuOq7jh3hbHSU1APWhpuRHO0ciUjswjvtzj
 I/D0xu12Znajp1Ad0c0ciTcmIWUUBpMqmQSCz+dyNK97ChjVgrYfjSvjw/+eumbLzD1JXPstVkV
 VVxkZ35gStmHKeeeyO7wyeOhI5l93uZuBEnrE6/7QubdIa5AOFPNnQZDM1Kng6Yht0BueUUbDPH
 rmkvE5qOAe/gTbs3EuwhRhZAeBUeHNXpiHBlLiEnDE4POlg65l6LgUn+NNKYh7EuYXY1mHqLZy1
 PYWXnHRTUfqSJZn7Av23czmI93EVKM3TXZYz8y+iKlmtvnE9u6iujotolGhxXsbQwrxTE/dHKXg
 gnXIazsgTnSpziQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD sends every CB_RECALL_ANY with craa_objects_to_keep set to
zero, as RFC 8881 Section 20.6.3 does not mandate any particular
way for a client to choose which delegations to choose, if any.

However, a zero value can result in some clients giving back more
delegations than is necessary to relieve temporary memory pressure
on the server, which needlessly impacts performance.

NFSD intends the callback as a signal to return unused delegations.
Only the Linux client has been tested against it, and that client
ignores craa_objects_to_keep and returns only one unused delegation
of the named types, so the fixed zero never produced visible
misbehavior during our testing.

So, change NFSD so that each CB_RECALL_ANY asks a client to give up
one delegation. Both reaper callers (the shrinker to relieve memory
pressure, and the laundromat to cap the total number of delegations
the server tracks) re-arm while their condition lasts.

NFSD sets no recall target and remembers nothing across CB_RECALL_ANY
callbacks. RFC 8881 Section 20.6.4 prescribes the use of CB_RECALL
to target specific delegations if a client fails to return any. NFSD
does not take that step yet. CB_RECALL_ANY is asynchronous and
reports no completion, so NFSD treats it as advisory.

---
Changes in v2:
- Drop the gate that skipped clients holding a single delegation.
- Cover letter rewritten to give performance rationale.
- Link to v1: https://patch.msgid.link/20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org

---
Chuck Lever (4):
      NFSD: Do not send CB_RECALL_ANY to NFSv4.0 clients
      NFSD: Count the delegations held by each client
      NFSD: Name directory delegations in the CB_RECALL_ANY type mask
      NFSD: Send a meaningful CB_RECALL_ANY keep count

 fs/nfsd/nfs4state.c | 27 +++++++++++++++++++++++----
 fs/nfsd/state.h     |  2 ++
 2 files changed, 25 insertions(+), 4 deletions(-)
---
base-commit: 1d479c6b53f684b27da84ec352b7efb97f7f115f
change-id: 20260810-recall-any-keep-count-f50c2ae1b792

Best regards,
--  
Chuck Lever <cel@kernel.org>

