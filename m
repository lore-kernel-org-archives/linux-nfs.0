Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2642433F8B7
	for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2026 19:22:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781896971; cv=none; b=jZKIJavI70axVlT9yRXhZ0caIHZzekG1nJmTcRL9MaxANCArqkHBw7qNVw2XGhLc4TOPDD2N0uHEvDOj8gQe7iYJad3OLhdFNcscfRmfsYAp/VPu9U+Va4h95IYxyBuIc7IolYX5LHlngkSRS+Ey/7/PKgHB0clhseH6qjFAC1Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781896971; c=relaxed/simple;
	bh=z8jx2zpFCG2NB80pAo0IqGjGWIZPZwjQ4ZDKXPcx+oo=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=CL5715rthHK1RoZX2yO/v/EjwNBmNQGnr/kGH07f+3lIMUOjfr6HTxoNKnO2XL/GxWXnN8s4wmzSl3sBEAgzrShBxloG3tpCnUplDl+IUk+n151P+ExOYUJfuWBcxZoC3CXxV/DidD0QdPT3ksCD4j6C/aPxuhEuGgz4XkUl1ts=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HeKRCDcN; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HeKRCDcN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AFAAF1F000E9;
	Fri, 19 Jun 2026 19:22:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781896959;
	bh=DJTotpZhoblzjMQvl/lF1p8iFX7lPlYNbL6OBuJcLgI=;
	h=From:Subject:Date:To:Cc;
	b=HeKRCDcN+YLPiVdFCd98XYeDxsIrUiNcciKHtioMi7oE2rDqdAdpn09XNI5yRkCPh
	 XuJQe1fuIr7UwHUdbUb8CWSM8CrwZWNJJA7rSvIch5X4vOhe5xufQhUZB2WczEQiIR
	 ISpG06XpVWX63jaFlIWVNrfzOYzkfCy9rhqtE1Im/mtKn8zKiJB6sNhabnrag55drk
	 DalsNhdr3c+jXZv+ecEvhuPC/Dvrk/l9dLZN1r8Y5HdU+5a9QuBQ5DN8JAMJHj/N/t
	 PhD20vxMwM2mEnCn+W3rWXLKU4LoGchakVDEPb8bs5l2ReoimeS2sjaLHgMISKCh6L
	 II2g5codJl02Q==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH pynfs v3 00/26] nfs4.1: add some directory delegation
 testcases
Date: Fri, 19 Jun 2026 15:22:19 -0400
Message-Id: <20260619-dir-deleg-v3-0-1077ce8aab1b@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/1WNyw7CIBBFf8XMWgzPPlz5H8YFlKElNrQBQ2ya/
 ruEVV3euXPO3SFh9JjgftkhYvbJL6EEcb3AMOkwIvG2ZOCUN1QIRqyPxOKMI9HMCNkq14lOQfl
 fIzr/ra4nrFtwCV7lPPn0WeJWFzKrZZVJ2p5kmRFKlBz6vkNtWm4eb4wB59sSx6rJ/ISy5ozyg
 jptFaPWqF6yP/Q4jh/IqnOi5QAAAA==
X-Change-ID: 20260331-dir-deleg-a1b3475f8385
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Scott Mayhew <smayhew@redhat.com>, 
 linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3483; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=z8jx2zpFCG2NB80pAo0IqGjGWIZPZwjQ4ZDKXPcx+oo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqNZb07zF1eUp+mHLLI0tTyCRib8g6Mk/PP9Vzd
 enYeAoHjiiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajWW9AAKCRAADmhBGVaC
 FSgcD/9n2VxkJdas0yfasJVJ7hrY5CqkGWWjWP2rD7EZ7YIJ8Dpg1YJwevxKMLzB1L/S05M/Xlv
 Xl2PsRgP1JzvUGajB8PmJ4yivkfox+DicLx7eM3vKhubBgfCWDeHnZOzUbQ2WJOe7Uif2QcHaDM
 XeQI9FTSiIUZRD01eO6RjSubm0yI2u8FRnoJTC6LuSdwaucmcrjeyCkfSyfWyFxV6fTFVXE95N7
 vSLZKKRzhyHDF76QtY5iOUBSJ6keNj043uVBH1wOsfC+du84TdqOjhaRI7OpdHPumxaYZf1I6mf
 4K8u8wKO2n07eSMO/wDRPgBA0H5oTRzCpOTw/Uo+HWzzYwC/A1LFjF1eGyeAb/iWOIdlNz3W1dL
 Bzm42DEfDIkDRqliRVZbB7fhoQymn0cjHBrySR6rtcARYLa5CReWOaHzPhuT/SNo3sTLTMrwVwH
 7mPfZEVhbxnRTpz5AHk5/G1TeQP4xp7C9QjA+BadVtzFxY/WZdGqZv1KvPLwSAuBs7MCviQyHdK
 eaJaG91UNr14YXFzHkIUBfYpSkLW3XRRoY5BDJcTkXq1OtuCEAi/zGAoi32Lt3qjL4/jc7wYice
 5Fx3Dm7GH+a+C8UQpmIFYzQM8PT35R9+fEA7Y1fvPFt7s3wZItXYFuIb3ySzncgt9l5o9y7JUrb
 LFhmYIU0w1TcD4w==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Long delay since v2, but the CB_NOTIFY patches only recently got merged
