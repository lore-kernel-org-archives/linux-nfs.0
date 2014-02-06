Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:34492 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284AbaBFWNC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Feb 2014 17:13:02 -0500
Received: by mail-ie0-f178.google.com with SMTP id x13so1125541ief.37
        for <linux-nfs@vger.kernel.org>; Thu, 06 Feb 2014 14:13:01 -0800 (PST)
Message-ID: <1391724779.6399.2.camel@leira.trondhjem.org>
Subject: Re: readdir vs. getattr
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Date: Thu, 06 Feb 2014 17:12:59 -0500
In-Reply-To: <20140206135101.1cc83442@notabene.brown>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	 <20130404151507.GA8484@umich.edu>
	 <CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
	 <1365090480.10726.22.camel@leira.trondhjem.org>
	 <20140129182532.7479eeda@notabene.brown>
	 <1342984553.746756.1390987303295.JavaMail.zimbra@desy.de>
	 <20140129071841.1979a48c@tlielax.poochiereds.net>
	 <20140206134539.53d09434@notabene.brown>
	 <20140206135101.1cc83442@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-02-06 at 13:51 +1100, NeilBrown wrote:
> On Thu, 6 Feb 2014 13:45:39 +1100 NeilBrown <neilb@suse.de> wrote:
> 
> 
> > The change to nfs_update_inode fixes an issue that had me stumped for a
> > while.  It was still sending lots of GETATTR requests even after it had
> > switched to READDIRPLUS instead of using cached info.  So that might be a
> > genuine bug that should be fixed independently of this patch.
> 
> I managed to post the wrong version of the patch, which didn't have this
> change.  Sorry.
> 
> Here is the real one.
> 
> NeilBrown

Hi Neil,

Is there any reason why this patch couldn't just be replaced with the
following?
(Please note the separate fix for the labeled NFS regression that you
pointed out.)

Cheers
  Trond

8<-------------------------------------------------------------------
>From fda6d0fb7988fd7d541ef6d1023bca92b0e10333 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 6 Feb 2014 16:45:21 -0500
Subject: [PATCH] NFS: Use readdirplus in order to efficiently revalidate whole
 directories

When we call nfs_force_lookup_revalidate() in order to force a full
lookup of all child dentries of a directory, it makes sense to use
readdirplus to perform that revalidation as efficiently as possible.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index be38b573495a..2abcae330ad0 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -437,6 +437,24 @@ void nfs_advise_use_readdirplus(struct inode *dir)
 	set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(dir)->flags);
 }
 
+/*
+ * Force use of readdirplus to ensure efficient revalidation of
+ * the directory child dentries when we know that we will need
+ * to revalidate the whole directory.
+ *
+ * Caller must hold dir->i_lock.
+ */
+static
+void nfs_force_use_readdirplus(struct inode *dir)
+{
+	if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS)) {
+		struct nfs_inode *nfsi = NFS_I(dir);
+
+		set_bit(NFS_INO_ADVISE_RDPLUS, &nfsi->flags);
+		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+	}
+}
+
 static
 void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 {
@@ -942,12 +960,14 @@ static int nfs_fsync_dir(struct file *filp, loff_t start, loff_t end,
  * This forces the revalidation code in nfs_lookup_revalidate() to do a
  * full lookup on all child dentries of 'dir' whenever a change occurs
  * on the server that might have invalidated our dcache.
+ * Call nfs_force_use_readdirplus for efficiency.
  *
  * The caller should be holding dir->i_lock
  */
 void nfs_force_lookup_revalidate(struct inode *dir)
 {
 	NFS_I(dir)->cache_change_attribute++;
+	nfs_force_use_readdirplus(dir);
 }
 EXPORT_SYMBOL_GPL(nfs_force_lookup_revalidate);
 
-- 
1.8.5.3


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


