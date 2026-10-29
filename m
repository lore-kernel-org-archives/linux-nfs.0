Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793275825;
	b=3aJW4l7N8Co5LnJnOHLgbwGnfnyVTFdcZ57fdN3ghPWJoVLoDF8BFSXKZrC0VQ83DqIE
	 185nGASUVpOLi0fNXTXEwCnFGk4liVAsTleaqk59kbEI+E4Yv0nRJhlsz3C83ndonlGQI
	 s+d5RZ7Y18zsME1FEXPBBHdApj7lRUK/o3c6rEPs0AgDmYV32leqPMlehzBrqpEI8bY8r
	 77xht1gRcd0M79MUUAHqFJ6wEQkyLMNeBAz3jAC8/uGyrUUmPNsC8KxF2TWhrTV3eeL4e
	 XmfMMql78XXW5wbm84xGToeVotXFOBTA8/RuHHAJTNTyBNizH+3pg0DYlQsZ94Cf2fw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793275825;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=QR1i+yww90bVu0i+4wVLQKrdMbTQqUVkz2XMMpA1+Ik=;
	b=l5Ko3Tvvv+HWBDTcVENEbxYW+PVa11epIiPRYYZO6SXun15rWqQEb1JuPjjZwG5ONyNN
	 k2+ZOi1vFH/cyHlj0FoT6g4ldS8LchHC4iyo6e50r9Vu5Hr1BfLx1tr55Ttb2dVl0YOvW
	 GPEFTWgXn/vywC5o/Q8+P6mwwOroaV0jxSu5ShRqYCZ4q9Bxjbxpy8W9hEeBwyK9j9So9
	 NKtv+T7YW1sPjInWw2aReSjskR+4cp7YTTxx8mVG2PSD5X5pdNznJ94xR4uIYFmg1J5Vh
	 3B03IVRl8dfKsUOPL5Xad6j3iFyxg5AMg/R+H2g/fkeatozRD7ceSVc1q6tlsXMJwOQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QE8ItHK6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25365606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 12:10:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QE8ItHK6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2BEBD1F01828;
	Thu, 29 Oct 2026 12:10:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793275825;
	bh=QR1i+yww90bVu0i+4wVLQKrdMbTQqUVkz2XMMpA1+Ik=;
	h=From:Subject:Date:To:Cc;
	b=QE8ItHK6sA+W5jFRJR60BS+Es8SWUSiMLMoXhVRabg7cYOFxjD3xM/+jysedqHaCq
	 qr4/s6YsYU2rz85FYc489rz477GUZJYj0rb6ipmgcDWv0mdsVqSAy6vaV/eBIUOzmV
	 WOLYKD1UnGMeTElcvXsK14VqPl61T3+w66cz9x7VZU6qGgTXBp45MSBkZEHm7LRRGv
	 1dtmSjnOx1LgN84zRnChZOmT0vo13WyZOA1/fpEneHGRM45W51UEBk8SvwSavlYprO
	 EHK1g2PUIgNuWxj/++aFpXMmgSKeqm5pm981VVED1PS1TYbrEIOlKmUlu+CkkAFTPE
	 XdSYBu4c6KraQ==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH nfs-utils v2 0/4] exports: add support for new read_io= and
 write_io= export options
Date: Thu, 29 Oct 2026 08:10:07 -0400
Message-Id: <20261029-master-v2-0-32bfc6ac16da@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/zWNQQ6CMBBFr0JmbQ0t0qor72FYFJnCRCxmBomG9
 O42GJcv/+X9FQSZUOBcrMC4kNAUM5hdAbfBxx4VdZnBlMbqUh/Uw8uMrNrah86esHLOQJafjIH
 eW+gKMYh6zTQKNHkaSOaJP9vFojfhVzPuX1u0KpUNOjhf1f5YtZc7csRxP3EPTUrpC7Mnj2uoA
 AAA
