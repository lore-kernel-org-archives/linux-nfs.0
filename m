Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297425;
	b=k4lcm8wo73I0pV655IJ1KMTgTexda4jJZrPw3jNI+OlBDym7aNJ0EIYQZAmdeqPnRX6J
	 kFWg3nNPjMmIpiQc+qNfUV+05d+Q5Ncp2BR5Mp4xy6EyjELQsWAvAZKPTkwb1MsGDSgnD
	 eCBjWmjleORwswJCyWLIHkBB6dW2FIBlbOE+9q2BxOU3s3TUFSNpiUb5Y5zIRpsA8jtOl
	 yhB2gDKnvuKoy7AxH2WZvoEpYkWKlYB5L2aXJMdiczyPvCqCV+fRAEwaQtxdrne/iEL4c
	 bT08A670MQmFHz/nbnjyPwwWf2mX8F6XNviay6zAiXCO1Qpx4vKD0EfZsU3Rp0jBpbQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297425;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=4xMOYm4IpfE3gPGdn9UWNdhcEWDkgMVOaC7S309xY8U=;
	b=zocG66NiuWBuVcat8gDVfyUlLStsVl3bb4AvuzgPdqUrkNpjqhjgE9KINETjRlDdchM+
	 CH0SqTTMx1CjmRhGOdj42eOCLPvC3ayQhiY1Jzg3I9xQn4Si/3RTzAS0hevQNirK+2KtT
	 6mum9AfjgZc9Y2dX8ULE8BbfdYWK0VCKEuy7+dtYzNPwwf93//bxRNo2SS1u7/oA1wYaQ
	 vkDEBBWEUKtxpByhonFshcMmBmvoMclk2exgHL3EYYqEf0NPj6sN98NKMWoxCvD030uCW
	 +GpYkKQRp/tHerWMF82pUp7Tpls2zo8iGPUO6KJNSJCTHF759DWq7QafYqmVSOkmNdw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=O9MuA2oQ;
	arc=none smtp.remote-ip=209.85.210.47
