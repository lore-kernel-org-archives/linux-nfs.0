Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F170536680F;
	Thu, 28 May 2026 21:55:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780005327; cv=none; b=MQ1wMDfOCmvr2CBIydbm/FF9ytmNokmj5zSPYR9lbym7F4dySSpCA3mN5pKTJFaBNbAEHEIzsvBbuX5b8O6UNcio9Ic2goXTuzXFbGMDm9eYknaQ83Vx4GtT81gsGKrZXpll/iFNy+tkD1kbaPGJ+qToYucS7BT/RamazChLBdY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780005327; c=relaxed/simple;
	bh=gjb+t+GFGwIAMLWc+fx9UrSt2NhFCH00LIf4QSFacFs=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=A/W86jzEyDy9amJL1LI4VVRCHPjXQsDRWxrVdEbfK3tDNeHRX5jydL1aslzdLztXEz2T7l08k2OY6G6QVTdnRH12HxR3ey9LQFTc0k2NE0qy+C+oGfIosH3hRtnuvaMQFUDIpO6Z1sqsQ+VXp9nXnqS155S8KjH7fe0aptpGpZ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QvnuxL64; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QvnuxL64"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B25A1F00ADB;
	Thu, 28 May 2026 21:55:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780005325;
	bh=KpoUz9yFGQSS59AaDRB7126bXm8z4UgOxHiX7K8JR5E=;
	h=From:Subject:Date:To:Cc;
	b=QvnuxL648xjwtLjFU8FFMsoy7+zmyK+D5T4f9xjatfh/NDTx+tFR0256a7fs6Gmeb
	 HUUXs8cd0uJaRFIL7hdkLia1y3PWr1jO4rJHdT2W9mW+GXoCIcczpoFFlLBPfZ0ImQ
	 tFArQjeoQMgm4jpm/07mLEDBDPAqSLpIAp97nTOc6A87FxKv5NFNfqAfmUjaitZJDx
	 EQPyX42UmvWZ5EHhtMn8l5ZznMBuMzfHwjqDMsQdJE6PDsbCCDnZrNQcxrgVc8n6Td
	 vPJ/lbKX1pY53pFYpQtEtgg4/z8WqDg2cPSEMoyl4EDlvmypDk8aGrXe74R2bLWYM/
	 bmfac59fj2PDw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 00/10] nfsd: a pile of fixes for random bugs
Date: Thu, 28 May 2026 17:55:11 -0400
Message-Id: <20260528-nfsd-fixes-v1-0-e78708eff77d@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x2LQQqAIBAAvyJ7bsEERftKdAhday8WLkQg/j3pO
 MxMA6HKJLCoBpUeFr7KgHlSEM+9HIScBoPRxmlrPJYsCTO/JOjD7siS0TEkGMNd6RejX7feP/X
 5+BpcAAAA
X-Change-ID: 20260528-nfsd-fixes-89a6e5e20c9d
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>, 
 Scott Mayhew <smayhew@redhat.com>, 
 Trond Myklebust <Trond.Myklebust@netapp.com>, 
 Andreas Gruenbacher <agruen@suse.de>, Mike Snitzer <snitzer@kernel.org>, 
 Rick Macklem <rmacklem@uoguelph.ca>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1970; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=gjb+t+GFGwIAMLWc+fx9UrSt2NhFCH00LIf4QSFacFs=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqGLnFhSjWaI0mR6jpfPxewP9lAAv4vRRSzJb7J
 vE239IdureJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCahi5xQAKCRAADmhBGVaC
 FSDuD/49eSIN52VZ6abSjV2eD6Rto/oxxs28ZWNIcoiUbvrsdZPIuWgBIqp9JMS5NkVVC9cMJz5
 HeQtAfpiPPZuDH2AMwlQhJP8kpCGvzW7qsb2q0gxN+B46GKbbsdA4jbyOVucSrLmTzUxoFo2cPT
 JOzQvkphvK90mGR+1X3Yp+D9v34J8CHYEmGDjidOlZlDuWwSR68cjdaF+rzNFO7JTlIPaFXyNYQ
 qbLziyo/zb3X8AWafQ0vsxy4pN/bD25ZcicjE6byEjVL36c65a+THho7Ion9zcPtvfMAe/Nl/4J
 1X2WDZ0b3/4tzeVAjMKu9V4FCqp3WVQCxCoN3ZIpUci6OTK0N+lPmRau3yv2NVXr4WLscWCjkjZ
 NV/Qo6VBvJ9ih/bV8f+lvSV0K1mryn3sDi4GWmAMF7bVFiVeIZP57hfLjtb1l53+KxpLhZ/lIlU
 b5SadhuE7GA8/XShpP4SLCx+stnKfUyzqXiEkJ5Xgw2YSGc5tB5Yf4vZd4htpl0PIdCDv+giTcN
 GJDG5zW7xQDcTDPZZtAklqNUuWsEkcS6TKwSXcpu08bFA+USfetwDMKcQlhDrX8zoasOjU6FKEV
 Amjw3BNeZhGGYdrCqBXPIvrI6sijblhpmnalsEeOensw0YQTUCGQyk781Su8ySOMVp25o3EA7rZ
 jmw+Hx6wnoWgrPQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

These bugs were categorized as remotely-triggerable panics, UAFs, DoS's,
etc., but they aren't reliable. There are also a few protocol fixes in
here too, etc. It's a grab bag.

A few of the patches were not authored by me. In particular, this patch
was submitted by Chuck a couple of years ago:

    NFSD: Enable return of an updated stable_how to NFS clients

...but Claude believes that this fixes a real bug and isn't optional.

The set passes basic pynfs smoke testing.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Chris Mason (6):
      nfsd: drain callbacks and clear cl_cb_session
      nfsd: serialize nfsd4_end_grace() with atomic test-and-set
      nfsd: dedup nfs4_client_to_reclaim inserts
      nfsd: gate nfs3 setacl by argp->mask
      nfsd: fix partial-write detection in nfsd_direct_write
      nfsd: cap decoded POSIX ACL count to bound sort cost

Chuck Lever (2):
      NFSD: Enable return of an updated stable_how to NFS clients
      NFSD: check truncate permission under inode lock

Jeff Layton (2):
      nfsd: fix BUG_ON in nfsd4_alloc_layout_stateid on racing delegation revoke
      nfsd: validate symlink target length in NFSv4 CREATE

 fs/nfsd/nfs3acl.c      | 17 +++++++++++------
 fs/nfsd/nfs3proc.c     |  2 +-
 fs/nfsd/nfs4callback.c | 21 ++++++++++++++++----
 fs/nfsd/nfs4layouts.c  | 12 +++++++++---
 fs/nfsd/nfs4proc.c     |  2 +-
 fs/nfsd/nfs4recover.c  | 16 +++++++++++++---
 fs/nfsd/nfs4state.c    | 52 +++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4xdr.c      |  6 ++++++
 fs/nfsd/nfsproc.c      |  3 ++-
 fs/nfsd/vfs.c          | 46 +++++++++++++++++++++++++++-----------------
 fs/nfsd/vfs.h          |  6 ++++--
 fs/nfsd/xdr3.h         |  2 +-
 12 files changed, 142 insertions(+), 43 deletions(-)
---
base-commit: bbe29ec5b789b9e613170cf0d869260c9128e1e0
change-id: 20260528-nfsd-fixes-89a6e5e20c9d

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

