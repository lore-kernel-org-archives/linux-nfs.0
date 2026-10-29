Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297417;
	b=ZWKqgEkhWILPA9M8h8S3rAtQUQDu2FD6ouUGCY8fYp9loMGqHVrda3Az/DwDhWwe2zc9
	 nvkwgT93RlgxRBTZAIY+WPrdvQvdMB2i2iHCIPN61oULK8YmmdnV0nlnQIgjZT9pdcxHi
	 JKaUosEBbZHiR0EbSbrL/zeEnt5vq0fYmLJe/19G/oZ9YnSYQ0TZF41gACROwBQmJKXhp
	 SjFECyAmPIlmnG1UdMp466i0vJDleRyQ6btcQG9UQllhYVv9ZobPdZgmrat2yLlV5ZPpO
	 x/JHVcSo5XywwyZYb+QGKLjMG46gope8qxpO5ZFixElFP3PTGUj3dbb0QKih8WpdOIw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297417;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=DJ2DAyUZ/cE8PWYufte6QskZeIdiAS+8BIHT7ee4M9A=;
	b=2O/3rVM8egXeO5JCbP+R6enPt9f0FXNEh/qYx3ugTX9Yn9H9E18GA+QmVBAraWkT4v1v
	 dZjkRtwJTTu0fEfAfRdW0LCSph1RI2HdK8y6ul/LsNTLMTfdJhYRx9d1dr4YAWX+omRA3
	 G5Se87HrA+NB9mcaKGtRQZ2Q1VVnMholspDK2KYzc9gGBkKr5lABGuatAaLogsC9elP13
	 L0tGCP2/7k5I3XMt5KaIc8Aag5qzMvYa6Tj1hGRsiysWpP9MJJUvmfNaCz2XH4P9KvoeZ
	 aPkG8/jE7O6BdmonUaishU1i75Y7+HzKgUM7T9CC9d+9C+mipG/7lmL+7eTOdZi7IxQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=n5Ycg7Ix;
	arc=none smtp.remote-ip=209.85.210.53
Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com [209.85.210.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16A22606AB4D
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:10:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 16A22606AB4D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=n5Ycg7Ix
Received: by mail-ot1-f53.google.com with SMTP id 46e09a7af769-83bbcfba0ffso1851029a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:10:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297416; x=1793902216; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=DJ2DAyUZ/cE8PWYufte6QskZeIdiAS+8BIHT7ee4M9A=;
        b=n5Ycg7IxyZ+K65mf71RWcIDKfS2t3bQ1TMnTVvBEHF/qTOn8KHah5qx/iuaDmb0YCr
         AbogfBSMjHHUVO6j7S42cuw8dxSO2XuLXYxAcEYk/c6TUBHa4koTsGhBhVOcyPyzOOig
         Gkf0lC3j2BgUBb22KiadsllXwF6xONDrHxisxOMzk8U7+VLj3z7Hy/kbi1M0m99h/gXQ
         MY7QMxI4MCT23si6o0qTNVhd2Os7ijq8tTT5aO+FYwhAW7boMuui+yBWbPihESGwf4zI
         TgHJMhmie8psihtkrQiKu/mVgNrN2GVpvetVKtl7Xs3KqnV1w9UjkLYc5yAnmkhW0Vue
         DtSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297416; x=1793902216;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=DJ2DAyUZ/cE8PWYufte6QskZeIdiAS+8BIHT7ee4M9A=;
        b=FD2S/qboFI1a51VKXvr/0dvZ34ogHa/yDpvlu49nSd02Yh/VUXcdLI65aWZcy2zec0
         /zp9Fuvj+EUz3LZ5epVpC8sfiL/Eq7b+xbbnBnw4TqMDqOJuRnVBZQngnNxUI1utkYfL
         QRARZwDx1p0OPqHn685TJuDTJ2IHgsTT0yn5FrjKyjeNZ5NzRkf6j13in/mpkqOZAFhv
         /Jg0Mru53ZOodAiCmPoLhGOiMZsZY0m8mEzjLdUVj+g0uNNyYEKnv4M0mfGEcbI+YnsP
         b3iXp/oBoVKfvXCr7lwHosjf7No3zYqWJPwKwQQcXOdJC1y639kgBpsqLWltIuoYQFeT
         OeZg==
X-Forwarded-Encrypted: i=1; AKwUvBx+LNjOxC37p5gEA8nAjyBr7VRW6MPng1/+yKlO5YimLSv1DYObmIZrkjsoRlNzhRi4Xhyp5AK0md8=@vger.kernel.org
X-Gm-Message-State: AFq9FYLT96NR7QH45XOhcLUcHXXSde0i07w5e4C8R/YGCyG27GC/cV4o
	ETWXP4NbkvXdjP2qan/MqpiT8bs/cJN6AgqP4J+5AEfXEgTnSdrg+kbqu8CQyAAZDMk=
X-Gm-Gg: AYBFou1Y7G5MDzKLGA5IaIpf/5REEoSq7OPYfkl7JfE+LZXKbfnEV/1dN9mtfz4KB1z
	1zcZ/slN5QBJG5lEovJlSTMtULkB3j2oiU80mpI6NEVkRKMs6xjtSkWIxRciJ8styCwdTqLgXcV
	+DYZLlssmUAYSTOCf92F1ariZWg4EYfUVhreJ2WpD/qNx0Z3KjxGPJ6US5dk4vYYmPQvTCAh/2o
	1tARktNEeuAvENvnlpqZOaa9/jGVcwPF4ib6OTS5d4ZzCROrpcn/n0x5gxz76kxCgOIiIbjfiCk
	BT2vo4l/YZ9VnP8q+TeIoFw82lCrs098yEw0zOu4jOeDs8VlQB2ghOiI/pwK832QS874r/WWywH
	VSfk2TVjbrT5hNV4+uDReSDcdnyzKSahlTt7tFmZSKA+9LgPPKHwnO5iSI4cQliYFwZhmAoIw2K
	6CWPbjZXRAgfaypxlq1hsWk0BDc3N4Q2H3/e0bKnvdIOfFxq67C1ryFGur7YHYUymAvL9rGG5ed
	B7vEnx/9efzMjWlhCAkG8WsZTPTA1Kr/mvWvyOp+IjkrRHGp508J+CpFcQZ1uo0Z+5eVSeyEUp8
	6iF2JvG3cRd+4bNZ++gATHO6tLzgW2y7afJF4QHnwNO4JHMeDmcyM9stziy+WyCz4tYfyr6hYWW
	GbhP9QAGGRVbgTr08uw==
X-Received: by 2002:a05:6808:1b27:b0:53c:7298:3598 with SMTP id 5614622812f47-56382b885d6mr4651460b6e.31.1793297415482;
        Thu, 29 Oct 2026 11:10:15 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-563c5a4d8b7sm4093861b6e.8.2026.10.29.11.10.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:10:12 -0700 (PDT)
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
Subject: [PATCH RFC 08/12] nfs: keep the dentry of a shared-parent removal hashed
Date: Thu, 29 Oct 2026 12:09:53 -0600
Message-ID: <20261029180957.387138-9-jonathan.flynn@hammerspace.com>
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

With the directory locked shared, a removal stays ordered against
lookups and opens of the same name only through the name's dentry,
whose ->d_revalidate() waits while the dentry is marked.  Three paths
act on a cached dentry without that wait: nfs_prime_dcache(), which
unhashes a dentry that a directory listing disagrees with and
otherwise refreshes its inode from the listing; nfs4_file_open() when
the open fails; and recovery of open state.  Make each of them leave
a dentry marked by such a removal alone, so that it stays hashed until
the removal itself deletes it, and so that a listing that may predate
the removal does not stop the removal from dropping the link count.

Have nfs_prime_dcache() also leave alone a dentry that has been
unhashed.  When the listing holds a reference, a successful removal
unhashes the dentry, rather than making it negative, before it clears
the mark, and a refresh from a listing that predates the removal could
then put back the link count that the removal took away.  Without that
reference the removal makes the dentry negative instead, and the
listing treats the name as one it has no dentry for: the case that
"nfs: do not cache a name from a listing that a removal overlapped"
handles.

Of the three, only the listing runs beside such a removal by design,
since it holds the directory shared too.  The other two hold no
directory lock, and can meet a marked dentry only through a reference
taken after it was marked, by a path that does not wait for the mark:
an open by file handle, which NFSv4.1 and later mounts support.  A
lockless path walk that checked the dentry before it was marked fails
its recheck and retries, because marking it also invalidates the
dentry's sequence count.

Nothing marks a dentry this way yet, so the one change is that
nfs_prime_dcache() leaves alone a dentry that something else has
unhashed, rather than refreshing its inode or caching a replacement
for it.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---
 fs/nfs/dir.c      | 42 +++++++++++++++++++++++++++++++++++++++
 fs/nfs/internal.h | 50 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4file.c |  9 ++++++++-
 fs/nfs/nfs4proc.c |  3 ++-
 4 files changed, 102 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 68a1e578e1..2a4c059064 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -756,6 +756,48 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry,
 		return;
 
 	if (!d_in_lookup(dentry)) {
+		bool hands_off;
+
+		/*
+		 * Leave alone a dentry that a removal made under a shared
+		 * parent anchors on, or that has been unhashed.  readdir holds
+		 * the parent shared as well, so it can run beside such a
+		 * removal, and while the REMOVE is in flight neither of the
+		 * two things done below is safe: unhashing the dentry would
+		 * let a lookup or open of the name overtake the REMOVE, and
+		 * refreshing its inode from this reply would advance the
+		 * attribute generation that the remover's nfs_drop_nlink()
+		 * compares against, so that the removed file kept its link
+		 * count.  Nor is a refresh safe once the REMOVE has succeeded,
+		 * since this reply can still list the name: on a server that
+		 * reports how its change attribute behaves, nfs_refresh_inode()
+		 * takes attributes with a newer change attribute whatever
+		 * their generation, and would put back the link count that
+		 * the removal took away.
+		 *
+		 * Both are tested once, before anything else is done with the
+		 * dentry, in a ->d_lock section of their own.  This caller has
+		 * held a counted reference since before the test, and the
+		 * remover stores the sentinel only on a dentry whose count it
+		 * reads as one in the section it stores in: either the remover
+		 * sees this reference and hands the removal back, or the
+		 * sentinel was stored first.  If the REMOVE then succeeds, the
+		 * VFS calls d_delete() before ->unlink_shared_done() clears the
+		 * sentinel.  A d_delete() that finds this reference only
+		 * unhashes the dentry, under ->d_lock, so a test that finds the
+		 * sentinel gone comes after that section and sees the unhash.
+		 * One that ran before this reference was taken left the dentry
+		 * negative instead, and the code below drops a negative dentry
+		 * and treats the name as one it has no dentry for.  -ENOENT
+		 * ends either way too, through nfs_dentry_handle_enoent(), and
+		 * any other failure leaves the file in place.
+		 */
+		spin_lock(&dentry->d_lock);
+		hands_off = nfs_dentry_is_shared_anchor(dentry) ||
+			    d_unhashed(dentry);
+		spin_unlock(&dentry->d_lock);
+		if (hands_off)
+			goto out;
 		/* Is there a mountpoint here? If so, just exit */
 		if (!nfs_fsid_equal(&NFS_SB(dentry->d_sb)->fsid,
 					&entry->fattr->fsid))
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7cda8b7b3f..907ea27ea2 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -102,6 +102,56 @@ static inline bool nfs_dentry_is_blocked(struct dentry *dentry)
 	return nfs_fsdata_blocked(READ_ONCE(dentry->d_fsdata));
 }
 
+/*
+ * Does a removal made under a shared parent anchor on this dentry?  The
+ * caller holds ->d_lock; READ_ONCE() as in nfs_dentry_is_blocked().
+ */
+static inline bool nfs_dentry_is_shared_anchor(struct dentry *dentry)
+{
+	lockdep_assert_held(&dentry->d_lock);
+	return nfs_fsdata_blocked_shared(READ_ONCE(dentry->d_fsdata));
+}
+
+/**
+ * nfs_d_drop_unless_anchored - unhash a dentry unless a removal anchors on it
+ * @dentry: dentry to unhash
+ *
+ * As d_drop(), except that a dentry carrying NFS_FSDATA_BLOCKED_SHARED is
+ * left hashed: a removal of its name is in flight under a shared parent,
+ * and unhashing the dentry would let a lookup or open of the same name
+ * overtake the REMOVE.  The test and the unhash are one ->d_lock section,
+ * and ->d_lock is the lock the sentinel is stored under.  The sentinel is
+ * all that is consulted - not the parent's lock and not its operations
+ * table - and a further condition, if one is ever added here, has to come
+ * after that test, not in front of it.
+ *
+ * The callers hold a reference to the dentry and no lock on the parent.
+ * The remover anchors only on a dentry that nobody else holds, so they can
+ * meet an anchor only if that reference was taken after the sentinel was
+ * stored, by a path that did not then consult ->d_revalidate(), which would
+ * have waited.  An RCU-walk that consulted ->d_revalidate() before the
+ * sentinel was stored is not such a path: the store is followed, in the
+ * same ->d_lock section, by write_seqcount_invalidate(), so the walk's
+ * ->d_seq recheck in legitimize_path() fails and it retries in ref-walk,
+ * where ->d_revalidate() waits.  An open by file handle is such a path:
+ * its reference comes from d_obtain_alias().
+ *
+ * The sentinel is cleared without ->d_lock, so the test can still see it
+ * for an instant after the REMOVE has completed and leave hashed a dentry
+ * that would otherwise have been dropped.  That direction is safe: the
+ * remover's own d_delete() normally unhashes the dentry, and an open by
+ * path that returns -EOPENSTALE is retried by the VFS, first in ref-walk
+ * if it was begun in RCU-walk and, if it fails again, with LOOKUP_REVAL,
+ * whose ->d_revalidate() asks the server.
+ */
+static inline void nfs_d_drop_unless_anchored(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	if (!nfs_dentry_is_shared_anchor(dentry))
+		__d_drop(dentry);
+	spin_unlock(&dentry->d_lock);
+}
+
 static inline fmode_t flags_to_mode(int flags)
 {
 	fmode_t res = (__force fmode_t)flags & FMODE_EXEC;
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 9a434f5dda..ccb801ab38 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -101,7 +101,14 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	return err;
 
 out_drop:
-	d_drop(dentry);
+	/*
+	 * Unhash, unless a removal made under a shared parent anchors on
+	 * the dentry.  For an open by path, -EOPENSTALE makes the VFS redo
+	 * the lookup either way, and that lookup waits for the removal in
+	 * ->d_revalidate(); an open by file handle is not looked up again,
+	 * as it never was.
+	 */
+	nfs_d_drop_unless_anchored(dentry);
 	err = -EOPENSTALE;
 	goto out_put_ctx;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 808bb8f1c1..fbf9e97815 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2791,8 +2791,9 @@ static int _nfs4_open_expired(struct nfs_open_context *ctx, struct nfs4_state *s
 	 */
 	opendata->o_arg.open_flags = O_DIRECT;
 	ret = nfs4_open_recover(opendata, state);
+	/* Unhash, unless a removal under a shared parent anchors here */
 	if (ret == -ESTALE)
-		d_drop(ctx->dentry);
+		nfs_d_drop_unless_anchored(ctx->dentry);
 	nfs4_opendata_put(opendata);
 	return ret;
 }
-- 
2.43.0

