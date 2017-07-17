Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:36555 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdGQMCs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jul 2017 08:02:48 -0400
Received: by mail-qt0-f180.google.com with SMTP id 21so28537763qtx.3
        for <linux-nfs@vger.kernel.org>; Mon, 17 Jul 2017 05:02:47 -0700 (PDT)
Message-ID: <1500292965.4766.2.camel@redhat.com>
Subject: Re: open by handle support for NFS V2
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>, hch <hch@lst.de>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>
Date: Mon, 17 Jul 2017 08:02:45 -0400
In-Reply-To: <87r2xsx45l.fsf@notabene.neil.brown.name>
References: <20170629133453.19641-1-hch@lst.de>
         <20170629154650.GC1651@fieldses.org>
         <1498842056.6728.1.camel@primarydata.com>
         <87zichvuh9.fsf@notabene.neil.brown.name>
         <1499397566.36826.1.camel@primarydata.com>
         <87r2xsx45l.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-07-07 at 14:27 +1000, NeilBrown wrote:
> On Fri, Jul 07 2017, Trond Myklebust wrote:
> 
> > On Fri, 2017-07-07 at 12:41 +1000, NeilBrown wrote:
> > > On Fri, Jun 30 2017, Trond Myklebust wrote:
> > > 
> > > > On Thu, 2017-06-29 at 11:46 -0400, J. Bruce Fields wrote:
> > > > > On Thu, Jun 29, 2017 at 06:34:49AM -0700, Christoph Hellwig
> > > > > wrote:
> > > > > > this resurrects parts of an old series to add open by handle
> > > > > > support to
> > > > > > NFS.  The prime intent here is to support the actual open by
> > > > > > handle
> > > > > > ioctls, although it will also allow very crude re-
> > > > > > exporting.  Without
> > > > > > the other patches from Jeff's series that re-exporting will
> > > > > > suck
> > > > > > badly
> > > > > > though.
> > > > > 
> > > > > Why do we want this?
> > > > > 
> > > > > Any re-export support is going to have some major
> > > > > limitations.  (No
> > > > > file
> > > > > locking, and re-export of NFSv4 probably not possible?)
> > > > > 
> > > > > Last I heard the only motivation was extremely specific to
> > > > > Primary
> > > > > Data's setup.  I'm happy to help them, but I think we need *some*
> > > > > evidence this will be useful to upstream users.
> > > > > 
> > > > 
> > > > The main use case for open by filehandle was (and still should be)
> > > > the
> > > > promise of being able to do the sort of tricks you normally
> > > > associate
> > > > with object storage on a standard filesystem.
> > > > 
> > > > Imagine that you are trying to build an application for indexing
> > > > and
> > > > searching the data on your storage. You basically want to trawl
> > > > through
> > > > the filesystem on a regular basis and build up a database of key
> > > > words
> > > > and other metadata to tell you what is in the files. For that kind
> > > > of
> > > > application, the namespace is a real PITA to deal with, because
> > > > files
> > > > get renamed, moved and deleted all the time; so if you can store
> > > > something that is independent of the namespace and that will give
> > > > you
> > > > access to the file contents, then why wouldn't you do so? Normally,
> > > > applications like that use the inode number, but you can't open a
> > > > file
> > > > by inode number, and you have the same problems with inode number
> > > > reuse
> > > > that a NFS server has.
> > > > 
> > > > That's the sort of thing I'd think we want to allow through open by
> > > > filehandle, and I see no reason why NFS should be excluded from
> > > > that
> > > > type of application.
> > > 
> > > Given that the goal, and presumably the testing, is focused on this
> > > use-case, I wonder if we should take steps to disable the NFS-re-
> > > export
> > > use case.
> > > As the patch stands, I suspect that NFS re-export would appear to
> > > work,
> > > but - as Bruce suggests - would likely hit some problems.  This might
> > > not be a user-friendly thing to do.
> > > 
> > > Probably the ideal would be to keep re-export disabled by default,
> > > but
> > > to allow it to be enabled using a module parameter.
> > > I'm not sure the best way for NFS to tell nfsd that export shouldn't
> > > be
> > > trusted.
> > > Maybe add a "flags" field to struct export_operations, which can
> > > contain
> > > a "No NFS export" flag ??
> > > 
> > 
> > You could, but the reason why we developed the code in the first place,
> > was because we have an internal use case which does involve re-export
> > of NFS, so we're familiar with the limitations.
> > 
> > FYI, the limitations are:
> > 1) Recovery of locks is not possible when the re-exporting server is
> > the one being rebooted. It works just fine for all other cases.
> > 2) Re-exporting anything to NFSv2 is not possible.
> > 3) Re-export of filesystems with very large filenandles could be
> > problematic. This would also affect open-by-filehandle. In practice it
> > turns out to be a non-issue because nobody uses filehandles > 64 bytes.
> > 4) Stateless NFSv3 reads and writes can be a problem with NFSv4 when
> > the application usees odd modebit settings such as 000.
> > 
> > IOW: in practice this is no worse than all the other re-exporters such
> > as already exist for gluster -> NFSv3, ceph -> NFSv3, NFS -> SMB,...
> > and which everyone seems happy to use.
> > 
> 
> Thanks.  That isn't as bad as I feared.  Maybe it would be useful to put
> notes like in this in the nfs(5) man page.
> For the NFSv2 export I suspect that in some cases you might be
> able to successfully mount, but then not access anything.
> The linux NFS server uses a very small file handles for an export-point.
> It might be good to have nfs_encode_fh always fail if *max_len <= 32/4
> just to ensure that NFSv2 doesn't even get off the ground.
> 

I just saw this on the LWN article entitled "4.13 Merge window, part 2":

   - NFS filesystems can now be re-exported over NFS.

I'm posting a comment there to try and clarify this, but it's a little
worrisome that this misconception is already getting out. I think we
need to do something to clear up this confusion, whether via
documentation or other means.
-- 
Jeff Layton <jlayton@redhat.com>
