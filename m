Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A431547073;
	Sat, 26 Sep 2026 00:10:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790381460; cv=none; b=ChDgjtb5cNFo2hPJrrjsvH4qtp8sBPSwYYbDw6GbamCzlOQVRZ8rQe/Tc6lxEZGUWwGMoOmzYeaSSyyq8pii3rcqbqcfNtZaGa0O7w85P3LTlgEFsDb1aih23as39tCV53XLd7OqMV/65k7MjObdIkTdmbU/Kc/P8EHF4/s6bFg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790381460; c=relaxed/simple;
	bh=rYLOYBRstCBxkIDIRobiKp8nkdTXNJthHML1aMVlpX0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=e/4YkBjNKm4kYWY/GSW0HXwV7JgHC1/RT7Zc8pJ9C6DES2QBLkHiAPEtZEnI0KIK3/c+q/vdRRyHTG+9Dc+LK//SU9JSRlyLw8AaObYzwhGCeATE91V7AkmFUa6Qb7/dnImxuCNyV9yTmCAXVQ2o1PGxVTIBJ6McadgdfbwO0Ew=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=C2ndbK91; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=CytCPBK+; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="C2ndbK91";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="CytCPBK+"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id B3A5D1D0007E;
	Fri, 25 Sep 2026 20:10:57 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Fri, 25 Sep 2026 20:10:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790381457;
	 x=1790467857; bh=0ma6EHUA9ZqNeo5Lg2+dQtOo2dUBWsjNdBT2myIDiug=; b=
	C2ndbK91RJfnj/eYqrfOEHPgFrs0EAh1RtmS/uH+w+I919wwPwNxE9NM+4g4scxO
	Onhdni2it6uPgrB8GFP9T7JeROlMPmRfrzRCvu9z5H89uDdn/h8FnbDkd/fKeyx3
	FYOdqVN0Nu5oahjxoJn8aVckmj0v3Uiu3LPIeTcgAq1jICyH3aLhoo75OrX8E44X
	Wt3r3sbSB6iyrWiUIgxByGW4YslxLvGrz/2zXnrPNpkeRiw1hiqd4Bpmazc10hF9
	4+R6ySnMKSXaaai4ZJRpHPy0uslgkk1GVglEAFW1w1Zw8tVXaDpwzcleCOXoc3BO
	W7AFGX/w9Fj8d3SIByPhkQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790381457; x=1790467857; bh=0
	ma6EHUA9ZqNeo5Lg2+dQtOo2dUBWsjNdBT2myIDiug=; b=CytCPBK+gM5GD3olJ
	pavvzWmu47zEmRG/wULbG/OogkN0+0B0UcZlPF2KjcKgpPkqSFFJ2JNEHQBq7skB
	T1+XZUKIn8tg/cFL7iavMeOjs/L/Vkb2tJCpNukaTz1RYjdoONlUdvxAF0gTYZBo
	AawxDIbjPTXzPmJ4iMGdlaSTD5W4ND7KcSTd+pAeZtVuMuZVk9CCvflriNPPPMfY
	JnRn/bx/LLkcsX+mJNt01oAMEakDDcmpQZtwqT88ihn9a9bd3gPZ9CaFF+9rApXk
	uMeoSLDRLlwe5/fm/kwXoniLNG1Xu2ib1WUaB/XQLV1GDs3rK0aadhO1HA5g3DUs
	TWRWQ==
X-ME-Sender: <xms:kQ23aqmTzRcnelCmlLVhzGOcJCWkoj_DU53FBm50YCpuwBvcrj_AhA>
    <xme:kQ23akaVsbXceuSdqyZsN27RV3Bhsn-JYQvT_wqSS6Hx3ae91rQl83eMTjLq6Vmq_
    0uSM6XJsrN606PqIV5scHihsOns-BxsTpvDiCMXBm2zVdDjWjw>
X-ME-Received: <xmr:kQ23asRHX8BuDcJNS1i04AiHfHw0XK6SO1ha93-UT_JYGL-PowBjvh6gSeVdNgjmiVDU8wf47JxZLw6Od_xSmZ-KuerfC4c>
X-ME-Proxy-Cause: dmFkZTGRK8QWXe3nRadxtPbELLkvrDBk65jMMJlDbRQiJ3I+eAs/RrYr2334q3aeTtDUsI
    0yJSntmoLyr8KgVTJcuP/52kAG2EyKLVvKYyj+YdVJwI+dWCtt8dkqbOnPk6a2iewUGGb3
    5sQj5r9IclyDj0CAiqpm3vyd7jbFlQXpDU3euXydwz3xORujrGGX6LjLAjm1JKIOAkSHG0
    CGuV8YJ1pyazczarobqBmpnb5/CbkcyeHZR9PgXLYLIeLUcFAa/VxqXyPNB74WmhkHPaqt
    SLuuWaNBYf4+L6TSmt2yFibGnXA34bmiRTwWSSrtl8p44WF281+A3SXE5JbZjkpdVhTYed
    NxYsEMSvzhQwHkTtxLmgLK4EjBrdH7fEqQ+zlvj8u+w3iSeNGL6lJCo7P4pSEiUhXRJY7N
    k+XCkUVtBCHda01GO/LZe0vdL715Set2b8MNB6N6wBKZ1dQqhvaolr2TB0efFKL5p+p9gJ
    wwIdVM/S2u4j4ncVHAUABrzQqVmSSCdAFoZApWeTjzwJ3BRF6pLRQwyPk5y4OjmLzcBKRY
    qdgLZg+A0KUQNco3nKTK1Ns0Rs9XA4AsI73w8xcTudCajX8y9knBwWRNAqGkACnxN8O4T+
    yEKOpAfDmBeSOnQOohQv08G+0sXRQYbCuVyvI0GbuxUvFi1F06vx0r5zUeeQ
