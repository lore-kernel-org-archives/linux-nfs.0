From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [2.6.31-rc4] nfs4 writecount warning...
Date: Tue, 28 Jul 2009 14:15:47 -0400
Message-ID: <20090728181547.GB23901@fieldses.org>
References: <6278d2220907271449l38609680n943875d2672da20f@mail.gmail.com> <20090728161813.GG19497@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41803 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755350AbZG1SPt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2009 14:15:49 -0400
In-Reply-To: <20090728161813.GG19497@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 28, 2009 at 12:18:14PM -0400, bfields wrote:
> On Mon, Jul 27, 2009 at 10:49:03PM +0100, Daniel J Blueman wrote:
> > After two days uptime on my NFS4 server with 2.6.31-rc4 and a few
> > 2.6.28 clients, I hit the file write-count
> > WARN_ON(f->f_mnt_write_state != 0) in file_take_write() in the
> > nfsd4_open path [1].
> 
> Hm, so probably introduced by:
> 
> e518f0560a191269bd345178c899c790eb1ad4c8 "nfsd: take file and mnt write
> in nfs4_upgrade_open".
> 
> The other possible file_take_write() caller here is dentry_open (which
> calls it in the (f->f_mode & FMODE_WRITE) case).
> 
> Looks like nfs4_upgrade_open() isn't handling error case cleanup
> correctly.  Perhaps that could explain this.

The below (untested) should fix the error handling, at the expense of
making nfs4_upgrade_open() just a little more byzantine.

There's another problem, though: if our server gets a sequence like:

	- OPEN for read
	- OPEN for write
	- OPEN_DOWNGRADE to read
	- OPEN for write

all with the same open owner and file, then at the vfs level we do all
this with a single filp, like:

	- OPEN for read
		dentry_open();
	- OPEN for write
		get_write_access(inode);
		mnt_want_write(mnt);
		file_take_write(file);
	- OPEN_DOWNGRADE to read
		put_write_access(inode);
		mnt_drop_write(mnt);
		file_release_write(file);
	- OPEN for write
		get_write_access(inode);
		mnt_want_write(mnt);
		file_take_write(file);

But examination of the code shows that file_take_write() doesn't allow
this kind of use: you'll hit the warning you found, because

	f_mnt_write_state == FILE_MNT_WRITE_TAKEN | FILE_MNT_WRITE_RELEASE;

We could fix that by replacing our file_release_write() with a
file_reset_write().  But I suspect we're abusing the VFS interface, and
we should really just keep separate filp's for read and write.

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7729d09..3018839 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2378,14 +2378,19 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct svc_fh *cur_fh, struct nfs4_sta
 		if (err)
 			return nfserrno(err);
 		err = mnt_want_write(cur_fh->fh_export->ex_path.mnt);
-		if (err)
+		if (err) {
+			put_write_access(inode);
 			return nfserrno(err);
+		}
 		file_take_write(filp);
 	}
 	status = nfsd4_truncate(rqstp, cur_fh, open);
 	if (status) {
-		if (new_writer)
+		if (new_writer) {
+			file_reset_write(filp);
+			mnt_drop_write(cur_fh->fh_export->ex_path.mnt);
 			put_write_access(inode);
+		}
 		return status;
 	}
 	/* remember the open */
