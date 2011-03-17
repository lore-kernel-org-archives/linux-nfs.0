Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45551 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752118Ab1CQAzd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 20:55:33 -0400
Date: Thu, 17 Mar 2011 11:55:22 +1100
From: NeilBrown <neilb@suse.de>
To: <peter.staubach@emc.com>, <Trond.Myklebust@netapp.com>
Cc: <bjschuma@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: Use of READDIRPLUS on large directories
Message-ID: <20110317115522.29020461@notabene.brown>
In-Reply-To: <20110317084038.6d4ea49d@notabene.brown>
References: <20110316155528.31913c58@notabene.brown>
	<5E6794FC7B8FCA41A704019BE3C70E8B068397B4@MX31A.corp.emc.com>
	<20110317084038.6d4ea49d@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 17 Mar 2011 08:40:38 +1100 NeilBrown <neilb@suse.de> wrote:

> On Wed, 16 Mar 2011 08:30:20 -0400 <peter.staubach@emc.com> wrote:
> 
> > Perhaps the use of a heuristic that enables readdirplus only after the application has shown that it is interested in the attributes for each entry in the directory?  Thus, if the application does readdir()/stat()/stat()/stat()/readdir()/... then the NFS client could use readdirplus to fill the caches.  If the application is just reading the directory and looking at the names, then the client could just use readdir.
> 
> I think this could work very well.
> "ls -l" certainly calls 'stat' on each file after each 'getdents' call.
> 
> So we could arrange that the first readdir call on a directory
> always uses the 'plus' version, and clears a "seen any getattr calls"
> flag on the directory.
> 
> nfs_getattr then sets that flag on the parent
> 
> subsequent readdir calls only use 'plus' if the flag was set, and
> clear the flag again.
> 
> 
> There might be odd issues with multiple processes reading and stating
> in the same directory, but they probably aren't very serious.
> 
> I'm might give this idea a try ... but I still think the original
> switch to always use readdirplus is a regression and should be reverted.

I've been experimenting with this some more.
I've been using an other-wise unloaded NFS server (4 year old consumer
Linux box) with ordinary drives and networking etc.
Mounting with NFSv3 and default options (unless specified).

I created a directory with 30,000 small files.

 echo 3 > /proc/sys/vm/drop_caches 

on bother server and client before running a test.
All timing runs on client (of course).

% time ls  --color=never > /dev/null

This takes about 4 seconds on 2.6.38, using READDIRPLUS.

With the patch below applied it takes about 1.5 seconds.
The first 44 requests are READDIRPLUS, which provide the 1024
entries requested by the getdents64 call.  The remaining
requsts are READDIR.  So on a big directory I get a factor-of-2 speed up.
On a more loaded NFS server the real numbers might be bigger(??)

% time ls -l  --color=never > /dev/nulls 

This takes about 25 seconds when using READDIRPLUS, either with or
without that patch the same sequence of requests are sent.
With READDIR (using -o nordirplus) it takes about 40 seconds.

Much of the 25 seconds is due to GETACL requests.


So while this only provides a 2 second speed-up for me, it is a real
speed up.

The only cost I can find is that the sequence:
   ls
   ls -l
becomes slower.  The "ls -l" doesn't perform any READDIR as the 
directory listing is in cache.  So that means we need 30,000 GETATTR
calls and 30,000 GETACL calls, which all take a while.

What do people think?


Strangely, when I try NFSv4 I don't get what I would expect.

"ls" on an unpatched 2.6.38 takes over 5 seconds rather than around 4.
With the patch it does back down to about 2. (still NFSv3 at 1.5).
Why would NFSv4 be slower?
 On v3 we make 44 READDIRPLUS calls and 284 READDIR calls - total of  328
       READDIRPLUS have about 30 names, READDIR have about 100
 On v4 we make 633 READDIR calls - nearly double.
       Early packed contain about 19 name, later ones about 70

Is nfsd (2.6.32) just not packing enough answers in the reply?
Client asks for a dircount of 16384 and a maxcount of 32768, and gets
packets which are about 4K long - I guess that is PAGE_SIZE ??

"ls -l" still takes around 25 seconds - even though READDIR is asking
for and receiving all the 'plus' attributes, I see 30,000 "GETATTR" requests
for exactly the same set of attributes.  Something is wrong there.

NeilBrown


From: NeilBrown <neilb@suse.de>
Subject: Make selection of 'readdir-plus' adapt to usage patterns.

While the use of READDIRPLUS is significantly more efficient than
READDIR followed by many GETATTR calls, it is still less efficient
than just READDIR if the attributes are not required.

We can get a hint as to whether the application requires attr information
by looking at whether any ->getattr calls are made between
->readdir calls.
If there are any, then getting the attributes seems to be worth while.

This patch tracks whether there have been recent getattr calls on
children of a directory and uses that information to selectively
disable READDIRPLUS on that directory.

The first 'readdir' call is always served using READDIRPLUS.
Subsequent calls only use READDIRPLUS if there was a getattr on a child
in the mean time.

The locking of ->d_parent access needs to be reviewed.
As the bit is simply a hint, it isn't critical that it is set
on the "correct" parent if a rename is happening, but it is
critical that the 'set' doesn't set a bit in something that
isn't even an inode any more.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2c3eb33..6882e14 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -804,6 +804,9 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	desc->dir_cookie = &nfs_file_open_context(filp)->dir_cookie;
 	desc->decode = NFS_PROTO(inode)->decode_dirent;
 	desc->plus = NFS_USE_READDIRPLUS(inode);
+	if (filp->f_pos > 0 && !test_bit(NFS_INO_SEEN_GETATTR, &NFS_I(inode)->flags))
+		desc->plus = 0;
+	clear_bit(NFS_INO_SEEN_GETATTR, &NFS_I(inode)->flags);
 
 	nfs_block_sillyrename(dentry);
 	res = nfs_revalidate_mapping(inode, filp->f_mapping);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2f8e618..4cb17df 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -505,6 +505,15 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	struct inode *inode = dentry->d_inode;
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
 	int err;
+	struct dentry *p;
+	struct inode *pi;
+
+	rcu_read_lock();
+	p = dentry->d_parent;
+	pi = rcu_dereference(p)->d_inode;
+	if (pi && !test_bit(NFS_INO_SEEN_GETATTR, &NFS_I(pi)->flags))
+		set_bit(NFS_INO_SEEN_GETATTR, &NFS_I(pi)->flags);
+	rcu_read_unlock();
 
 	/* Flush out writes to the server in order to update c/mtime.  */
 	if (S_ISREG(inode->i_mode)) {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 6023efa..2a04ed5 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -219,6 +219,10 @@ struct nfs_inode {
 #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
+#define NFS_INO_SEEN_GETATTR	(8)		/* flag to track if app is calling
+						 * getattr in a directory during
+						 * readdir
+						 */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {
