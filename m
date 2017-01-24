Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50164 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750713AbdAXUjI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jan 2017 15:39:08 -0500
Date: Tue, 24 Jan 2017 15:31:53 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1] nfs: Don't increment lock sequence ID after
 NFS4ERR_MOVED
Message-ID: <20170124203153.GD20844@fieldses.org>
References: <20170122190429.7337.77928.stgit@manet.1015granger.net>
 <69D3212A-874D-42A2-BE65-F3A01B061A87@oracle.com>
 <20170123164913.GB9493@fieldses.org>
 <1F944D3D-A28B-48C5-88CC-39EBD6CB8430@oracle.com>
 <20170124191515.GA20844@fieldses.org>
 <1485289414.12087.0.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1485289414.12087.0.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 24, 2017 at 08:23:36PM +0000, Trond Myklebust wrote:
> On Tue, 2017-01-24 at 14:15 -0500, J. Bruce Fields wrote:
> > On Tue, Jan 24, 2017 at 02:06:16PM -0500, Chuck Lever wrote:
> > > 
> > > > On Jan 23, 2017, at 11:49 AM, bfields@fieldses.org wrote:
> > > > 
> > > > On Mon, Jan 23, 2017 at 10:01:27AM -0500, Chuck Lever wrote:
> > > > > 
> > > > > > On Jan 22, 2017, at 2:04 PM, Chuck Lever <chuck.lever@oracle.
> > > > > > com> wrote:
> > > > > > 
> > > > > > Xuan Qi reports that the Linux NFSv4 client failed to lock a
> > > > > > file
> > > > > > that was migrated. The steps he observed on the wire:
> > > > > > 
> > > > > > 1. The client sent a LOCK request
> > > > > > 2. The server replied NFS4ERR_MOVED
> > > > > > 3. The client switched to the destination server
> > > > > > 4. The client sent the LOCK request again with a bumped
> > > > > >  lock sequence ID
> > > > > > 5. The server rejected the LOCK request with
> > > > > > NFS4ERR_BAD_SEQID
> > > > > 
> > > > > The list of steps could be more clear:
> > > > > 
> > > > > 1. The client sent a LOCK request to the source server
> > > > > 2. The source server replied NFS4ERR_MOVED
> > > > > 3. The client switched to the destination server
> > > > > 4. The client sent the same LOCK request to the destination
> > > > >   server with a bumped lock sequence ID
> > > > > 5. The destination server rejected the LOCK request with
> > > > >   NFS4ERR_BAD_SEQID
> > > > > 
> > > > > 
> > > > > > RFC 3530 section 8.1.5 provides a list of NFS errors which do
> > > > > > not
> > > > > > bump a lock sequence ID.
> > > > > > 
> > > > > > However, RFC 3530 is now obsoleted by RFC 7530. In RFC 7530
> > > > > > section
> > > > > > 9.1.7, this list has been updated by the addition of
> > > > > > NFS4ERR_MOVED.
> > > > 
> > > > I guess we figured the backwards-incompatible change was OK since
> > > > essentially the Solaris server is the first we know of to be
> > > > making real
> > > > use of NFS4ERR_MOVED?
> > > > 
> > > > And probably it's required for the their implementation because
> > > > the old
> > > > server no longer has the ability to update the state once it's
> > > > reached
> > > > the point of returning ERR_MOVED.
> > > > 
> > > > OK, makes sense to me, I think.
> > > 
> > > Hi Bruce-
> > > 
> > > Does this mean you will take this patch, or should
> > > I just add your Reviewed-by: ?
> > 
> > I can take it if nobody objects.  Mind if I append the above to the
> > changelog?  (Just want to document why we think the apparently
> > backwards-incompatible change is OK.)
> > 
> I've already added it to my linux-next branch as a stable patch.

OK, fine by me, dropping.--b.
