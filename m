Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A487175A72
	for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 19:52:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786477935; cv=none; b=FZQtZBis1H8qPnMrLvInhlV6LgeB49cvITomjBZnWheKa3ZdqEeb3EpEPJhnV2VBW9VjWCmVgvuAaI9lffiTRPqjem9HnEhV/VTIDPH4Ru0JlM9hAWVDDTmtHsqYNV8gvvuPbaWNXZfrKZZD9bQp74pdc/Q0nTOd91Y8WOQtrRE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786477935; c=relaxed/simple;
	bh=I+phUOQyZAy/ZkFZSO1vrMzuJFcZa9p3AefhZlQXLOE=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=Hao9QJadkyH3yVhdgSwzS8VWdgbqQZvS3Siookudzp4PTY4S+vHIqbEzDv+KqJZ97vlOiI5MgOU8+V9uUNW1FL9ZoByeMrmg7/zvuy4zdbBAFIwTMNiEYhkszMi9pyLlXm2rENJ5NxTtJoIOuZSnr3pIhXRENgmdSWQSmUGqEVQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QtW3cBGi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QtW3cBGi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 728F11F000E9;
	Tue, 11 Aug 2026 19:52:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786477934;
	bh=MIKgUP+qs5Yzmko9CDb0o0ZlY1HuNwmVhruA8LfVdys=;
	h=From:Subject:Date:To:Cc;
	b=QtW3cBGig7Ru2UKJGJ5lU8WOPUlHzso+BbvhjxvCKd9Kh2mBlLZ7ypbtXvRtb7Ux1
	 sZ0+eKPahrTHaCELYZ9kQLVNKGnhiy07PWh/4bBZ2kabnTG5f2HjaL8cmWAHwqPWIz
	 UjP5ucmQYxDOknae2yRPCfNhudVsCUX6XThpgm5YtxO6GIQdHcf9cuCHF/yxRnXJNS
	 7a0cyrWgsvszTuqP4j+wv32rhPcrNOZg0qdPOMx3Pn4Vawp6U6EsQIipJKtId7sDDt
	 +kKozlNHA+98+wx9cnTIjHMs52XjVxcfMbLhuqUet68soMrFuAxANw0pnGdUXAcIHQ
	 Mi8Zn336Sincg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/4] NFSD: CB_RECALL_ANY fixes and a meaningful keep count
Date: Tue, 11 Aug 2026 15:52:01 -0400
Message-Id: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMSw7CMAwFr1J5jUUaie9VEIvEddtA5FZxikBV7
 04Cy3l6Mysop8AK12aFxK+gYZIC7a4BGp0MjKErDNbYozm3BhOTixGdfPDJPCNNi2TsD4as49a
 fLhaKOyfuw/vXvd3/rIt/MOUaqw/vlNEnJzTWiTjupdcOM2sOMsC2fQE+PdjUnAAAAA==
X-Change-ID: 20260810-recall-any-keep-count-f50c2ae1b792
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2309; i=cel@kernel.org;
 h=from:subject:message-id; bh=I+phUOQyZAy/ZkFZSO1vrMzuJFcZa9p3AefhZlQXLOE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqe31k3QNZxPksahqv2LahWU0cKu6ue8osmCX4h
 HhJDFba6HmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCant9ZAAKCRAzarMzb2Z/
 lwSlD/oDC/79Ds2cM94DDzuS9NUer0pr02fw82p7VxJQbY1BShfLF4hJV3WJ9e+nMHsFsV9N51e
 Wq5nLH6ywFpnUZFRG8jR4cvARJ6gVpvWTNWt3tVJz5UJ1YKmpkVQzzzvq2Maniq25prb7tK4sA9
 8Oxtb2XTLw6WH5lsBm/8cXcJxb/fj/5B+w15GeIjflpdnH0LYmgvmACbrhjunlRgDPfawuZDba2
 1xZEyw/dMkSoyxs0lzGFxAtDz5qm738EGkFnRSmPqTIJli18l3DPlPXW9n5bvDbn6l48MnvSJdP
 t7/dRIbOeLv3xF78ZDhf0/6B/eZ4ploPXd+gz62VicCqkdQTk16fhC+S08Hhzgxu4JdSQTBcRxZ
 6Q+SEc289PzcdDQD9ET2X4fywkTbwmOMFSHuTDndHJNBabGez+/s56FWWoC5oTMNzaw2V6y6jHi
 y+XlXBkWc0R8D/FCbQjjxDYmstA2CCSnAR9iij0TT28fN2BfnnhAlYYxdNZN72rSRD1T4svpp26
 oXDqId1Y0dFyO8LsWr5z3ht12sjK+PXvAOw4NFdcCHxGqdO1ESxhaORNwLS47U9FZp/b25nMCU4
 y6uZ+Zgk8Q1lvYZGQyhNC2p2paJE/LyTuJBSOgimP5YhPGx+AJsZZym8TKqvLfzWxxQln3VyUBf
 jxnLFfSeWQ6l5dQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD sends every CB_RECALL_ANY with craa_objects_to_keep set to
zero. RFC 8881 Section 20.6.3 reads that as a request to retain no
delegation at all, whether or not the delegation backs a file an
application still has open.

NFSD meant the callback as a signal to return unused delegations.
Only the Linux client has been tested against it, and that client
ignores craa_objects_to_keep and returns every unused delegation of
the named types, so the fixed zero never produced visible
misbehavior.

The NFSv4.0 recipient bug is fixed on its own so it can be
backported to LTS ahead of the rest. An NFSv4.0 callback service
rejects CB_RECALL_ANY, and nothing brings the callback channel back
up afterward (patch 1).

The keep count comes from a new per-client delegation count rather
than a walk of cl_delegations (patch 2). deleg_reaper() runs under
nn->client_lock, and cl_delegations is serialized by nn->deleg_lock,
which nests outside it, so the reaper cannot count the list. It
reads the counter without the lock and may not depend on the value.

Each callback asks a client to give up one delegation. A larger
request reaches delegations that applications still have open, and
both reaper callers re-arm while their condition lasts. A client
holding a single delegation is skipped rather than sent the old
zero. That strands one delegation per client, which this
best-effort design accepts for now.

NFSD sets no recall target and remembers nothing across callbacks.
RFC 8881 Section 20.6.4 prescribes CB_RECALL against specific
delegations once a client fails to return any. NFSD does not take
that step yet. CB_RECALL_ANY is asynchronous and reports no
completion, so NFSD treats it as advisory.

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

