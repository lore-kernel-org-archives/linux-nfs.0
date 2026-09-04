Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 582E94AD4AB;
	Fri,  4 Sep 2026 14:17:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788531465; cv=none; b=FXiKt12fHh3KPCdXlkWmVRaGUWQ7rOPbmFoMkfhPq7pq0BBWzwvyjPH3QZyJHiUlyLzeoKW0sKEx6wz08Cu3zlJqDqxNno3JZgZSk4DwBIQRrAEjhavvvtArK2YrV1/LXC3IcRFARnWVBH2VM5pwx3YKr/o34sf5uOFLIfcZ1Zw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788531465; c=relaxed/simple;
	bh=wBMrjl7+c1YrjhibX59dHjem/Uo9outGY8u/9APmJGo=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=h0Oi5hKatTEpmEhfiRqNR2Ru9MMo8TP3FSxOFrhQ+pxKe082wAF1TUeFcC1BW6tPgHsYsJv5JL3heUKPmaQAQWOUPiXNuWGLPq5bQnEslrzjx1gHHMjkSLo9yoBdm4YC34fuSr0UIS2pfPa4rAAK6oDBmlksh9T94RrWvbUpFk0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=n7qfsvXC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="n7qfsvXC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E27E61F00A3D;
	Fri,  4 Sep 2026 14:17:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788531463;
	bh=0yxcnzWC08gcUWeoZg3nP3VhnvBPnI+J7kQEnjBdfIc=;
	h=From:Subject:Date:To:Cc;
	b=n7qfsvXCyoyaFcTXs/UKQKK4DRNzTMFlI/jcOFsE2IlhG+R+bfuExI8I9xU5z1zuX
	 vFbeppFHTpirlQt0vG3CnVensqkqPPLutMQIH2BpjoAETwsMPDOPWXGDKkxFVmlnFf
	 iQA1picGPgtcBCoCCgRLhOQa60tDdCwkonrDpQcdzDjA0QwptATuXnr2Pco9s4BGqg
	 hPsO6CFNabQGrI/bb++PyxTVj9sQVesFApe/X4rWJnA7gHmoDjvQQIzmvuclrHQKBd
	 SjAnHzlLP9hA3Fs+kqaJyXAJyXX754oL/tn5AVNEmMNS2YZGS4NETcX+UfMVBZ9dYm
	 7BDClbFvzoXmA==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v3 0/3] fs/nfsd: accept a backdated timestamp from a
 delegation holder
Date: Fri, 04 Sep 2026 10:17:31 -0400
Message-Id: <20260904-delegts-v3-0-b6062ba75f07@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/2WMQQ6CMBBFr0Jm7Zh2SmjrynsYF1gGaCRgWtJoC
 He3sFHj8v389xaIHDxHOBULBE4++mnMoA4FuL4eO0bfZAYSVAkrJDY8cDdHZCvrqjStLElDfj8
 Ct/65ly7XzL2P8xReezjJbf1vJIkSrVW61cyl0uJ85zDycJxCB1sk0bdIH5FQoDLK3chYx8b8i
 Ou6vgEZSUPl2AAAAA==
X-Change-ID: 20260901-delegts-e91a648f1427
To: Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2483; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=wBMrjl7+c1YrjhibX59dHjem/Uo9outGY8u/9APmJGo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqmtMB0AkDD09K2GKYMsujvyNc82v0d9dCuXveB
 4hgBVcLVFCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaprTAQAKCRAADmhBGVaC
 FTtVD/9s7zqXVfs5UlJ0QlP9i/JyYuSpC8I8MJ06Ph3O15oUzjXJ2byAkudNOl1ba0OsOujJ+Qn
 PhxM2c4qNF+QUHFpL4oBq5V6JWXOPkgGd8lf7XEOFrHvNtGfd7Fxf1zKDvVNIuU371bd2gIIvfa
 8yDMVQNQutHjSkxmWZqg/ZEa9gZ3jFF/9Sk+MKsKF09BERgpxfVdzRhJMX18Xl4NqgufHxlw8t0
 nZ05VM3Q6sQvJ21NFG+7WhWYb96WHPjShRETMmWg8/DOFFrQOZKzlovmU/2rsV3HmQK8lnnxwo4
 +c/kAfJ2/X9hcutpCMWKlQCbBCdIuXczIuCP/lYkkaZCgCz8DLVXZtyCJaBqIiqV8u5Y9LQFVQD
 Dt5xrcDz06T1e71KGbVU8VgkU9xyZYZkmiCdNdjzD2BzzIhBr8JNtu3O+YQJmtc3FiBbXW87XmF
 g7gW/puO8SSnAMcSnO6DNrOy0b3S/Ui2ELcGGktIEMQaQSRNgc9F8aIMOA3n+NrirBske70RtDm
 wSlN8Yjm+Mdn+OqfNDKlkg4B0kuc0WII+AAl1GmxvlVEuJCGUkM0TUYRT1WU++/zgP1ZpnVOm57
 FyiZAqMs9rGWmREtGvoXls56YEJldTscdxZmuBzz1o1C/lAkTZQIxI62PGKBfYbLLedoZINC2vn
 Wlguy0NZgiOJuUg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version fixes a couple of issues that Sashiko's review pointed out.

The main problem is that an attribute delegation has strict rules about
updates can be done, and that prevents applications that backdate
timestamps on files after writing them, (e.g. tar -x, cp -p, etc.) from
setting them properly.

We could fix this on the client by making it always issue an RPC for the
SETATTR, but that would harm performance in these common use-cases.
This set allows the server to accept some of these backdated mtime
updates, by changing how the ctime is handled.

It'd be nice to see this in v7.4.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v3:
- Compare after the clamp and truncate in inode_set_ctime_deleg(), not
  before, so a clamped update stamps too
- Compare a SETATTR report against the inode before clamping, so an
  untouched file with a future time keeps it
- Set dl_setattr only once nfsd_setattr() has applied the update, and
  hold the stateid reference until then
- Note the SETATTR/DELEGRETURN race on dl_setattr in a comment
- Link to v2: https://lore.kernel.org/r/20260902-delegts-v2-0-383cb289ce88@kernel.org

Changes in v2:
- Split the change into three patches
- Stamp now in inode_set_ctime_deleg() for a stale update, so nfsd need
  not compare
- Drop a SETATTR report that matches the inode, so an untouched file
  keeps its change attribute
- Set dl_setattr only on the branch that carries a c/mtime update
- Compare against the inode, not the grant-time snapshots (Chuck)
- Set the ctime whenever a CB_GETATTR moves the mtime
- Take i_rwsem before the CB_GETATTR comparison
- Drop the unused dl_atime, dl_mtime and dl_ctime, and make
  nfsd4_vet_deleg_time() static
- Link to v1: https://lore.kernel.org/r/20260901-delegts-v1-1-9937f7ee4370@kernel.org

---
Jeff Layton (3):
      fs: stamp the current time for a stale delegated ctime update
      nfsd: accept a backdated timestamp from a delegation holder
      nfsd: compare CB_GETATTR times against the inode

 fs/inode.c          | 25 +++++++++------
 fs/nfsd/nfs4proc.c  | 92 +++++++++++++++++++++++++++++++++++++++++------------
 fs/nfsd/nfs4state.c | 49 +++++++++++++++++-----------
 fs/nfsd/state.h     |  8 -----
 4 files changed, 119 insertions(+), 55 deletions(-)
---
base-commit: ac579868af0c900d8fd9c8cfe9e10db46ccc5a75
change-id: 20260901-delegts-e91a648f1427

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

