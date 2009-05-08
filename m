From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: integrity: nfsd imbalance bug fix
Date: Fri, 8 May 2009 14:07:30 -0400
Message-ID: <20090508180730.GB20539@fieldses.org>
References: <1240943534.4143.55.camel@dyn9002018117.watson.ibm.com> <20090429141837.beaa5d59.akpm@linux-foundation.org> <1241804120.4843.7.camel@dyn9002018117.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org,
	jmorris@namei.org, safford-aZOuKsOsJu3MbYB6QlFGEg@public.gmane.org,
	linux-nfs@vger.kernel.org
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:53273 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbZEHSIe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2009 14:08:34 -0400
In-Reply-To: <1241804120.4843.7.camel-Ip4+SIe7dfOMop5i0OabyFN1H4us77DDVpNB7YpNyf8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 08, 2009 at 01:35:20PM -0400, Mimi Zohar wrote:
> On Wed, 2009-04-29 at 14:18 -0700, Andrew Morton wrote: 
> > On Tue, 28 Apr 2009 14:32:14 -0400
> > Mimi Zohar <zohar@linux.vnet.ibm.com> wrote:
> > 
> > > The number of calls to ima_path_check()/ima_file_free()
> > > should be balanced.  An extra call to fput(), indicates
> > > the file could have been accessed without first being
> > > measured.
> > > 
> > > An nfsd exported file is opened/closed by the kernel
> > > causing an integrity imbalance message.
> > > 
> > > - rename and export opencount_get to ima_opencount_get
> > > - replace ima_shm_check calls with ima_opencount_get
> > > - add call to increment opencount for files opened by nfsd.
> > > - add call to measure exported files in nfsd_permission().
> > > - export ima_path_check
> > > 
> > 
> > The patch looks fragile to me.  It sprinkles IMA-specific operations
> > over random unrelated subsystems.  There is hence a decent chance of
> > breakage in the future.
> > 
> > Suppose some other new piece of kernel code opens/closes a file.  The
> > developer didn't think to add the IMA hooks and whoops, we have a bug.
> 
> Agreed.  Exactly for that reason we have the imbalance message. The
> imbalance message is not a bug per se, but an indication that the
> file hasn't been integrity (permission) checked.

Where do I need to go to find out what this integrity checking is?  I
don't know the first thing about it....

--b.

