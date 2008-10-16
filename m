From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH/RFC]  Make nfs_file_cred more robust.
Date: Thu, 16 Oct 2008 14:15:16 +1100
Message-ID: <18678.45508.754388.782723@notabene.brown>
References: <18678.28273.285015.747371@notabene.brown>
	<1224110698.7371.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:39781 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752876AbYJPDP6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 23:15:58 -0400
In-Reply-To: message from Trond Myklebust on Wednesday October 15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday October 15, Trond.Myklebust@netapp.com wrote:
> On Thu, 2008-10-16 at 09:28 +1100, Neil Brown wrote:
> > Hi Trond,
> >  I wonder if you would consider including the following patch which
> >  makes nfs_file_cred a little more robust.
> > 
> >  It isn't strictly needed with current mainline.  However we have a patch
> >  set which (among other things) passes a 'struct file' down (via
> >  ATTR_FILE) for a chmod call.
> >  If chmod is called on e.g. a device special file, this will cause
> >  nfs3_proc_setattr to call nfs_file_cred on a 'struct file' which does
> >  not have an associated open context or credential.  That goes Oops.
> > 
> >  Thanks for your consideration,
> > NeilBrown
> 
> Hi Neil,
> 
> Won't this still end up exploding in nfs4_proc_setattr?
> 

Yes, of course.  I guess NFSv4 wasn't tested.

How's this?

Thanks,
NeilBrown


From: Neil Brown <neilb-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Subject: [PATCH] Make nfs_file_cred more robust.

As not all files have an associated open_context (e.g. device special
files), it is safest to test for the existence of the open context
before de-referencing it.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/nfs4proc.c      |    6 ++++--
 include/linux/nfs_fs.h |    8 ++++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c910413..83e700a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1659,8 +1659,10 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		struct nfs_open_context *ctx;
 
 		ctx = nfs_file_open_context(sattr->ia_file);
-		cred = ctx->cred;
-		state = ctx->state;
+		if (ctx) {
+			cred = ctx->cred;
+			state = ctx->state;
+		}
 	}
 
 	status = nfs4_do_setattr(inode, cred, fattr, sattr, state);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 78a5922..63bf8f0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -372,8 +372,12 @@ static inline struct nfs_open_context *nfs_file_open_context(struct file *filp)
 
 static inline struct rpc_cred *nfs_file_cred(struct file *file)
 {
-	if (file != NULL)
-		return nfs_file_open_context(file)->cred;
+	if (file != NULL) {
+		struct nfs_open_context *ctx =
+			nfs_file_open_context(file);
+		if (ctx)
+			return ctx->cred;
+	}
 	return NULL;
 }
 
-- 
1.5.6.5