Received: from mail-ot1-f47.google.com (mail-ot1-f47.google.com [209.85.210.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 62AFB60A3803
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:10:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 62AFB60A3803
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=O9MuA2oQ
Received: by mail-ot1-f47.google.com with SMTP id 46e09a7af769-8241a56cd70so1551267a34.3
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:10:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297424; x=1793902224; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4xMOYm4IpfE3gPGdn9UWNdhcEWDkgMVOaC7S309xY8U=;
        b=O9MuA2oQA2kKI8pZQsdNwps8O5ygNrAV9ZydO26Te8GbEpNPTdYi3/2h09zNgZ4jJ6
         v+T8Zv3m3Xd9Lg9M0k9USqpLOw1LcZAPcVHvGJVhIxjAkUVUfLgz4yWQdSLF9PlLbOLH
         qZAY6RQEMsDC258PV97I6yO5FGZF8C//UC0BFJHXKWKuE8Iq6oU3h0F/Tk5hsqwogcXp
         hspPthNAYMAjZH/MoFbqRcpPUxoyR4R1Dlo8AkWHKMD4jL2Y+rOYTd9t8pvumdhTTLbG
         9l/SK1SZbGoP3d76hRXhlSUckIh7eDJKfa4rQVWWtuu2EZuTQM1yiFea/5rv0V9BzLqY
         m6aA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297424; x=1793902224;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=4xMOYm4IpfE3gPGdn9UWNdhcEWDkgMVOaC7S309xY8U=;
        b=V4q2/1I3AwYVPLaau6XOKHKWV26yhpzgfa0hDU6Cs2FuU0avNRFF0Wcbk0eumIKlXu
         P115jYLfHFKoNkJVTfwGPm/lkg4MvOFh6mY600Hh0CwfLSrX3N2xNp2GxnmLatxTDTge
         Xh0oo5Q7kPthupT0m/1Ea3x1JVGJIIDC+JRZL+WcfcWD/ywoGkXx/C8KOdbT155rBVBL
         e53Y8t6M8Mv+zJOsxegOHhCmL/WzyI1rZ6X+pWWDcxoVDKlErexbO4j8R0fn0ZaUgqF/
         bi/dLD4g/184OVDeIsTxIoHInNqigwpMNNahNbI7TUL0XPcpwTtbBVp3MZWTL/dy/93G
         Y1Gw==
X-Forwarded-Encrypted: i=1; AKwUvBzS/gV9cj2QTNwEe5PfbODUtrBVLNxNBgUaxlv1wcEffYexx4Ca7ASOmDKpoaimPbMjID69L5f35Rk=@vger.kernel.org
X-Gm-Message-State: AFq9FYLz2qVMrSzn7AZkQpLvGWNF8+XmDxwMqj7gdzLyWwpueNQRvSHc
	KPmeSKuent56qrimh+X7HmDx5S2VzjCbZ3pBjsoavGGiY4ZJFRbMeHyxlMk3TPKX5iPRmBf8ZJ8
	F2P53jpc=
X-Gm-Gg: AYBFou0Yn4b3q+ZveU+dbl48CRwJ1PQCNKiU3VSMSBcwJJPrpfjtkLV3yxpEcFEt0Dh
	o+1HcKHWqjW4KafjD6vclXtJir6+cp09KiOKRsAo83NWQg1hvb13aLlinOEIVG3y+bI6v9dPR/8
	49rrYkNXBZgO33WKF8ZBkQoG6uW9bFihg6hmhbRnoXm9KnhWM8ydxnCbNbr0cKueYRZydIW7SUq
	Ka+wZ98kBPG61uyI+o3kp5FALJcPKTnBbWQJGRIFNL2FrhySvfL1OJCyFtQLnXxSBuqAgzGOlBy
	97Dnu87FQCBcPP5aDu7RrDssgAPgkisIx1tbMsTCFtM6l2U67RVOu2DrdoMyO0dh1F1OJEdzrMA
	lf8wOgHfq3nVlGWa1bjiw1/juNt8flko1dY9S5S3jasGBveuO2OxzKuimr7CnO9m1fUPsnsJh4H
	ya2jf19qSzOCzTXYpIvAelTUHRk3XnZaYRYmMwrQgrSfiBtdd/bkT+JK/xasM6ywnljIou/Y3ok
	8yNglcQIfayh4GbKM48LP5OJ9M3fr39Hv2ttsgiMb97BlS6MRbed+k6K+fQdpBzqq4MHhG8cVDS
	pdp5FDhiKJsFvZ4I0B5Rby310o5+kiqYufR40puR2bopun8Qq2JPLrEaDNuh+B8FjImig+1T
X-Received: by 2002:a05:6820:f02c:b0:6f6:a60e:3675 with SMTP id 006d021491bc7-714f29073b7mr51392eaf.34.1793297424010;
        Thu, 29 Oct 2026 11:10:24 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-714f2e3c910sm291eaf.9.2026.10.29.11.10.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:10:20 -0700 (PDT)
From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
To: NeilBrown <neil@brown.name>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-doc@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH RFC 10/12] nfs: add the removal method for a parent directory locked shared
Date: Thu, 29 Oct 2026 12:09:55 -0600
Message-ID: <20261029180957.387138-11-jonathan.flynn@hammerspace.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
References: <20261028041023.3738553-1-neilb@ownmail.net>
 <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
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

Add the client's method for removing a file while its directory is
locked shared.  It handles one case: a cached name that nothing else is
using.  It marks the cached entry and sends the REMOVE, which the
listing check of "nfs: do not cache a name from a listing that a removal
overlapped" counts as waiting until the protocol's ->remove() returns,
and as answered after.  A second method, which the VFS calls after any
delete event for the removal, clears the mark, so that a create of the
same name that waited on it emits its create event after that delete
event, not before.  Everything else, such as an open file that would
have to be renamed aside, or an entry that is no longer hashed or no
longer names a file, is handed back untouched and done with the
directory locked exclusive, as today.  The VFS does not call the method
on a server that reports itself case-insensitive or not case-preserving,
and the method hands back any removal that reaches it there.  A warning
fires if the marked entry is found dropped from the cache when the
removal succeeds.

Two new trace events record the attempts made this way and the
hand-backs, so a trace shows whether removals took this path.  Make
block_revalidate() a wrapper around a new __block_revalidate(), which
stores the mark it is given; the wrapper still stores
NFS_FSDATA_BLOCKED, and now warns if it finds NFS_FSDATA_BLOCKED_SHARED.
The existing removal method is otherwise unchanged, and no directory
uses the new one yet, so nothing changes.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---
 fs/nfs/dir.c           | 183 +++++++++++++++++++++++++++++++++++++++--
 fs/nfs/internal.h      |  19 +++--
 fs/nfs/nfstrace.h      |   2 +
 include/linux/nfs_fs.h |  11 ++-
 4 files changed, 196 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d9ba3cb1d7..0b6de87030 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1919,12 +1919,12 @@ static int nfs_lookup_revalidate(struct inode *dir, const struct qstr *name,
 	return nfs_do_lookup_revalidate(dir, name, dentry, flags);
 }
 
-static void block_revalidate(struct dentry *dentry)
+static void __block_revalidate(struct dentry *dentry, void *sentinel)
 {
 	/* old devname - just in case */
 	kfree(dentry->d_fsdata);
 
-	dentry->d_fsdata = NFS_FSDATA_BLOCKED;
+	dentry->d_fsdata = sentinel;
 
 	/* Any new reference that could lead to an open
 	 * will either:
@@ -1933,14 +1933,13 @@ static void block_revalidate(struct dentry *dentry)
 	 *    after taking the reference.
 	 *
 	 * Holding this lock and invalidating ->d_seq *after* recording
-	 * NFS_FSDATA_BLOCKED ensures we cannot race with
-	 * __nfs_lookup_revalidate().
-	 * If __nfs_lookup_revalidate() doesn't see NFS_FSDATA_BLOCKED then:
+	 * @sentinel ensures we cannot race with __nfs_lookup_revalidate().
+	 * If __nfs_lookup_revalidate() doesn't see @sentinel then:
 	 * In the ref-walk case - d_lookup() will have incremented
 	 * d_count() before we check it.
 	 * In the RCU-walk case - ->d_seq must have been sampled before
 	 * we call write_seqcount_invalidate() below (because it was sampled
-	 * before we set NFS_FSDATA_BLOCKED) so d_count() will have been
+	 * before we set @sentinel) so d_count() will have been
 	 * incremented or the d_seq check will fail in legitimize_path()
 	 * (or both).
 	 */
@@ -1949,6 +1948,16 @@ static void block_revalidate(struct dentry *dentry)
 
 }
 
+static void block_revalidate(struct dentry *dentry)
+{
+	/*
+	 * The caller holds the parent's i_rwsem exclusive, and a shared
+	 * remover's sentinel does not outlive its shared hold of that lock.
+	 */
+	WARN_ON_ONCE(nfs_fsdata_blocked_shared(dentry->d_fsdata));
+	__block_revalidate(dentry, NFS_FSDATA_BLOCKED);
+}
+
 static void unblock_revalidate(struct dentry *dentry)
 {
 	store_release_wake_up(&dentry->d_fsdata, NULL);
@@ -2689,6 +2698,168 @@ int nfs_unlink(struct inode *dir, struct dentry *dentry)
 }
 EXPORT_SYMBOL_GPL(nfs_unlink);
 
+/*
+ * ->unlink_shared(): remove a file with the parent's i_rwsem held shared.
+ *
+ * The lock then excludes no lookup of this name, and no open of it but
+ * one that takes the parent exclusive.  What orders those behind the
+ * REMOVE is the dentry.  While it is hashed it is what every resolver of
+ * the name is handed, and NFS_FSDATA_BLOCKED_SHARED in ->d_fsdata makes
+ * each one that consults ->d_revalidate() after it is stored wait there
+ * until the removal is over: the REMOVE, and the VFS's report of it (see
+ * nfs_unlink_shared_done()).  That works only for a dentry in the one
+ * clean state tested below.  Anything else is handed back with
+ * UNLINK_NEED_EXCL and is done by nfs_unlink() with the parent held
+ * exclusive, as it always has been.  Nothing here silly-renames, and
+ * nothing here waits for another removal.
+ *
+ * An RCU-walk that consulted ->d_revalidate() before the store does not
+ * get past it: __block_revalidate() invalidates ->d_seq after the store,
+ * in the same ->d_lock section, so the walk fails its recheck and waits
+ * in ref-walk.  The one resolver that does get past, as it gets past the
+ * exclusive lock, is set out below.
+ *
+ * NFSv4 sets IOPF_ATOMIC_OPEN_CREATE_SHARED, so an O_CREAT open of the
+ * name takes the parent shared too, and the lock does not exclude it
+ * either.  While the dentry is hashed, such an open is handed it like any
+ * other resolver, and waits as they do.
+ *
+ * The sentinel is not cleared here.  nfs_unlink_shared_done() clears it, and
+ * the VFS calls that after any event for the removal is out, so that an open
+ * released by the clear cannot create the name and have its create event out
+ * before the delete event of the removal it waited for.
+ */
+int nfs_unlink_shared(struct inode *dir, struct dentry *dentry)
+{
+	int error;
+
+	dfprintk(VFS, "NFS: unlink_shared(%s/%llu, %pd)\n", dir->i_sb->s_id,
+		 dir->i_ino, dentry);
+
+	lockdep_assert_held_read(&dir->i_rwsem);
+	trace_nfs_unlink_shared_enter(dir, dentry);
+
+	/*
+	 * The anchor is keyed on the dcache name, and NFS installs no
+	 * ->d_hash or ->d_compare, so names are compared byte for byte: the
+	 * anchor assumes that the server keeps one object per byte string.
+	 * On a server for which "FOO" and "foo" are one object the client
+	 * can hold two independent hashed dentries, and blocking one of them
+	 * makes no resolver of the other wait.  A server that reports itself
+	 * case-insensitive, or as not preserving case, has SB_I_NAMES_COLLIDE
+	 * on its superblock (nfs_server_publish_name_caps()), and the VFS does
+	 * not call this method there; the test here hands back a removal whose
+	 * caller read the bit before it was set.  A server that makes one
+	 * object of other names that differ as byte strings, as Unicode
+	 * normalization does, is not detected, and a removal there is not
+	 * ordered against an open of another spelling; that is a limitation
+	 * of this method.
+	 */
+	if (READ_ONCE(dir->i_sb->s_iflags) & SB_I_NAMES_COLLIDE)
+		goto need_excl;
+
+	spin_lock(&dentry->d_lock);
+	/*
+	 * The clean state, read in the ->d_lock section the sentinel is
+	 * stored in, so that nothing can come between the two.
+	 *
+	 * A count of one is the interlock everything else rests on.  A second
+	 * reference either calls for a silly-rename, which ends in d_move()
+	 * and needs the parent exclusive, or belongs to a resolver that may
+	 * be past its ->d_revalidate() consult and would then unhash the
+	 * dentry without having seen the sentinel.  Every resolver that can
+	 * do that takes its reference before it consults, so with a count of
+	 * one here every resolver that consults from now on finds the
+	 * sentinel and waits.  The readdir guard in nfs_prime_dcache()
+	 * depends on this test and the store staying in one ->d_lock
+	 * section.
+	 *
+	 * One resolver escapes, as it escapes the exclusive lock: an open by
+	 * file handle, whose reference comes from d_obtain_alias() with no
+	 * ->d_revalidate().  It may go on to fail its open, reaching
+	 * nfs_d_drop_unless_anchored(), to open the file that the REMOVE then
+	 * deletes, or to get -ESTALE from the server.  An RCU-walk that
+	 * consulted ->d_revalidate() before the store does not escape; see
+	 * above.
+	 *
+	 * A victim that is no longer hashed and positive is no anchor.
+	 * Nothing between the lookup and here re-tests either, and with the
+	 * parent shared a failed ->d_revalidate() in another lookup, or
+	 * another remover's d_delete(), may have unhashed it since.  That is
+	 * not -ENOENT: a name invalidated locally may still exist on the
+	 * server.  A pending silly-delete on the dentry, or a block already
+	 * present, is for the exclusive pass to answer as well, and both
+	 * tests have to stay ahead of the store: __block_revalidate()
+	 * kfree()s ->d_fsdata, which while DCACHE_NFSFS_RENAMED is set is
+	 * the queued struct nfs_unlinkdata, and a store over another
+	 * sentinel would end that block early.
+	 */
+	if (d_count(dentry) > 1 ||
+	    (dentry->d_flags & DCACHE_NFSFS_RENAMED) ||
+	    nfs_dentry_is_blocked(dentry) ||
+	    d_unhashed(dentry) || d_really_is_negative(dentry)) {
+		spin_unlock(&dentry->d_lock);
+		goto need_excl;
+	}
+	__block_revalidate(dentry, NFS_FSDATA_BLOCKED_SHARED);
+	spin_unlock(&dentry->d_lock);
+
+	trace_nfs_unlink_enter(dir, dentry);
+	/*
+	 * The REMOVE of nfs_safe_remove(), less its silly-renamed case, which
+	 * the tests above hand back; the protocol's ->remove() drops the link
+	 * count itself.  It is copied and not called so that the directory's
+	 * removal sequence moves as soon as the server has answered, whatever
+	 * the answer, and before anything here can unhash the anchor: on
+	 * -ENOENT, nfs_dentry_handle_enoent() does.  See
+	 * nfs_dir_shared_removal_since().
+	 */
+	trace_nfs_remove_enter(dir, dentry);
+	nfs_dir_start_shared_removal(dir);
+	error = NFS_PROTO(dir)->remove(dir, dentry);
+	nfs_dir_end_shared_removal(dir);
+	/* Nothing may unhash an anchor while its REMOVE is in flight */
+	WARN_ON_ONCE(!error && d_unhashed(dentry));
+	if (error == -ENOENT)
+		nfs_dentry_handle_enoent(dentry);
+	trace_nfs_remove_exit(dir, dentry, error);
+
+	nfs_dentry_remove_handle_error(dir, dentry, error);
+	trace_nfs_unlink_exit(dir, dentry, error);
+	return error;
+
+need_excl:
+	trace_nfs_unlink_need_excl(dir, dentry);
+	return UNLINK_NEED_EXCL;
+}
+EXPORT_SYMBOL_GPL(nfs_unlink_shared);
+
+/*
+ * ->unlink_shared_done(): end the exclusion nfs_unlink_shared() installed.
+ *
+ * The VFS calls this for a call of nfs_unlink_shared() that did not hand the
+ * removal back, with the parent still held shared and the event for the
+ * removal, if there was one, already out.  Clearing the sentinel here rather
+ * than at the end of nfs_unlink_shared() is what keeps the notifications for
+ * the name in order: an O_CREAT open released by the clear would otherwise be
+ * able to create the name and have its create event out first.
+ *
+ * Every such call stored the sentinel, both of the tests that hand a removal
+ * back being made before the store, so there is nothing to test for here.
+ * Nor can anything have replaced it: nfs_unlink_shared() anchors only on a
+ * dentry with no reference but the caller's, which the caller still holds, so
+ * no second remover can anchor on it and nfs_d_release() cannot run;
+ * nfs_call_unlink() skips a dentry that is blocked; and every other writer of
+ * the field needs either the parent held exclusive or DCACHE_NFSFS_RENAMED,
+ * which is one of the cases handed back above.
+ */
+void nfs_unlink_shared_done(struct inode *dir, struct dentry *dentry)
+{
+	lockdep_assert_held_read(&dir->i_rwsem);
+	unblock_revalidate(dentry);
+}
+EXPORT_SYMBOL_GPL(nfs_unlink_shared_done);
+
 /*
  * To create a symbolic link, most file systems instantiate a new inode,
  * add a page to it containing the path, then write it out to the disk
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9cd8e5e808..2600ae7865 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -49,7 +49,7 @@ static inline bool nfs_lookup_is_soft_revalidate(const struct dentry *dentry)
  * removal of the dentry's name is in flight: the first when the remover
  * holds the parent's i_rwsem exclusive, the second when it holds it shared,
  * and the second until the VFS ends the removal, after any delete event for
- * it (see the client's ->unlink_shared_done()).
+ * it (see nfs_unlink_shared_done()).
  * ->d_revalidate() waits for either to clear.  The two differ in what the
  * dentry is to the removal.
  *
@@ -73,12 +73,15 @@ static inline bool nfs_lookup_is_soft_revalidate(const struct dentry *dentry)
  * ->d_revalidate(), has to leave an anchor hashed or wait for its sentinel
  * to clear.
  *
- * The shared sentinel is stored and cleared within one shared hold of the
- * parent, so it is never present while the parent is held exclusive.  That
- * is why the two tests made with the parent exclusive, the WARN_ON()s in
- * nfs_unlink() and nfs_rename(), still compare against NFS_FSDATA_BLOCKED
- * alone.  They are the only bare compares against a sentinel; every other
- * test uses the helpers below.
+ * The shared sentinel is stored in nfs_unlink_shared() and cleared in
+ * nfs_unlink_shared_done(), which the VFS calls while it still holds the
+ * parent shared, so it is stored and cleared within one shared hold of the
+ * parent and is never present while the parent is held exclusive.  That
+ * is why the WARN_ON()s in nfs_unlink() and nfs_rename(), made with the
+ * parent exclusive, still compare against NFS_FSDATA_BLOCKED alone, and
+ * why block_revalidate(), which both call, warns if it finds
+ * NFS_FSDATA_BLOCKED_SHARED.  Those WARN_ON()s are the only bare compares
+ * against a sentinel; every other test uses the helpers below.
  */
 static inline bool nfs_fsdata_blocked(const void *fsdata)
 {
@@ -611,6 +614,8 @@ struct dentry *nfs_mkdir(const struct mnt_idmap *, struct inode *, struct dentry
 			 umode_t);
 int nfs_rmdir(struct inode *, struct dentry *);
 int nfs_unlink(struct inode *, struct dentry *);
+int nfs_unlink_shared(struct inode *dir, struct dentry *dentry);
+void nfs_unlink_shared_done(struct inode *dir, struct dentry *dentry);
 int nfs_symlink(const struct mnt_idmap *, struct inode *, struct dentry *,
 		const char *);
 int nfs_link(struct dentry *, struct inode *, struct dentry *);
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index a32c76df72..99393ebc7e 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -748,6 +748,8 @@ DEFINE_NFS_DIRECTORY_EVENT(nfs_remove_enter);
 DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_remove_exit);
 DEFINE_NFS_DIRECTORY_EVENT(nfs_unlink_enter);
 DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_unlink_exit);
