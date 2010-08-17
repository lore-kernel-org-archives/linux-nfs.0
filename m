Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from os.inf.tu-dresden.de ([141.76.48.99]:56771 "EHLO
	os.inf.tu-dresden.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840Ab0HQRPC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 13:15:02 -0400
Date: Tue, 17 Aug 2010 19:14:54 +0200
From: Adam Lackorzynski <adam@os.inf.tu-dresden.de>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>, stable@kernel.org
Subject: Re: 2.6.35.2: NFS related Oops
Message-ID: <20100817171454.GB11366@os.inf.tu-dresden.de>
References: <20100816215056.GA5376@os.inf.tu-dresden.de>
 <4C6A5FF1.3070209@cn.fujitsu.com>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <4C6A5FF1.3070209@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Tue Aug 17, 2010 at 18:09:53 +0800, Bian Naimeng wrote:
>   Please try to apply the followed patch.

Thanks, this fixes the Oops. Patch is required for both 2.6.35 and
2.6.36 trees.

 
----
 
We we open a positive file just with O_EXCL but no O_CREAT, may cause kernel crash.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
 
---
 fs/nfs/dir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 29539ce..1a672dd 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1100,7 +1100,7 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 		goto no_open_dput;
 	openflags = nd->intent.open.flags;
 	/* We cannot do exclusive creation on a positive dentry */
-	if ((openflags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL))
+	if (openflags & O_EXCL)
 		goto no_open_dput;
 	/* We can't create new files, or truncate existing ones here */
 	openflags &= ~(O_CREAT|O_TRUNC);
-- 
1.7.0



Adam
-- 
Adam                 adam@os.inf.tu-dresden.de
  Lackorzynski         http://os.inf.tu-dresden.de/~adam/
