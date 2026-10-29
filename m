Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297397;
	b=4zkXfqMAKBj3hvZGldh8HfJ1ydaiBO+nUbrvZUQeMMddsyieIqSULobahc4K35u9rQO1
	 G+NarTJ7SwTiP3c5qfe09pzxlPfUPUN5voVyL0Pbh62Ox8fQ09K/oPYm2uQTaLHYq+luW
	 PiBNNaTgSqnq8wZdWFnLQoLV1lbKzKs5OPIMD27yQ1XZIIZ8th/ifxTVaUIfRV5ZCvDZ9
	 Le8wE07d3MoyJnZhlxO0wFh0J4VfcSB1OvjGvqxvPPKYJKNj//odEkGe4Ig6pSmFkAMXt
	 Qwvn5TvEzxz8cvVouLR8SAsKqnfXxSul9myAfKgjAHHxVshxpfJO2XM9pmJaQCkj/2A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297397;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=OAjOFeHOiJyO3E+LMShJhniXIw/25NQLu/aILC9IA/A=;
	b=XYzjJP1K7xcIV4jszEQGySkfSX/o61KRpHfI8k0n+brG2SLiPSyDO6fM+i2OpiPujZRz
	 Lb9+g9Pk1AJLPPDpiia8vzlKcX7ic4Gv5xDt0qtKUsAEH1mXvUUtgfUsVM2WiQgSsd/rb
	 HhRUwIn4/ky1fx+7HgPfMrnXnwi9mlUkjMyOSxx/sJS9IjrhbXJkeEKQA5734BxkwdJq8
	 LgEfp5RyS56BWAAZ9L175qzVPb41G2W751GipDNnna/pX9KC9Vf1IRLQpLWxOuv7cJEIm
	 XRNi/2PTe/eoHHEc5xCt5Cl+3ZDK4mKm60DG7P2yasuq9EkFqJVuD8aV3Uj3bQm3UFQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b="G/r5O3WT";
	arc=none smtp.remote-ip=209.85.161.51
