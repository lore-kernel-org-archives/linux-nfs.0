Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297427;
	b=G4DFw400adjMOh+tUls8kw+xPCBPnKI09DGZTXMco3jvkrUIsWwMW0uRF//MHrnMqJRB
	 ka3DF/fj5agWBCsuiJSz0FlyO1HfGi+vQo3yKZ9Q3vcqQ2BlE9RCfSM91vJR4v6ekXRC3
	 eIWrWFWjIHbk/M2FYFtEUx5leGCbL9EoXh0Jmx4BFKyjcFI7hjCEPCOTNy5TUSAyrqZcs
	 b9lOBzwj/jhJUsFqMA7M/hZ0bOaXU04Pi1Vtk1/peNgSYYq1WgPxHuGbkYF7NrJBfA0rN
	 a2ug2iHp2Y1DbmHzJDrsbWDeUiUa9lVZfQywac6cUO6WKtg1IaMz0fXCI4S9/b8IOAA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297427;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=SzS3inKuIzObQRIJP0XLNfoskd/GgXHCSXyF9Wdht4c=;
	b=oNnCrvNIUsI1e6z2EuhJvvlTHKLaomp7XC0OO2EVZnkpzVsa7L+6LzjDdwUhTZRlNVcR
	 UquR009mdbnIIh357N1gcQbH6+dlCLDGHo8SOeLWke1RSAVgye0qtIKZU+qTISVD9HxHh
	 cmEaJnh/tzxplX9xSfYjYASjnudEQMp96Moc1NS4MjowDTveLUUT+TLz/i5IFj7XsuPp+
	 VdkIBdxkOgNT1gCPzpkW/figIpXv2ZdnYvcn0zmRptY76zaZBK/ZLO+tmEetZgvvRl16u
	 SEsXGhtlQL3m8eqNtRZ1b3aBf0YWCVpO5XmL1ftW6kfr7wU5JOFLgUon4CDLtxrK5Qw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=HCQaAvkJ;
	arc=none smtp.remote-ip=209.85.210.50
Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A242360A381D
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:10:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A242360A381D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=HCQaAvkJ
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-843b6f8e2c7so2733243a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:10:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297425; x=1793902225; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=SzS3inKuIzObQRIJP0XLNfoskd/GgXHCSXyF9Wdht4c=;
        b=HCQaAvkJ/BlYzUKBgPx6FYAly7bYB6v2l+zGLRA8QBqfS0Q+3X6beLcpk8M243IQa5
         GNSSRWHaya5Me9rh6sTlLJjWW0B0wctrcnNbOqA8LKi+AHSi0ayF0bwhr02D+MhFHNj/
         nLatmgmrp8PX7qscpAZe5r9ARzedXvt54XWHfHAuiuI9sq2Jj08Nha93kVmGwzLsBr1U
         XWF+G8a2+qp5HHdYB5P9S5kvM3aHRms2ylSPwmxzUK5AZG1cUIT31e41r2lU12MWavMk
         ruJxnlrj9EsSbmxAiE3EtmYDq07FLHj3UdSsS2EeMZCusmQq53jUls9KgQ5Nc44H2TRj
         IvHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297425; x=1793902225;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=SzS3inKuIzObQRIJP0XLNfoskd/GgXHCSXyF9Wdht4c=;
        b=fUATV5VgV6OYKlrQvTNF7lf5rd/2rpFy+0IvHKqRZTBxAPvnCVNCmMafkncQtbwOE+
         WOXvnBX35gmEYmpNHV4Q9Dv/qr74iH9/YSM/uLg5UBTzlAQZJdeoGaLkyugdAR/UWkWT
         cvGEECXmwLxAINxUmFHfp8wJohREkGkQ6b3ok8zo+uguYQfOi+a/MVwCF2iqvN5gslvq
         iY6OgRGZ7kYd3XvasewcQPqf8Bos8ivkhO6Q5QpblqjM9AFqup4nQOxezjxc47INkM0c
         jnzSzf8FnAkOwXtfbrAl1cLK6oYe4tsmNX+D/+VmIB5kjiwh9jHFgZi95mqlji7Lli4j
         tMVg==