X-ME-Proxy: <xmx:kQ23autbSLEgoZnS0GQvCiemFa1iCW03Efq8G3yBxJD-grHPfgFIeA>
    <xmx:kQ23auF0iIbpruCOqqf28zvtaLxhuhdsYGRzeUcuB5Risgf3sq6CBA>
    <xmx:kQ23avyfKdALA5MBnd63_7EMCOP-KOioBc9an6FrRLWqacRRTI4V5w>
    <xmx:kQ23ao2CzNT9PKspM2eSLVcMreRNvQWYzyydI3tS7E6x1EKse0X2kA>
    <xmx:kQ23asd8p88ChmaJRNXu4dwQyG4NieS_wcD7DGiQqmOYekPq-hCRllr6>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 20:10:54 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] nfs: fix open-blocking with d_fsdata
Date: Sat, 26 Sep 2026 10:01:18 +1000
Message-ID: <20260926001011.401824-2-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260926001011.401824-1-neilb@ownmail.net>
References: <20260926001011.401824-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

The logic described in block_revalidate() that ->d_lock must be taken in
lookup_open() missed the fact that sometimes lookup_open() isn't called.

If open_last_lookups() is called while still in RCU-walk and
lookup_fast() finds a dentry, it does not take ->d_lock or increment
d_count() before calling d_revalidate() - only afterwards.

So on that path d_count() can be incremented and the file opened *after*
nfs_unlink() has checked d_count() and set NFS_FSDATA_BLOCKED.  So an
application could have the file open when it is unlinked on the server.

To fix this we need block_revalidate() to ensure the RCU-walk path
is blocked as well. This is easily done with
  write_seqcount_invalidate(&dentry->d_seq);

legitimize_path() will increment d_count() and then check d_seq.
The write_seqcount_invalidate() call with cause that check to fail if
nfs_unlink() has already seen d_count() being 1.  So the RCU-walk will
fail with -ECHILD and it will be retried as a ref-walk.

Also the smp_load_acquire() in __nfs_lookup_revalidate() is pointless.
wait_var_event() contains the required barriers (a spinlock in
prepare_to_wait_event()) to ensure the correct value is read after any
wakeup.

That barrier doesn't apply for the very first test of the condition in
wait_var_event) but the locking of ->d_lock described above provides
sufficient barriers.

Fixes: 99bc9f2eb3f7 ("NFS: add barriers when testing for NFS_FSDATA_BLOCKED")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 49394123bd09..4f1bf45b0c70 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1837,8 +1837,7 @@ __nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	} else {
 		/* Wait for unlink to complete - see unblock_revalidate() */
 		wait_var_event(&dentry->d_fsdata,
-			       smp_load_acquire(&dentry->d_fsdata)
-			       != NFS_FSDATA_BLOCKED);
+			       dentry->d_fsdata != NFS_FSDATA_BLOCKED);
 	}
 	return 0;
 }
@@ -1857,12 +1856,15 @@ static void block_revalidate(struct dentry *dentry)
 	kfree(dentry->d_fsdata);
 
 	/* Any new reference that could lead to an open
-	 * will take ->d_lock in lookup_open() -> d_lookup().
-	 * Holding this lock ensures we cannot race with
-	 * __nfs_lookup_revalidate() and removes and need
-	 * for further barriers.
+	 * will either:
+	 *  - take ->d_lock in lookup_open() -> d_lookup() or
+	 *  - will check d_seq in legitimize_mnt()
+	 *
+	 * Holding this lock and invalidating ->d_seq ensures we cannot
+	 * race with __nfs_lookup_revalidate().
 	 */
 	lockdep_assert_held(&dentry->d_lock);
+	write_seqcount_invalidate(&dentry->d_seq);
 
 	dentry->d_fsdata = NFS_FSDATA_BLOCKED;
 }

base-commit: 3879f51857325da9bf3cfb073280257cd16ae067
-- 
2.50.0.107.gf914562f5916.dirty

