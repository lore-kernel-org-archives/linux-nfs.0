Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 404412931FE
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 00:38:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788136733; cv=none; b=Cxe1zSUQSV++BucskG9claztvczfOan21oXwG0DaZIBV6B/84ZCkls8qLlFOflCynSDexVwUOaHwHSvirAsl7DA5Yarjwoaqu7OZqAO872Wq8u7czgPbifqKKeB6nFLQXMtVmem8pJMQytdOg4GaRknAuMT5BUfj+7HtqmCBPGU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788136733; c=relaxed/simple;
	bh=1vgmdGLOuPMyCu3Z2edI5ZUb2de9Qt8rXDahHuroD2M=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gBEzSDqYod7qRQl464i5BBCOoNpms5vpHicN+3RU3m1uhzQHj9oFNyEy8VJuTtfaQwJn6e36FtjENoTXdRsrA4qVrJ0Jzlk60Xmq/i1WIYkSmD/NNXDIfDN1/Oj8Gt5rzvr81kbA+cg+6rDnioOSus8gd5gp1vZOsHNlWP4+Hrc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YYt2hyE8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YYt2hyE8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 429B21F00ACA;
	Mon, 31 Aug 2026 00:38:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788136732;
	bh=91b4Zv61bDlt8Wa17pdpWbmSGdhmL2q4bafSCxClm/o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YYt2hyE8tCp/XFw4e0hDgR5+jfu9JJqFHz2Y0+PeB4U5pU2YVFgGkkYEafemOIAfi
	 1x3qwVmZ95N/FLi3k/QO4Hf1oJkiM4EEqJtMl99MOS5ABaNouBUdpY3pWl6RZbuIkD
	 39EOe8MwTgafimXmNLQpOtFiYvsoNzZnkdH7AU0Q1wjZfv5OFAPthP6Ile+xZYJlpD
	 VZpmIOBZc4+99kdvUcBAr2wjHhMkeup4MTe7wL2ICqwD/f1HK+AHWir5vskUaR5wMA
	 ZNqEWqT12s5AU1CTHNp5cZf52znK4J8/YmIpn9Fyw15feqlukcuD9Rskq6/6Rb5iaf
	 fNhVsZulIw00Q==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 30 Aug 2026 20:38:38 -0400
Subject: [PATCH 1/5] NFSD: Don't complete a cld upcall the daemon has not
 read
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260830-alemi-v1-1-463f80b9e9a8@kernel.org>
References: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
In-Reply-To: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>, 
 Scott Mayhew <smayhew@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Farhad Alemi <farhad.alemi@berkeley.edu>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3383; i=cel@kernel.org;
 h=from:subject:message-id; bh=1vgmdGLOuPMyCu3Z2edI5ZUb2de9Qt8rXDahHuroD2M=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlM0ZZhe348ifqG7x/hqQ830N9HKR+ePwBGkOH
 cpMeVxyHsOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapTNGQAKCRAzarMzb2Z/
 lzT5D/9Pj1qswegwL7aXiWMvEhEFwXTLyET6aYjdEk+SAHHAsJ2a3pSKFTpBMLwL4Z1lL2x7tO5
 UNtFFEZx6jqZ3JMNX/VN0n74zXaS5pfCdWVSXCSl/A+zWQg4q11EQNxuLM+YTKh/lhILk/Sd6Mi
 DVRWgmcWOHg6BucgU9hFi3Emv7e+8di6O3icEG1x8pZn4/fQLmoigoLPB5JBY3Xkvv0ZMXemUin
 Mh0C8D3h7z1aIV3rTZSHe/1PsND9RQHZTPCauipU7fo2z8HxOGsCjiKALsejNZMytCBB0DxRzkf
 vQAAdeBxGPg1HxD6uPjMSVRNvPHLbyJ0uz8AsP+bejswv1RxA38WrCUFh1qb8IKp8vfgvqTxxzY
 1lRopiElBUILnM6e7wijeC2YJ2p/pF8K4byHRWkvrtL4eIOrHX8+Rs/xrS0dnr9Lc80ifsR20s4
 8dmUca2vYoiPPWdYRBVp8QzT7vTWeAmzttUpVcUBBwPzxMYSfe8O0sateAmEO6PLvsIzspltfhJ
 F+ebafTffSKL150L3h5bX5JvIVwmfSQ2oIm56nEoAV2xqHoyW+u1/Z//8BGSz4PDGIv9JkOip29
 iVd9/UlOCKUsNLFuL0NJ/5Mf8O8HaZ3E2dUMJyt22q39SvlqqlIi+UxtGRoffTxM8LTFCjPynaW
 OJqdkur+yidqA0Q==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

