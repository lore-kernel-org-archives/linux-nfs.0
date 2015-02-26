Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:59051 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbbBZAhu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 19:37:50 -0500
Received: by mail-qg0-f53.google.com with SMTP id f51so6095763qge.12
        for <linux-nfs@vger.kernel.org>; Wed, 25 Feb 2015 16:37:50 -0800 (PST)
Message-ID: <1424911067.41161.2.camel@primarydata.com>
Subject: Re: File Read Returns Non-existent Null Bytes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Chris Perl <cperl@janestreet.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Date: Wed, 25 Feb 2015 19:37:47 -0500
In-Reply-To: <E6147A6E-E0B4-4DB1-A35F-2EB4BC6910B0@oracle.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
	 <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
	 <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
	 <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
	 <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
	 <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
	 <E6147A6E-E0B4-4DB1-A35F-2EB4BC6910B0@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2015-02-25 at 17:32 -0500, Chuck Lever wrote:
> FWIW it’s easy to reproduce a similar race with fsx, and I encounter
> it frequently while running xfstests on fast NFS servers.
> 
> fsx invokes ftruncate following a set of asynchronous reads
> (generated possibly due to readahead). The reads are started first,
> then the SETATTR, but they complete out of order.
> 
> The SETATTR changes the test file’s size, and the completion
> updates the file size in the client’s inode. Then the read requests
> complete on the client and set the file’s size back to its old value.
> 
> All it takes is one late read completion, and the cached file size
> is corrupted. fsx detects the file size mismatch and terminates the
> test. The file size is corrected by a subsequent GETATTR (say, an
> “ls -l” to check it after fsx has terminated).
> 
> While SETATTR blocks concurrent writes, there’s no serialization
> on either the client or server to help guarantee the ordering of
> SETATTR with read operations.
> 
> I’ve found a successful workaround by forcing the client to ignore
> post-op attrs in read replies. A stronger solution might simply set
> the “file attributes need update” flag in the inode if any file
> attribute mutation is noticed during a read completion.

That's different. We definitely should aim to fix this kind of issue
since you are talking about a single client being the only thing
accessing the file on the server.
How about the following patch?

8<---------------------------------------------------------------
>From d4c24528e8ac9c38d9ef98c5bbc15829f4032c0d Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 25 Feb 2015 19:26:28 -0500
Subject: [PATCH] NFS: Quiesce reads before updating the file size after
 truncating

Chuck Lever reports seeing readaheads racing with truncate operations
and causing the file size to be reverted. Fix is to quiesce reads
after truncating the file on the server, but before updating the
size on the client.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 83107be3dd01..c0aa87fd4766 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -565,6 +565,10 @@ static int nfs_vmtruncate(struct inode * inode, loff_t offset)
 	if (err)
 		goto out;
 
+	/* Quiesce reads before changing the file size */
+	invalidate_inode_pages2_range(&inode->i_mapping,
+			offset >> PAGE_CACHE_SHIFT;, -1);
+
 	spin_lock(&inode->i_lock);
 	i_size_write(inode, offset);
 	/* Optimisation */
-- 
2.1.0



