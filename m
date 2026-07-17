Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA64238B14B
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 18:41:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784313677; cv=none; b=OtLXhA0aIgR18EpjFbb7p1L2QWhVfU753Lw6vutmm3AiH/ltfMh/giey6tMO8326zMWisZqtgiKABc8/OtyQpqKngB/t2R1aLfH0/fjnhi9NVFTgqE93dKB8/2JJ/j19A+p9ZO2Ar2WC+6brjaMaP/UJLUcYlIlpDLk8fCRgIhA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784313677; c=relaxed/simple;
	bh=tYotsjX1fZefXOfxJASGhsztZowfJCHXkSXWI7aXn3Q=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Pz/dQitJcwOT1Wtc6/OakjaBpiT/kE4657usbUmn/+YselR0FYAJd6N8fwDVfGk6Cw6PDBaBNqG+j7wW4WZd/AS2hhGBkei34GwtYFb0FpYk57+PxzbMQF3/CodVi2t3CPKjg/xxTzs0O3EKskLqrodwVlfiD/OK18j0+VwR1Ww=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fqRhlVnC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fqRhlVnC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2AA751F00A3D;
	Fri, 17 Jul 2026 18:41:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784313676;
	bh=uBEG3SiW5Uy8DquRssoXFl5ObOm13dY5+Rme+1X0ZZ8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fqRhlVnC4mKjYIjcasj3TlAiuXoqhstgtkDsJBLGmhYR1uAmIdWtTqpfi0lfKS40f
	 2CYVpKHDyZ9yN2NCY64x5B9nnmnpWuAyknmUlLWaj+nsg1+wN4Bm17UFrBur8Vjaad
	 7fL288WJD1zk5krfCezjkUlp/VZ539iM1UI2pg4Sl7j3btcuNqNyJDKo1LH1kCXCy2
	 np9r0cZurqn3NhImaLL/xQYO5K+SCzh76ga0wPYlkM60KEdKyVyVlZARmSy9k6Zo8G
	 eH9PXS9QioyuV+NJtKip76cGQdrjDx/+O5ZUF5Iqbaog+RrUpC2S72dtKJQifQg6V/
	 c6YopxE6EkCoQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/6] NFSD: Remove two unused NFSv4 constants
Date: Fri, 17 Jul 2026 14:41:09 -0400
Message-ID: <20260717184112.507548-4-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260717184112.507548-1-cel@kernel.org>
References: <20260717184112.507548-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Neither COMPOUND_SLACK_SPACE nor NFSD_COURTESY_CLIENT_TIMEOUT has
a remaining user. COMPOUND_SLACK_SPACE lost its last reference in
commit ea8d7720b274 ("nfsd4: remove redundant encode buffer size
checking"), which deleted the encode buffer-space check the macro
fed; the comment above it still describes that departed check.
NFSD_COURTESY_CLIENT_TIMEOUT is likewise unreferenced: the
courteous-server code expires clients through the laundromat's
reaper and conflict paths, never a fixed 24-hour timer.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsd.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 384a2498b6a2..27e5384cd849 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -204,21 +204,14 @@ void		nfsd_lockd_shutdown(void);
  * we might process an operation with side effects, and be unable to
  * tell the client that the operation succeeded.
  *
- * COMPOUND_SLACK_SPACE - this is the minimum bytes of buffer space
- * needed to encode an "ordinary" _successful_ operation.  (GETATTR,
- * READ, READDIR, and READLINK have their own buffer checks.)  if we
- * fall below this level, we fail the next operation with NFS4ERR_RESOURCE.
- *
  * COMPOUND_ERR_SLACK_SPACE - this is the minimum bytes of buffer space
  * needed to encode an operation which has failed with NFS4ERR_RESOURCE.
  * care is taken to ensure that we never fall below this level for any
  * reason.
  */
-#define	COMPOUND_SLACK_SPACE		140    /* OP_GETFH */
 #define COMPOUND_ERR_SLACK_SPACE	16     /* OP_SETATTR */
 
 #define NFSD_LAUNDROMAT_MINTIMEOUT      1   /* seconds */
-#define	NFSD_COURTESY_CLIENT_TIMEOUT	(24 * 60 * 60)	/* seconds */
 #define	NFSD_CLIENT_MAX_TRIM_PER_RUN	128
 #define	NFS4_CLIENTS_PER_GB		1024
 #define NFSD_DELEGRETURN_TIMEOUT	(HZ / 34)	/* 30ms */
-- 
2.54.0

