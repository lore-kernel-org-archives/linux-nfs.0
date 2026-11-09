Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794256653;
	b=xnf9Yb9miUPICKZ4LU/6Wi93ENr1/v+JACEI1ddE1SNc8DXX2jFFR8YaGp9nlHTFieIN
	 mOozt47+B52jljG9PWKU3bgzsGL4QAZwqA1t5FSIGC/LndnWviAnZex/e0l2F2+M+HHIr
	 Jha/AYBEAWojBHw2+sdVkpIdWcu0DYPYVqzISan3mpu7ngBzE+hTkss1rdeEaj51x6Y7p
	 HMUjZ2I/wraPPiM9MeLYnWK3JLcy80jK6/ii9kOz+IXoSOPFknKIMpD+J6WlCJHDPha1G
	 IUETErmmLKmPa6jZm1i3JcSOk+7R8+wxklna/XGQRO3o/ri6JpuFEx2QnfkBW1qxPZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794256653;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=M4LGor6pRRJPQWUsoALuLp2en+PJOzlSuC08jgfdS9k=;
	b=RVPdsrBN526F1V9dWdE3xCqMPEdmH6aKT1XOMkbrdd5hElH8aA8KFYieDdDh6fiI6Hea
	 89GG22zLsRgddaksjYgoNmLIo0R9bZI4bboUfpDIm8QX3fXQKaVfmNnRn5+kD/UC57MuY
	 NkTywehzAjlJrLYMIygEMLPSPPR+4n6i4umN3mUWKB2F1y4NrdrY3mSB5Q8sreG/rMpGu
	 xPsb8yJxQtwqmK9XSzeytlsVYiOHHCCTaj9Dzs+6nQqHdu1+zLxKPqeIEJSH0+tpT0Y2U
	 2iNiZuF0jWQUg1gwlJGkOodNVma1uM+GaQosU5hjXvZ+LrJ37UN9JfdbBXuWgFrA5FQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WowX2hE+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1039160A2610;
	Mon,  9 Nov 2026 20:37:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WowX2hE+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B001A1F008BF;
	Mon,  9 Nov 2026 20:37:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794256652;
	bh=M4LGor6pRRJPQWUsoALuLp2en+PJOzlSuC08jgfdS9k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WowX2hE+VNMm5AadyRfixW+darbRy+TikpKKk1c7iV6pM47y9y5GD9c89Ho0d7l2O
	 DJV4tLTMaPRp5KgMG4drWR569MnEEId2/e4SOoN90czexsAhwOMdvnizEGj35aVL2A
	 wcUg491fHwTfAFW/jXF3vBON+6oLkwVf7/FTw1P+hZM6HzdhddcMY5gPMfQ0gLz8lv
	 o+xUy/A/h87uCH3wO8bRhdvDosNfcTpfd6r2CzwlwUY/9yP0rJ/VuT9zhKQl5SdWRI
	 XL/fKfuj7oKODe6v2dF8s9wit6HPf6dBPsNIP40+C9JmylpMIE1CH+WzUEB4dLj8+Q
	 no8Pq4s1ukLgg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:36:44 -0500
Subject: [PATCH v3 3/8] nfsd: don't stamp over an applied delegated mtime
 at DELEGRETURN
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261109-deleg-cb-getattr-times-v3-3-710c7244a6ea@kernel.org>
References: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
In-Reply-To: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=7756; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=p+jtrCV6W0z5bVFmKR0AH25Ah/r3PDPnwycdscNlV7g=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8i79pN1b07eUdbMvrjOxeNCuFPy75tShXL2kY
 aVNTH3zajaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIu/QAKCRAADmhBGVaC
 FeZeD/43zm1VBddo4CnjicQBfVvbcxBk/4kLtvxBVC7gIcLh/Y8bzvUhZ5z1JJNTEJJ/Q0JXWkX
 O15VIJr9lZPDj2Tuw9zmV/C6Ypo93yjkf1Vn/NVQC127Qo1aHNhY8cpfuxrRr8TT7EXbw8jyr2O
 7olTczjgaW8neLko5pj3iNi0v1dWqQX2ALz5FpG1tvrPit3cMwKIJ15gIqIMjcH9kPMN0dDtcmH
 MGIQd0zkeh7UYIoUUNprHSWwsjvXbIVtFQV5F+++AuYBYQPtdgwwUriJ6s2Q52nydO3zySnFpF4
 pwwFUXA7/YuY281dNHxjhc1Kz/UctIrvvrIEnmV74YcXj2KenIU9+Oav9olJx/eQDxSd11oqkRV
 l+VRFJWg4JlNECZZ2UCBRk4T8XW/di6+nUcDmHfnD/wwCuHNdp7TZ9adno+ZCb3zlLKgIisUeiI
 mFYH1xorqKSJTUl+3o/E7RQvgXEhYHM07NsAZzVarjaKHgcHLxquOubijFTDgT1/5FyRHRzVnoL
 UcSa47ufnI3NU90ISx55m5uIvjegU88OkDwLRuY9RUWOfcfmlbOnnBUfIjMWYv7ieWjV/4ky1Ae
 t3F8/Z7+gS/CiO2O5F/enO+PR0fHAcbIk8h3t52W5kvFojOylOdDVYx22cfnpv59ck0wS0YGemk
 oMQAEq59TY/gnDw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_finalize_deleg_timestamps() stamps a/m/ctime to "now" at