into Chuck's nfsd-testing branch. They're currently slated to make v7.3.
This version of the series fixes some potential state leaks that Scott
pointed out, and adds a patch to make the output a bit less chatty with
normal settings.

Original cover letter follows:

---------------------8<-------------------

This patchset adds some new testcases for directory delegations.

DIRDELEG1-7 should pass on current mainline kernels, with recall-only
support. The rest require CB_NOTIFY support. If the server doesn't
offer notifications, then the tests pass_warn (so there should be no
failures in those cases):

    https://lore.kernel.org/linux-nfs/20260416-dir-deleg-v2-0-851426a550f6@kernel.org/

Signed-off-by: Jeff Layton <jlayton@kernel.org>

---
Changes in v3:
- Ensure we clean up state after tests
- Demote some extra-chatty messages to debug level
- Link to v2: https://lore.kernel.org/r/20260416-dir-deleg-v2-0-fad510db5941@kernel.org

Changes in v2:
- Added more tests for CB_NOTIFY behavior
- Link to v1: https://lore.kernel.org/r/20260407-dir-deleg-v1-0-54c998eab72b@kernel.org

---
Jeff Layton (26):
      nfs4.1: add proposed NOTIFY4_GFLAG_EXTEND flag
      nfs4.1: add a getfh() to the end of create_obj() compound
      server41tests: add a basic GET_DIR_DELEGATION test
      server41tests: add a test for duplicate GET_DIR_DELEGATION requests
      server41tests: pass_warn() when server doesn't support dir delegations
      server41tests: test remove triggers dir delegation recall
      server41tests: test rename triggers dir delegation recall
      server41tests: test mkdir triggers dir delegation recall
      server41tests: test link triggers dir delegation recall
      server41tests: test no notifications without GFLAG_EXTEND
      server41tests: test unrequested notification type triggers recall
      server41tests: add a test for removal from dir with dir delegation
      server41tests: add a test for directory add notifications
      server41tests: add test for RENAME event notifications
      server41tests: verify child attributes in ADD notification
      server41tests: test CHANGE_DIR_ATTRS notification
      server41tests: test mkdir triggers ADD notification
      server41tests: test DELEGRETURN stops notifications
      server41tests: verify filehandle in ADD notification
      server41tests: test cross-directory rename REMOVE notification
      server41tests: test cross-directory rename ADD notification on target
      server41tests: test link triggers ADD notification
      server41tests: test same-client changes don't trigger notifications
      server41tests: test cross-directory rename-over nad_old_entry
      server41tests: test within-directory rename-over nad_old_entry
      nfs4.1: move a lot of log/log_cb.info messages to log/log_cb.debug

 nfs4.1/nfs4client.py                  |   42 +-
 nfs4.1/server41tests/__init__.py      |    1 +
 nfs4.1/server41tests/environment.py   |    6 +-
 nfs4.1/server41tests/st_delegation.py |    3 -
 nfs4.1/server41tests/st_dir_deleg.py  | 1117 +++++++++++++++++++++++++++++++++
 nfs4.1/xdrdef/nfs4.x                  |    3 +-
 6 files changed, 1147 insertions(+), 25 deletions(-)
---
base-commit: cd4701827a8261fedbfb4c6e39029fb9671321a6
change-id: 20260331-dir-deleg-a1b3475f8385

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

