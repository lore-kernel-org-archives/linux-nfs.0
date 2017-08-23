Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:34911 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753691AbdHWLMn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Aug 2017 07:12:43 -0400
Received: by mail-qk0-f179.google.com with SMTP id 130so6407748qkg.2
        for <linux-nfs@vger.kernel.org>; Wed, 23 Aug 2017 04:12:42 -0700 (PDT)
Message-ID: <1503486760.5294.2.camel@redhat.com>
Subject: Re: [PATCH 4/8] NFS: flush out dirty data on file fput().
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 23 Aug 2017 07:12:40 -0400
In-Reply-To: <87r2w5ln2a.fsf@notabene.neil.brown.name>
References: <150304014011.30218.1636255532744321171.stgit@noble>
         <150304037195.30218.15740287358704674869.stgit@noble>
         <1503083704.11511.9.camel@primarydata.com>
         <87ziawl698.fsf@notabene.neil.brown.name>
         <1503106038.10673.11.camel@primarydata.com>
         <87r2w5ln2a.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-08-21 at 11:35 +1000, NeilBrown wrote:
> On Sat, Aug 19 2017, Trond Myklebust wrote:
> 
> > On Sat, 2017-08-19 at 11:02 +1000, NeilBrown wrote:
> > > On Fri, Aug 18 2017, Trond Myklebust wrote:
> > > 
> > > > On Fri, 2017-08-18 at 17:12 +1000, NeilBrown wrote:
> > > > > Any dirty NFS page holds an s_active reference on the superblock,
> > > > > because page_private() references an nfs_page, which references
> > > > > an
> > > > > open context, which references the superblock.
> > > > > 
> > > > > So if there are any dirty pages when the filesystem is unmounted,
> > > > > the
> > > > > unmount will act like a "lazy" unmount and not call ->kill_sb().
> > > > > Background write-back can then write out the pages *after* the
> > > > > filesystem
> > > > > unmount has apparently completed.
> > > > > 
> > > > > This contrasts with other filesystems which do not hold extra
> > > > > s_active
> > > > > references, so ->kill_sb() is reliably called on unmount, and
> > > > > generic_shutdown_super() will call sync_filesystem() to flush
> > > > > everything out before the unmount completes.
> > > > > 
> > > > > When open/write/close is used to modify files, the final close
> > > > > causes
> > > > > f_op->flush to be called, which flushes all dirty pages.  However
> > > > > if
> > > > > open/mmap/close/modify-memory/unmap is used, dirty pages can
> > > > > remain
> > > > > in
> > > > > memory after the application has dropped all references to the
> > > > > file.
> > > > > Similarly if a loop-mount is done with a NFS file, there is no
> > > > > final
> > > > > flush when the loop device is destroyed and the file can have
> > > > > dirty
> > > > > data after the last "close".
> > > > > 
> > > > > Also, a loop-back mount of a device does not "close" the file
> > > > > when
> > > > > the
> > > > > loop device is destroyed.  This can leave dirty page cache pages
> > > > > too.
> > > > > 
> > > > > Fix this by calling vfs_fsync() in nfs_file_release (aka
> > > > > f_op->release()).  This means that on the final unmap of a file
> > > > > (or
> > > > > destruction of a loop device), all changes are flushed, and
> > > > > ensures
> > > > > that
> > > > > when unmount is requested there will be no dirty pages to delay
> > > > > the
> > > > > final unmount.
> > > > > 
> > > > > Without this patch, it is not safe to stop or disconnect the NFS
> > > > > server after all clients have unmounted.  They need to unmount
> > > > > and
> > > > > call "sync".
> > > > > 
> > > > > Signed-off-by: NeilBrown <neilb@suse.com>
> > > > > ---
> > > > >  fs/nfs/file.c |    6 ++++++
> > > > >  1 file changed, 6 insertions(+)
> > > > > 
> > > > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > > > > index af330c31f627..aa883d8b24e6 100644
> > > > > --- a/fs/nfs/file.c
> > > > > +++ b/fs/nfs/file.c
> > > > > @@ -81,6 +81,12 @@ nfs_file_release(struct inode *inode, struct
> > > > > file
> > > > > *filp)
> > > > >  {
> > > > >  	dprintk("NFS: release(%pD2)\n", filp);
> > > > >  
> > > > > +	if (filp->f_mode & FMODE_WRITE)
> > > > > +		/* Ensure dirty mmapped pages are flushed
> > > > > +		 * so there will be no dirty pages to
> > > > > +		 * prevent an unmount from completing.
> > > > > +		 */
> > > > > +		vfs_fsync(filp, 0);
> > > > >  	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
> > > > >  	nfs_file_clear_open_context(filp);
> > > > >  	return 0;
> > > > 
> > > > The right fix here is to ensure that umount() flushes the dirty
> > > > data,
> > > > and that it aborts the umount attempt if the flush fails.
> > > > Otherwise, a
> > > > signal to the above fsync call will cause the problem to reoccur.
> > > 
> > > The only way to ensure that umount flushes dirty data is to revert
> > > commit 1daef0a86837 ("NFS: Clean up nfs_sb_active/nfs_sb_deactive").
> > > As long as we are taking extra references to s_active, umount won't
> > > do
> > > what it ought to do.
> > > 
> > 
> > Reverting that patch is not sufficient. You'd still need to call
> > sync_filesystem(), and abort the umount if the latter fails.
> 
> generic_shutdown_super() (which nfs_kill_super() calls) already calls
> sync_filesystem().  However sync_filesystem() cannot fail - it just
> asks bdi workers to flush data out, then waits for completion.
> 
> If the server is working, this should complete correctly.  If it isn't
> this will block indefinitely in the same way that a "sync" following the
> umount will block indefinitely today.
> 
> So while I agree that reverting this isn't sufficient, I think it might
> be a step in the right direction.
> 
> I've been experimenting with what happens when the server does down and
> you try to unmount.  With NFSv4, the state manager can still be trying
> to send a RENEW and not want to let go until it gets an answer.  I
> haven't traced it all through yet to understand why or how significant
> this is.
> 
> 
> > 
> > > I do wonder what we should do when you try to unmount a filesystem
> > > mounted from an inaccessible server.
> > > Blocking is awkward for scripts to work with.  Failing with EBUSY
> > > might
> > > be misleading.
> > > I don't think that using MNT_FORCE guarantees success does it?  It
> > > would
> > > need to discard any dirty data and abort any other background tasks.
> > 
> > MNT_FORCE will only abort any outstanding RPC calls. It is constrained
> > by the fact that we don't serialise umount and mount, and that the
> > filesystem on which we are operating may be mounted in several places
> > in the main namespace and indeed in several private namespaces to
> > boot.
> 
> Yes, that is a problem.
> If we could arrange that SIGKILL *always* kills the process so that it
> drops the reference to the filesystem, we could possible delay the
> MNT_FORCE handling until deactivate_super(), but at present we sometimes
> need MNT_FORCE to allow KILLed processes to die, and while there are
> processes with file descriptors, umount will not get as far as
> deactivate_super().
> (We need filemap_fdatawait_range() to be killable to do better.)
> 

Indeed. I think we need to consider variants of these that are killable,
and replace the existing calls with the killable variants in the
appropriate places. That's a long term (and difficult) project though...

> > 
> > > I think I would be in favor of EBUSY rather than a hang, and of
> > > making
> > > MNT_FORCE a silver bullet providing there are no open file
> > > descriptors
> > > on the filesystem.
> > 
> > All other filesystems trigger sync_filesystem(), and that's what the
> > VFS expects us to do. The problem is the VFS assumes that call will
> > always succeed, and won't ever return an error.
> 
> Yes, it is not easy to find an "ideal" solution.
> 
> Given that fact, and given that the present patch does address an easily
> demonstrated symptom, would you accept it as a small step in a good
> direction?  When the server is still accessible, and when no-one kills
> processes at awkward times, it definitely helps.
> 
> Even with a SIGKILL, I think the WRITEs and the COMMIT will be sent, but
> the COMMIT won't be waited for...
> 
> Thanks,
> NeilBrown

-- 
Jeff Layton <jlayton@redhat.com>
