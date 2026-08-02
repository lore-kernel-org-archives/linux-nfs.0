Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B24F73C4B93;
	Sun,  2 Aug 2026 17:04:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785690285; cv=none; b=lUkFS3P7kkQ4cIjmF+MFDbmwrnq5GedgyaehAlM7N6GH2M7te0DjTeL7+4UdMRN0YBVN6CCYb3Ax56VfrbL/4qkwuMMWrkcfkD17RtiHKN5R7AXRHobv6zxnX/plDR6EAvMFcp/atblFv6J4LEVUtyYkZB2DqkQ4RoJHEc/EdrI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785690285; c=relaxed/simple;
	bh=fqJgzrTpQ4Suc86FNUj5U8eh3UTmwSnppt5wZCBD+vs=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=Kn2giOED5TvVH1uG7WXGvM02A0616nsAZNssI9h6vL404hYv1MPLvci8upFxNzYrGyhsX1qW85Vve1OK6IZqtEVO636D9lhNqwkv8ZcHRiQ0iUtVsHU0FPswGmmBO4lk2VBD3rXOr3XBtmGgA713B9fP6PGniluczs/RaX2U7Rk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mxsJEiw3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mxsJEiw3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D5AD71F000E9;
	Sun,  2 Aug 2026 17:04:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785690283;
	bh=nnnABPv7qgeE9oxtox00HOw+wO6rVYdv+mOfxqbQXOc=;
	h=From:Subject:Date:To:Cc;
	b=mxsJEiw3WKjfkzt5Rl+XauL87rSN1W2lCx5UEIFQ9PilXC8UGwaWNBRSR5Yn9aRb1
	 vGfQ84m4pTbZdZFvfhTvqdFCkwZSsae1ixdyxDFFfSh9qSMWybZf6bPMMtuOqOEAg6
	 DTfEZQyithTP5iMnIa8lFIpakpY2jdyLorLSFJwLwG/TyQ6PVyczzz/rH+I5mvmaA9
	 EOr2n8wJoV/Lv23D7ld6IC+c4NdZt8Q2x5E+VvTwUs0pAJYkZ8xxpjXsReDIOD1peh
	 nQw9bmkZ1P2LFvQ51sjaxqM11jvIk7KySHTV+Gg8y9jXjwYHvLHqXcNOKd3jRv1RYF
	 xd+vTyKE0PPwQ==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/9] NFSD: Do not revoke a delegation the client never
 recorded
Date: Sun, 02 Aug 2026 13:04:27 -0400
Message-Id: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWN2wrCMBBEf6Xss4sxARV/RXzIZZuuhFSyqSil/
 25SXwbOMJxZQagwCdyGFQq9WXjODU6HAfxkcyTk0Bi00md1VRrzKAEDJYotpZb5i86GNg2J0Bh
 jL1oFb4yGpngVGvmz6++PP8vinuRrd/aFs0Lois1+6pWndNwfanNzjrBtP5b3/76jAAAA
X-Change-ID: 20260802-nfsd-deleg-destroy-badhandle-333a720dc332
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
 stable@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2538; i=cel@kernel.org;
 h=from:subject:message-id; bh=fqJgzrTpQ4Suc86FNUj5U8eh3UTmwSnppt5wZCBD+vs=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqb3igZ0B9T+cgvFPh0AIUH2/uamRZyeXzNaVKH
 V3zqURjeYmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCam94oAAKCRAzarMzb2Z/
 l8ryD/9tdGxSlrME0jbDADlp/SYZNLT3XhuDx9XAmnmYVIhshSIpz+HknROGCo7VGTwgY604//W
 uJdiEbLaZc7z/lTLIpduPpGiMx220WAN1oCSpNWvfKTO0jPvGovyLTlneXbRHsYB+3rS6HhFWtU
 +wNRWrgYguXemsvT/8+lddFcZsgjg0w0mVflqb7ZWZ4NQ4w7C0tEu9U0L1OxBJnsQNyObxNfHGC
 HeH6sj+xaVPJLhc/6tzhwOWdZ/Bry9xFxIns5MZhKNmRwAvigN47oYBlQ2z7xA93vOizz8olg4a
 k4ilOslXvpmNCEB3fmjFpSsgI8FzWbSyWSnOrx0hPtiI33HLi25Vsd6guuPBeBkNnWPYHlSKjst
 OlzE74mUl90JkgMFR1ABQAl8I0XqVdU6qiCdosg/fy5iS0hjbMlOzlqUd+/xj9EmVUWb7m6NbQN
 XUj8yRCUNLpTnCOxve/q8qgsxhbht2MFKb/TZmPEC+mU6VPQf5nIPs1AideckQZnPpoMYrKmK4p
 Ctz9XnCdiT4iXf7wEJOInKmXKE0lDHT5vOgHXwMct85FEGkXR+YpuR/lzHZagAcx2mIoZOGlShp
 /Du59yhm56j2fjrc38werNlhD3e2VfxBrFoNLH+FF1uBKlCxuSfX22LG9fk9v3y6OrbkqzqUfLJ
 bSGtsb4kMMBYLuQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A nightly backup on my home directory server ran into this. NFSD had
granted a write delegation during the day, and the client lost that
delegation to the bug that "NFS: Return a delegation the client fails
to record" addresses:

  https://lore.kernel.org/r/20260617125257.1293452-1-cel@kernel.org

When NFSD recalled that delegation, the client had no record of the
stateid and answered CB_RECALL with NFS4ERR_BAD_STATEID. NFSD added
the delegation to cl_revoked, where only a FREE_STATEID drains it.
That FREE_STATEID never arrives, so every later SEQUENCE reply
carries SEQ4_STATUS_RECALLABLE_STATE_REVOKED. The client's state
manager loops issuing TEST_STATEID but never finds the missing state.

A delegation whose recall the client rejects is now destroyed rather
than revoked (patch 8). RFC 8881 Section 20.2.4 mandates that the
NFS server complete the delegation recall in this case rather than
marking the state as revoked.

There are some complications, of course. CB_RECALL can outrun the
reply that granted the delegation; a rejection proves nothing until
the client has seen that grant. RFC 8881 Section 2.10.6.3 makes
retirement of the slot that carried the grant that proof. NFSD
retries the CB_RECALL until the slot retires and revokes in the old
way when the retries lapse.

The series also makes CB_RECALL the second consumer of referring
call lists. The CB_RECALL send buffer budget has to be correct
before a referring call list can ride in it. Unfortunately NFSD's
original referring call lists implementation got some of the XDR
sizes wrong.

---
Chuck Lever (9):
      NFSD: Budget the CB_SEQUENCE opcode and referring call array count
      NFSD: Budget the CB_RECALL truncate field
      NFSD: Budget the CB_LAYOUTRECALL recall stateid
      NFSD: Budget the CB_OFFLOAD opcode
      NFSD: Budget the CB_NOTIFY_LOCK opcode
      NFSD: Budget the CB_RECALL_ANY opcode
      NFSD: Correct locking documentation for delegation sc_status
      NFSD: Destroy a recalled delegation the client does not hold
      NFSD: Send referring calls with CB_RECALL

 fs/nfsd/nfs4callback.c |   7 +-
 fs/nfsd/nfs4state.c    | 228 ++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/state.h        |  24 ++++--
 fs/nfsd/xdr4cb.h       |  20 +++--
 4 files changed, 231 insertions(+), 48 deletions(-)
---
base-commit: 106c31f3d72c56fce98bb2f0e8b3de1a0024228d
change-id: 20260802-nfsd-deleg-destroy-badhandle-333a720dc332

Best regards,
--  
Chuck Lever <cel@kernel.org>

