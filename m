Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793651917;
	b=04gQlFsdDS/GfmAw5D6HAgB+bbzkylfqz6Mxet5AzK1lZf/oGnEknY5FKcnhvNN+tHWL
	 Oo6ofnDLK1JGd8PUSPRq5ej/NPae5vGTYF72meyIwiSsAluSW3tj9VlXApZ9ik5bPC666
	 EhQfXmG22wbRqeXUWD5TZZQnwDFbsZ0/dd0pUJXtV/CJqfkmfO11pZYplu+qqmr8mfWdZ
	 HNcOkmPiF1QdzHbYH0joE1htcsrYAGuh1TrCBVJ52JDXbhG2LMqkXb6umh+RjdRpKEaqz
	 RCGDK7zdgbVXSHzEEP/+cjCKQ2Vuny3Cs5q/lpJrVGY8reN5acHe66809aFTcUwqkMg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793651917;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=onegsaRrEGUYSzsonlLe9pt0lNSYzMi4Rer4fCtT5Hk=;
	b=vPKSi0qOUNEV5lO1RUUurznmpFrchktKU4RGRnYLDurXCc5GK4BwFj2qb2ZXdVEwBrsc
	 SligMNztq2h4/o8Tv0j6AmP/JCI3McOBTASjSxsmHKn1AyHlRXkgl2mFIoX7YvoKfeepg
	 nfPokqreH93N0G7Lw1b4gdzE0n7D8WiIvgMpI/VtfhjjhE8+B8NTgeQl/kXz03LRWEAfB
	 qBWRjxC1oHn/iJxI8T8asqJaA7zzCuOr/FArQSnS7D/Ir5zIZnErbd6MB5EAPw5912IDB
	 rcVtpnVpc/YKlDIOSihH+/rhK44KCiQ6AzeHKBHbqGUHoMU2RFNVPFCvKPa73fMttXg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="ZdN5F/zm";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD5EA606A330;
	Mon,  2 Nov 2026 20:38:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZdN5F/zm
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 94C8A1F00A1B;
	Mon,  2 Nov 2026 20:38:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793651916;
	bh=onegsaRrEGUYSzsonlLe9pt0lNSYzMi4Rer4fCtT5Hk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ZdN5F/zmT4mUwRmCv/YJebbq/ZERBQ72B0g1VJ6BZDf6KzvK9utl9OekpfWBuok2w
	 zMRDnemKWyWtkZksW61PczgjHIUJKNLW9D+0zwQSxuXawnvlZpttRSyvKTO4HgEQmq
	 O3P7kwqfGAoVWM/5gqyRizsE3Pc3fnuOPZXmbCjjgFb43wIVRsNcfkVm9GPc6g9cz+
	 2e56J0hAlz/4ImFtKyaLTwZ1IBq+DgSaP8Tu8ynQXXtTGtzBpTRnY3hBCePvJOAOM1
	 U2muOEL/bLpcjC9OC3SRwiO41tQo5M80Z45w8CXevvX+wnzRGQaGptvbuzwQteq3Eq
	 7prc4VL2mnMjg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 02 Nov 2026 15:38:10 -0500
