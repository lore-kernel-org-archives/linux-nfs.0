Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549752;
	b=jFbgjGuomnpDxsexJIPl2/D0U9w7MnKSq9JeaKFGLwqrqW5dQEO1H/GWVNT+Z6je1czS
	 vc6llCyYhdhao2Y3rI7xcoAKvhJt80iyt+ZWHoFNM1W3il7l5Ply2NfC9U6Z4LPBV0hx7
	 zkxX9ZWxfrbtzcXMcls0RhHhPwnp2pUFakJhwjaN2M4KGx1S1DIioT7ba/unQ/rJ/MyrZ
	 TMgbX3ybyVBwRhYmZMuRraEO7za8QTYQ4pw9jS+U7BcAhsvjkP2ytBFWvb39fRZxd+Eve
	 zAiuE3nQ0Zt8q20Z4GUay2vVPKluU9mjFtyRYbsR6lepYxpcubnZBs0sJkvzSgzrRQQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549752;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gTzK+s6Y3xM+ihVOyEyoikGdVd1xvoW3//Ffc7sCTvk=;
	b=04xMM2/vnZ/adkWk+PKE6nLj6rwedwxgAhkwjSqDX6zKL/R7FE5gQZbP5rugRHJjSRWT
	 hS8pOBhazwO5YOKItHblo/e1aJ23pXQEC6gWYez/J/nv1l2H1v+LCUoMr7BaFs/0hlLbJ
	 /DXVuyZyKRxLwvVuSIQ5Q7RHuSkoevAJE1fk50/SvFmSp4qUbv2HK6cWoE71Y9Bamv0LA
	 9yKkIq5Y/DIytoaqvouqPijabheHOboteBosYyKUhfWi/07UskyIywkVDwSgdBBnAZsA8
	 iru8LdPCFHcrX3niVyW17fOZ1c70v2lfha9sUd7I/6B80194VCpwRHxymjYK0iuleSw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="BYSo9bL/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C105E606A334;
	Tue, 24 Nov 2026 19:49:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BYSo9bL/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D54141F000CA;
	Tue, 24 Nov 2026 19:49:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549752;
	bh=gTzK+s6Y3xM+ihVOyEyoikGdVd1xvoW3//Ffc7sCTvk=;
	h=From:Subject:Date:To:Cc;
	b=BYSo9bL/UKfGI54+q3UcQgEsSFHrokcRnqSsdHq0tMi4ej3wGy0bjjzIUUGx5zSk6
	 ZQOmjmRiOgRQya6EdjWxc5edoCDrE7ivnKblKqTuafiCEZ4avR0WKJg7DQM2yN1lhu
	 S1axrVyOUnPZNpEoL8E3JiNv7G8L5v7tpRtkjpy276k70/l48bZG09G6YsTx1/L4rC
	 1YfjOdeBvIx3zX7wgwj/ya4z4onHBI4jfxCkM/M4KSyq/72xDRAgAgzv/MBndKnQSs
	 xlH2nuHXdqWfvz0jfrBS0UjVzrgPTHNydtHVYpaW+pyiDpFff2nk66S5RA2NB6aGmH
	 HW7FPeRynlqmw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v3 00/12] nfsd: various delegated timestamp fixes
Date: Tue, 24 Nov 2026 14:48:39 -0500
Message-Id: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3XMQQ6CMBCF4auQWVvTTg1QV97DuJDOFBoJkJY0G
 sLdLazUxOWbyfcvEDl4jnAuFgicfPTjkIc+FGC7+9Cy8JQ3oMRSKZSCuOd2jsL5J0dRmVprRUZ
 R7SCbKfD+yOR6y7vzcR7Da88ntV3/lZISUtjaNLoipFOJlweHgfvjGFrYUgk/uf7lmLkppWXpG
 nRMX3xd1zdfY7L16gAAAA==
X-Change-ID: 20261120-delegts-fixes-798331d91d8f
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2930; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=yXYKQP9cyLOuBOT5cFrb98nKOREgRgqnzEb5yiJYNFQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeovsCzxJN34YJPmJD1u/ybeDN000fFXz09XW
 3lFpKWWTgCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqLwAKCRAADmhBGVaC
 FeNKD/0V8GFri/Y26mIvT1JglaYLV6MBfOeaOQ/Ld5KuDoVvkkik4c99mor1lvasuhhrSFx+YO+
 WcWwUtHnU9FrwZ60ASCUiHEGsHgMwejWKw1FScGMZK0Hpy5sTAhK81N2rh4gXoHhq14Z788EqLK
 LoNL9Iz/nLphZNxr3V9QrVZ5uJ15tXFPlDiewbksmRkMi7E0rzrdoqE5iPQXKQFSFAMea3fjRRX
 zVmdKbnWf0HjwJoi+txNyb9pDOwaCC+hxvFYL2ZLj/BZxxzsQuq3S0aJXiU4Qy31uYM3+Ol31lv
 gQE08luxPSwAmTD99jnemhkUuJghDak0JpcaaIxiMOZ2ugbExGYBHt8SKEQ0ulC/7uF3zXUOZR+
 giW0pwy9XQOtSGmV6d4F7WJh5jZds5T9taNtAzwN+63ajDD4+yYsMcPUYjTsgre95YGLwjdoiIz
 j3R9eHT4YDbT3Zy94jBZJo9TYOcFdrCBd2+8dxnS7ThZAeOXtIN0AI805uASAtg8Cvj6u5vKO4Y
 4q1mKszqlWLgirn6Ez3XGH6w/4ZW5gHAPbXrAb2Dc3HNeaa3dvrZSw5LQFDcm2u3op/EOPyZozo
 s0lFzrJsBX6JT59TLcH7joBbQZRIooWBlQ3bX8qBg7MUv/0/dK/9Z1tKwt27AGxp/40ucDL9+xk
 jjlVI7wLUcAYAuQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

v3 fixes two problems in the v2 freeze protection and SETATTR ctime
patches, and adds a patch for the same ctime bug in CB_GETATTR.

While I was reworking NFSD's delegated timestamp support, LLM review
found several bugs in the existing code. This series fixes them.

The timestamp rework is still a work in progress. These fixes can go in
ahead of it.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v3:
- nfsd4_finalize_deleg_timestamps(): wait for a thaw on DELEGRETURN
- vet_deleg_attrs(): set dl_setattr on any applied delegated mtime
- nfsd4_deleg_set_times(): likewise set dl_setattr on an applied mtime
- new patch: move ctime when CB_GETATTR applies a delegated mtime
- Link to v2: https://lore.kernel.org/r/20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org

Changes in v2:
- nfsd_setattr(): sanitize a fresh copy of the attributes under
  inode_lock on each attempt, since the setid bits a chown must clear
  depend on the current mode
- cb_getattr_update_times(): pin fi_deleg_file for the mount's write
  access, and skip the update once the delegation is unhashed
- nfsd4_deleg_set_times(): set dl_setattr only after notify_change()
  succeeds
- add the missing Signed-off-by to the nfsd_setattr() inode_lock patch
- reword changelogs and comments
- don't use ! operator on cl_minorversion
- Link to v1: https://lore.kernel.org/r/20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org

---
Jeff Layton (12):
      nfsd: don't hold inode_lock while waiting for a delegation in nfsd_setattr()
      nfsd: take freeze protection before updating delegation timestamps
      nfsd: count a delegation in cl_delegs_in_recall only once
      nfsd: don't grant write delegations to NFSv4.0 clients on CLAIM_PREVIOUS
      nfsd: set ctime when a SETATTR with delegated times changes other attributes
      nfsd: pin the client while a GETATTR holds a conflicting delegation
      nfsd: recall when a CB_GETATTR reply omits the size
      nfsd: apply delegated times in a separate times-only setattr
      nfsd: grant a plain read delegation when timestamps are wanted on a read open
      nfsd: check fi_had_conflict under deleg_lock before hashing a delegation
      nfsd: take the write delegation grant stat before hashing
      nfsd: move ctime when CB_GETATTR applies a delegated mtime

 fs/nfsd/nfs4callback.c |   1 +
 fs/nfsd/nfs4proc.c     | 171 ++++++++++++++++++---------
 fs/nfsd/nfs4state.c    | 313 +++++++++++++++++++++++++++++++++++++------------
 fs/nfsd/nfs4xdr.c      |  56 +++++----
 fs/nfsd/state.h        |   2 +
 fs/nfsd/vfs.c          |  62 +++++-----
 fs/nfsd/vfs.h          |   1 +
 fs/nfsd/xdr4.h         |   3 +
 8 files changed, 426 insertions(+), 183 deletions(-)
---
base-commit: 194069b5ff38d82d302c33a4dd280d948c96cfe6
change-id: 20261120-delegts-fixes-798331d91d8f

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

