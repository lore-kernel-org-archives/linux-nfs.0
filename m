From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd change for 2.6.28
Date: Sun, 9 Nov 2008 15:23:11 -0500
Message-ID: <20081109202311.GC27376@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>, Doug Nazar <nazard-9NxrcwDPlTov2OKnPYDugg@public.gmane.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49248 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752470AbYKIUXN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2008 15:23:13 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One more readdir fix suitable for 2.6.28 is available from the
for-2.6.28 branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.28

--b.

Doug Nazar (1):
      Fix nfsd truncation of readdir results

 fs/nfsd/vfs.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

commit b726e923ea4d216027e466aa602d914e4b4a63af
Author: Doug Nazar <nazard-9NxrcwDPlTov2OKnPYDugg@public.gmane.org>
Date:   Wed Nov 5 06:16:28 2008 -0500

    Fix nfsd truncation of readdir results
    
    Commit 8d7c4203 "nfsd: fix failure to set eof in readdir in some
    situations" introduced a bug: on a directory in an exported ext3
    filesystem with dir_index unset, a READDIR will only return about 250
    entries, even if the directory was larger.
    
    Bisected it back to this commit; reverting it fixes the problem.
    
    It turns out that in this case ext3 reads a block at a time, then
    returns from readdir, which means we can end up with buf.full==0 but
    with more entries in the directory still to be read.  Before 8d7c4203
    (but after c002a6c797 "Optimise NFS readdir hack slightly"), this would
    cause us to return the READDIR result immediately, but with the eof bit
    unset.  That could cause a performance regression (because the client
    would need more roundtrips to the server to read the whole directory),
    but no loss in correctness, since the cleared eof bit caused the client
    to send another readdir.  After 8d7c4203, the setting of the eof bit
    made this a correctness problem.
    
    So, move nfserr_eof into the loop and remove the buf.full check so that
    we loop until buf.used==0.  The following seems to do the right thing
    and reduces the network traffic since we don't return a READDIR result
    until the buffer is full.
    
    Tested on an empty directory & large directory; eof is properly sent and
    there are no more short buffers.
    
    Signed-off-by: Doug Nazar <nazard-9NxrcwDPlTov2OKnPYDugg@public.gmane.org>
    Cc: David Woodhouse <David.Woodhouse@intel.com>
    Cc: Al Viro <viro@zeniv.linux.org.uk>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 848a03e..4433c8f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1875,11 +1875,11 @@ static int nfsd_buffered_readdir(struct file *file, filldir_t func,
 		return -ENOMEM;
 
 	offset = *offsetp;
-	cdp->err = nfserr_eof; /* will be cleared on successful read */
 
 	while (1) {
 		unsigned int reclen;
 
+		cdp->err = nfserr_eof; /* will be cleared on successful read */
 		buf.used = 0;
 		buf.full = 0;
 
@@ -1912,9 +1912,6 @@ static int nfsd_buffered_readdir(struct file *file, filldir_t func,
 			de = (struct buffered_dirent *)((char *)de + reclen);
 		}
 		offset = vfs_llseek(file, 0, SEEK_CUR);
-		cdp->err = nfserr_eof;
-		if (!buf.full)
-			break;
 	}
 
  done:
