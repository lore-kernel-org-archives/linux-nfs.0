Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD97B3B3886;
	Tue, 28 Apr 2026 07:12:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777360349; cv=none; b=cmMrl0nvXG7UecL300pkqIMdeR47EfbX1Dt5spkqv9IFDWlJJBB3gu+QvdMRKLg1NqrB6VvC9mD4Gz4sSKdUTzDj61cFsSHCkdD7PYvQL7TZOfiMu9mojNyrPrEXckkZhCOKggEx5hKU4UV9Sq/QhGWV80MfmtVW5+P3ryh4UsQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777360349; c=relaxed/simple;
	bh=6iP3wYS36Ujy51+xluiGDluKmbUNqp5bbfa1ol4Sl74=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=rIWobAHfYesOxMNrwJu2pLeqn4kSMZGkhmO5bba9JfCTx3eCp4Pmw4S5R6OQahfcaIJObSoxigXfcjMPgE0uZ8btqbrzQ8UFRWHMF0pQ0GDAErVW7Cuqd5HZAMVnUVwfqGsDfWQDp2uS7j6zetYp2VrK2UaaB8+py6AOrXq8e0E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nVZ53hhQ; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nVZ53hhQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 005A6C2BCB9;
	Tue, 28 Apr 2026 07:12:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777360349;
	bh=6iP3wYS36Ujy51+xluiGDluKmbUNqp5bbfa1ol4Sl74=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=nVZ53hhQOsTlfkCFYNEOPGZRfbG/aYUnsVEnxDQ/EI27S8AYhT87Qwa+6vKeU/oFA
	 zvCtUrPZx9NCM1w9lrTrL/vIdZtRcER5WrqyWPA6NErcgVQjiVrxAGokSQGWWU1xBl
	 7kJOPLsUT2pHVWJOicUUsPTUnwaWtt1ge+RWe2+fpdFGlfwtXujk2wQqGw0pvIY1pO
	 tuKkyA1Wrlo00ncJm3Pkxoiyr2raWc1onSMNAeImjoQkHQ6hfUzBogAWHYVMRY0Xmh
	 4qk9eOiAdS6XOdbJs/UDXt8n1FdSCJ35cHwN01jsG4IEFvL9srLEJYSuTsEDiMj0Ac
	 DMqocD1SDKH4w==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 28 Apr 2026 08:10:11 +0100
Subject: [PATCH v3 27/28] nfsd: track requested dir attributes
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260428-dir-deleg-v3-27-5a0780ba9def@kernel.org>
References: <20260428-dir-deleg-v3-0-5a0780ba9def@kernel.org>
In-Reply-To: <20260428-dir-deleg-v3-0-5a0780ba9def@kernel.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
 Chuck Lever <chuck.lever@oracle.com>, 
 Alexander Aring <alex.aring@gmail.com>, 
 Steven Rostedt <rostedt@goodmis.org>, 
 Masami Hiramatsu <mhiramat@kernel.org>, 
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Amir Goldstein <amir73il@gmail.com>
Cc: Calum Mackay <calum.mackay@oracle.com>, linux-fsdevel@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3281; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=6iP3wYS36Ujy51+xluiGDluKmbUNqp5bbfa1ol4Sl74=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBp8F1V9Xq0xqLREm9f1HzT9TJF7HNltp5h5bQPo
 /A09BEXNOCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCafBdVQAKCRAADmhBGVaC
 FTVrEACNnH01nCrAifRdrmRbvkd3VmH5rWZPwoL8dlubkuYnXbyQO8TiboU1j5nUtQcwRwOHfdF
 EzMOGepJCVFNFh8GD2eXWt9XIDBRYzIZlFEgjC35cr0jsIqJan/mqloXYiwDEGMU7ScKG6VmX1X
 QTYWqELUav51AM6ea6LLDeIQ6Ol4y1VN9w4jHQR4Gn4+0ZO/RWhNrfvJqJOIhXO0adVUH6j+m5C
 Svblfq946FQucbH5I0jgwbV8JLZwNkmbTnykwU7RmqEHedhXzBfrr1fFs2CbBCgOnimiw/+SEQb
 D8L6VALGp3SBBd/pRueZu2NxGTzelwxQs687R976erF8uAmeDS5ByLkbqT/3o3Ul+jAB24dIlwF
 bmg1pWjUzfsLBkVDtlLBF2ldWWxq6FfMwJabrOzrnoUzMh5mxEEdCtaW0+oIO6F05vW8ZtIrftW
 TqpVMV+EoEiDEfm1z0R/x0GuBSYa3jKtH7Xjn5ZE2t8KH1U2jq9H3t5pjrDeW6/9kEwj0Y/p82r
 sXLrbABLFtBUmsbkzdlJmxDL4K4ySn1zn7WRnnP1aUTSf1wfDKw9PDrmG7d7VP3QFTDJyePGsrB
 9u2p0rDLwGzak/T2Twgj2s6lD3BNbUjbEwvsQyFqZzacxZBYb/256nTtRuXmbLDZMt0mNUnfZLC
 XAmzAPaC12fCoOQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Track the union of requested and supported dir attributes in the
