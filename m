Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58844 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756553Ab3C2Snc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Mar 2013 14:43:32 -0400
Date: Fri, 29 Mar 2013 14:43:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: kernel 3.8.4 : kernel BUG at fs/locks.c:2093!   part #2
Message-ID: <20130329184331.GH22307@fieldses.org>
References: <514F31AF.3080709@gmx.de>
 <20130325220143.GD10887@fieldses.org>
 <20130326144640.GB3353@fieldses.org>
 <51536610.7010809@gmx.de>
 <20130327215727.GB27426@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130327215727.GB27426@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 27, 2013 at 05:57:27PM -0400, J. Bruce Fields wrote:
> On Wed, Mar 27, 2013 at 10:35:12PM +0100, Toralf Förster wrote:
> > On 03/26/2013 03:46 PM, J. Bruce Fields wrote:
> > > Can you run with test patches?
> > 
> > applied - today I got a warning instead a bug at the host kernel (3.8.4):
> 
> Excellent!  Thanks, I think I see the bug now....

This logic is just terrible; I'll see what if I can make this more
sensible.

For now, though, this should fix the bug.

Thanks again for this testing.

--b.

commit 01463db0a864d43bd2c9a69ff37d5a75b7822a49
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 28 20:37:14 2013 -0400

    nfsd4: don't close read-write opens too soon
    
    Don't actually close any opens until we don't need them at all.
    
    This means being left with write access when it's not really necessary,
    but that's better than putting a file that might still have posix locks
    held on it, as we have been.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index aac878e..285a0c8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -210,13 +210,7 @@ static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 {
 	if (atomic_dec_and_test(&fp->fi_access[oflag])) {
 		nfs4_file_put_fd(fp, oflag);
-		/*
-		 * It's also safe to get rid of the RDWR open *if*
-		 * we no longer have need of the other kind of access
-		 * or if we already have the other kind of open:
-		 */
-		if (fp->fi_fds[1-oflag]
-			|| atomic_read(&fp->fi_access[1 - oflag]) == 0)
+		if (atomic_read(&fp->fi_access[1 - oflag]) == 0)
 			nfs4_file_put_fd(fp, O_RDWR);
 	}
 }
