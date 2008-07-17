From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: Re: [RFC][PATCH] Basic pre-allocation support for nfsd write
Date: Fri, 18 Jul 2008 09:07:23 +1000
Message-ID: <487FD0AB.1000008@cse.unsw.edu.au>
References: <487D526D.8070307@cse.unsw.edu.au> <20080717151236.GB11759@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tone.orchestra.cse.unsw.EDU.AU ([129.94.242.59]:59478 "EHLO
	tone.orchestra.cse.unsw.EDU.AU" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761073AbYGQXWF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2008 19:22:05 -0400
In-Reply-To: <20080717151236.GB11759@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Jul 16, 2008 at 11:44:13AM +1000, Shehjar Tikoo wrote:
>> Please see the attached patches for adding
>> pre-allocation support into nfsd writes. Comments follow.
>>
>> Patches:
>> a. 01_vfs_fallocate.patch
>> Adds vfs_fallocate. Basically, encapsulates the call to
>> inode->i_op->fallocate, which is currently called directly from
>> sys_fallocate, which takes a file descriptor as argument, but nfsd
>> needs to operate on struct file's.
>>
>> b. 02_init_file_prealloc_limit.patch
>> Adds a new member to struct file, to keep track of how much has been
>> preallocated for this file. For now, adding to struct file seemed an
>> easy way to keep per-file state about preallocation but this can be
>> changed to use a nfsd-specific hash table that maps (dev, ino) to
>> per-file pre-allocation state.
>>
>> c. 03_nfsd_fallocate.patch
>> Wires in the call to vfs_fallocate into nfsd_vfs_write.
>> For now, the function nfsd_get_prealloc_len uses a very simple
>> method to determine when and how much to pre-allocate. This can change
>> if needed.
>> This patch also adds two module_params that control pre-allocation:
>>
>>  1. /sys/module/nfsd/parameters/nfsd_prealloc
>>   Determine whether to pre-allocate.
>>
>>  2. /sys/module/nfsd/parameters/nfsd_prealloc_len
>>   How much to pre-allocate. Default is 5Megs.
> 
> So, if I understand the algorithm right:
> 
> 	- Initialize f_prealloc_len to 0.
> 	- Ignore any write(offset, cnt) contained entirely in the range
> 	  (0, f_prealloc_len).
> 	- For any write outside that range, extend f_prealloc_len to
> 	  offset + 5MB and call vfs_alloc(., ., offset, 5MB)
> 
> (where the 5MB is actually the configurable nfsd_prealloc_len parameter
> above).
> 

Yes. However, it doesnt handle all the ways in which write requests
can come in at the server but the aim was to test for sequential
writes as a proof of concept first.

>> The patches are based against 2.6.25.11.
>>
>> See the following two plots for read and write performance, with and
>> without pre-allocation support. Tests were run using iozone. The
>> filesystem was ext4 with extents enabled. The testbed used two Itanium
>> machines as client and server, connected through a Gbit network with
>> jumbo frames enabled. The filesystem was aged with various iozone and
>> kernel compilation workloads that consumed 45G of a 64G disk.
>>
>> Server side mount options:
>> rw,sync,insecure,no_root_squash,no_subtree_check,no_wdelay
>>
>> Client side mount options:
>> intr,wsize=65536,rsize=65536
>>
>> 1. Read test
>> http://www.gelato.unsw.edu.au/~shehjart/docs/nfsmeasurements/ext4fallocate_read.png
> 
> Sorry, I don't understand exactly what iozone is doing in this test (and
> the below).  Is it just doing sequential 64k reads (or, below, writes)
> through a 2G file?


Yes, write tests involve sequential writes with and without
pre-allocation. The read tests read back the same file sequentially.

So if we set nfsd_prealloc_len to 5Megs, then the sequential writes
will be written to preallocated blocks of 5Megs. Once nfsd realizes
that we've written to the previously pre-allocated block, it will
pre-allocate another 5Mb block. The corresponding read test will be 
read back the same file to determine the affect of
5Meg preallocation on  read throughput.


