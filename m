Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57704 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227AbcHPPVu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2016 11:21:50 -0400
Date: Tue, 16 Aug 2016 11:21:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/8] mountd: remove 'dev_missing' checks
Message-ID: <20160816152148.GC30124@fieldses.org>
References: <20160714021310.5874.22953.stgit@noble>
 <20160714022643.5874.84409.stgit@noble>
 <20160718200121.GC12304@fieldses.org>
 <878twx9ra3.fsf@notabene.neil.brown.name>
 <20160721172452.GC27148@fieldses.org>
 <87wpjokofy.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87wpjokofy.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 11, 2016 at 12:51:45PM +1000, NeilBrown wrote:
> On Fri, Jul 22 2016, J. Bruce Fields wrote:
> 
> > On Wed, Jul 20, 2016 at 08:50:12AM +1000, NeilBrown wrote:
> >> On Tue, Jul 19 2016, J. Bruce Fields wrote:
> >> 
> >> > On Thu, Jul 14, 2016 at 12:26:43PM +1000, NeilBrown wrote:
> >> >> I now think this was a mistaken idea.
> >> >> 
> >> >> If a filesystem is exported with the "mountpoint" or "mp" option, it
> >> >> should only be exported if the directory is a mount point.  The
> >> >> intention is that if there is a problem with one filesystem on a
> >> >> server, the others can still be exported, but clients won't
> >> >> incorrectly see the empty directory on the parent when accessing the
> >> >> missing filesystem, they will see clearly that the filesystem is
> >> >> missing.
> >> >> 
> >> >> It is easy to handle this correctly for NFSv3 MOUNT requests, but what
> >> >> is the correct behavior if a client already has the filesystem mounted
> >> >> and so has a filehandle?  Maybe the server rebooted and came back with
> >> >> one device missing.  What should the client see?
> >> >> 
> >> >> The "dev_missing" code tries to detect this case and causes the server
> >> >> to respond with silence rather than ESTALE.  The idea was that the
> >> >> client would retry and when (or if) the filesystem came back, service
> >> >> would be transparently restored.
> >> >> 
> >> >> The problem with this is that arbitrarily long delays are not what
> >> >> people would expect, and can be quite annoying.  ESTALE, while
> >> >> unpleasant, it at least easily understood.  A device disappearing is a
> >> >> fairly significant event and hiding it doesn't really serve anyone.
> >> >
> >> > It could also be a filesystem disappearing because it failed to mount in
> >> > time on a reboot.
> >> 
> >> I don't think "in time" is really an issue.  Boot sequencing should not
> >> start nfsd until everything in /etc/fstab is mounted, has failed and the
> >> failure has been deemed acceptable.
> >> That is why nfs-server.services has "After= local-fs.target"
> >
> > Yeah, I agree, that's the right way to do it.  [snip]
> 
> There is actually more here ... don't you love getting drip-feed
> symptoms and requirements :-)

It's all good.

> It turns out the the customer is NFS-exporting a filesystem mounted
> using iSCSI.  Such filesystems are treated by systemd as "network"
> filesystem, which seems at least a little bit reasonable.
> So it is "remote-fs" that applies, or more accurately
> "remote-fs-pre.target"
> And nfs-server.services contains:
> 
> Before=remote-fs-pre.target

This is to handle the loopback case?

In which case what it really wants to say is "before nfs mounts" (or
even "before nfs mounts of localhost"; and vice versa on shutdown).  I
can't tell if there's an easy way to get say that.

> So nfsd is likely to start up before the iSCSI filesystems are mounted.
> 
> The customer tried to stop this bt using a systemd drop-in to add
> RequiresMountsFor= for the remote filesystem, but that causes
> a loop with the Before=remote-fs-pre.target.
> 
> I don't think we need this line for sequencing start-up, but it does
> seem to be useful for sequencing shutdown - so that nfs-server is
> stopped after remote-fs-pre, which is stopped after things are
> unmounted.
> "useful", but not "right".  This doesn't stop remote servers from
> shutting down in the wrong order.
> We should probably remove this line and teach systemd to use "umount -f"
> which doesn't block when the server is down.  If systemd just used a
> script, that would be easy....
> 
> I'm not 100% certain that "umount -f" is correct.  We just want to stop
> umount from stating the mountpoint, we don't need to send MNT_FORCE.
> I sometimes think it would be really nice if NFS didn't block a
> 'getattr' request of the mountpoint.  That would remove some pain from
> unmount and other places where the server was down, but probably would
> cause other problem.

I thought I remembered Jeff Layton doing some work to remove the need to
revalidate the mountpoint on unmount in recent kernels.

Is that the only risk, though?  Maybe so--presumably you've killed any
users, so any write data associated with opens should be flushed.  And
if you do a sync after that you take care of write delegations too.

> Does anyone have any opinions on the best way to make sure systemd
> doesn't hang when it tries to umount a filesystem from an unresponsive
> server?  Is "-f" best, or something else.
> 
> 
> 
> There is another issue related to this that I've been meaning to
> mention.  It related to the start-up ordering rather than shut down.
> 
> When you try to mount an NFS filesystem and the server isn't responding,
> mount.nfs retries for a little while and then - if "bg" is given - it
> forks and retries a bit longer.
> While it keeps gets failures that appear temporary, like ECONNREFUSED or
> ETIMEDOUT (see nfs_is_permanent_error()) it keeps retrying.
> 
> There is typically a window between when rpcbind starts responding to
> queries, and when nfsd has registered with it.  If mount.nfs sends an
> rpcbind query in this window. It gets RPC_PROGNOTREGISTERED which
> nfs_rewrite_pmap_mount_options maps to EOPNOTSUPP, and
> nfs_is_permanent_error() thinks that is a permanent error.

Looking at rpcbind(8)....  Shouldn't "-w" prevent this by loading some
registrations before it starts responding to requests?

--b.

> 
> Strangely, when the 'bg' option is used, there is special-case code
> Commit: bf66c9facb8e ("mounts.nfs: v2 and v3 background mounts should retry when server is down.")
> to stop EOPNOTSUPP from being a permanent error.
> 
> Do people think it would be reasonable to make it a transient error for
> foreground mounts too?
> 
> Thanks,
> NeilBrown


