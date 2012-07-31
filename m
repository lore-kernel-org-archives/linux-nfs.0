Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368Ab2GaSfb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 14:35:31 -0400
Date: Tue, 31 Jul 2012 14:35:28 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, makc@redhat.com
Subject: read/write performance regression due to better v4 lock state
 tracking
Message-ID: <20120731143528.29ffe69a@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/AECECls4/y4T_QiCat_dW__"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/AECECls4/y4T_QiCat_dW__
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

We've gotten some recent bug reports about a performance regression in
recent RHEL kernels that have gotten the backported RELEASE_LOCKOWNER
changes (commit f11ac8db5 in particular). I've also been able to
reproduce this in recent mainline kernels too.

Most of the reports concern dump(8), which apparently forks and has
multiple processes doing I/O to the same area of a file. There's no
fcntl locking involved.

Max Matveev did some analysis of the problem and wrote a reproducer for
it (attached). Simply run this on a current kernel and you'll see a
bunch of FILE_SYNC page-sized writes go out onto the wire. Older
kernels run this program much faster.

He discovered that the problem is primarily due to the bottom two
conditions in nfs_flush_incompatible that were added in commit
f11ac8db5:

 do_flush = req->wb_page != page || req->wb_context != ctx ||
            req->wb_lock_context->lockowner != current->files ||
            req->wb_lock_context->pid != current->tgid;

Because it's doing I/O from different tasks to the same page, those
pages all get flushed out with FILE_SYNC writes. Previously they were
not considered incompatible and no flush was required. It's important
to note that this is even the case on a v3 mount, which shouldn't have
any issue with different lockowners.

The following patch is a proof-of-concept that corrects the problem,
but it's more of a hack than a real fix. Consider it a starting point
for discussion. What would be preferable is a real fix that could allow
v4 to perform better in this situation too, but I'm unclear on how best
to do that.

Perhaps we could look somehow at whether there were any fcntl locks
active and skip those two checks if not?

Thoughts?

--------------------------[snip]--------------------------

[PATCH] nfs: allow coalescing of requests from different lockowners for v2/3 mounts

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/pagelist.c | 12 ++++++++----
 fs/nfs/write.c    |  4 ++--
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index aed913c..754968b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -286,16 +286,20 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 {
 	if (req->wb_context->cred != prev->wb_context->cred)
 		return false;
-	if (req->wb_lock_context->lockowner != prev->wb_lock_context->lockowner)
-		return false;
-	if (req->wb_context->state != prev->wb_context->state)
-		return false;
 	if (req->wb_pgbase != 0)
 		return false;
 	if (prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
 		return false;
 	if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
 		return false;
+	/* no need to do following checks if this is not stateful mount */
+	if (!req->wb_context->state)
+		goto out;
+	if (req->wb_context->state != prev->wb_context->state)
+		return false;
+	if (req->wb_lock_context->lockowner != prev->wb_lock_context->lockowner)
+		return false;
+out:
 	return pgio->pg_ops->pg_test(pgio, prev, req);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 4d6861c..0b1d73f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -836,8 +836,8 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		if (req == NULL)
 			return 0;
 		do_flush = req->wb_page != page || req->wb_context != ctx ||
-			req->wb_lock_context->lockowner != current->files ||
-			req->wb_lock_context->pid != current->tgid;
+			(ctx->state && (req->wb_lock_context->lockowner != current->files ||
+			req->wb_lock_context->pid != current->tgid));
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
-- 
1.7.11.2


--MP_/AECECls4/y4T_QiCat_dW__
Content-Type: text/x-csrc
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=forkwrite.c

#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(int ac, char *av[])
{
	int f = open(av[1], O_WRONLY|O_TRUNC|O_CREAT, 644);
	char buf[10240];
	int i;
	int pid = 0;
	int status;

	if (f < 0) {
		perror(av[1]);
		return 1;
	}

	pid = fork();

	for (i=0; i < 1000; i++) {
		memset(buf, i, sizeof(buf));
		if (write(f, buf, sizeof(buf)) != sizeof(buf)) {
			perror("write failed");
			return 1;
		}
	}
	if (pid) 
		waitpid(pid, &status, 0);

	close(f);
	return 0;
}


--MP_/AECECls4/y4T_QiCat_dW__--
