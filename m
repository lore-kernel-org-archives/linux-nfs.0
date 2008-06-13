From: NeilBrown <neilb@suse.de>
Subject: [PATCH] knfsd: nfsd: Handle ERESTARTSYS from syscalls.
Date: Fri, 13 Jun 2008 21:41:03 +1000
Message-ID: <1080613114103.27052@suse.de>
References: <20080613213759.26929.patches@notabene>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: J.Bruce@suse.de, Fields@suse.de,
	" <bfields@fieldses.org>@suse.de"@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:33151 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752904AbYFMLln (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 07:41:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


OCFS2 can return -ERESTARTSYS from write requests (and possibly
elsewhere) if there is a signal pending.

If nfsd is shutdown (by sending a signal to each thread) while there
is still an IO load from the client, each thread could handle one last
request with a signal pending.  This can result in -ERESTARTSYS
which is not understood by nfserrno() and so is reflected back to
the client as nfserr_io aka -EIO.  This is wrong.

Instead, interpret ERESTARTSYS to mean "don't send a reply".
The client will resend and - if the server is restarted - the write will
(hopefully) be successful and everyone will be happy.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsproc.c |    1 +
 1 file changed, 1 insertion(+)

----
Funny how the shortest patches sometimes have the longest
descriptions.

The symptom that I narrowed down to this was:
   copy a large file via NFS to an OCFS2 filesystem, and restart
   the nfs server during the copy.
   The 'cp' might get an -EIO, and the file will be corrupted -
   presumably holes in the middle were writes appeared to fail.

diff .prev/fs/nfsd/nfsproc.c ./fs/nfsd/nfsproc.c
--- .prev/fs/nfsd/nfsproc.c	2008-06-13 21:31:53.000000000 +1000
+++ ./fs/nfsd/nfsproc.c	2008-06-13 21:31:57.000000000 +1000
@@ -614,6 +614,7 @@ nfserrno (int errno)
 #endif
 		{ nfserr_stale, -ESTALE },
 		{ nfserr_jukebox, -ETIMEDOUT },
+		{ nfserr_dropit, -ERESTARTSYS },
 		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },
 		{ nfserr_badname, -ESRCH },

### Diffstat output
 ./fs/nfsd/nfsproc.c |    1 +
 1 file changed, 1 insertion(+)

diff .prev/fs/nfsd/nfsproc.c ./fs/nfsd/nfsproc.c
--- .prev/fs/nfsd/nfsproc.c	2008-06-13 21:31:53.000000000 +1000
+++ ./fs/nfsd/nfsproc.c	2008-06-13 21:31:57.000000000 +1000
@@ -614,6 +614,7 @@ nfserrno (int errno)
 #endif
 		{ nfserr_stale, -ESTALE },
 		{ nfserr_jukebox, -ETIMEDOUT },
+		{ nfserr_dropit, -ERESTARTSYS },
 		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },
 		{ nfserr_badname, -ESRCH },