+DEFINE_NFS_DIRECTORY_EVENT(nfs_unlink_shared_enter);
+DEFINE_NFS_DIRECTORY_EVENT(nfs_unlink_need_excl);
 DEFINE_NFS_DIRECTORY_EVENT(nfs_symlink_enter);
 DEFINE_NFS_DIRECTORY_EVENT_DONE(nfs_symlink_exit);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 3e86449485..7ccdc5b867 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -697,12 +697,11 @@ static inline bool nfs_ooo_test(struct nfs_inode *nfsi)
  *  - NFS_FSDATA_BLOCKED, while a REMOVE of the name, or a RENAME onto it,
  *    is in flight with the parent's i_rwsem held exclusive.  It outlives
  *    that hold only when a rename is killed, until its RENAME completes;
- *  - NFS_FSDATA_BLOCKED_SHARED, from the store in the client's
- *    ->unlink_shared(), with the parent's i_rwsem held shared, until its
- *    ->unlink_shared_done(), which the VFS calls after any delete event
- *    for the removal, whether or not it succeeded, and before it drops
- *    that hold.  The dentry may be negative, or positive and unhashed,
- *    by then.
+ *  - NFS_FSDATA_BLOCKED_SHARED, from the store in nfs_unlink_shared(),
+ *    with the parent's i_rwsem held shared, until nfs_unlink_shared_done(),
+ *    which the VFS calls after any delete event for the removal, whether
+ *    or not it succeeded, and before it drops that hold.  The dentry may
+ *    be negative, or positive and unhashed, by then.
  * Both sentinels are stored under ->d_lock and cleared by
  * unblock_revalidate(), and ->d_revalidate() waits while either is set.
  * fs/nfs/internal.h says what else has to respect them.
-- 
2.43.0