X-Forwarded-Encrypted: i=1; AKwUvBwul51oM48NafzyNQXJCDeDi3QnHHfxMwfJOVWynqde91CnnStgYluXgm7b3m0nTIrhkHjfMzVpWbs=@vger.kernel.org
X-Gm-Message-State: AFq9FYJhbx6ARGkKy86vJrHjroyGKAPH3VHhJzAGPTJ2de0J30dwtzBh
	rofT48RfR7HR5a8R9on7xMwEfj4kOH8oKmGdbX0HvMD5O6gQIGEfxpTjrIlrTuI/MH4=
X-Gm-Gg: AYBFou0S76r/s2yk6wxa6FmneBOf+dYInFRi15dMItDGF/peFCZDBqTruoGuUMB1TOs
	kLQ8Q4K3vbRC9IKtNg/avnz92ZHiSR0QNpFMJ5O4KFxAtF/SLcXuRJjCZ2FD+10Evm8D/UDhumy
	yOqxzyphiyz/fPquJe5i9d6QAFc7bAwC32I2wZHOMwk1nPeGsXbUYAiTaC/NzuxoOrnOcgHiIm0
	RVHiPy2ZPTeg64daMo5V7wrBlsRQvWSxGPpKAyWhbgIjdSeYa7fXp51wgJz6uQv35R1YAwwoJRk
	5XOsYPgxoco5fj1RDLC7V5XIdWtvMeaXsX2AJsHOC9KbjJOmuoAKv85kgOY7FNVGw6yXPQALPJr
	voCuhSZBicNqGAKyxHP9k8EyG0iFE4GMQtSqKaLZo9XeFPfXsfHsK05Mn0UbirvMbTtWq5hIwEq
	TiE9A7Jv0FT4EM+sEPUyBgcEKuEHR8px4NsaD95+RcPPplcp9pvMhGLqJqfDKwveNGStRlRX0S4
	qhQD6XGgX73RZPWr+0wWfSiHoQEebLscgsNzcfBPW3CMGCAxNrIoUDvEsSLs2AA2G0WjOOXYx64
	n0HSL6dMLvxjXSHXLuvdnzbB3kSSofAdnGFRmHSge1Aag6ANkfkbOxMU8cGKeVkJim51wQvQ
X-Received: by 2002:a05:6830:4120:b0:826:1ccc:8bb9 with SMTP id 46e09a7af769-85ab7040645mr5227606a34.6.1793297425401;
        Thu, 29 Oct 2026 11:10:25 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-85d351e9684sm187806a34.3.2026.10.29.11.10.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:10:24 -0700 (PDT)
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
Subject: [PATCH RFC 11/12] nfs: look a name up again once its removal has unhashed it
Date: Thu, 29 Oct 2026 12:09:56 -0600
Message-ID: <20261029180957.387138-12-jonathan.flynn@hammerspace.com>
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

An open or lookup of a name can wait for a removal of the same name made
with the directory locked shared, and is then ordered after it.  When
that removal succeeds while the waiter still holds the name's cache
entry, the entry is only taken out of the cache, not emptied, so the
waiter is left holding an entry for a name that no longer exists.
Revalidation can then accept it: an open without O_EXCL is sent to the
server for the removed file, and if the client holds a delegation for
the directory, an exclusive create of the name fails with "file exists".

When NFSv4's revalidation has waited for such a removal and finds the
entry out of the cache once the wait ends, have it answer that the entry
is invalid, so that the name is looked up again;
__nfs_lookup_revalidate() now reports whether the mark it waited for was
the shared one.  Without such a wait, an entry out of the cache goes
through the usual checks, as before.  Its holder may be unable to look
the name up again: overlayfs revalidates the entries of its lower layers
itself, and an answer of "invalid" for one that a transient error took
out of the cache would leave the overlay reporting it stale until it
dropped its own entry.  A lookup that took the entry while the removal
was in flight but finds the mark already clear is not covered either;
it overlapped the removal, so the old entry is still an answer it may
be given.

