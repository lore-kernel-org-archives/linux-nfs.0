Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:59386 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932094AbaIRQAY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2014 12:00:24 -0400
Received: by mail-ie0-f172.google.com with SMTP id rd18so1485044iec.3
        for <linux-nfs@vger.kernel.org>; Thu, 18 Sep 2014 09:00:23 -0700 (PDT)
Message-ID: <1411056020.10845.1.camel@leira.trondhjem.org>
Subject: Re: NFS Kernel Bug
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: James Drews <drews@engr.wisc.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Thu, 18 Sep 2014 12:00:20 -0400
In-Reply-To: <CAHQdGtQZ0kcBZ0QCb+sf52thERjJgz-5M++CsT7kdoDweG61sQ@mail.gmail.com>
References: <541AD7E5.8020409@engr.wisc.edu>
	 <CAHQdGtQZ0kcBZ0QCb+sf52thERjJgz-5M++CsT7kdoDweG61sQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-09-18 at 10:31 -0400, Trond Myklebust wrote:
> On Thu, Sep 18, 2014 at 9:02 AM, James Drews <drews@engr.wisc.edu> wrote:
> > Good morning!
> >
> > I believe we have found a bug in the NFS kernel area.  The "bug" is a leak
> > of a file handle where the NFS client never tells the server to close the
> > file. The problem is very similar to one we had reported and got a fix for
> > previously. We are using that patch, but ran in to another case where the
> > client sends out an OPEN_DOWNGRADE but never sends a CLOSE.
> >
> > Attached is a simple c program that we have been able to reproduce the bug
> > with, along with a packet capture of what we see on the wire.
> >
> > To reproduce the bug:
> > -compile the c code
> > -execute the c code with:
> >
> > ./test ; cat testfile3 > /dev/nul
> >
> > -now if we try to remove the file we get a file in use error (server is
> > using mandatory locking)
> >
> > Things to note:
> >
> > -if you just run the program without the immediate cat'ing of the file, the
> > bug does not happen
> > suggesting a timing issue
> > -If you alter the program so the code mimics the cat of the file, the bug
> > does not happen (ie, add an open, read file, close to the code).
> > -If you run the program as described above, and then run it again without
> > the "; cat testfile3 > /dev/nul", the kernel squeaks out the file close to
> > the server when the code does the close.
> >
> > The attached packet capture is us doing:
> >
> > ./test ; cat testfile3 > /dev/null
> > rm testfile3
> > ./test
> > rm testfile3
> >
> > where we are denied the rm the first time, but not the second.
> >
> 
> Argh. This is a situation where the client shouldn't have called
> OPEN_DOWNGRADE, but should have done a CLOSE. The issue is that the
> client opens the file with OPEN4_SHARE_ACCESS_BOTH, so it is not
> allowed to downgrade to OPEN4_SHARE_ACCESS_READ. Instead it should
> have closed the file, and then used the delegation...
> 

Does the following patch help (and does it still fix your original
bugreport)?

Cheers
  Trond
8<----------------------------------------------------------------
>From d5f56bc67514a290032ff063d837179853231acf Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 18 Sep 2014 11:51:32 -0400
Subject: [PATCH] NFSv4: Fix another bug in the close/open_downgrade code

James Drew reports another bug whereby the NFS client is now sending
an OPEN_DOWNGRADE in a situation where it should really have sent a
CLOSE: the client is opening the file for O_RDWR, but then trying to
do a downgrade to O_RDONLY, which is not allowed by the NFSv4 spec.

Reported-by: James Drews <drews@engr.wisc.edu>
Link: http://lkml.kernel.org/r/541AD7E5.8020409@engr.wisc.edu
Fixes: aee7af356e15 (NFSv4: Fix problems with close in the presence...)
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ac2dd953fc18..6ca0c8e7a945 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2618,23 +2618,23 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	is_rdwr = test_bit(NFS_O_RDWR_STATE, &state->flags);
 	is_rdonly = test_bit(NFS_O_RDONLY_STATE, &state->flags);
 	is_wronly = test_bit(NFS_O_WRONLY_STATE, &state->flags);
-	/* Calculate the current open share mode */
-	calldata->arg.fmode = 0;
-	if (is_rdonly || is_rdwr)
-		calldata->arg.fmode |= FMODE_READ;
-	if (is_wronly || is_rdwr)
-		calldata->arg.fmode |= FMODE_WRITE;
 	/* Calculate the change in open mode */
+	calldata->arg.fmode = 0;
 	if (state->n_rdwr == 0) {
-		if (state->n_rdonly == 0) {
-			call_close |= is_rdonly || is_rdwr;
-			calldata->arg.fmode &= ~FMODE_READ;
-		}
-		if (state->n_wronly == 0) {
-			call_close |= is_wronly || is_rdwr;
-			calldata->arg.fmode &= ~FMODE_WRITE;
-		}
-	}
+		if (state->n_rdonly == 0)
+			call_close |= is_rdonly;
+		else if (is_rdonly)
+			calldata->arg.fmode |= FMODE_READ;
+		if (state->n_wronly == 0)
+			call_close |= is_wronly;
+		else if (is_wronly)
+			calldata->arg.fmode |= FMODE_WRITE;
+	} else if (is_rdwr)
+		calldata->arg.fmode |= FMODE_READ|FMODE_WRITE;
+
+	if (calldata->arg.fmode == 0)
+		call_close |= is_rdwr;
+
 	if (!nfs4_valid_open_stateid(state))
 		call_close = 0;
 	spin_unlock(&state->owner->so_lock);
-- 
1.9.3