delegation, and only encode the attributes in that union when sending
add/remove/rename updates.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c  |  9 ++++++---
 fs/nfsd/nfs4state.c | 14 +++++++++++++-
 fs/nfsd/state.h     |  2 ++
 3 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a807a55dddf9..e4717e1e3d93 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2506,9 +2506,10 @@ nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status == nfserr_same ? nfs_ok : status;
 }
 
-#define SUPPORTED_NOTIFY_MASK	(BIT(NOTIFY4_REMOVE_ENTRY) |	\
-				 BIT(NOTIFY4_ADD_ENTRY) |	\
-				 BIT(NOTIFY4_RENAME_ENTRY) |	\
+#define SUPPORTED_NOTIFY_MASK	(BIT(NOTIFY4_CHANGE_DIR_ATTRS) |	\
+				 BIT(NOTIFY4_REMOVE_ENTRY) |		\
+				 BIT(NOTIFY4_ADD_ENTRY) |		\
+				 BIT(NOTIFY4_RENAME_ENTRY) |		\
 				 BIT(NOTIFY4_GFLAG_EXTEND))
 
 static __be32
@@ -2555,6 +2556,8 @@ nfsd4_get_dir_delegation(struct svc_rqst *rqstp,
 	memcpy(&gdd->gddr_stateid, &dd->dl_stid.sc_stateid, sizeof(gdd->gddr_stateid));
 	gdd->gddr_child_attributes[0] = dd->dl_child_attrs[0];
 	gdd->gddr_child_attributes[1] = dd->dl_child_attrs[1];
+	gdd->gddr_dir_attributes[0] = dd->dl_dir_attrs[0];
+	gdd->gddr_dir_attributes[1] = dd->dl_dir_attrs[1];
 	nfs4_put_stid(&dd->dl_stid);
 	return nfs_ok;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d2b3283c0d31..b60aa2cf1eba 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -9823,6 +9823,15 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct dentry *dentry,
 				 FATTR4_WORD1_TIME_MODIFY |	\
 				 FATTR4_WORD1_TIME_CREATE)
 
+#define GDD_WORD0_DIR_ATTRS	(FATTR4_WORD0_CHANGE |		\
+				 FATTR4_WORD0_SIZE)
+
+#define GDD_WORD1_DIR_ATTRS	(FATTR4_WORD1_NUMLINKS |	\
+				 FATTR4_WORD1_SPACE_USED |	\
+				 FATTR4_WORD1_TIME_ACCESS |	\
+				 FATTR4_WORD1_TIME_METADATA |	\
+				 FATTR4_WORD1_TIME_MODIFY)
+
 /**
  * nfsd_get_dir_deleg - attempt to get a directory delegation
  * @cstate: compound state
@@ -9892,10 +9901,13 @@ nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
 		dp->dl_stid.sc_export =
 			exp_get(cstate->current_fh.fh_export);
 
+	dp->dl_notify_mask = gdd->gddr_notification[0];
 	dp->dl_child_attrs[0] = gdd->gdda_child_attributes[0] & GDD_WORD0_CHILD_ATTRS;
 	dp->dl_child_attrs[1] = gdd->gdda_child_attributes[1] & GDD_WORD1_CHILD_ATTRS;
+	dp->dl_dir_attrs[0] = gdd->gdda_dir_attributes[0] & GDD_WORD0_DIR_ATTRS;
+	dp->dl_dir_attrs[1] = gdd->gdda_dir_attributes[1] & GDD_WORD1_DIR_ATTRS;
 
-	fl = nfs4_alloc_init_lease(dp, gdd->gddr_notification[0]);
+	fl = nfs4_alloc_init_lease(dp, dp->dl_notify_mask);
 	if (!fl)
 		goto out_put_stid;
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cb1ac3248fe8..4c5848285378 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -286,7 +286,9 @@ struct nfs4_delegation {
 	struct timespec64	dl_ctime;
 
 	/* For dir delegations */
+	uint32_t		dl_notify_mask;
 	uint32_t		dl_child_attrs[2];
+	uint32_t		dl_dir_attrs[2];
 };
 
 static inline bool deleg_is_read(u32 dl_type)

-- 
2.54.0

