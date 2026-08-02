Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C767A3C5536
	for <linux-nfs@vger.kernel.org>; Sun,  2 Aug 2026 17:04:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785690292; cv=none; b=YQMhJLTGzI805ewbpTXMy4iOWOsT+ea5We3Fyj8Ht91pynQEnGxV8HomZBIEPdixhntgn/01qgy4pzCEJwZS1eunxb+HMLe7bsXpGFAz46olfXdkWnCCd4mV16nfvdEIAZPdzntFoHIO3I3r8fMiWsieKJF2BZzGQavzggEecTg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785690292; c=relaxed/simple;
	bh=HkCW3/iSM1445Dr42BoI0Yd7shY8gouh1kFcyvz9Xw8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=n9KaTA6m8ZPa7mZgWX3OhAtIQeBx4A6aLfhRxomn0/PK1dhmaWsSqWcDRoe6lQhy7snljFmkeP6Rn+5n2/XF/c9ZCt1ZEMot+yyiacEd/gndpjITPtGvu3AnrBCSEIcyCJAi6tFs8kvmIGPdtuxydDR60SIX4A7+jMPFJugzz18=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Fwqg2iQv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Fwqg2iQv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 083EF1F00A3D;
	Sun,  2 Aug 2026 17:04:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785690288;
	bh=Kq7l4M0kTwCwHnWHMcbAHrnNjbySkBBk/J4VdbDlIKk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Fwqg2iQv/jVXLHmQGpJ/OyS2cP4XE5S43SyznzxuiWMmB4oeISRtKBMSupgavhnX9
	 Z5jW9QjQrJnjeo6tWWhY1UsSALe13+giQz2gR5eJ6dAImY1kKrMh9BnKgVVIU4Dw/4
	 NIXu0cNo89BtsgI1a5g+2WQlVuCtcNbmCddgmxGRPWkEGd5IeDWJA3K8DMhsuEWFUs
	 ++0MXbBU6i6/zWZLmT7hbtPq3PfaJKTT+yZ4t+2XAZvCmid/pr0A6TTL2dy+D09dMI
	 pmMOCnVCbvxb3qzPrc6IcMMw0LXb6EBLLs1HG6cfNZqOfhCmtfdY5n8RloXUIFeKKG
	 6b709xfcasZmQ==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 02 Aug 2026 13:04:34 -0400
Subject: [PATCH 7/9] NFSD: Correct locking documentation for delegation
 sc_status
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260802-nfsd-deleg-destroy-badhandle-v1-7-323aa7196055@kernel.org>
References: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
In-Reply-To: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1512; i=cel@kernel.org;
 h=from:subject:message-id; bh=HkCW3/iSM1445Dr42BoI0Yd7shY8gouh1kFcyvz9Xw8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqb3iqSx5SyerR8ZtD6/eWVw8ThBvn2O263w1L+
 FQSwThkRxOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCam94qgAKCRAzarMzb2Z/
 l/lCD/91AEoKDoJJntaz9/diJs3h0rkdceKwiOG2oQV3Tiue4w6qmoI+iN3UJStYFBezaudBPBs
 FTgkvGDtokBaUDI/7aadpSCpSC7e+zpW3/MufSfyXhQzmwMyQX/6mZ+x7SVBz62PXNOMxGUkNvm
 naH4YpZcoFuD59rycz+ueXzHEPcmiMDKYXA9awU1Z+s982KmGQrdtMXAtpvRxWW/hk6p5v/M6iO
 30CKsM9Fxe1xj/3ppsVe29PKDW/HDKbUVupS2/aJ20tEAVyDF1CAp45QKrP5Wi3ZEcQsm6UgafV
 f0qEGB90KidqD1RVAW8Kv0eceMdWrwr52R/W/xff8N0ovV+Lf43X+4wIMVepCVWPC71lEcRnUWA
 UDnB2wBcJQfnIwQJefzJ1gRoBwbBKGUAzau7aJ1ddn+ElmxKvyS+UbMK+5AJDgsiQiIVoluz3xg
 8OItXj8iDiIDnzJxOYaSKsy5ATKN35UP6mcBxKAJzHZlKzfvO4ffIUh0EUa/zs19V7gABGT08r6
 6K7kM6tzmA9PRBZ2cQ5SD3XYZE8/n0CxNbPkjMoBKmMU5VRBHflDurW/1HERneCd+J+frpSsE+j
 61/bmSYaIAGxlR1wyqhzliMMsXaNLOZPRwZT72KWwMD9lWJNkLAhnVj6TPfParFlbI1oF4AtcZ4
 vkEMK6I8pirvISA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The comment above the SC_STATUS_ flags states that nn->deleg_lock
protects sc_status for delegation stateids, but only the transitions
made while a delegation is hashed are taken under that lock. This
comment was accurate until commit c88c150a467f ("nfsd: fix possible
badness in FREE_STATEID") set SC_STATUS_CLOSED under ->cl_lock.
Commit 8dd91e8d31fe ("nfsd: fix race between laundromat and
free_stateid") added the other two sites.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/state.h | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c4627dc91e20..42d3320622eb 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -145,10 +145,13 @@ struct nfs4_stid {
 #define SC_TYPE_COPY		BIT(4)
 	unsigned short		sc_type;
 
-/* nn->deleg_lock protects sc_status for delegation stateids.
- * ->cl_lock protects sc_status for open and lock stateids.
- * ->st_mutex also protect sc_status for open stateids.
- * ->ls_lock protects sc_status for layout stateids.
+/*
+ * nn->deleg_lock protects sc_status for hashed delegation stateids.
+ * ->cl_lock protects the bits set as one is disposed of
+ * (SC_STATUS_CLOSED, SC_STATUS_FREEABLE, SC_STATUS_FREED) and
+ * sc_status for open and lock stateids. ->st_mutex also protects
+ * sc_status for open stateids. ->ls_lock protects sc_status for
+ * layout stateids.
  */
 /*
  * For an open stateid kept around *only* to process close replays.

-- 
2.54.0

