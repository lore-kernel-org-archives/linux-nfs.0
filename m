Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mrout1-b.corp.re1.yahoo.com ([69.147.107.20]:29334 "EHLO
	mrout1-b.corp.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752414Ab0A2RBK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jan 2010 12:01:10 -0500
Date: Fri, 29 Jan 2010 10:57:56 -0600
From: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: Random I/O over NFS has horrible performance due to small I/O transfers
Message-ID: <20100129165756.GA26747@yahoo-inc.com>
References: <20091226204531.GA3356@yahoo-inc.com> <E7A7B701-B471-4D14-8D45-B0FF691D1CCC@oracle.com> <20100121011238.GA30642@yahoo-inc.com> <B02A2206-CFEB-4FF4-8825-E953CFD7637C@oracle.com> <20100124184634.GA19426@yahoo-inc.com> <A9262578-3560-4EEE-87BC-8AA339F77B10@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A9262578-3560-4EEE-87BC-8AA339F77B10@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> > If the flush call has no data to flush, the GETATTR is pointless.
> > The file's cached attribute information is already as valid as can
> > ever be hoped for with NFS and its life is limited by the normal
> > attribute timeout.  On the other hand, if the flush has cached data
> > to write out, I would expect the WRITE will return the updated
> > attributes with the post-op attribute status, again making the
> > GETATTR on close pointless.  Can you explain what I'm not following?
> 
> The Linux NFS client does not use the post-op attributes to update the  
> cached attributes for the file.  Because there is no guarantee that  
> the WRITE replies will return in the same order the WRITEs were sent,  
> it's simply not reliable.  If the last reply to be received was for an  
> older write, then the mtime and ctime (and possibly the size) would be  
> stale, and would trigger a false data cache invalidation the next time  
> a full inode validation is done.

Ah, yes, the out of order WRITE replies problem.  I knew I was
forgetting something.

This may be a stupid question, but why not use the post-op attribute
information to update the inode whenever the fattr mtime exceeds the
inode mtime and just ignore using the post-op update all the other
times since that would indicate an out of order arrival?  (Of course
other fields would want to be checked to see if the file suddenly
changed other state information warranting general invalidation.)
I would assume that there are other out of order arrivals for other
op replies that prevent such a trivial algorithm?

This out-of-order post-op attribute data invalidating cache sounds
like a well-known problem that people have been trying to solve for
a long time or have proved that it can't be solved.  If there's a
white paper you can point me to that discuss the problem at length,
I'd like to read it.

> So, post-op attributes are used to detect the need for an attribute  
> cache update.  At some later point, the client will perform the update  
> by sending a GETATTR, and that will update the cached attributes.   
> That's what NFS_INO_INVALID_ATTR is for.

NFS_INO_INVALID_ATTR is just the tip of the iceberg.  I'm still trying
to absorb all the NFS inode state information that's tracked, how and
under what conditions it is updated, and when it is set as invalid.

> The goal is to use a few extra operations on the wire to prevent  
> spurious data cache invalidations.  For large files, this could mean  
> significantly fewer READs on the wire.

Yes, definitely better to reread attribute info when needed than cause
a data cache flush.

> > However, I tore into the code to better understand what was triggering
> > the GETATTR on close.  A close(2) does two things, a flush
> > (nfs_file_flush) and a release (nfs_file_release).  I had thought the
> > GETATTR was happening as part of the nfs_file_flush().  It's not.  The
> > GETATTR is triggered by the nfs_file_release().  As part of it doing a
> > put_nfs_open_context() -> nfs_close_context() ->  
> > nfs_revalidate_inode(),
> > that triggers the NFS_PROTO(inode)->getattr()!
> >
> > I'm not sure, but I suspect that O_DIRECT files take the
> > put_nfs_open_context() path that results in the extraneous GETATTR
> > on close(2) because filp->private_data is non-NULL where for regular
> > files it's NULL.  Is that right?  If so, can this problem be easily
> > fixed?
> 
> I'm testing a patch to use an asynchronous close for O_DIRECT files.   
> This will skip the GETATTR for NFSv2/v3 O_DIRECT files, and avoid  
> waiting for the CLOSE for NFSv4 O_DIRECT files.

When you're ready for external testing, will you be publishing it here
on the NFS mailing list?  Any guess when it might be ready?

> > Because the app was designed with O_DIRECT in mind, the app does its
> > own file buffering in user space.
> >
> > If for the Linux port we can move away from O_DIRECT, it would be
> > interesting to see if that extra user space buffering could be
> > disabled and let the kernel do its job.
> 
> You mentioned in an earlier e-mail that the application has its own  
> high-level data cache coherency protocol, and it appears that your  
> application is using NFS to do what is more or less real-time data  
> exchange between MTAs and users, with permanent storage as a side- 
> effect.  In that case, the application should manage its own cache,  
> since it can better optimize the number of READs required to keep its  
> local data caches up to date.  That would address the "too many data  
> cache invalidations" problem.

True.

But we also have many other internal groups using NFS with many
different use cases.  Though I'm primarily focused on this one use
case I recently mentioned, I may jump around at times to other ones
without being clear that I hopped.  I'll try to watch for that.  :-)

> In terms of maintaining the Linux port of your application, you  
> probably want to stay as close to the original as possible, yes?    
> Given all this, we'd be better off getting O_DIRECT to perform better.
> 
> You say above that llseek(2), write(2), and close(2) cause excess  
> GETATTR traffic.
> 
> llseek(SEEK_END) on an O_DIRECT file pretty much has to do a GETATTR,  
> since the client can't trust it's own attribute cache in this case.
> 
> I think we can get rid of the GETATTR at close(2) time on O_DIRECT  
> files.  On open(2), I think the GETATTR is delayed until the first  
> access that uses the client's data cache.  So we shouldn't have an  
> extra GETATTR on open(2) of an O_DIRECT file.
> 
> You haven't mentioned a specific case where an O_DIRECT write(2)  
> generates too many GETATTRs before, unless I missed it.

I've been evaluating this NFS use case with kernels from
2.6.{9,18,21,24,26,30,31,32,33-rc5} builds.  After reading your
note, I went back and looked at the tcpdumps from the latest 2.6.32
runs, I didn't see the GETATTRs before write(2)s anymore.  I'm going
to assume that problem was from an older kernel I was testing and
jumbled them in my head.  I should have double-checked that on the
current kernels and not relied on my faulty memory.

> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Quentin
