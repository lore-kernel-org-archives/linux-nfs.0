Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43897 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465Ab1LML0M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Dec 2011 06:26:12 -0500
From: Miklos Szeredi <miklos@szeredi.hu>
To: Sage Weil <sage@newdream.net>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        roel <roel.kluin@gmail.com>, LKML <linux-kernel@vger.kernel.org>,
        Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
        fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: ceph, cifs, nfs, fuse: boolean and / or confusion
References: <4EE688FC.8090606@gmail.com>
	<20111212152856.871a8301.akpm@linux-foundation.org>
	<1323733153.13849.17.camel@lade.trondhjem.org>
	<1323733511.13849.19.camel@lade.trondhjem.org>
	<20111212155423.24543d6a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.1112122123040.17811@cobra.newdream.net>
Date: Tue, 13 Dec 2011 12:25:19 +0100
In-Reply-To: <Pine.LNX.4.64.1112122123040.17811@cobra.newdream.net> (Sage
	Weil's message of "Mon, 12 Dec 2011 21:29:51 -0800 (PST)")
Message-ID: <87obvc3e8w.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sage Weil <sage@newdream.net> writes:

> On Mon, 12 Dec 2011, Andrew Morton wrote:
>> 
>> So please prepare and send the NFS patch, with a Reported-by:roel?

Fuse patch follows.  Also pushed to git tree:

  git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse.git for-linus

Thanks Roel.

Miklos

----
>From b48c6af2086ab2ba8a9c9b6ce9ecb34592ce500c Mon Sep 17 00:00:00 2001
From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 13 Dec 2011 10:37:00 +0100
Subject: [PATCH] fuse: fix llseek bug

The test in fuse_file_llseek() "not SEEK_CUR or not SEEK_SET" always evaluates
to true.

This was introduced in 3.1 by commit 06222e49 (fs: handle SEEK_HOLE/SEEK_DATA
properly in all fs's that define their own llseek) and changed the behavior of
SEEK_CUR and SEEK_SET to always retrieve the file attributes.  This is a
performance regression.

Fix the test so that it makes sense.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
CC: stable@vger.kernel.org
CC: Josef Bacik <josef@redhat.com>
CC: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/fuse/file.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 594f07a..19029e9 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1556,7 +1556,7 @@ static loff_t fuse_file_llseek(struct file *file, loff_t offset, int origin)
 	struct inode *inode = file->f_path.dentry->d_inode;
 
 	mutex_lock(&inode->i_mutex);
-	if (origin != SEEK_CUR || origin != SEEK_SET) {
+	if (origin != SEEK_CUR && origin != SEEK_SET) {
 		retval = fuse_update_attributes(inode, NULL, file, NULL);
 		if (retval)
 			goto exit;
-- 
1.7.7

