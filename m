Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F51E3B7772;
	Tue,  1 Sep 2026 13:09:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788268198; cv=none; b=l5U50EINrm+k7snhkyIsQKEpKarJtz3lYHWHjzHJZnEeyYB+HM0/u6+Yvj9aJ3fKvxw78GHX9vB/LXNjv3W3rKCpxxnuRTL6/KYC+chz4phMKHMORteoUfiekrg84TnfbjyNQ9hCh6ioCMxnibtH3LZXkJgXYlcnOMP6edyax1o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788268198; c=relaxed/simple;
	bh=X3/9YKE3xBinmEV1GhMgbWWOEofArSRsmpCB4eh3SG0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=nNCh2yE92MsKU+CEJcSdTVLWW/A5+WM653ZC7XgsHRJ6UqJ3vRjq0tSRkwztFUizIOiM7xsE6bvg0KKMy5477HAVcpewnwST6sGXtwCSxlNqFg5zj3/45WKLXQkseB1y/2s/U+khtBAB9k6igwASBKMGKEkGqshV8m9ozoeb/6c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=l2LKEPcr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="l2LKEPcr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C9481F000E9;
	Tue,  1 Sep 2026 13:09:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788268197;
	bh=fcZJwXoy1vxhyp3/EHTEhV3TKVx2/a3XYBdOKnUnH00=;
	h=From:Date:Subject:To:Cc;
	b=l2LKEPcrRxFxtVBkhim/FhfqcPE7cNryj8kQ7GW4c2No39IrHb73JE52nveGMruPs
	 4Sg7E7nB7xegDtf3Lgk2PuDrcv8ANDyQXUq91yT6HODZGlCA/UEQlmAjP0NwZ5bKt1
	 0VPAMUpkuM6M+dUHYytwbyIcd5BFx+6HbuQhgws1Yyko/KJbN/M2azPCOk1JgXg0SH
	 PaQn+Eo/ant6HfPlaE3xDLmJFedPVqHVFqgCEKud0l4+q/rmJedhN7kXUIg8YH4c9z
	 gSSX9B5mEDDyNo8wHGYwYDQe7lN2W+KkZPlDRxLN2/ZrORtvHDctIwgeid9hSa/+XA
	 cL/qZ2JADlvhw==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:09:43 -0400
Subject: [PATCH] nfsd: accept a backdated timestamp from a delegation
 holder
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-delegts-v1-1-9937f7ee4370@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDSwND3ZTUnNT0kmLdVEvDRDMTizRDEyNzJaDqgqLUtMwKsEnRsbW1AGk
 LXr9ZAAAA
X-Change-ID: 20260901-delegts-e91a648f1427
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5040; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=X3/9YKE3xBinmEV1GhMgbWWOEofArSRsmpCB4eh3SG0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqls6fHAJqUA/5PG2cikuzcfp2wcvblXuXbCWgn
 jqoe5l+L1mJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbOnwAKCRAADmhBGVaC
 FRsfD/0U0PVqe3WFr9WPr3/pqSi5Kl5X1kimR43J5yBB/vaMJMUw8GN2F80u4zkQP+MAIvEUahc
 0Rf/rXsshM2OzQH7ZICc+BCrbpOuL+WoGnOyxl32J5wf8p0F2Hb4yWnRdbs6GkZ1NUqeb8F2joF
 +1noiUMqUCW48ddlS7M/uv3GAkrkzHxDaz/hDB4QC3WtLo3tGY68GETTRNrdC+vYhIhIrTl7stb
 k6AZTUZEy+WaU3Nkjx1MSLClkuUVpzLSnN8AyT75QDZss2EzpwDMQc8yqZ7Rd4BPtxvqcJSag5J
 KFeL7Ju1UHtcRJbNRea68cohxNvaDTVE3pT4QyFj0vul5bVhb0oxkKpWxE/QDy4kFivENZtynts
 DIMnhdxfZPHNmF2i3bWvMDqfABoSPM1F21ShtF19UCrx0+zCOQgyZUSMXwqBWcR5DfgRDhma5dQ
 /KxY8efMuYENFYPl6iRBwGDgmJX+vuSulxG3flglQN+QwWwkLkp1Y/eEN/lIbVVaPvdQOzfwH81
 9esU+S594TLjlS0UkzcG8a7/LUWJjBvxIdTvpTPo3rWCqoz1rR574bgPBwcqlw9ZYO/5uKa+xdK
 U+X7pftEqzUA2h8kW0fkIVVNbzmyoCa01yZwCL/rnzYRCaqSMUiyhtUmwj1dStwJS9UOC6PW7Ni
 WH0TurdRSr2voKA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A client with an attribute delegation reports the file times in a