Subject: [PATCH 2/2] nfsd: Honor delegated timestamps when change and size
 match
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
Message-Id: <20261102-deleg-cb-getattr-times-v1-2-ca0326d88623@kernel.org>
References: <20261102-deleg-cb-getattr-times-v1-0-ca0326d88623@kernel.org>
In-Reply-To: <20261102-deleg-cb-getattr-times-v1-0-ca0326d88623@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2775; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=nc9COnIhB+A0quOumFWCa8sEV5bNcg18ILthQa0pBzU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq6PTJUAX+HjMkHsSJLL+hO40LbPjiAJAvvEAVc
 aaVe6rYwuGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauj0yQAKCRAADmhBGVaC
 Feu8EACGy76heDATh0plCwnLSQZkD3UcJTWA/mC7XZlp/oiuCTbHtKHrtuLQcsVZCYkJkGjcFIi
 ZjwRwxpuR73hDubHuXiPfl1r/pQ7tZUztjJa//kqPD/zjr7nl8mV8oaBPxSe72j6F3oVl32P409
 zhSoLY00l3cWDrI0BdVRsEeFdngvnacr0UjAmXhPzA5mf1yaCKFvQ4Ob7IQe1YgcnYpHkoxsPtb
 Bw8Zc1IMvwBFNYDg+yuskzcpATz/Zd1cW57iV4GR4M3OOEQg5JV55VsWT4j0K7buLOGOaP+riOc
 gDK/KE5AVyPkbyDDx2pxxo+ceQG6aZzJE4pFxsQqul2VnAF3r0jfDBcPLy8TosnTUoT1jrl0xPx
 3AHqJrFAPv43GLT4WyGeTp+jQEQQjQB+ciPnitWkWReiP8hm8x6cn+lPolRhZ+wcpRP7pA6flmE
 a2ddofn7cDt2sucaU5XXCR90MQe3RqTRiSaCvGwz3I/JzsqJNgTNzFFaMq3yA8kNqaV9kVSkBd9
 zSe/oWujIQxJr3UlsWBanjrrC6gt6Pl/XXC/xrGEBVza95hSxsbDhqOIQbrIS+mpyvEH5b3Lw4O
 zsiQ1zqmUgBFv1X69MsjpVlUgIu37ii1QFmr/Vje9KPL7oKj94vP3NL9Q71ry3puwoPUWi2YHb9
 80QFcRS4pZir7+g==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_deleg_getattr_conflict() applies time_deleg_access and
time_deleg_modify from a CB_GETATTR reply only when the reply's change
attribute or size differs from the server's. RFC 9754 section 5 makes
the holder of a timestamp delegation the authority for atime and mtime,
and puts no such condition on accepting them.

Because the delegation's file has FMODE_NOCMTIME, the holder's WRITEs
change neither mtime nor the change attribute on the server. After a
flushed WRITE, the CB_GETATTR reply matches on change and size, the
holder's mtime is dropped, and other clients see new data with the
pre-WRITE mtime. Since commit 304d81a2fbf2 ("nfsd: fix file change
detection in CB_GETATTR") compares against the current file size, this
also hits flushed extending WRITEs. Holder reads lose the atime the
same way.

- For timestamp delegations, always vet and apply the CB_GETATTR
  times.
- If that advances mtime, mark the file modified so that GETATTR
  reports a new change attribute (RFC 9754: the change time is derived
  from the modify time). An atime-only update must not advance the
  change time, so leave the file unmodified in that case.

Fixes: 6ae30d6eb26b ("nfsd: add support for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cd70d86f4bc6..418b3ee37c68 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10751,6 +10751,13 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
 	inode_lock(inode);
 	ret = notify_change(&nop_mnt_idmap, dentry, &attrs, NULL);
 	inode_unlock(inode);
+
+	/*
+	 * FMODE_NOCMTIME kept the holder's WRITEs from bumping the change
+	 * attribute; a newer delegated mtime is the only evidence of them.
+	 */
+	if (!ret && (attrs.ia_valid & ATTR_MTIME))
+		ncf->ncf_file_modified = true;
 	return ret;
 }
 
@@ -10836,7 +10843,11 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 		else if (i_size_read(inode) != ncf->ncf_cb_fsize)
 			ncf->ncf_file_modified = true;
 	}
-	if (ncf->ncf_file_modified) {
+	/*
+	 * The holder of a timestamp delegation is the authority for atime
+	 * and mtime (RFC 9754, section 5), even if change and size match.
+	 */
+	if (ncf->ncf_file_modified || deleg_attrs_deleg(dp->dl_type)) {
 		int err;
 
 		/*
@@ -10849,6 +10860,8 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 			status = nfserrno(err);
 			goto out_status;
 		}
+	}
+	if (ncf->ncf_file_modified) {
 		ncf->ncf_cur_fsize = ncf->ncf_cb_fsize;
 		*pdp = dp;
 		return nfs_ok;

-- 
2.56.0