cld_pipe_downcall() matches a reply to its upcall on the xid alone.
A write that arrives before the daemon has read that upcall
completes __cld_pipe_upcall() while its struct rpc_pipe_msg is still
queued on the pipe. The waiter returns, its stack frame goes away,
and the pipe keeps a list_head that points into it. The next
rpc_queue_upcall() walks that pointer:

  BUG: KASAN: vmalloc-out-of-bounds in __list_add_valid_or_report
  Read of size 8 at addr ffffc90007027950 by task syz.0.96/13066
   __list_add_valid_or_report+0x6a/0x130
   rpc_queue_upcall
   cld_pipe_upcall
   nfsd4_cld_grace_start
   nfsd4_cld_tracking_init

The pipe is mode 0600 in rpc_pipefs, so the trigger is a broken or
hostile nfsdcld rather than an unprivileged task.

Record whether the daemon has consumed the whole message and
complete only when it has. cld_pipe_destroy_msg() runs on every path
by which the pipe releases a message, so it can maintain that flag
under cn_lock. nfsdcld sends its -EINPROGRESS downcalls only after
reading the upcall, so the new check does not break the GraceStart
record stream.

Fixes: f3f8014862d8 ("nfsd: add the infrastructure to handle the cld upcall")
Reported-by: Farhad Alemi <farhad.alemi@berkeley.edu>
Closes: https://lore.kernel.org/linux-nfs/CA+0ovCjVF58WLeen2ctdzHyWUASAAW3Y=Yjihyq0pFApYawtDg@mail.gmail.com/
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4recover.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index aee3a0b22d1c..22a9a366d7eb 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -648,6 +648,8 @@ struct cld_upcall {
 	struct list_head	 cu_list;
 	struct cld_net		*cu_net;
 	struct completion	 cu_done;
+	/* daemon has read the whole upcall; protected by cn_lock */
+	bool			 cu_inflight;
 	union {
 		struct cld_msg_hdr	 cu_hdr;
 		struct cld_msg		 cu_msg;
@@ -808,6 +810,13 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	spin_lock(&cn->cn_lock);
 	list_for_each_entry(tmp, &cn->cn_list, cu_list) {
 		if (get_unaligned(&tmp->cu_u.cu_hdr.cm_xid) == xid) {
+			/*
+			 * Completing now would return the waiter
+			 * while its message is still queued on the
+			 * pipe.
+			 */
+			if (!tmp->cu_inflight)
+				break;
 			cup = tmp;
 			if (status != -EINPROGRESS)
 				list_del_init(&cup->cu_list);
@@ -816,9 +825,9 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	}
 	spin_unlock(&cn->cn_lock);
 
-	/* couldn't find upcall? */
+	/* no upcall to complete? */
 	if (!cup) {
-		dprintk("%s: couldn't find upcall -- xid=%u\n", __func__, xid);
+		dprintk("%s: no completable upcall -- xid=%u\n", __func__, xid);
 		return -EINVAL;
 	}
 
@@ -838,8 +847,16 @@ cld_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	struct cld_msg *cmsg = msg->data;
 	struct cld_upcall *cup = container_of(cmsg, struct cld_upcall,
 						 cu_u.cu_msg);
+	struct cld_net *cn = cup->cu_net;
+
+	/*
+	 * errno >= 0 means the daemon read the whole message and a
+	 * downcall will complete the upcall.
+	 */
+	spin_lock(&cn->cn_lock);
+	cup->cu_inflight = msg->errno >= 0;
+	spin_unlock(&cn->cn_lock);
 
-	/* errno >= 0 means we got a downcall */
 	if (msg->errno >= 0)
 		return;
 

-- 
2.54.0

