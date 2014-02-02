Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:63630 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbaBBWEk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Feb 2014 17:04:40 -0500
Received: by mail-ie0-f172.google.com with SMTP id e14so5907824iej.31
        for <linux-nfs@vger.kernel.org>; Sun, 02 Feb 2014 14:04:40 -0800 (PST)
Message-ID: <1391378678.8123.5.camel@leira.trondhjem.org>
Subject: Re: NFS client broken in Linus' tip
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>,
        linux-arm-kernel@lists.infradead.org
Date: Sun, 02 Feb 2014 17:04:38 -0500
In-Reply-To: <20140202122757.GC26684@n2100.arm.linux.org.uk>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk>
	 <20140130141405.GA23985@infradead.org>
	 <20140130142752.GX15937@n2100.arm.linux.org.uk>
	 <20140130143208.GB9573@infradead.org>
	 <20140130153812.GA15937@n2100.arm.linux.org.uk>
	 <1391201970.6978.1.camel@leira.trondhjem.org>
	 <20140201010328.GI15937@n2100.arm.linux.org.uk>
	 <20140202122757.GC26684@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2014-02-02 at 12:27 +0000, Russell King - ARM Linux wrote:
> On Sat, Feb 01, 2014 at 01:03:28AM +0000, Russell King - ARM Linux wrote:
> > On Fri, Jan 31, 2014 at 03:59:30PM -0500, Trond Myklebust wrote:
> > > On Thu, 2014-01-30 at 15:38 +0000, Russell King - ARM Linux wrote:
> > > > On Thu, Jan 30, 2014 at 06:32:08AM -0800, Christoph Hellwig wrote:
> > > > > On Thu, Jan 30, 2014 at 02:27:52PM +0000, Russell King - ARM Linux wrote:
> > > > > > Yes and no.  I still end up with an empty /etc/mtab, but the file now
> > > > > > exists.  However, I can create and echo data into /etc/mtab, but it seems
> > > > > > that can't happen at boot time.
> > > > > 
> > > > > Odd.  Can you disable CONFIG_NFSD_V3_ACL for now to isolate the issue?
> > > > 
> > > > Unfortunately, that results in some problem at boot time, which
> > > > ultimately ends up with the other three CPUs being stopped, and
> > > > hence the original reason scrolls off the screen before it can be
> > > > read... even at 1920p.
> > > > 
> > > Hi Russell,
> > > 
> > > The following patch fixes the issue for me.
> > 
> > It doesn't entirely fix the issue for me, instead we've got even weirder
> > behaviour:
> > 
> > root@cubox-i4:~# ls -al test
> > ls: cannot access test: No such file or directory
> > root@cubox-i4:~# touch test
> > root@cubox-i4:~# ls -al test
> > -rw-r--r-- 1 root root 0 Feb  1 01:01 test
> > root@cubox-i4:~# echo foo > test
> > root@cubox-i4:~# ls -al test
> > -rw-r--r-- 1 root root 4 Feb  1 01:01 test
> > root@cubox-i4:~# cat test
> > foo
> > root@cubox-i4:~# rm test
> > root@cubox-i4:~# echo foo > test
> > -bash: test: Operation not supported
> > root@cubox-i4:~# ls -al test
> > -rw-r--r-- 1 root root 0 Feb  1 01:01 test
> 
> FYI, I just tested Linus' tip, and NFS is still broken.
> 
Hi Russell,

The following patch should fix the above problem. It needs to be applied
on top of the one I sent you previously. In addition, you will want to
apply Noah Massey's patch from
http://lkml.kernel.org/r/1391135472-9639-1-git-send-email-Noah.Massey@gmail.com 

Cheers,
  Trond

8<------------------------------------------------------------------------------
>From f9ad7a7b43554bc36eccf03d33617c05b8a2c77d Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Sun, 2 Feb 2014 14:36:42 -0500
Subject: [PATCH] NFSv3: Fix return value of nfs3_proc_setacls

nfs3_proc_setacls is used internally by the NFSv3 create operations
to set the acl after the file has been created. If the operation
fails because the server doesn't support acls, then it must return '0',
not -EOPNOTSUPP.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs3acl.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 9271a6bb9a41..871d6eda8dba 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -113,7 +113,7 @@ getout:
 	return ERR_PTR(status);
 }
 
-int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
+static int __nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 		struct posix_acl *dfacl)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
@@ -198,6 +198,15 @@ out:
 	return status;
 }
 
+int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
+		struct posix_acl *dfacl)
+{
+	int ret;
+	ret = __nfs3_proc_setacls(inode, acl, dfacl);
+	return (ret == -EOPNOTSUPP) ? 0 : ret;
+
+}
+
 int nfs3_set_acl(struct inode *inode, struct posix_acl *acl, int type)
 {
 	struct posix_acl *alloc = NULL, *dfacl = NULL;
@@ -225,7 +234,7 @@ int nfs3_set_acl(struct inode *inode, struct posix_acl *acl, int type)
 		if (IS_ERR(alloc))
 			goto fail;
 	}
-	status = nfs3_proc_setacls(inode, acl, dfacl);
+	status = __nfs3_proc_setacls(inode, acl, dfacl);
 	posix_acl_release(alloc);
 	return status;
 
-- 
1.8.5.3


-- 
Trond Myklebust
Linux NFS client maintainer

