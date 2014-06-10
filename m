Return-Path: linux-nfs-owner@vger.kernel.org
Received: from granite.fifsource.com ([173.255.216.206]:48434 "EHLO
	granite.fifsource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758AbaFJVUH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2014 17:20:07 -0400
Message-ID: <1402435203.24047.9.camel@ceramic.home.fifi.org>
Subject: Re: Phantom ACL-related xattrs on 3.14.4 NFS client
From: Philippe Troin <phil@fifi.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Tue, 10 Jun 2014 14:20:03 -0700
In-Reply-To: <1402195701.12743.18.camel@ceramic.home.fifi.org>
References: <1402082953.28220.7.camel@ceramic.home.fifi.org>
	 <CAHQdGtS2BL9u4DV=FZ0HaXO-iTNPU4hTGVR--HubNa4A_6UNog@mail.gmail.com>
	 <20140607140414.GA26534@infradead.org>
	 <1402195701.12743.18.camel@ceramic.home.fifi.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, Christoph,

Since my last email, I've been testing 3.14.6.
Stock 3.14.6 is still broken, and Christoph's patch does help, but does
not entirely cure the problem.

On Sat, 2014-06-07 at 19:48 -0700, Philippe Troin wrote:
> It's still broken, but in a different way.
> The phantom attrs are gone, but the attr/acl interaction is still
> uncertain.
> 
> I have tested vanilla  3.14.5 + this patch on x86_64.
> Mount options are the same as last time (NFSv3).
> 
> This is what I see on the client:
> 
>         nfsv3client% mkdir x
>         nfsv3client% cd x
>         nfsv3client% getfattr -m '.*' .
>         nfsv3client% getfacl .
>         # file: .
>         # owner: phil
>         # group: phil
>         user::rwx
>         group::rwx
>         other::r-x
> 
> OK so far: no more phantom attrs.
> This is where things get dodgy:
>         
>         nfsv3client% setfacl -m u:root:r .   
>         nfsv3client% getfacl .
>         # file: .
>         # owner: phil
>         # group: phil
>         user::rwx
>         user:root:r--
>         group::rwx
>         mask::rwx
>         other::r-x
>         
>         nfsv3client% getfattr -m '.*' .
>         [1]    2123 segmentation fault  getfattr -m '.*' .
>         % strace getfattr -m '.*' . 2>&1 | tail -n 20
>         fstat(3, {st_mode=S_IFREG|0644, st_size=26254, ...}) = 0
>         mmap(NULL, 26254, PROT_READ, MAP_SHARED, 3, 0) = 0x7f46a1450000
>         close(3)                                = 0
>         getrlimit(RLIMIT_NOFILE, {rlim_cur=1024, rlim_max=4*1024}) = 0
>         lstat(".", {st_mode=S_IFDIR|0775, st_size=4096, ...}) = 0
>         listxattr(".", NULL, 0)                 = 23
>         listxattr(".", "system.posix_acl_access", 256) = 23
>         brk(0)                                  = 0x1138000
>         brk(0x1178000)                          = 0x1178000
>         brk(0)                                  = 0x1178000
>         brk(0)                                  = 0x1178000
>         brk(0x1159000)                          = 0x1159000
>         brk(0)                                  = 0x1159000
>         mmap(NULL, 266240, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f46a140f000
>         brk(0)                                  = 0x1159000
>         brk(0)                                  = 0x1159000
>         brk(0x1139000)                          = 0x1139000
>         brk(0)                                  = 0x1139000
>         --- SIGSEGV {si_signo=SIGSEGV, si_code=SEGV_MAPERR, si_addr=0x11586e8} ---
>         +++ killed by SIGSEGV +++
>         [1]    2311 segmentation fault  strace getfattr -m '.*' . 2>&1
>         | 
>                2312 done                tail -n 20

I have since discovered that getfattr crashes because on an NFSv3 mount,
listxattr() does not NULL terminate the attribute strings.

Compare a broken 3.14.6:
        listxattr(".", NULL, 0)                 = 23
        listxattr(".", "system.posix_acl_access", 256) = 23
vs a working 3.13:
        listxattr(".", NULL, 0)      = 24
        listxattr(".", "system.posix_acl_access\0", 256) = 24

The above behavior happens with or without Christoph's patch.

Also, with Christoph's patch applied:

> On Sat, 2014-06-07 at 07:04 -0700, Christoph Hellwig wrote:
> > On Fri, Jun 06, 2014 at 04:37:03PM -0400, Trond Myklebust wrote:
> > > Christoph, what is the intended interface for telling
> > > posix_acl_xattr_list() that there are no acls on a particular file?
> > > Should there perhaps be a call to get_acl()?
> > 
> > The interface is to not call posix_acl_xattr_list unless you have ACLs.
> > Every implementation does this, except for generic_listxattr which is
> > only used by NFS.
> > 
> > Philippe, can you test the patch below?
> > 
> > 
> > diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
> > index 871d6ed..e083827 100644
> > --- a/fs/nfs/nfs3acl.c
> > +++ b/fs/nfs/nfs3acl.c
> > @@ -247,3 +247,45 @@ const struct xattr_handler *nfs3_xattr_handlers[] = {
> >  	&posix_acl_default_xattr_handler,
> >  	NULL,
> >  };
> > +
> > +static int
> > +nfs3_list_one_acl(struct inode *inode, int type, const char *name, void *data,
> > +		size_t size, ssize_t *result)
> > +{
> > +	struct posix_acl *acl;
> > +	char *p = data + *result;
> > +
> > +	acl = get_acl(inode, type);
> > +	if (!acl)
> > +		return 0;
> > +
> > +	posix_acl_release(acl);
> > +
> > +	*result += strlen(name);
> > +	if (!size)
> > +		return 0;
> > +	if (*result > size)
> > +		return -ERANGE;
> > +
> > +	strcpy(p, name);
> > +	return 0;
> > +}
> > +
> > +ssize_t
> > +nfs3_listxattr(struct dentry *dentry, char *data, size_t size)
> > +{
> > +	struct inode *inode = dentry->d_inode;
> > +	ssize_t result = 0;
> > +	int error;
> > +
> > +	error = nfs3_list_one_acl(inode, ACL_TYPE_ACCESS,
> > +			POSIX_ACL_XATTR_ACCESS, data, size, &result);
> > +	if (error)
> > +		return error;
> > +
> > +	error = nfs3_list_one_acl(inode, ACL_TYPE_DEFAULT,
> > +			POSIX_ACL_XATTR_DEFAULT, data, size, &result);
> > +	if (error)
> > +		return error;
> > +	return result;
> > +}
> > diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> > index db60149..0e2bb26 100644
> > --- a/fs/nfs/nfs3proc.c
> > +++ b/fs/nfs/nfs3proc.c
> > @@ -891,7 +891,7 @@ static const struct inode_operations nfs3_dir_inode_operations = {
> >  	.getattr	= nfs_getattr,
> >  	.setattr	= nfs_setattr,
> >  #ifdef CONFIG_NFS_V3_ACL
> > -	.listxattr	= generic_listxattr,
> > +	.listxattr	= nfs3_listxattr,
> >  	.getxattr	= generic_getxattr,
> >  	.setxattr	= generic_setxattr,
> >  	.removexattr	= generic_removexattr,
> > @@ -905,7 +905,7 @@ static const struct inode_operations nfs3_file_inode_operations = {
> >  	.getattr	= nfs_getattr,
> >  	.setattr	= nfs_setattr,
> >  #ifdef CONFIG_NFS_V3_ACL
> > -	.listxattr	= generic_listxattr,
> > +	.listxattr	= nfs3_listxattr,
> >  	.getxattr	= generic_getxattr,
> >  	.setxattr	= generic_setxattr,
> >  	.removexattr	= generic_removexattr,

Now, if a file has no ACLs, there are no phantom xattrs appearing
anymore.
However, if ACLs are created, then removed, the ACL xattrs will stick
after the ACL clearing.

For example:

  setfacl -m u:root:r .
  setfacl -b .
  getfattr -m '.*' .

will still show a system.posix_acl_access xattr.

Phil.

