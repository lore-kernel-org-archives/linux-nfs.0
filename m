Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754026Ab2BJIHd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 03:07:33 -0500
Message-ID: <1328861244.8981.139.camel@serendib>
Subject: Re: NFS Mount Option 'nofsc'
From: Harshula <harshula@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Derek McEachern <derekm@ti.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 10 Feb 2012 19:07:24 +1100
In-Reply-To: <1328801489.13180.41.camel@lade.trondhjem.org>
References: <4F31E1CA.8060105@ti.com>
	 <1328676860.2954.9.camel@lade.trondhjem.org>
	 <1328687026.8981.25.camel@serendib>
	 <386479B9-C285-44C9-896B-A254091272FD@oracle.com>
	 <1328759776.8981.75.camel@serendib>
	 <1328760721.3234.86.camel@lade.trondhjem.org>
	 <1328766702.8981.106.camel@serendib>
	 <1328801489.13180.41.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Thu, 2012-02-09 at 15:31 +0000, Myklebust, Trond wrote:
> On Thu, 2012-02-09 at 16:51 +1100, Harshula wrote:
> > Hi Trond,
> > 
> > Thanks for the reply. Could you please elaborate on the subtleties
> > involved that require an application to be rewritten if forcedirectio
> > mount option was available?
> 
> Firstly, we don't support O_DIRECT+O_APPEND (since the NFS protocol
> itself doesn't support atomic appends), so that would break a bunch of
> applications.
> 
> Secondly, uncached I/O means that read() and write() requests need to be
> serialised by the application itself, since there are no atomicity or
> ordering guarantees at the VFS, NFS or RPC call level. Normally, the
> page cache services read() requests if there are outstanding writes, and
> so provides the atomicity guarantees that POSIX requires.
> IOW: if a write() occurs while you are reading, the application may end
> up retrieving part of the old data, and part of the new data instead of
> either one or the other.
> 
> IOW: your application still needs to be aware of the fact that it is
> using O_DIRECT, and you are better of adding explicit support for it
> rather than hacky cluges such as a forcedirectio option.

Thanks. Would it be accurate to say that if there were only either
streaming writes or (xor) streaming reads to any given file on the NFS
mount, the application would not need to be rewritten? 

Do you see forcedirectio as a sharp object that someone could stab
themselves with?

> > There's another scenario, which we talked about a while back, where the
> > cached async reads of a slowly growing file (tail) was spitting out
> > non-exist NULLs to user space. The forcedirectio mount option should
> > prevent that. Furthermore, the "sync" mount option will not help anymore
> > because you removed nfs_readpage_sync().
> 
> No. See the points about O_APPEND and serialisation of read() and
> write() above. You may still end up seeing NUL characters (and indeed
> worse forms of corruption).

If the NFS client only does cached async reads of a slowly growing file
(tail), what's the problem? Is nfs_readpage_sync() gone forever, or
could it be revived?

> > > > The other hack that seems to work is periodically triggering an
> > > > nfs_getattr(), via ls -l, to force the dirty pages to be flushed to the
> > > > NFS server. Not exactly elegant ...
> > > 
> > > ???????????????????????????????? 
> > 
> > int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
> > {
> >         struct inode *inode = dentry->d_inode;
> >         int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
> >         int err;
> > 
> >         /* Flush out writes to the server in order to update c/mtime.  */
> >         if (S_ISREG(inode->i_mode)) {
> >                 err = filemap_write_and_wait(inode->i_mapping);
> >                 if (err)
> >                         goto out;
> >         }
> 
> I'm aware of that code. The point is that '-osync' does that for free.

-osync also impacts the performance of the entire NFS mount. With
aforementioned hack, you can isolate the specific file(s) that need
their dirty pages to be flushed frequently to avoid hitting global dirty
page limit.

cya,
#

