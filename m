From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [ltt-dev] [PATCH] nfs: add support for splice writes
Date: Wed, 22 Apr 2009 14:03:09 +0530
Message-ID: <49EED645.3090208@suse.de>
References: <49D45974.2060202@suse.de> <20090402063235.GB24846@Krystal>	 <49D45E42.3050502@suse.de>	 <91e0b5050904020542l6b38d7a6hab6d7ef8b4593425@mail.gmail.com>	 <49EC0A83.8060802@suse.de> <1240230224.8073.6.camel@heimdal.trondhjem.org>	 <49EC6CB3.8080800@suse.de> <1240237274.13636.9.camel@heimdal.trondhjem.org>	 <49EC990B.1030007@suse.de>  <20090421144810.GA7036@infradead.org> <1240335302.5390.20.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Christoph Hellwig <hch@infradead.org>,
	Masahiro Tamori <masahiro.tamori@gmail.com>,
	Mathieu Desnoyers <compudj-vdFpqfd5riKZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>,
	linux-nfs@vger.kernel.org, ltt-dev-33AaDErTWvBVxDZ2/Zk0YoryAYyacSEB@public.gmane.org,
	LKML <linux-kernel@vger.kernel.org>,
	linux-embedded@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:57912 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbZDVIdi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 04:33:38 -0400
In-Reply-To: <1240335302.5390.20.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2009-04-21 at 10:48 -0400, Christoph Hellwig wrote:
>> On Mon, Apr 20, 2009 at 09:17:23PM +0530, Suresh Jayaraman wrote:
>>> +static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
>>> +				     struct file *filp, loff_t *ppos,
>>> +				     size_t count, unsigned int flags)
>>> +{
>>> +	struct dentry *dentry = filp->f_path.dentry;
>>> +
>>> +	dprintk("NFS splice_write(%s/%s, %lu@%Lu)\n",
>>> +		dentry->d_parent->d_name.name, dentry->d_name.name,
>>> +		(unsigned long) count, (unsigned long long) *ppos);
>>> +
>>> +	return generic_file_splice_write(pipe, filp, ppos, count, flags);
>>> +}
>>> +
>> You need all calls from nfs_file_write, too:
>>
>>  - most importantly the nfs_revalidate_file_size for O_APPEND
> 
> Isn't O_APPEND illegal for splice_write()? It looks like it is from a
> quick perusal of do_splice_from().

Yes, I would also think so and also from upstream commit
efc968d450e013049a662d22727cf132618dcb2f.
I've added a little comment to make his clear.

>>  - the nfs_do_fsync for sync writes
> 
> generic_file_splice_write() calls generic_osync_inode(), which should
> ensure sync writes even with NFS.
> The one thing it won't do is propagate NFS write errors back to the
> caller. If we do care about this, then we should certainly test for
> nfs_need_sync_write() and then call nfs_do_fsync() (see
> nfs_file_write()).

I think it makes sense to propagate NFS write errors back.

>>  - probably the stats increment
> 
> We should talk to Chuck about this.
> 

Have added it to NORMALBYTESWRITTEN based on Chuck's suggestion.

Here is the updated patch. Does this look OK?

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 fs/nfs/file.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5a97bcf..6f2cd67 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -48,6 +48,9 @@ static ssize_t nfs_file_splice_read(struct file *filp, loff_t *ppos,
 					size_t count, unsigned int flags);
 static ssize_t nfs_file_read(struct kiocb *, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos);
+static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
+					struct file *filp, loff_t *ppos,
+					size_t count, unsigned int flags);
 static ssize_t nfs_file_write(struct kiocb *, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos);
 static int  nfs_file_flush(struct file *, fl_owner_t id);
@@ -73,6 +76,7 @@ const struct file_operations nfs_file_operations = {
 	.lock		= nfs_lock,
 	.flock		= nfs_flock,
 	.splice_read	= nfs_file_splice_read,
+	.splice_write	= nfs_file_splice_write,
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
@@ -587,6 +591,34 @@ out_swapfile:
 	goto out;
 }
 
+static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
+				     struct file *filp, loff_t *ppos,
+				     size_t count, unsigned int flags)
+{
+	struct dentry *dentry = filp->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	ssize_t ret;
+
+	dprintk("NFS splice_write(%s/%s, %lu@%llu)\n",
+		dentry->d_parent->d_name.name, dentry->d_name.name,
+		(unsigned long) count, (unsigned long long) *ppos);
+
+	/*
+	 * We don't need to worry about O_APPEND as the combination of splice
+	 * and an O_APPEND destination is disallowed.
+	 */
+
+	nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, count);
+
+	ret = generic_file_splice_write(pipe, filp, ppos, count, flags);
+	if (ret >= 0 && nfs_need_sync_write(filp, inode)) {
+		int err = nfs_do_fsync(nfs_file_open_context(filp), inode);
+		if (err < 0)
+			ret = err;
+	}
+	return ret;
+}
+
 static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
