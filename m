Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41121 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab3JAWAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 18:00:32 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSv4: Fix a use-after-free situation in _nfs4_proc_getlk()
Date: Tue, 1 Oct 2013 18:00:29 -0400
Message-ID: <1380664829-6450-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In nfs4_proc_getlk(), when some error causes a retry of the call to
_nfs4_proc_getlk(), we can end up with Oopses of the form

 BUG: unable to handle kernel NULL pointer dereference at 0000000000000134
 IP: [<ffffffff8165270e>] _raw_spin_lock+0xe/0x30
<snip>
 Call Trace:
  [<ffffffff812f287d>] _atomic_dec_and_lock+0x4d/0x70
  [<ffffffffa053c4f2>] nfs4_put_lock_state+0x32/0xb0 [nfsv4]
  [<ffffffffa053c585>] nfs4_fl_release_lock+0x15/0x20 [nfsv4]
  [<ffffffffa0522c06>] _nfs4_proc_getlk.isra.40+0x146/0x170 [nfsv4]
  [<ffffffffa052ad99>] nfs4_proc_lock+0x399/0x5a0 [nfsv4]

The problem is that we don't clear the request->fl_ops after the first
try and so when we retry, nfs4_set_lock_state() exits early without
setting the lock stateid.
Regression introduced by commit 70cc6487a4e08b8698c0e2ec935fb48d10490162
(locks: make ->lock release private data before returning in GETLK case)

Reported-by: Weston Andros Adamson <dros@netapp.com>
Reported-by: Jorge Mora <mora@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: <stable@vger.kernel.org> #2.6.22+
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d53d678..d2b4845 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5106,6 +5106,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 			status = 0;
 	}
 	request->fl_ops->fl_release_private(request);
+	request->fl_ops = NULL;
 out:
 	return status;
 }
-- 
1.8.3.1

