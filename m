Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49751 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751982Ab2BIFvu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Feb 2012 00:51:50 -0500
Message-ID: <1328766702.8981.106.camel@serendib>
Subject: Re: NFS Mount Option 'nofsc'
From: Harshula <harshula@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Derek McEachern <derekm@ti.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 09 Feb 2012 16:51:42 +1100
In-Reply-To: <1328760721.3234.86.camel@lade.trondhjem.org>
References: <4F31E1CA.8060105@ti.com>
	 <1328676860.2954.9.camel@lade.trondhjem.org>
	 <1328687026.8981.25.camel@serendib>
	 <386479B9-C285-44C9-896B-A254091272FD@oracle.com>
	 <1328759776.8981.75.camel@serendib>
	 <1328760721.3234.86.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Thanks for the reply. Could you please elaborate on the subtleties
involved that require an application to be rewritten if forcedirectio
mount option was available?

On Thu, 2012-02-09 at 04:12 +0000, Myklebust, Trond wrote:
> On Thu, 2012-02-09 at 14:56 +1100, Harshula wrote:
> >
> > The "sync" option, depending on the NFS server, may impact the NFS
> > server's performance when serving many NFS clients. But still worth a
> > try.
> 
> What on earth makes you think that directio would be any different?

Like I said, sync is still worth a try. I will do O_DIRECT Vs sync mount
option runs and see what the numbers look like. A while back the numbers
for cached Vs direct small random writes showed as the number of threads
increased the cached performance fell well below direct performance. In
this case I'll be looking at large streaming writes, so completely
different scenario, but I'd like to verify the numbers first.

Just to be clear, I am not disagreeing with you. "sync" maybe sufficient
for the scenario I described earlier.

> If
> your performance requirements can't cope with 'sync', then they sure as
> hell won't deal well with 'fsc'.

"fsc"? 

> Directio is _synchronous_ just like 'sync'. The big difference is that
> with 'sync' then at least those reads are still cached.

There's another scenario, which we talked about a while back, where the
cached async reads of a slowly growing file (tail) was spitting out
non-exist NULLs to user space. The forcedirectio mount option should
prevent that. Furthermore, the "sync" mount option will not help anymore
because you removed nfs_readpage_sync().

> > The other hack that seems to work is periodically triggering an
> > nfs_getattr(), via ls -l, to force the dirty pages to be flushed to the
> > NFS server. Not exactly elegant ...
> 
> ???????????????????????????????? 

int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
{
        struct inode *inode = dentry->d_inode;
        int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
        int err;

        /* Flush out writes to the server in order to update c/mtime.  */
        if (S_ISREG(inode->i_mode)) {
                err = filemap_write_and_wait(inode->i_mapping);
                if (err)
                        goto out;
        }

Thanks,
#