X-Change-ID: 20261014-master-b5afd69e3772
To: Steve Dickson <steved@redhat.com>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2274; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=NGzXvq1mp3+chR8mzG3UYuV+RtQdw927IiH1KCV92VE=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4zeuwZLmety9+cxoFEqfHMfirHLq5n/8aMzxs
 2eDbYG5VdeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauM3rgAKCRAADmhBGVaC
 FacGEADWkovF3wA7Q8wo+8ELsxfOEk/Tgtbuxg38s881mjL2XtXvTOkhQiSfRwU54uY7NivZb6F
 y9NddgKMtVTWHmY6JE6kwyS3IOaz6hFoAs+i4RJ/HIinkk+42xF+9Xi2ktFwxoe13dmm/NmFJvw
 0KhcnjJ5uWasoRVSVBzRm6Qcb6BA5/fha3XSMvCCWTqiYNX7aSzc7DLfjWdWDd0vXOjfxIJl8eP
 d2WA5i8RWdYgcwl7cdt9g5/37mqFRwoVqVAINQj5Ob7EL+Sl4P/qNxDCkX+UnEg7pRYuVXCnyAO
 rHssz8usYvQajvjDb9yGka6FC7f1aJ+IWk/ZoFc5R0IEwMEgka8Qq+yWWDkWh4osHcwY10lEVuA
 txs6fiQH7M3NFT+T5fwCNs3ju0YmfItujjpsPzyoXogQ7XJ9fSAk+hoVhbkHxbOTQ5BSsQbbTMW
 6svGHVlsTLY/zbcjjgfbUhPiij9WuqJii1XPqurIzk9wNC1cXJYW+XhubzdfntIyWD8uljy7Fg8
 Z7oij91I/9hVa70hyBfOUzr/RmPqbmYNOdTGMh0SdmM+kfiSEbvf1u8JG81vNLzEgfq05vWnZBp
 XHKJd0saor0eMbA8emvUDLM//ZoyrHOrzAouBlOxXhmtq/QzTAuvFtp0+AnNRmiLy2una3KFuWo
 /PTx0vlSR6sxoxQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This is the companion patch series to [1]. Chuck suggested we change the
export options to read_io= and write_io=. That's the only real change
in this version.

The last patch in this adds a new nfsd-iomode-advisor script that
watches various stats on the server and advises the admin what mode to
use.

I consider the advisor optional as it was largely vibe-coded. I'm not
sure I'd trust its advice that far, but it's probably better than
guessing. I did test it on a range of different machine types and it
seemed to do the right thing.

[1]: https://lore.kernel.org/linux-nfs/20261029-export-iomode-v2-6-fe8ec6251a36@kernel.org/

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- Rename riomode=/wiomode= to read_io=/write_io= to match the kernel series.
- Link to v1: https://lore.kernel.org/r/20261027-master-v1-0-6f1f7a35a83b@kernel.org

---
Jeff Layton (4):
      exportfs/mountd/exportd: track the svc_export policy highest attribute
      exports: Add read_io= and write_io= export options
      exportfs: Display and document read_io= and write_io=
      nfsd-iomode-advisor: recommend read_io= and write_io= for an export

 configure.ac                                      |    3 +-
 support/export/cache.c                            |   59 +-
 support/export/export_policy.c                    |   29 +-
 support/export/v4root.c                           |    2 +
 support/include/exportfs.h                        |    3 +
 support/include/nfsd_netlink.h                    |   12 +
 support/include/nfslib.h                          |   14 +
 support/nfs/exports.c                             |   51 +
 tools/Makefile.am                                 |    2 +-
 tools/nfsd-iomode-advisor/Makefile.am             |   14 +
 tools/nfsd-iomode-advisor/nfsd-iomode-advisor.man |  232 ++++
 tools/nfsd-iomode-advisor/nfsd-iomode-advisor.py  | 1198 +++++++++++++++++++++
 utils/exportfs/exportfs.c                         |   34 +
 utils/exportfs/exports.man                        |   22 +
 14 files changed, 1671 insertions(+), 4 deletions(-)
---
base-commit: 0ed4324cbbb8020039d338d597c1422a980f7085
change-id: 20261014-master-b5afd69e3772

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