> 
> > It would be really really better if we could add the IMA hooks in a
> > single place.  That might require the addition of a new function, and
> > that's fine.  d_instantiate_kernel() or init_file_kernel() or whatever
> > - that's fine.  It still has the risk that new code will forget to use
> > the in-kernel variant, but we have a better chance of detecting it.
> 
> Definitely. Originally the integrity checking was in inode_permission().
> But measuring a file requires a dentry and mount point.
> 
> I've updated the patch to fix a 'counts' error and divided the patch
> into two, separating the IMA code changes from the IMA calls in nfsd.
> 
> > > 
> > > Index: security-testing-2.6/fs/nfsd/vfs.c
> > > ===================================================================
> > > --- security-testing-2.6.orig/fs/nfsd/vfs.c
> > > +++ security-testing-2.6/fs/nfsd/vfs.c
> > > @@ -55,6 +55,7 @@
> > >  #include <linux/security.h>
> > >  #endif /* CONFIG_NFSD_V4 */
> > >  #include <linux/jhash.h>
> > > +#include <linux/ima.h>
> > >  
> > >  #include <asm/uaccess.h>
> > >  
> > > @@ -735,6 +736,8 @@ nfsd_open(struct svc_rqst *rqstp, struct
> > >  			    flags, cred);
> > >  	if (IS_ERR(*filp))
> > >  		host_err = PTR_ERR(*filp);
> > > +	else
> > > +		ima_opencount_get(*filp);
> > 
> > This suggests dentry_open_kernel().
> 
> Good name, but making dentry_open_kernel() the default behavior,
> would mask the real bug - not doing integrity (permission) checking.
> 
> > 
> > >  out_nfserr:
> > >  	err = nfserrno(host_err);
> > >  out:
> > > @@ -2096,7 +2099,13 @@ nfsd_permission(struct svc_rqst *rqstp, 
> > >  	if (err == -EACCES && S_ISREG(inode->i_mode) &&
> > >  	    acc == (NFSD_MAY_READ | NFSD_MAY_OWNER_OVERRIDE))
> > >  		err = inode_permission(inode, MAY_EXEC);
> > > +	if (err)
> > > +		goto nfsd_out;
> > >  
> > > +	err = ima_path_check(&exp->ex_path,
> > > +			     acc & (MAY_READ | MAY_WRITE | MAY_EXEC));
> > 
> > hm, dunno what to do about that.
> 
> The real problem is that this belongs in inode_permission(), but an
> inode is not enough.  It requires a dentry and mount point to
> measure the file.
> 
> > > +	return err;
> > > +nfsd_out:
> > >  	return err? nfserrno(err) : 0;
> > >  }
> > >  
> > > Index: security-testing-2.6/security/integrity/ima/ima_main.c
> > > ===================================================================
> > > --- security-testing-2.6.orig/security/integrity/ima/ima_main.c
> > > +++ security-testing-2.6/security/integrity/ima/ima_main.c
> > > @@ -206,6 +206,7 @@ out:
> > >  	kref_put(&iint->refcount, iint_free);
> > >  	return 0;
> > >  }
> > > +EXPORT_SYMBOL_GPL(ima_path_check);
> > >  
> > >  static int process_measurement(struct file *file, const unsigned char *filename,
> > >  			       int mask, int function)
> > > @@ -234,7 +235,16 @@ out:
> > >  	return rc;
> > >  }
> > >  
> > > -static void opencount_get(struct file *file)
> > > +/*
> > > + * ima_opencount_get - incr opencount for files opened by the kernel
> > > + *
> > > + * - IPC shm and shmat create/fput a file.
> > > + * - nfsd opens/closes exported files.
> > > + *
> > > + * Increment the opencount for these files to prevent unnecessary
> > > + * imbalance messages.
> > > + */
> > > +void ima_opencount_get(struct file *file)
> > >  {
> > >  	struct inode *inode = file->f_dentry->d_inode;
> > >  	struct ima_iint_cache *iint;
> > > @@ -248,6 +258,7 @@ static void opencount_get(struct file *f
> > >  	iint->opencount++;
> > >  	mutex_unlock(&iint->mutex);
> > >  }
> > > +EXPORT_SYMBOL_GPL(ima_opencount_get);
> > >  
> > >  /**
> > >   * ima_file_mmap - based on policy, collect/store measurement.
> > > @@ -272,18 +283,6 @@ int ima_file_mmap(struct file *file, uns
> > >  	return 0;
> > >  }
> > >  
> > > -/*
> > > - * ima_shm_check - IPC shm and shmat create/fput a file
> > > - *
> > > - * Maintain the opencount for these files to prevent unnecessary
> > > - * imbalance messages.
> > > - */
> > > -void ima_shm_check(struct file *file)
> > > -{
> > > -	opencount_get(file);
> > > -	return;
> > > -}
> > > -
> > >  /**
> > >   * ima_bprm_check - based on policy, collect/store measurement.
> > >   * @bprm: contains the linux_binprm structure
> > > Index: security-testing-2.6/include/linux/ima.h
> > > ===================================================================
> > > --- security-testing-2.6.orig/include/linux/ima.h
> > > +++ security-testing-2.6/include/linux/ima.h
> > > @@ -20,7 +20,7 @@ extern void ima_inode_free(struct inode 
> > >  extern int ima_path_check(struct path *path, int mask);
> > >  extern void ima_file_free(struct file *file);
> > >  extern int ima_file_mmap(struct file *file, unsigned long prot);
> > > -extern void ima_shm_check(struct file *file);
> > > +extern void ima_opencount_get(struct file *file);
> > >  
> > >  #else
> > >  static inline int ima_bprm_check(struct linux_binprm *bprm)
> > > @@ -53,7 +53,7 @@ static inline int ima_file_mmap(struct f
> > >  	return 0;
> > >  }
> > >  
> > > -static inline void ima_shm_check(struct file *file)
> > > +static inline void ima_opencount_get(struct file *file)
> > >  {
> > >  	return;
> > >  }
> > > Index: security-testing-2.6/ipc/shm.c
> > > ===================================================================
> > > --- security-testing-2.6.orig/ipc/shm.c
> > > +++ security-testing-2.6/ipc/shm.c
> > > @@ -384,7 +384,7 @@ static int newseg(struct ipc_namespace *
> > >  	error = PTR_ERR(file);
> > >  	if (IS_ERR(file))
> > >  		goto no_file;
> > > -	ima_shm_check(file);
> > > +	ima_opencount_get(file);
> > >  
> > >  	id = ipc_addid(&shm_ids(ns), &shp->shm_perm, ns->shm_ctlmni);
> > >  	if (id < 0) {
> > > @@ -891,7 +891,7 @@ long do_shmat(int shmid, char __user *sh
> > >  	file = alloc_file(path.mnt, path.dentry, f_mode, &shm_file_operations);
> > >  	if (!file)
> > >  		goto out_free;
> > > -	ima_shm_check(file);
> > > +	ima_opencount_get(file);
> > >  
> > >  	file->private_data = sfd;
> > >  	file->f_mapping = shp->shm_file->f_mapping;
> > > Index: security-testing-2.6/mm/shmem.c
> > > ===================================================================
> > > --- security-testing-2.6.orig/mm/shmem.c
> > > +++ security-testing-2.6/mm/shmem.c
> > > @@ -2680,7 +2680,7 @@ int shmem_zero_setup(struct vm_area_stru
> > >  	if (IS_ERR(file))
> > >  		return PTR_ERR(file);
> > >  
> > > -	ima_shm_check(file);
> > > +	ima_opencount_get(file);
> > >  	if (vma->vm_file)
> > >  		fput(vma->vm_file);
> > >  	vma->vm_file = file;
> > 
> > Maybe do the IMA operations in (or under) shmem_file_setup() and
> > hugetlb_file_setup()?
> 
> Again, that would hide the real issue of not having done integrity
> (permission) checking.
> 
> Mimi
> 