> 
>> Read throughput clearly benefits due to the contiguity of disk blocks.
>> In the best case, i.e. with pre-allocation of 4 and 5 Mb during the
>> writing of the test file, throughput, during read of the same
>> file, more than doubles.
>>
>> 2. Write test
>> http://www.gelato.unsw.edu.au/~shehjart/docs/nfsmeasurements/ext4fallocate_write.png
>> Going just by read performance, pre-allocation would be a nice thing
>> to have *but* note that write throughput also decreases drastically,
>> by almost 10 Mb/sec with just 1Mb of pre-allocation.
> 
> So I guess it's not surprising--you're doing extra work at write time in
> order to make the reads go faster.
> 

True. With ext4 it looks like pre-allocation algorithm is not fast
enough to help nfsd maintain the same throughput as the no 
pre-allocation case. XFS, with its B-tree oriented approach, might
help but this patch remains to be tested on XFS.

> A general question: since this preallocation isn't already being done by
> the filesystem, there must be some reason you think it's appropriate for
> nfsd but not for other users.  What makes nfsd special?

Nothing special about nfsd. I've been looking at NFS performance so 
thats what I focus on with this patch. As I said in an earlier email,
the ideal way would be to incorporate pre-allocation into VFS for
writes which need O_SYNC. The motivation to do that is not so high
because both ext4 and XFS now do delayed allocation for buffered
writes.

Thanks
Shehjar

