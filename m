From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [ltt-dev] [PATCH] nfs: add support for splice writes
Date: Mon, 20 Apr 2009 21:17:23 +0530
Message-ID: <49EC990B.1030007@suse.de>
References: <49D45974.2060202@suse.de> <20090402063235.GB24846@Krystal>	 <49D45E42.3050502@suse.de>	 <91e0b5050904020542l6b38d7a6hab6d7ef8b4593425@mail.gmail.com>	 <49EC0A83.8060802@suse.de> <1240230224.8073.6.camel@heimdal.trondhjem.org>	 <49EC6CB3.8080800@suse.de> <1240237274.13636.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Masahiro Tamori <masahiro.tamori@gmail.com>,
	Mathieu Desnoyers <compudj@krystal.dyndns.org>,
	linux-nfs@vger.kernel.org, ltt-dev@lists.casi.polymtl.ca,
	LKML <linux-kernel@vger.kernel.org>,
	linux-embedded@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756484AbZDTPsj@vger.kernel.org>
In-Reply-To: <1240237274.13636.9.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Mon, 2009-04-20 at 18:08 +0530, Suresh Jayaraman wrote:
>> Trond Myklebust wrote:
>>> On Mon, 2009-04-20 at 11:09 +0530, Suresh Jayaraman wrote:
>>>> Hi Trond,
>>>>
>>>> Do you think this patch is OK? Can this be considered for merging?
>>>>>>>> +
>>>>>>>> +  if (IS_SWAPFILE(inode)) {
>>>>>>>> +      printk(KERN_INFO "NFS: attempt to write to active swap"
>>>>>>>> +          "file!\n");
>>>>>>>> +      return -EBUSY;
>>>>>>>> +  }
>>> I don't know that we really need this. We should sweep through the NFS
>>> code and kill all those IS_SWAPFILE() thingys. Or at least #define
>>> IS_SWAPFILE(a) (0)
>>> ...
>> Hmm.. I'm not sure whether we should kill them now. I think originally,
>> these were added keeping in mind the future NFS swap support. Given that
>> the recent work from Peterz Zilstra on "Swap over NFS" and multiple
>> iterations/review on the same, I think those patches will eventually get
>> merged sooner or later. Perhaps, it's a good idea to #define
>> IS_SWAPFILE(a) 0 than killing them entirely..?
> 
> Why are they needed at all? AFAICS, other filesystems check IS_SWAPFILE
> when truncating a file, but don't litter their code with all these weird
> checks for writing, reading, etc.

Yes, except for afs other filesystems seem to check only during
truncation.

> It's not as if these checks can stop a determined privileged person from
> writing to the swapfile anyway. All they have to do is go to another
> client or write directly to the file on the server...
> 

Make sense.

Here is the trimmed version. I think the dprink could be retained
for debugging issues, if any.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 fs/nfs/file.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5a97bcf..6dfe7df 100644
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
@@ -587,6 +591,19 @@ out_swapfile:
 	goto out;
 }
 
+static ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe,
+				     struct file *filp, loff_t *ppos,
+				     size_t count, unsigned int flags)
+{
+	struct dentry *dentry = filp->f_path.dentry;
+
+	dprintk("NFS splice_write(%s/%s, %lu@%Lu)\n",
+		dentry->d_parent->d_name.name, dentry->d_name.name,
+		(unsigned long) count, (unsigned long long) *ppos);
+
+	return generic_file_splice_write(pipe, filp, ppos, count, flags);
+}
+
 static int do_getlk(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
