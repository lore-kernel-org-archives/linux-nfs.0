Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E1724A2A62
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 20:19:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788293999; cv=none; b=HYQroNRcVGIOa/gagnpTUOkfvlyf/n1SLpJCNiVad5Wegk6R1Cp37GhDRoMHIhETXe8tjMKJtnmVWA8vGo2mWsTGZLCMVVh/sV5c5ICZNf1k4KZc3qbdiiLhu80u9dhRAKXRHx6awS7cO+t5WBKAS7l0B3rjY76lot7/yfqk2oc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788293999; c=relaxed/simple;
	bh=1vgmdGLOuPMyCu3Z2edI5ZUb2de9Qt8rXDahHuroD2M=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=egkxVOyoywYRVhP1FN+cxHSjw+ox6yZDVwVqv8sghVqITQHbjl2KzTWYFnNNXBzAt3FuGZOkHIcF+HTjwcFBFrOXD8Qds2Ic3EUdxFayX/frioTU2Rn4ufKfbmvKpwcWRVcetQ3yHee3jUoWngcGcymIfOSS+YF9DPZLUpArgj4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J58aXDFe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J58aXDFe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 542AB1F000E9;
	Tue,  1 Sep 2026 20:19:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788293998;
	bh=91b4Zv61bDlt8Wa17pdpWbmSGdhmL2q4bafSCxClm/o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=J58aXDFehZ2bozzx2wIwHBiNTkhGTPSGAs9860l7GtgVidMbBiEKaRtvLguA/Djk3
	 8OhfEGmKz7/T2Pd9fiWCpGpO/i7EU9f6lthyHUX8TCVsVeYXa52e7eG+2Ij8ULySTB
	 FxujvaMyldZWxIaMnp6lXEuczhF5zb09k+DM17TzPNNmaP6tSArv2YuON+dg9Tem3M
	 YdsysVR/zEg8LgFXagMtfIgeVjYOiJ+yd8dcpJs4BHchJvhnVYNJgz9itw4il/haBd
	 /wfq8+7UhrFp3UMx7qjqULpoIkLPWK80fD1btg2CsM9TmUbLzg4Mz5ihoznZB6IM5L
	 vt1PQOTsG/tHA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 01 Sep 2026 16:19:41 -0400
Subject: [PATCH v2 1/8] NFSD: Don't complete a cld upcall the daemon has
 not read
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-alemi-v2-1-e163f94a3a6e@kernel.org>
References: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
In-Reply-To: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Scott Mayhew <smayhew@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Farhad Alemi <farhad.alemi@berkeley.edu>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3383; i=cel@kernel.org;
 h=from:subject:message-id; bh=1vgmdGLOuPMyCu3Z2edI5ZUb2de9Qt8rXDahHuroD2M=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlzNrdsGDdjbwKundJYev8Dhczy5WgUKmnxS7D
 0mJNfwy4y6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapczawAKCRAzarMzb2Z/
 l4phEACsuHRaxXsJQcWiGICN3U1dm9Qm9fopBMi2uq3AeDhR6AqqhQV121CBlS+D+sKuEVobL/q
 yO3exz2VRovydTEO/c/dM6baXmBY6i/JNq3glcFqPOd7A20L0OxLNW3I7wI1/4zqdDZmGz/DwFk
 65oR1scMWOHM2knLVV0fwKUmV8VojsLp4FAv4oi7UcZe0mL5PbeIG94v2eeqPgiPK/THyky8eby
 33lhfl7RGeSjXU+75D0L21GKj8fWCTZv8EvUKYZzUN77Zre7tFuKteSmL+usx+3ZL0fCa5EpRmM
 4FE6asu7imVdI6H24fUaHYrAjutJz2NLsSw73UEjmKGoSGNbmVPIHee5/lo5jd9hYGD2JwojjYj
 RSyj9NykG7t7GNerwhyJLKrQUXQHQBgduVgIif5L6V8p+Q55+HGCNYAADpjQW+ofOkxYm8MMOzh
 krFW4hz7pVuC0cFfIVGqaGDiX4O5o+3z9SqwcHv3WAv1dJ02KX3cfau/Fogr9hQg5iVzKWCry59
 lVefxdbhiMCLNcmannTcrlweEh/QXp6CgB3/1MnwJP55xkOb7tQ9yBVng7XkUs5tqCScmW8l802
 aAPix6KQySwDcude+dbOpOeHFKWDJhBGhoCNEzS3Y+ENE5KE9g2HAtEDl9+Y6w996B25NwQvI7a
 mnuP76RqL3SHzrg==
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