> 
> --b.
> 
>> A question at this point is, how well does pre-allocation perform
>> under other filesystems? I have no idea yet. I'll try to test XFS,
>> RSN.
>>
>> Comments/suggestions are welcome.
>>
>> Regards
>> Shehjar
> 
>> diff --git a/fs/open.c b/fs/open.c
>> index a99ad09..b5b641a 100644
>> --- a/fs/open.c
>> +++ b/fs/open.c
>> @@ -359,39 +359,34 @@ asmlinkage long sys_ftruncate64(unsigned int fd, loff_t length)
>>  }
>>  #endif
>>  
>> -asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len)
>> +long vfs_fallocate(struct file * file, int mode, loff_t offset, loff_t len)
>>  {
>> -	struct file *file;
>>  	struct inode *inode;
>>  	long ret = -EINVAL;
>>  
>>  	if (offset < 0 || len <= 0)
>>  		goto out;
>> -
>> +	
>>  	/* Return error if mode is not supported */
>>  	ret = -EOPNOTSUPP;
>>  	if (mode && !(mode & FALLOC_FL_KEEP_SIZE))
>>  		goto out;
>>  
>> -	ret = -EBADF;
>> -	file = fget(fd);
>> -	if (!file)
>> -		goto out;
>>  	if (!(file->f_mode & FMODE_WRITE))
>> -		goto out_fput;
>> +		goto out;
>>  	/*
>>  	 * Revalidate the write permissions, in case security policy has
>>  	 * changed since the files were opened.
>>  	 */
>>  	ret = security_file_permission(file, MAY_WRITE);
>>  	if (ret)
>> -		goto out_fput;
>> +		goto out;
>>  
>>  	inode = file->f_path.dentry->d_inode;
>>  
>>  	ret = -ESPIPE;
>>  	if (S_ISFIFO(inode->i_mode))
>> -		goto out_fput;
>> +		goto out;
>>  
>>  	ret = -ENODEV;
>>  	/*
>> @@ -399,19 +394,33 @@ asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len)
>>  	 * for directories or not.
>>  	 */
>>  	if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
>> -		goto out_fput;
>> +		goto out;
>>  
>>  	ret = -EFBIG;
>>  	/* Check for wrap through zero too */
>>  	if (((offset + len) > inode->i_sb->s_maxbytes) || ((offset + len) < 0))
>> -		goto out_fput;
>> +		goto out;
>>  
>>  	if (inode->i_op && inode->i_op->fallocate)
>>  		ret = inode->i_op->fallocate(inode, mode, offset, len);
>>  	else
>>  		ret = -EOPNOTSUPP;
>> +out:
>> +	return ret;
>> +}
>> +EXPORT_SYMBOL(vfs_fallocate);
>>  
>> -out_fput:
>> +asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len)
>> +{
>> +	struct file *file;
>> +	long ret;
>> +
>> +	ret = -EBADF;
>> +	file = fget(fd);
>> +	if (!file)
>> +		goto out;
>> +
>> +	ret = vfs_fallocate(file, mode, offset, len);
>>  	fput(file);
>>  out:
>>  	return ret;
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index d8e2762..498a422 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -1287,6 +1287,7 @@ extern ssize_t vfs_readv(struct file *, const struct iovec __user *,
>>  		unsigned long, loff_t *);
>>  extern ssize_t vfs_writev(struct file *, const struct iovec __user *,
>>  		unsigned long, loff_t *);
>> +extern long vfs_fallocate(struct file * file, int mode, loff_t offset, loff_t len);
>>  
>>  struct super_operations {
>>     	struct inode *(*alloc_inode)(struct super_block *sb);
> 
>> diff --git a/fs/open.c b/fs/open.c
>> index b5b641a..77820d3 100644
>> --- a/fs/open.c
>> +++ b/fs/open.c
>> @@ -832,6 +832,7 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
>>  	f->f_path.mnt = mnt;
>>  	f->f_pos = 0;
>>  	f->f_op = fops_get(inode->i_fop);
>> +	f->f_prealloc_limit = 0;
>>  	file_move(f, &inode->i_sb->s_files);
>>  
>>  	error = security_dentry_open(f);
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index 498a422..5aaf82b 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -799,6 +799,7 @@ struct file {
>>  	struct fown_struct	f_owner;
>>  	unsigned int		f_uid, f_gid;
>>  	struct file_ra_state	f_ra;
>> +	unsigned long 		f_prealloc_limit;
>>  
>>  	u64			f_version;
>>  #ifdef CONFIG_SECURITY
> 
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 46f59d5..3d7c48d 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -57,6 +57,7 @@
>>  #include <linux/jhash.h>
>>  
>>  #include <asm/uaccess.h>
>> +#include <linux/falloc.h>
>>  
>>  #define NFSDDBG_FACILITY		NFSDDBG_FILEOP
>>  
>> @@ -89,6 +90,14 @@ static struct raparms *		raparml;
>>  #define RAPARM_HASH_MASK	(RAPARM_HASH_SIZE-1)
>>  static struct raparm_hbucket	raparm_hash[RAPARM_HASH_SIZE];
>>  
>> +/* User-definable preallocation size in bytes */
>> +unsigned long nfsd_prealloc_len = 5242880;
>> +module_param(nfsd_prealloc_len, ulong, S_IRUGO|S_IWUSR);
>> +
>> +/* 0 if preallocation is disabled, 1 otherwise. */
>> +int nfsd_prealloc = 0;
>> +module_param(nfsd_prealloc, int, S_IRUGO|S_IWUSR);
>> +
>>  /* 
>>   * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
>>   * a mount point.
>> @@ -954,6 +963,21 @@ static void kill_suid(struct dentry *dentry)
>>  	mutex_unlock(&dentry->d_inode->i_mutex);
>>  }
>>  
>> +
>> +static unsigned long
>> +nfsd_get_prealloc_len(struct file * file, loff_t offset, unsigned long cnt)
>> +{
>> +	/* Might want to do something more complex here to decide
>> +	 * pre-allocation size.
>> +	 */
>> +	if(file->f_prealloc_limit > (offset + cnt))
>> +		return 0;
>> +
>> +	file->f_prealloc_limit = offset + nfsd_prealloc_len;
>> +	return nfsd_prealloc_len;
>> +}
>> +
>> +
>>  static __be32
>>  nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>>  				loff_t offset, struct kvec *vec, int vlen,
>> @@ -966,6 +990,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>>  	__be32			err = 0;
>>  	int			host_err;
>>  	int			stable = *stablep;
>> +	unsigned long		prealloc_len = 0;
>>  
>>  #ifdef MSNFS
>>  	err = nfserr_perm;
>> @@ -998,6 +1023,11 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>>  	if (stable && !EX_WGATHER(exp))
>>  		file->f_flags |= O_SYNC;
>>  
>> +	if(nfsd_prealloc && inode->i_op && inode->i_op->fallocate) {
>> +		prealloc_len = nfsd_get_prealloc_len(file, offset, cnt);
>> +		if(prealloc_len > 0)
>> +			vfs_fallocate(file, FALLOC_FL_KEEP_SIZE, offset, prealloc_len);
>> +	}
>>  	/* Write the data. */
>>  	oldfs = get_fs(); set_fs(KERNEL_DS);
>>  	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
> 