DELEGRETURN when the file was written and dl_setattr is clear. But
dl_setattr is only set when both the mtime and ctime vets pass:

- nfsd4_vet_deleg_attrs() applies the holder's mtime but leaves
  dl_setattr clear if that mtime doesn't pass dl_ctime. A client mtime a
  fraction of a millisecond behind the server's ctime at grant is
  enough.
- cb_getattr_update_times() applies the holder's mtime but never sets
  dl_setattr.

Either way, DELEGRETURN then overwrites the mtime the holder supplied
with the return time. Seen as git t1092 failures over NFSv4.2: an
untouched file's c/mtime jump ~25s after git recorded them.

- Set dl_setattr whenever the holder's mtime is applied. Test it under
  inode_lock at DELEGRETURN, so a racing CB_GETATTR reply's mtime isn't
  stamped over.
- If that mtime doesn't pass dl_ctime, set ctime to the current time
  instead of leaving it at its grant value. DELEGRETURN no longer
  stamps it, and where the change attribute derives from ctime (no
  i_version), it must still move across the holder's writes. dl_ctime
  is recorded from the inode, so later vetting sees that ctime. RFC 9754
  specifies the change time only when the mtime exceeds it; RFC 8881
  section 10.4.3 says the server SHOULD keep time_metadata and change
  from going backward.
- Have SETATTR and CB_GETATTR share nfsd4_vet_deleg_attrs(), so their
  vetting can't diverge again.

The client fix "NFS: don't let delegated c/mtime stamps go backward"
makes the ctime case rare.

