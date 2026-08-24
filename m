Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D16DD433059
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 14:04:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787580295; cv=none; b=WrkVPEII4HiKtU1Fl6m1/0+6fs1tnMzZZ2Higxw3+cAPdTybAtLrrfmgTgY0TTPue2m3ky+CCJm8os8oFbFdj8eUsYKVKqoRAfWFaS/warq1JpkIs4vug4t5KxWM23NnFSCHXaehTK1xFuBGFIVE5L/JVtzAGQuUooaOAS3dFwY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787580295; c=relaxed/simple;
	bh=dm0QEoDqyYPVdycXxqcq65jZs8yIJLWpWaylOb388l8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=L/R7q2g++e07JfQ5QsikXMADd8H1hnzR+YX1CIht98kLl4DEACvUnNqsasBckdhbnXjrydPiXErZX/ukiXtUbThGHOfe267pD7xT86e3I5lGRf9xJ2hClKAulrEDaoVoP7L2VHEyfeSikSIa0SHCRIYqpDGhpTp7YWFl4Sv5ZpE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J7Nke1jt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J7Nke1jt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D856A1F000E9;
	Mon, 24 Aug 2026 14:04:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787580293;
	bh=Veh3k0EWbNUJ94rZQlPIslZtiIhPa+roXeKYPTY7qxg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=J7Nke1jt8J6Rs5ZCVAHcZet3BB5syEu1H4ZwQHomI1qeJHUmRoisb5GNVZ7ISTMz2
	 /1bSzSNdh35XDoR84gahg8RzTKCROxnkPxpE9mDnLy0FGwWH1bkaKLlVRRrrsHB5Kr
	 WirfqtOPJx32yfO3OPEEp8/rKTliLH1q4NCcCwLemIpm4F34b9vloAC4gUmweAeZQU
	 qwPz8josea03mPS4LGDC4jxgw73HKfmaKXAZC2v7glm8JuolI4ow4V60FnWjVe7iUS
	 I6CsHq1ZiMNwRocRsUC5JZqEbah/TN8FAPZqhEEGO+P4mxs1xiYCsr7+GTchSeh1zf
	 vIFmRQg9gIfQg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 24 Aug 2026 10:04:40 -0400
Subject: [PATCH 1/2] NFSD: Fix out-of-bounds read in the rpc_status dump
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260824-nfsd-posix-acl-ownership-v1-1-090fffc608ec@kernel.org>
References: <20260824-nfsd-posix-acl-ownership-v1-0-090fffc608ec@kernel.org>
In-Reply-To: <20260824-nfsd-posix-acl-ownership-v1-0-090fffc608ec@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Lorenzo Bianconi <lorenzo@kernel.org>, 
 Rick Macklem <rmacklem@uoguelph.ca>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2543; i=cel@kernel.org;
 h=from:subject:message-id; bh=dm0QEoDqyYPVdycXxqcq65jZs8yIJLWpWaylOb388l8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqjE+D8k/GjZfS61uZIcaOOBQr0iWN1FOYl7rSC
 2iphiNngGSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoxPgwAKCRAzarMzb2Z/
 l60VD/9JKm4fUFkzr/d/qv5dot3H/qRuh2DsJTK195GDJ37A/aJ268hqvaVepfVZFCEau+RBL64
 2drRdAPGFxOHHv1Cy3yG1rKEg7GsYnVuLmj7JhrdONLBO4k4HO4o2tYwgU8683gQofXqM6Qcl4S
 9Q6BrIh5nRRq4eMU/uvHfhycZ75X9L0VaUqdPrW6wDjkM0yMgOHoPv+Zj9eSbvWPKpkl2Z/UwWX
 0rgoYoy/lrThY16R8hFHN0GYFAuWnOBOBQjCmoHykTvohzJZjT9eHUVnyzF4M4FvRKUFyKhpLaJ
 qfvFQbov5nM8pDG0JXi5VBnBAvnbF9K+XpLz/vuUQofJg+HVYNXMfzsrJzk5/3gokU2t4Bm8FYL
 4TjeOqvxq8wwQiHxEsAVcE4xadDGkDfI34sKIqOP/gKqAj/qcEv3/yCUtVsSQQzhiGxo29TPRVG
 A0GwDP/E0TthDOk/OosnqJBDmoE5SY+ucMHG91WTquafzsxvJWIE8i6Jl2oiWrE0gm9pKbjMy0r
 QZHCpaLvNs1uovYm5Ymcwv9iDcq2p4nLspbK8KYbx7TUys0DQbeqxo+IyRIXuXaXbbI99gJS9oT
 ZjEphqwtAbDxEzQVppsKX2chXmr4czaNgvcj9tUJT3KSB9D8LkVSxGSVNpR+u37zxGASkeUCWb3
 JMY8zTXbXVoEyrQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_nl_rpc_status_get_dumpit() loads args->opcnt and
args->ops separately, then walks ops[] before rechecking
rq_status_counter. A COMPOUND that completes between the two loads
runs nfsd4_release_compoundargs(), which zeroes opcnt and points ops
back at the eight-entry inline array. A dump that already sampled an
opcnt of 200 clamps it to the sixteen slots in rq_opnum, then indexes
iops[0..15]. iops is the last member of struct nfsd4_compoundargs and
rq_argp is allocated at exactly that size, so the walk runs off the
end of the allocation. The trailing recheck discards the sampled data,
but the read has already happened. NFSD_CMD_RPC_STATUS_GET carries
no GENL_ADMIN_PERM, so an unprivileged local user can repeat the dump
against a busy server until it lands in the window.

Sample opcnt and ops into locals, then finish the counter recheck
before dereferencing ops. An unchanged counter means both came from the
same COMPOUND, where opcnt cannot exceed what ops holds.

Fixes: bd9d6a3efa97 ("NFSD: add rpc_status netlink support")
Reported-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Closes: https://lore.kernel.org/linux-nfs/20260823113255.3417-1-prabhakar.pujeri@dell.com/
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsctl.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6e63950a99e1..5331b89c4281 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1588,14 +1588,29 @@ int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
 			    rqstp->rq_proc == NFSPROC4_COMPOUND) {
 				/* NFSv4 compound */
 				struct nfsd4_compoundargs *args;
+				struct nfsd4_op *ops;
+				u32 opcnt;
 				int j;
 
 				args = rqstp->rq_argp;
-				genl_rqstp.rq_opcnt = min_t(u32, args->opcnt,
+				opcnt = READ_ONCE(args->opcnt);
+				ops = READ_ONCE(args->ops);
+
+				/*
+				 * Finish the seqcount retry before
+				 * dereferencing ops. An unchanged counter means
+				 * opcnt and ops came from the same COMPOUND,
+				 * where opcnt cannot exceed what ops holds.
+				 */
+				smp_rmb();
+				if (READ_ONCE(rqstp->rq_status_counter) !=
+				    status_counter)
+					continue;
+
+				genl_rqstp.rq_opcnt = min_t(u32, opcnt,
 							    ARRAY_SIZE(genl_rqstp.rq_opnum));
 				for (j = 0; j < genl_rqstp.rq_opcnt; j++)
-					genl_rqstp.rq_opnum[j] =
-						args->ops[j].opnum;
+					genl_rqstp.rq_opnum[j] = ops[j].opnum;
 			}
 #endif /* CONFIG_NFSD_V4 */
 

-- 
2.54.0

