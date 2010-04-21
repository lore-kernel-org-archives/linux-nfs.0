From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/9] NFS: Squelch compiler warning
Date: Wed, 21 Apr 2010 13:43:23 -0400
Message-ID: <20100421174323.2037.58308.stgit@localhost.localdomain>
References: <20100421173628.2037.54635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:60335 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032Ab0DURnZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:43:25 -0400
Received: by mail-pw0-f46.google.com with SMTP id 9so5322309pwj.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Apr 2010 10:43:25 -0700 (PDT)
In-Reply-To: <20100421173628.2037.54635.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Seen with -Wextra:

/home/cel/linux/fs/nfs/fscache.c: In function =E2=80=98__nfs_readpages_=
from_fscache=E2=80=99:
/home/cel/linux/fs/nfs/fscache.c:479: warning: comparison between signe=
d and unsigned integer expressions

The comparison implicitly converts "int" to "unsigned", making it
safe.  But there's no need for the implicit type conversions here, and
the dfprintk() already uses a "%u" formatter for "npages."  Better to
reduce confusion.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/fscache.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index a6b16ed..ce153a6 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -467,7 +467,8 @@ int __nfs_readpages_from_fscache(struct nfs_open_co=
ntext *ctx,
 				 struct list_head *pages,
 				 unsigned *nr_pages)
 {
-	int ret, npages =3D *nr_pages;
+	unsigned npages =3D *nr_pages;
+	int ret;
=20
 	dfprintk(FSCACHE, "NFS: nfs_getpages_from_fscache (0x%p/%u/0x%p)\n",
 		 NFS_I(inode)->fscache, npages, inode);

