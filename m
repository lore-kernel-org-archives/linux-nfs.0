Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192821;
	b=EHSiXSWpgRsYQHj/0ebvkNipZPaGKugwZqVxfPzWfF1Q0MsqFg079ZV8UxP98uqcRry3
	 j/ezYKF1xMH+/7spR2LFnH3TvUX8fiewMdI+LFAnDLLmHGOHsd+HlcKX1dKrxv7uwgljb
	 tV7UZfdztUCFr2ndGVWWW1oQKo6LsX5yrgBZVnVWYXsS0OTk8IsW7DBp7hCYp5WAmYfJY
	 ybqU/RzfYEtqvlP+MOvGr+u5WJ1MelVuvej6hK8utcg1x2huIVReOXiamkkswDqctkYDg
	 fp/nUD+5FNqVbyi1cBqsy3SCbxPolYfzGcTrpg4Wywv1s3DmjARIUeegq1PeJFn9bkA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192821;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=x1dlnoX0+h8+R3Kb687G7S5xu2gU9ZrsFrBIDwfUWws=;
	b=uet65xnkqVReZ2CDez6PoH2NmbSB7wQBGB4ZPzIn3ECZZKkhCT4foiGY5K/xBVvjmpN/
	 ZnZdUUPZJhCYURoNNjY2B0iyJ9Rq3ZrAz/JpQCbgphEhXsRC93QAw/7aQVeFZpTXAkvcw
	 diFvy+UxXTZ9w8gU6flE98lZVhs1Xxv8BN+Gvhd++EjU/ZPQyF3g5IO0nCRSpvXfGZ+rf
	 qS/Kh3X/9e/d5tyrETjqgdzwIDli/sc+uZ1tdMIoaUTJ7wcYmkockKGMPz4w+ZBKF/m88
	 qNLGG6rcFDGE9G1t5b/e//+l7rQwfRPCk2MmZxgmrg7FLGm5O36rnCYwVSlQYLME3nA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gTtc8Qlx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92E1660A2602;
	Fri, 20 Nov 2026 16:40:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gTtc8Qlx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8783B1F000C0;
	Fri, 20 Nov 2026 16:40:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192820;
	bh=x1dlnoX0+h8+R3Kb687G7S5xu2gU9ZrsFrBIDwfUWws=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gTtc8QlxZ6A0S5M854ufd3VRdCqx8rqXMLQ1v3B2HlL3yWcxmEVB7Vtn+2ecZudCW
	 4+zPmXUsIoOVrzhcmqdhf5Xhyz0dvie5ZEHWvG7o5ChKn9cxVVBSEX1W5Yy1+/z18T
	 7ULKfs0pjAKFJJmxJ1j3KewCSCtdG7XfDEwdyEOg1/dzHaqiKLEHyymlVyeM9dN+SG
	 Pdom+jbfERuWZXkVzm+QaMlDQ8Vogr3w6CXqgrHnxl0LUffZktonf4sh1h58RddCuc
	 YSK8UILxjhqNQ1DBbLOPm85NHttjTMWDXdjB1KNVgGQ6z4n4K1uvV9HjZJLEkclmaj
	 xzqtEe9w03S8A==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:08 -0800
Subject: [PATCH 02/11] nfsd: take freeze protection before updating
 delegation timestamps
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
Message-Id: <20261120-delegts-fixes-v1-2-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5376; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ekCSUC6pGw2VndhtGf0sTzsAN60DohvMTN7Ku8bXbrQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfwd9lPiX9lktP3LDC08LKq0JKWKkVgqxnlU
 eZIOazsWAiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38AAKCRAADmhBGVaC
 FWOCD/4o9ucgMwJjnMe1ukhIixxcnbiLGVJGydPcm4uwo9O4Q54knE64GNyIutvxcQzPh/pPE2h
 skV3OiYwzoLE7sabGqccg1UxMIELWWGk5VXOrqINAot4xKM3EBnx6T9jC3LsqbxxBBZUQI5y5Uf
 W+62nHp3rDfrY1b6a63u9j2VooA1WMLsPE83zGVFGxPGcjpwK8UojOrm02w1J9kvZIrafPdLlAv
 la91xByYS98q+0RT/t8gsoo26JAWnTxrtQCgLFR80URuIVZhDfpux6369MdK0lF0ORlXGJ0OpR9
 PdR8eIDr4ofp5AgmmX/TghZOC2bGsLzwwuRftBUQlK4mcncLGkXZcL7j3zBi1TfvvqFhdcPyorU
 qckyRjldnJIHiCocK9mtgyaFZwFsBoBGx6BPXIEWOYM/JQRlpthp2Y/6430C+DeEdbvrMfHZq9h
 dQ6Ul1yFORUruSLIEt4vj5ZCyEPqkop+MsmwVxFeYae9Qx0Exr+oKMEt3FgUqqRs/UE/0TgHYzu
 ANZuJ235XEZ8qPz0GLMyv8v3Y355HNyswB+ZDLEPQfldDZXXAuU0iftkg8IB5XQaq047CcmkQ3Q
 kZIeRVG7kadR79x5ktFjZyFdTPql8P7RM0s0CXaqZg7GFiE+Oc9S4CxlzmF1hptg8ETPNKPHT2c
 Ilk94wN4pMuB1nQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

cb_getattr_update_times(), nfsd_update_cmtime_attr() and
nfsd4_finalize_deleg_timestamps() call notify_change() under
inode_lock(), but nothing holds freeze protection for the export. They
modify a frozen filesystem: on ext4, a foreign GETATTR whose CB_GETATTR
finds the holder modified the file trips the WARN_ON() in
ext4_journal_check_start(), and the inode's mtime and ctime change while
it is frozen.

