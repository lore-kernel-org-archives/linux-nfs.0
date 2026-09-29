Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB05239768D;
	Tue, 29 Sep 2026 02:26:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790648795; cv=none; b=K3pgocYn7Td7uXSjcr76Su4dMcTea5YA1USKXAcd5PSgEYHO2Gdpd/KftiXk4getQaUQXW0TxdJUfXxBadOsk4Iaztwcr7jKY1qEmPtmoIIp5VCXjroL0Km0AJAii6Lwi+gB9W2DxAhRbPyLhGKemPzZAvHqVFxS2I8x6kjykZ0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790648795; c=relaxed/simple;
	bh=rYLOYBRstCBxkIDIRobiKp8nkdTXNJthHML1aMVlpX0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ZhhLgQuwImgJa36cqDQXWIBmM3ql+85Fy9dBbBRjODk9k1+KIWAjxQ2sMPfSBNQmLAwMBEfPdB1RX4eBkkrak6NegTHrTN+c6UuOtXjWFvA38faNThaFvQw9xMCbiFWKc56hB5Dm5w0ZFTnZGLQJXo7/QQxQP+krTsQdHrTxLa0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=C2F7dUnn; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Jx3QMAyy; arc=none smtp.client-ip=202.12.124.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="C2F7dUnn";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Jx3QMAyy"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id EBF511D000F1;
	Mon, 28 Sep 2026 22:26:32 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Mon, 28 Sep 2026 22:26:33 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790648792;
	 x=1790735192; bh=0ma6EHUA9ZqNeo5Lg2+dQtOo2dUBWsjNdBT2myIDiug=; b=
	C2F7dUnnkdi48nIwVKguukqhNwMnGUplhWboXvOdP2RfK0KT6v9OpOnB/Raf111c
	npXqgvIcHUntc2Ro/lbgU5RpEFdnLXAfBzVuRRMNeyiYsMvGeyZ8/Cl83FfKG0Ha
	V6vYowywWldxhjbFxpUY2+kWnsM1NbUtodAKU/zwgbb7P5NBcIhEj0YUbODYUPf+
	uR/2xZ2ZO4G6ZXCr2R5F7Uh1S6qy6bVKcrYyKSlJ65raiwc/D1lc+T5L3/s0egrC
	9bWRTwB9Ede9ykgl3l3sZK4lQobOxl9Ug1aDrCjTKZ/4CKylL+VDPZLuemCv4+jW
	iYUMd0r2YzfNKoFhKlutBQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790648792; x=1790735192; bh=0
	ma6EHUA9ZqNeo5Lg2+dQtOo2dUBWsjNdBT2myIDiug=; b=Jx3QMAyy/k+pOfE3J
	8oaISedexKCi0hDR9g/z/ltsTSam4pWMAvfxpYKwIKLX8TcNZaxWdZg61YpFPF5J
	xJvILf6KU2hsYmltQE02kyagFCPZKeHb7fnVbyQVf9wGuCjFXjdxeqgd/0cCrUzy
	q+A3EQVcx4ACm2cLpd0ymi7Id0yVPLVwHPo9QlvA+un4QBKgkH51upMyU7N7QsWl
	dmAaZFHjC9h0hGoK7Is3CyHyABjsjHTp7bVSZ1mRXG2N0i0GrRKW3b60n7O9+31u
	ow1XQ0KhJvKY9aIyLrxUOjvVeFJadyn+G4B8z/MRTvJ1nR3QoVFhCClLFjsJ1kQX
	1UbmQ==
X-ME-Sender: <xms:2CG7aqGxqYWWv0CXmSW-zzIqkFijmJETdERsOBuc1J8QbxpUiekEDg>
    <xme:2CG7auZIuO3-IWauM5wvNDYafgBnX4WbPGXhIu31f2FuLchem6_UqEWkWa_SYaBNp
    rfrwpj2WRYoHLT2DQQbTFnOqNH9WVtZhAYUCy8O1jUTT70nBjGH>
X-ME-Received: <xmr:2CG7auyFG83YG4KMwcub4gXNmPOTp-eJ_o59RKecld1aqo4iDq3YEktkUMgYlLyjwJofxfffyvC8Rb7GTKTHhvIxmOcmh7k>
X-ME-Proxy-Cause: dmFkZTGVDNnzESBYR3mA0mj4J/oiPo94sEVuvz2NPFNMdz9kYeMQUYNSOMDonD5x5v1lxt
    Y3YKxth5y+5AcelhmbqoVXV3FsLexQGqy6ySfBbZdX3XOiA0j0ixOwBQ7YQLMW11urS7Nn
    P7GcHAm+fnGGsK6eRyjpaEjaW3wGzOUhgHmF6172kXxhvNqw5t03JcHMsDIg5eCzkcfYMp
    gzeksANsqYigaEYw/3+s/BCzhblwneuYn20KFgS0pcn7Y6OCynIfFAyFrn+uVtT1eBj7is
    YWaEDBls78d1VVrgCXv67Nm8xKS7Zaj2d89K8kC6IirWCBlABYeoWupGoWlHVy0aKpr4gp
    TDzd39fwQjlWQogNKv1vi/CVkxoc8hPSH3dUw0S3ehe26dP+vCHgbHhn0gWJLoDTj0OgAA
    3BO1W8NgpbxvNuBrQl1y1g5EQapH8T55sEnFsWRwScL0VNR6BMD5mcCreiXuJWEmGUt7e5
    PC+4BcB5JVlV/v03iTu2xjA6p9zPwmcqGGHTTydDVeZrtcw/jqo8enm6eAoZzloJJqaCPe
    TpFphPCxG51JOg0p5zlzbdNbRM+9aUdUSQEbNut0EZJUY17Qsn4W1rBZ8GwvCHFmdAXM9/
    qKcQwOvyexCX0SXRU+b6MdC+xlAWWKxyMfnQH1QabxVTIrM7liYcjag9Eykw
X-ME-Proxy: <xmx:2CG7agSFnAXMFCpwm1Tax3g_o_pi4hBt67XtsHe_QLx-3mSW89pAKQ>
    <xmx:2CG7arKjlq5hKIBGgV-BezeF8fqpVG4Pyl1Bqh79uQVwXRxGhu8ilA>
    <xmx:2CG7anWvv7NJX1TB6R_yB5HF9TCU4D47Q-QhTfi8WH-M-Dp7lit5KA>
    <xmx:2CG7avSUl38QivvWNi54votFCzt97pHav5fydCAxJi_jbyJctmLh2w>
    <xmx:2CG7alM_YkeWQnPy3P7-SU2-_hGjG0MvuB9Vr1vPBVUqts0_k6X0Fs59>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 28 Sep 2026 22:26:29 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 1/9] nfs: fix open-blocking with d_fsdata
Date: Tue, 29 Sep 2026 12:21:11 +1000
Message-ID: <20260929022547.1428036-2-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260929022547.1428036-1-neilb@ownmail.net>
References: <20260929022547.1428036-1-neilb@ownmail.net>
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

