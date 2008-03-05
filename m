From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "sync" mount option semantics
Date: Wed, 05 Mar 2008 14:44:14 -0500
Message-ID: <1204746254.5035.22.camel@heimdal.trondhjem.org>
References: <9DC7FC7A-41B0-43C6-9759-8DF253C47EEE@oracle.com>
	 <1204740788.3356.9.camel@heimdal.trondhjem.org>
	 <7915C1E7-A21C-4A6A-90CD-8E63E68FD780@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:39536 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754110AbYCEToS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2008 14:44:18 -0500
In-Reply-To: <7915C1E7-A21C-4A6A-90CD-8E63E68FD780@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-05 at 14:25 -0500, Chuck Lever wrote:
> On Mar 5, 2008, at 1:13 PM, Trond Myklebust wrote:
> > On Tue, 2008-03-04 at 18:15 -0500, Chuck Lever wrote:
> >> Hi Trond-
> >>
> >> I have kind of an academic question.
> >>
> >> When an NFS file system is mounted with the "sync" option, only
> >> writes via sys_write appear to be affected.  Writes via mmap or pages
> >> dirtied via a loopback device are not affected at all.
> >>
> >> Similarly, O_SYNC only appears to affect sys_write and not mmap or
> >> loopback.
> >>
> >> Is this the desired behavior?  If so, why not include cached writes?
> >> Should we document this in nfs(5)?
> >
> > What does it mean to have "synchronous writes with mmap"? I'm not sure
> > that I really understand your concern: mmap is by its very nature
> > asynchronous. AFAIK, the only guarantee you have w.r.t.  
> > synchronicity is
> > that msync(MS_SYNC) can only complete once the data is on disk.
> 
> Well, one way these are different is that the client still generates  
> multi-page UNSTABLE writes for mmap files when the "sync" option is  
> in effect, while for files written via write(2) the request is broken  
> into a sequence of single page NFS writes on the wire.

Nope, I can't see that this is the case. Where do we enforce stable
writes for the sync mount option?

AFAIK, the writeout in the O_SYNC/IS_SYNC case is enforced using
nfs_do_fsync(), which again calls nfs_wb_all() in the usual manner.
There is nothing there that enforces stable writes...

> > Ditto really for the loopback device. Its semantics are those of a  
> > block
> > device, and so I really don't see what guarantees we're violating  
> > by not
> > using synchronous writes at the NFS level.
> 
> Except that when you issue a write to a real block device, there is  
> an expectation that the written data appears immediately on the  
> disk.  The current loopback implementation aggressively caches  
> writes, which is nice for performance, but can be a little  
> problematic when write ordering is a requirement for the emulated  
> device.
> 
> This is a problem, for example, when a journalled ext3 file system  
> lives on a loopback device.  There is no way to guarantee write  
> ordering between data, metadata, and journal writes to the loopback  
> device.  If the writer crashes before it can issue a barrier or  
> flush, the file system stored in the backing file is toast.  Or, if  
> someone is, for example, trying to back up the backing file, the  
> backup is worthless.
> 
> Note: I think it's a problem for a loopback device on any file  
> system, but I'm just trying to clarify the expected behavior for  
> NFS.  It certainly may be the case that the loopback implementation  
> is entirely at fault here.
> 
> So, the connection is that loopback uses the same mechanism as mmap'd  
> writes to push data to the server.

Again, it seems to me that it is up to the loopback driver to signal to
the VM when it wants writeout to start. If it does so before the user
closes the file, then ordinary NFS close-to-open semantics apply, but if
not, then I fail to see how we can fix anything in the NFS layer.