The delegation's file and COPY's or CLONE's destination are open for
write, so the mount's write access is held. Only the superblock's
freeze protection is missing, and it goes outside inode_lock.

- cb_getattr_update_times() runs in an nfsd thread answering GETATTR.
  Rather than hold the thread until the thaw, it tries for freeze
  protection and returns NFS4ERR_DELAY, which has the client retry.
- nfsd_update_cmtime_attr(), from COPY and CLONE, waits for the thaw,
  as the data change that made the update necessary did.
- nfsd4_finalize_deleg_timestamps() runs when a delegation's lease is
  released, which includes the laundromat and nfsd shutdown. Those
  must not wait for a thaw, so it tries for freeze protection and
  leaves the times alone, with a notice, if the filesystem is frozen.

Reported-by: Christian Brauner <brauner@kernel.org>
Closes: https://lore.kernel.org/linux-nfs/20261114-abdrehen-mahnwache-farbpalette-9c31774145cc@brauner/
Fixes: 7e8ae8486e44 ("fs/nfsd: fix update of inode attrs in CB_GETATTR")
Fixes: e5e9b24ab8fa ("nfsd: freeze c/mtime updates with outstanding WRITE_ATTRS delegation")
Fixes: 2863bac7f49c ("nfsd: update mtime/ctime on CLONE in presense of delegated attributes")
Fixes: 4183cf383b6f ("nfsd: update mtime/ctime on COPY in presence of delegated attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 65 +++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 48 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 048b2616d783..f6a01ab0602a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1453,6 +1453,30 @@ static void put_deleg_file(struct nfs4_file *fp)
 	}
 }
 
+static void nfsd_cmtime_notice(struct inode *inode, int err)
+{
+	pr_notice_ratelimited("nfsd: Unable to update timestamps on inode %02x:%02x:%llu: %d\n",
+			      MAJOR(inode->i_sb->s_dev),
+			      MINOR(inode->i_sb->s_dev),
+			      inode->i_ino, err);
+}
+
+/* Caller holds freeze protection for @f's filesystem */
+static void __nfsd_update_cmtime_attr(struct file *f, unsigned int flags)
+{
+	struct inode *inode = file_inode(f);
+	struct iattr attr = {
+		.ia_valid = ATTR_CTIME | ATTR_MTIME | ATTR_DELEG | flags,
+	};
+	int ret;
+
+	inode_lock(inode);
+	ret = notify_change(&nop_mnt_idmap, f->f_path.dentry, &attr, NULL);
+	inode_unlock(inode);
+	if (ret)
+		nfsd_cmtime_notice(inode, ret);
+}
+
 static void nfsd4_finalize_deleg_timestamps(struct nfs4_delegation *dp, struct file *f)
 {
 	/* don't do anything if FMODE_NOCMTIME isn't set */
@@ -1471,8 +1495,18 @@ static void nfsd4_finalize_deleg_timestamps(struct nfs4_delegation *dp, struct f
 	if (dp->dl_setattr)
 		return;
 
+	/*
+	 * This runs from the laundromat and from nfsd shutdown too, which
+	 * must not wait for a frozen filesystem to thaw. Leave the times
+	 * alone then.
+	 */
+	if (!file_start_write_trylock(f)) {
+		nfsd_cmtime_notice(file_inode(f), -EBUSY);
+		return;
+	}
 	/* Stamp everything to "now" */
-	nfsd_update_cmtime_attr(f, ATTR_ATIME);
+	__nfsd_update_cmtime_attr(f, ATTR_ATIME);
+	file_end_write(f);
 }
 
 static void nfs4_unlock_deleg_lease(struct nfs4_delegation *dp)
@@ -10780,10 +10814,18 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
 	if (!attrs.ia_valid)
 		return 0;
 
+	/*
+	 * The delegation's file is open for write, so only freeze
+	 * protection is missing. Don't hold an nfsd thread until a frozen
+	 * filesystem thaws: NFS4ERR_DELAY has the client retry.
+	 */
+	if (!sb_start_write_trylock(inode->i_sb))
+		return -EAGAIN;
 	attrs.ia_valid |= ATTR_DELEG;
 	inode_lock(inode);
 	ret = notify_change(&nop_mnt_idmap, dentry, &attrs, NULL);
 	inode_unlock(inode);
+	sb_end_write(inode->i_sb);
 	return ret;
 }
 
@@ -11052,25 +11094,14 @@ nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
  * @flags: any additional flags that should be updated
  *
  * Given upon opening a file delegated attributes were issues, update
- * @f attributes to current times.
+ * @f attributes to current times. Waits for a frozen filesystem to thaw,
+ * like the data change that makes this necessary.
  */
 void nfsd_update_cmtime_attr(struct file *f, unsigned int flags)
 {
-	int ret;
-	struct inode *inode = file_inode(f);
-	struct iattr attr = {
-		.ia_valid = ATTR_CTIME | ATTR_MTIME | ATTR_DELEG | flags,
-	};
-
-	inode_lock(inode);
-	ret = notify_change(&nop_mnt_idmap, f->f_path.dentry, &attr, NULL);
-	inode_unlock(inode);
-	if (ret)
-		pr_notice_ratelimited("nfsd: Unable to update timestamps on "
-				      "inode %02x:%02x:%llu: %d\n",
-				      MAJOR(inode->i_sb->s_dev),
-				      MINOR(inode->i_sb->s_dev),
-				      inode->i_ino, ret);
+	file_start_write(f);
+	__nfsd_update_cmtime_attr(f, flags);
+	file_end_write(f);
 }
 
 static void

-- 
2.56.1