Received: from mail-oo1-f51.google.com (mail-oo1-f51.google.com [209.85.161.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6A3160A2606
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:09:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A6A3160A2606
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=G/r5O3WT
Received: by mail-oo1-f51.google.com with SMTP id 006d021491bc7-6f5a0893610so1963226eaf.1
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:09:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297395; x=1793902195; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=OAjOFeHOiJyO3E+LMShJhniXIw/25NQLu/aILC9IA/A=;
        b=G/r5O3WTCP567pyFF5NYPtgmj6MAguEOZ4imMA9ujQJRY6FkDHU8LkHDQ26A+Gxtp0
         ghWWgbuTzHHADAfYaL6ZO1bhp0FolkLu2fN7sgmG4RVS9332I7e7PkWYa3aVVUiHaSrR
         YAbdgKF+6sNaDLZtUElzXjxgDLayPCEcmUzhPI1qQQ4SRofPZmoJSMaGMsf0lZQXEyfl
         gC9dkfr8yHrIs85TyYPh1o6uqjiiNpPXOBTtDitcHoMyAuOcGbfV+UDI35u9taassuUZ
         W+B1RANUdjQXPJFOHCQWJ3IzqOPtooz2m37Mo8aN5Vw+hzHsYONl5s1aVWL5rPq5Zz/B
         OeoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297395; x=1793902195;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=OAjOFeHOiJyO3E+LMShJhniXIw/25NQLu/aILC9IA/A=;
        b=Uv+FmKVd56NnCiyvyUkIzOrqVQG+0FBeFEepnTozJUXnxInGnqp6NILb8g6xTrxH4J
         SgKNVxb35U/76degOaSF6/QokmOO0p+i5YqS9SAGWjQgo5wXR/bexRzTu8W4JorfFYGb
         zcP1oTdyEeoGrQcxv8Oox/Ck/Yk8T0/kPHaIGczZh4pnpg0jYSfHm90+0WpA0fzUg93T
         zbvo5ONtgSIbgdpgozGdatEH/hcPzOCi7W+uEYZ3jLDhMgNNGJyUxUewh9BLBWLe4vgF
         8Ksq/cGy6t/nCD+kBy1S5RHNGH86TpZvxttDkBG6A8TWKmmrJFkHeJl5DLcU9zBpey7x
         DdCg==
X-Forwarded-Encrypted: i=1; AKwUvBw8lX9ZqKLEj1zf8AFv+fVVd4XTNAT/DtoJcRTxiwHuDOx2sl0sn/Do2rOUxdYGGAuLxt/4LNPMLeM=@vger.kernel.org
X-Gm-Message-State: AFq9FYKwvbsDawkU28idovwmvQcneeGDseH0H4Uyj1Y3HkjdXP5QOAMl
	QroJcyGxkZZ9ZBacFIgoqUTeosauaRt/5X8t945R1/o43QWh2f+5aJLcn5sJfvBidyw=
X-Gm-Gg: AYBFou2hN8zQ7QkBMc2/LoaUO1oxGJL7pnez9lL84v4DM71NA7OZMOkkw1RuCWITlPC
	R1UMHKH562exEhQGGCNWKLUjweZqYCL6KwfKF8wKMO65uRI/QzD8LM1gDrRX37uQC30UIq5ShPu
	RYb9zsB2lf5c7zm7oKcd9787RUWgyGxxsXfSXoCKrmn6PZZV2yGM686MrWq/HgymkCRLOAwD7Ll
	mFhFZqS2pX2g2RUP8jupQa9RoR93ewv8nlSj8Nz8m9slsg7BPZj1SldS5Hvm67prE6xoLnpiftl
	xlj8wkCzpwuXp1E6HK3iF4kWmFpX4srYAPtnak2prhTHKgjqwDasGCLaCsLonr6NS2M2M9TLhre
	U8ECXxTEHmRlRVjOAiOpyKj/tWuwoLbTuio0hDco7TStfaXK8aolD2IxRWTN2FiFKmUAvwN/A5A
	LtutkgBNTNLczzun5BFmzx9cYJ6FKokmLGd6nwHDjQuSjMG6eb3qLmD69p+RUIGcisCxcbm0ORt
	fL40Bd8oDDbbsMQ88Vwr6FdAH7rIj28OOIu1DvWBge2GoaDRW57hSnF+gjKLxr9o3FmTkFHncMw
	XLOVMTsqKKFy+s/6S8YuMmpUeGFciBU0sVcyZPeAyjylhy+yToE+BXIp6+erRsYz8eFgkL87mQ=
	=
X-Received: by 2002:a05:6820:1c84:b0:713:da3b:8bc1 with SMTP id 006d021491bc7-714f29d3fb6mr35971eaf.39.1793297395405;
        Thu, 29 Oct 2026 11:09:55 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-85d355295fbsm149150a34.25.2026.10.29.11.09.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:09:54 -0700 (PDT)
From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
To: NeilBrown <neil@brown.name>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] nfs: answer a handed-off silly-delete on a removal target with -EBUSY
Date: Thu, 29 Oct 2026 12:09:49 -0600
Message-ID: <20261029180950.387072-3-jonathan.flynn@hammerspace.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261029180950.387072-1-jonathan.flynn@hammerspace.com>
References: <20261028041023.3738553-3-neilb@ownmail.net>
 <20261029180950.387072-1-jonathan.flynn@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When the last user of a silly-renamed file goes away, nfs_call_unlink()
can hand the delete it still owes to another cached entry for the same
name: it marks that entry DCACHE_NFSFS_RENAMED and stores its struct
nfs_unlinkdata in ->d_fsdata, under the entry's ->d_lock.  NeilBrown's
"nfs: fix nfs_call_unlink()" makes that hand-off reachable; before it,
the lookup for the other entry was given a name with no hash and never
found one.

The VFS refuses to remove an entry so marked, or to rename over one,
with -EBUSY, but may_delete_dentry() tests the flag without ->d_lock,
and a hand-off can land after it.  nfs_unlink() repeats the test under
->d_lock and treats a marked entry as a bug: it warns and returns
-ETXTBSY.  nfs_rename() makes the same test before it takes ->d_lock, so
a hand-off can also land between the test and block_revalidate(), which
then kfree()s the nfs_unlinkdata as if it were a device name.  Its
credential and name are leaked, DCACHE_NFSFS_RENAMED stays set with no
data behind it, and the final dput() of the target reaches
nfs_call_unlink() with a NULL pointer, which it dereferences.

Take the target's ->d_lock before the tests in nfs_rename(), as
nfs_unlink() already does, and answer a marked entry in both with
-EBUSY and no warning, as may_delete_dentry() does.  No hand-off can
land between the test and the store any more, and one that landed
before the test makes the entry the busy file the VFS already refuses.

This was found by an AI coding assistant (Claude Code) reading the
code.  The hand-off itself has been reproduced with "nfs: fix
nfs_call_unlink()" applied; its race with a removal or rename has not.

Fixes: 3c59366c207e ("NFS: don't unhash dentry during unlink/rename")
Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---

Notes:
    For reviewers and review tools; not part of the changelog.
    
    A hand-off that lands while nfs_rename() is in its silly-rename
    branch (the target's count above 2, with ->d_lock dropped before
    d_duplicate()) still gets -ETXTBSY: nfs_sillyrename() fails with
    -EBUSY, and that branch returns -ETXTBSY for every
    nfs_sillyrename() failure.  This patch leaves the branch as it
    was, and the handed-off data is neither freed nor leaked there,
    since nfs_async_unlink() tests and stores under ->d_lock.  An
    automated review (Claude Code running Sashiko's review prompts)
    raised this; it was checked and dropped as not introduced here.

 fs/nfs/dir.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 36cb99f746..dc7784b666 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2605,10 +2605,18 @@ int nfs_unlink(struct inode *dir, struct dentry *dentry)
 	 * completes.  ->d_revalidate will wait for ->d_fsdata
 	 * to clear.  We set it here to ensure no lookup succeeds until
 	 * the unlink is complete on the server.
+	 *
+	 * may_delete_dentry() refused an entry carrying a silly-delete,
+	 * but without ->d_lock, and nfs_call_unlink() can have handed
+	 * this one a silly-delete since.  It is busy, as the VFS says.
 	 */
+	error = -EBUSY;
+	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
+		spin_unlock(&dentry->d_lock);
+		goto out;
+	}
 	error = -ETXTBSY;
-	if (WARN_ON(dentry->d_flags & DCACHE_NFSFS_RENAMED) ||
-	    WARN_ON(dentry->d_fsdata == NFS_FSDATA_BLOCKED)) {
+	if (WARN_ON(dentry->d_fsdata == NFS_FSDATA_BLOCKED)) {
 		spin_unlock(&dentry->d_lock);
 		goto out;
 	}
@@ -2801,13 +2809,25 @@ int nfs_rename(const struct mnt_idmap *idmap, struct inode *old_dir,
 		 * completes.  ->d_revalidate will wait for ->d_fsdata
 		 * to clear.  We set it here to ensure no lookup succeeds until
 		 * the unlink is complete on the server.
+		 *
+		 * Test under ->d_lock, which nfs_call_unlink() hands a
+		 * silly-delete over under and block_revalidate() below
+		 * stores under, so that no hand-off lands between the test
+		 * and the store, which would kfree() it.  A target carrying
+		 * one is busy, as may_delete_dentry() says when it sees the
+		 * flag first.
 		 */
+		spin_lock(&new_dentry->d_lock);
+		error = -EBUSY;
+		if (new_dentry->d_flags & DCACHE_NFSFS_RENAMED) {
+			spin_unlock(&new_dentry->d_lock);
+			goto out;
+		}
 		error = -ETXTBSY;
-		if (WARN_ON(new_dentry->d_flags & DCACHE_NFSFS_RENAMED) ||
-		    WARN_ON(new_dentry->d_fsdata == NFS_FSDATA_BLOCKED))
+		if (WARN_ON(new_dentry->d_fsdata == NFS_FSDATA_BLOCKED)) {
+			spin_unlock(&new_dentry->d_lock);
 			goto out;
-
-		spin_lock(&new_dentry->d_lock);
+		}
 		if (d_count(new_dentry) > 2) {
 			int err;
 
-- 
2.43.0