SETATTR at DELEGRETURN. nfsd ignores a time that moves backwards. It
then stamps the c/mtime with the current time, so the file keeps the
DELEGRETURN time. cp -p, rsync -t and tar -x lose timestamps.

The client applies an explicit utimensat() to its own inode. It sends no
SETATTR while it holds the delegation, so the backdated value reaches
nfsd only as TIME_DELEG_MODIFY. The client can send an RPC for each time
change instead. That also works, but it loses the caching that the
delegation allows.

The delegation makes the client the authority for these times, so treat
its SETATTR as a statement of fact. The client can set the same value
with an ordinary SETATTR, which nfsd applies without a check.

- nfsd accepts a backwards atime or mtime.
- An mtime that moves backwards sets the ctime to the current time.
  The ctime never moves backwards.
- nfsd still clamps a future time.
- The CB_GETATTR path keeps the old rule. A backwards time there shows
  a stale report.

RFC 9754 says that the server ignores a time before the original time.
This patch does not follow that sentence. The same section also says
that the server MUST accept the change or MUST reject it with
NFS4ERR_DELAY. A silent discard does neither. A retry after
NFS4ERR_DELAY carries the same backdated value, so that option cannot
succeed.

There is still one gap: nfsd cannot tell an explicit utimensat() from a
report of a write. An mtime after the delegation and before the current
time therefore sets the ctime to that mtime, instead of to "now". RFC
9754 requires this. Fixing that would require the client to issue an RPC
for the mtime.

Fixes: 3952f1cbcbc4 ("nfsd: fix SETATTR updates for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: Claude:claude-opus-5
---
We could fix this more correctly on the client by making it always issue
an RPC for a utimensat(), but I think that would hurt untar-type
workloads (which often backdate timestamps).
---
 fs/nfsd/nfs4proc.c | 47 +++++++++++++++++++++++++++++++----------------
 1 file changed, 31 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bb74eef43938..fa3a43c20e95 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1292,9 +1292,22 @@ nfsd4_secinfo_no_name_release(union nfsd4_op_u *u)
 }
 
 /*
- * Validate that the requested timestamps are within the acceptable range. If
- * timestamp appears to be in the future, then it will be clamped to
- * current_time().
+ * A client holding a delegation with delegated timestamps is the authority for
+ * the file's timestamps, so a SETATTR from it asserts what they are rather than
+ * reporting that they have advanced. Honor a value that moves a timestamp
+ * backwards: the client could set the same value with an ordinary SETATTR, so
+ * refusing it here only loses data. Clamp a value in the future to the current
+ * time, as RFC 9754 permits.
+ */
+static void
+clamp_deleg_time(struct timespec64 *req, const struct timespec64 *now)
+{
+	if (timespec64_compare(req, now) > 0)
+		*req = *now;
+}
+
+/*
+ * Apply the timestamps that a delegation holder supplied in a SETATTR.
  */
 static void
 vet_deleg_attrs(struct nfsd4_setattr *setattr, struct nfs4_delegation *dp)
@@ -1302,21 +1315,23 @@ vet_deleg_attrs(struct nfsd4_setattr *setattr, struct nfs4_delegation *dp)
 	struct timespec64 now = current_time(dp->dl_stid.sc_file->fi_inode);
 	struct iattr *iattr = &setattr->sa_iattr;
 
-	if ((setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS) &&
-	    !nfsd4_vet_deleg_time(&iattr->ia_atime, &dp->dl_atime, &now))
-		iattr->ia_valid &= ~(ATTR_ATIME | ATTR_ATIME_SET);
+	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS)
+		clamp_deleg_time(&iattr->ia_atime, &now);
 
 	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_MODIFY) {
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
+		clamp_deleg_time(&iattr->ia_mtime, &now);
+
+		/*
+		 * The ctime must not move backwards. Carry the mtime into it
+		 * only when that advances it; otherwise clear ATTR_CTIME_SET so
+		 * that notify_change() stamps the ctime with the current time,
+		 * which is what a local utimensat() would do.
+		 */
+		iattr->ia_ctime = iattr->ia_mtime;
+		if (!nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
+			iattr->ia_valid &= ~ATTR_CTIME_SET;
+
+		dp->dl_setattr = true;
 	}
 }
 

---
base-commit: cfebfd3db73d82143ac54b1b6c6dad1d13952d59
change-id: 20260901-delegts-e91a648f1427

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