Fixes: e5e9b24ab8fa ("nfsd: freeze c/mtime updates with outstanding WRITE_ATTRS delegation")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 82 ++++++++++++++++++++++++++++++-----------------------
 1 file changed, 47 insertions(+), 35 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a8966d1f786f..35712e129b7a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1463,6 +1463,12 @@ static void put_deleg_file(struct nfs4_file *fp)
 
 static void nfsd4_finalize_deleg_timestamps(struct nfs4_delegation *dp, struct file *f)
 {
+	struct inode *inode = file_inode(f);
+	struct iattr attr = {
+		.ia_valid = ATTR_ATIME | ATTR_CTIME | ATTR_MTIME | ATTR_DELEG,
+	};
+	int ret;
+
 	/* don't do anything if FMODE_NOCMTIME isn't set */
 	if ((READ_ONCE(f->f_mode) & FMODE_NOCMTIME) == 0)
 		return;
@@ -1475,12 +1481,22 @@ static void nfsd4_finalize_deleg_timestamps(struct nfs4_delegation *dp, struct f
 	if (!READ_ONCE(dp->dl_written))
 		return;
 
+	/* A racing CB_GETATTR reply sets dl_setattr under inode_lock */
+	inode_lock(inode);
 	/* did it get a setattr for the timestamps at some point? */
-	if (dp->dl_setattr)
+	if (dp->dl_setattr) {
+		inode_unlock(inode);
 		return;
+	}
 
 	/* Stamp everything to "now" */
-	nfsd_update_cmtime_attr(f, ATTR_ATIME);
+	ret = notify_change(&nop_mnt_idmap, f->f_path.dentry, &attr, NULL);
+	inode_unlock(inode);
+	if (ret)
+		pr_notice_ratelimited("nfsd: Unable to update timestamps on inode %02x:%02x:%llu: %d\n",
+				      MAJOR(inode->i_sb->s_dev),
+				      MINOR(inode->i_sb->s_dev),
+				      inode->i_ino, ret);
 }
 
 static void nfs4_unlock_deleg_lease(struct nfs4_delegation *dp)
@@ -10720,14 +10736,16 @@ bool nfsd4_vet_deleg_time(struct timespec64 *req, const struct timespec64 *orig,
 }
 
 /**
- * nfsd4_vet_deleg_attrs - vet the delegated timestamps in a SETATTR
- * @iattr: attributes to be set
- * @dp: timestamp delegation held by the SETATTR's sender
- * @deleg_attrs: FATTR4_WORD2_TIME_DELEG_* bits in the SETATTR
+ * nfsd4_vet_deleg_attrs - vet a timestamp delegation holder's times
+ * @iattr: holder's times in ia_atime and ia_mtime
+ * @dp: holder's timestamp delegation
+ * @deleg_attrs: FATTR4_WORD2_TIME_DELEG_* bits naming the times to vet
  *
- * Drop requested timestamps that don't pass nfsd4_vet_deleg_time(), and
- * clamp ones in the future. Set dl_setattr if both the mtime and ctime
- * pass.
+ * Set the ATTR_[AMC]TIME* bits in @iattr for the times that pass
+ * nfsd4_vet_deleg_time(), clamping ones in the future, and clear them for
+ * the ones that don't. Ctime follows an applied mtime, or is set to the
+ * current time if that mtime doesn't pass dl_ctime: DELEGRETURN won't
+ * stamp it, and the change attribute may derive from it.
  *
  * Context: Caller holds the inode_lock across this, applying @iattr, and
  * nfsd4_record_deleg_attrs(), so cb_getattr_update_times() can't move
@@ -10741,21 +10759,21 @@ void nfsd4_vet_deleg_attrs(struct iattr *iattr, struct nfs4_delegation *dp,
 
 	lockdep_assert_held_write(&inode->i_rwsem);
 
-	if ((deleg_attrs & FATTR4_WORD2_TIME_DELEG_ACCESS) &&
-	    !nfsd4_vet_deleg_time(&iattr->ia_atime, &dp->dl_atime, &now))
+	if (deleg_attrs & FATTR4_WORD2_TIME_DELEG_ACCESS) {
 		iattr->ia_valid &= ~(ATTR_ATIME | ATTR_ATIME_SET);
+		if (nfsd4_vet_deleg_time(&iattr->ia_atime, &dp->dl_atime, &now))
+			iattr->ia_valid |= ATTR_ATIME | ATTR_ATIME_SET;
+	}
 
 	if (deleg_attrs & FATTR4_WORD2_TIME_DELEG_MODIFY) {
-		if (nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now)) {
-			iattr->ia_ctime = iattr->ia_mtime;
-			if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
-				dp->dl_setattr = true;
-			else
-				iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET);
-		} else {
-			iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET |
-					     ATTR_MTIME | ATTR_MTIME_SET);
-		}
+		iattr->ia_valid &= ~(ATTR_MTIME | ATTR_MTIME_SET |
+				     ATTR_CTIME | ATTR_CTIME_SET);
+		if (!nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now))
+			return;
+		iattr->ia_valid |= ATTR_MTIME | ATTR_MTIME_SET | ATTR_CTIME;
+		iattr->ia_ctime = iattr->ia_mtime;
+		if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
+			iattr->ia_valid |= ATTR_CTIME_SET;
 	}
 }
 
@@ -10778,9 +10796,12 @@ void nfsd4_record_deleg_attrs(const struct iattr *iattr,
 
 	if (iattr->ia_valid & ATTR_ATIME_SET)
 		dp->dl_atime = iattr->ia_atime;
-	if (iattr->ia_valid & ATTR_MTIME_SET)
+	if (iattr->ia_valid & ATTR_MTIME_SET) {
 		dp->dl_mtime = iattr->ia_mtime;
-	/* inode_set_ctime_deleg() keeps a later ctime */
+		/* Don't let DELEGRETURN stamp over the holder's mtime */
+		dp->dl_setattr = true;
+	}
+	/* Ctime may be "now", or inode_set_ctime_deleg() kept a later one */
 	if (iattr->ia_valid & ATTR_CTIME)
 		dp->dl_ctime = inode_get_ctime(inode);
 }
@@ -10810,8 +10831,6 @@ static void cb_getattr_update_times(const struct path *path,
 	/* Serialize vetting against dl_*time with their update below */
 	inode_lock(inode);
 	if (deleg_attrs_deleg(dp->dl_type)) {
-		struct timespec64 now = current_time(inode);
-
 		/*
 		 * The holder's own SETATTRs, xattr changes, fallocates, LINKs
 		 * etc. don't break its delegation and don't show up in its
@@ -10826,16 +10845,9 @@ static void cb_getattr_update_times(const struct path *path,
 
 		attrs.ia_atime = ncf->ncf_cb_atime;
 		attrs.ia_mtime = ncf->ncf_cb_mtime;
-
-		if (nfsd4_vet_deleg_time(&attrs.ia_atime, &dp->dl_atime, &now))
-			attrs.ia_valid |= ATTR_ATIME | ATTR_ATIME_SET;
-
-		if (nfsd4_vet_deleg_time(&attrs.ia_mtime, &dp->dl_mtime, &now)) {
-			attrs.ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
-			attrs.ia_ctime = attrs.ia_mtime;
-			if (nfsd4_vet_deleg_time(&attrs.ia_ctime, &dp->dl_ctime, &now))
-				attrs.ia_valid |= ATTR_CTIME | ATTR_CTIME_SET;
-		}
+		nfsd4_vet_deleg_attrs(&attrs, dp,
+				      FATTR4_WORD2_TIME_DELEG_ACCESS |
+				      FATTR4_WORD2_TIME_DELEG_MODIFY);
 
 		/*
 		 * The times are the holder's, so don't hold the GETATTR

-- 
2.56.0

