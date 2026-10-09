Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 73A614CCDC0
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 14:40:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791556826; cv=none; b=RGHdyleDCAP4sz+sAyESxokx3JvjLwCk3PFnifz5x0aosE2uzJ2h0ojXKXeA1XqTuNZCYt660lCj0waWMjNboCKaFa9gsW9/KYaRWx5AVzCqrcWdW31FD0TErMLmQ0fl80Yugwsy3l0ml21fb0+im1cI/UgP33bkhnJPTRevGCc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791556826; c=relaxed/simple;
	bh=Kw/6JNhdmxcxRaV2ty3gFNa6PZ4sDVgeh60ylqrS2lM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=oDRJiuUWrFuzmqY0Q37taFgnyZXITAru55yvehK6dCI0k2eF3idzpvpdcj+DCXek7Yl7F3/93uAb2yjFdjUwXralwU5RDlDrfgv5LF+IAcfUzITd+rTVc0Lvq9rPMHrADibgMfvYdHoBbLFWPBucjcUdre4UrkM9DOxzZDr7cE8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NRxu8JI1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NRxu8JI1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A1B771F00893;
	Fri,  9 Oct 2026 14:40:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791556825;
	bh=K5S6yi4PCLy5gd4q3z3dZyWVAglOjKp8C81iJ3uoKgY=;
	h=From:To:Cc:Subject:Date;
	b=NRxu8JI1p5R77dEA9a28ybjAao8s8i8JlB7PYRqDW1Zf4icD0HK8M8qvc9cERIRo2
	 JZovqEqsIkDYSk7+4TjtZ8V/sEB7jal8pB4wsuxJRiDMDaroJC76h+CTkGauByeGFK
	 5yLV9Zt1ZVFhlt7D+DGj97ZVs/UoK+gpDDuCZvDFgaUMHhvl6ZUpvhXaMwhbTedatY
	 yJh11C5a3kJm157Oxt6Djnr8hTFwD9z8CoFJfP+LHFD7ySxklIkR4O+AiQiht9+AN3
	 NhM4P95kTOz4QgNlFRBo9j8C7Crp1LaHurGfKPMn0G7gJVgYsBmmDowt255pMMrZ4Q
	 ufXMBG9grmhmA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	syzbot+9c7b9c5f6dd1d470b605@syzkaller.appspotmail.com
Subject: [PATCH v1] NFSD: Don't start nfsd threads from a pool_threads write
Date: Fri,  9 Oct 2026 10:40:17 -0400
Message-ID: <20261009144017.1284586-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Writing to pool_threads calls nfsd_set_nrthreads() directly, which
starts nfsd threads as soon as a svc_serv exists. A portlist write
creates the svc_serv without running nfsd_startup_net(), so a
pool_threads write that follows it starts threads in a namespace
whose NFSv4 state has not been set up. If the server in that
namespace has been started and shut down before, the hash table
pointers in struct nfsd_net still point at memory that
nfs4_state_destroy_net() freed, and the first EXCHANGE_ID those
threads handle reads it:

  BUG: KASAN: slab-use-after-free in add_to_unconfirmed
  nfsd4_exchange_id
  nfsd4_proc_compound
  nfsd_dispatch

A namespace that has never been started dereferences NULL instead.

write_pool_threads() already starts nothing when no svc_serv exists,
and its comment documents that only the threads file starts NFS.
Ignore the thread counts in a pool_threads write while NFSD_NET_UP
is clear as well, so a pool_threads write never starts threads
before nfsd_startup_net() has run. The reply still reports the
current thread count for each pool.

Fixes: 0a7ec37727dc ("nfsd: make unconf_id_hashtbl allocated per net")
Reported-by: syzbot+9c7b9c5f6dd1d470b605@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=9c7b9c5f6dd1d470b605
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsctl.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 2379b838c028..5a606086b811 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -497,7 +497,8 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	if (nthreads == NULL)
 		goto out_free;
 
-	if (size > 0) {
+	/* Threads started now would run without NFSv4 state. */
+	if (size > 0 && test_bit(NFSD_NET_UP, &nn->flags)) {
 		for (i = 0; i < npools; i++) {
 			rv = get_int(&mesg, &nthreads[i]);
 			if (rv == -ENOENT)
-- 
2.54.0