This relies on the VFS taking the entry out of the cache before it calls
->unlink_shared_done(), which clears the mark, and on the wait reading
the mark with acquire ordering, which pairs with the release in the
clear: a lookup that finds the mark clear, whether it slept or not, then
also sees the entry out of the cache.  A removal made with the directory
locked exclusive, and a rename onto the name, can clear the mark before
the entry is taken out of the cache; say so at the wait.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---
 fs/nfs/dir.c | 50 +++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 43 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 0b6de87030..1f255001a1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1889,6 +1889,11 @@ nfs_do_lookup_revalidate(struct inode *dir, const struct qstr *name,
 	return nfs_lookup_revalidate_done(dir, dentry, inode, error);
 }
 
+/*
+ * Answers -ECHILD under LOOKUP_RCU while a removal of the name is in
+ * flight.  Otherwise waits for any such removal to end, and answers 1 if
+ * the one it found was made with the parent held shared, else 0.
+ */
 static int
 __nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 {
@@ -1898,15 +1903,28 @@ __nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 			return -ECHILD;
 	} else {
 		void **fsdata = &dentry->d_fsdata;
+		void *mark;
 
-		/* Wait for unlink to complete - see unblock_revalidate().
-		 * smp_load_acquire() ensures ->d_fsdata is read after
-		 * ->d_seq was read, matching block_revalidate() which
-		 * sets ->d_fsdata before ->d_seq.
+		/*
+		 * Wait for unlink to complete - see unblock_revalidate().  One
+		 * load, as there are two values to test.  smp_load_acquire()
+		 * ensures ->d_fsdata is read after ->d_seq was read, matching
+		 * __block_revalidate(), which sets ->d_fsdata before ->d_seq.
+		 * The acquire in the wait pairs with the release in
+		 * unblock_revalidate(): a waiter that finds the mark clear
+		 * sees what the remover did before clearing it.  For a removal
+		 * made with the parent held shared, that includes the unhash of
+		 * a dentry it took away, as the VFS calls d_delete() before
+		 * ->unlink_shared_done(); nfs_unlink() and nfs_rename() may
+		 * clear the mark first and unhash after.
 		 */
+		mark = smp_load_acquire(fsdata);
+		if (!nfs_fsdata_blocked(mark))
+			return 0;
 		wait_var_event(fsdata,
-			       /* one load: there are two values to test */
+			       /* acquire: pairs with unblock_revalidate() */
 			       !nfs_fsdata_blocked(smp_load_acquire(fsdata)));
+		return nfs_fsdata_blocked_shared(mark);
 	}
 	return 0;
 }
@@ -1914,7 +1932,7 @@ __nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 static int nfs_lookup_revalidate(struct inode *dir, const struct qstr *name,
 				 struct dentry *dentry, unsigned int flags)
 {
-	if (__nfs_lookup_revalidate(dentry, flags))
+	if (__nfs_lookup_revalidate(dentry, flags) < 0)
 		return -ECHILD;
 	return nfs_do_lookup_revalidate(dir, name, dentry, flags);
 }
@@ -2329,10 +2347,28 @@ nfs4_lookup_revalidate(struct inode *dir, const struct qstr *name,
 		       struct dentry *dentry, unsigned int flags)
 {
 	struct inode *inode;
+	int ret;
 
-	if (__nfs_lookup_revalidate(dentry, flags))
+	ret = __nfs_lookup_revalidate(dentry, flags);
+	if (ret < 0)
 		return -ECHILD;
 
+	/*
+	 * A removal made with the parent held shared that succeeded while
+	 * this lookup waited for it, holding the dentry, has left the dentry
+	 * positive but unhashed: d_delete() empties a dentry only for its last
+	 * user.  The dentry no longer stands for its name, so have the caller
+	 * look the name up again; the checks below could accept it, since
+	 * with a directory delegation the removal stamped it delegated.  Only
+	 * ref-walk waits, so this never answers 0 under LOOKUP_RCU.  A dentry
+	 * found unhashed without such a wait is left to the checks below, as
+	 * before: its holder may be unable to look the name up again, as
+	 * overlayfs is for the dentries of its lower layers, which it
+	 * revalidates itself.
+	 */
+	if (ret && d_unhashed(dentry))
+		return 0;
+
 	trace_nfs_lookup_revalidate_enter(dir, dentry, flags);
 
 	if (!(flags & LOOKUP_OPEN) || (flags & LOOKUP_DIRECTORY))
-- 
2.43.0

