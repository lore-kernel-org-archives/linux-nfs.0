Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52776 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751671AbdITSeE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Sep 2017 14:34:04 -0400
Date: Wed, 20 Sep 2017 14:34:04 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "ffilzlnx@mindspring.com" <ffilzlnx@mindspring.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "stefanha@redhat.com" <stefanha@redhat.com>,
        SteveD redhat <steved@redhat.com>,
        "mbenjami@redhat.com" <mbenjami@redhat.com>,
        "berrange@redhat.com" <berrange@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170920183404.GI14329@fieldses.org>
References: <20170919164427.GV9536@redhat.com>
 <E94E2759-1734-4C52-838F-8906B3F969C0@oracle.com>
 <20170919204224.GA14329@fieldses.org>
 <37604438-9848-47CA-8884-8FD6292EAFC9@oracle.com>
 <20170920131641.GC14329@fieldses.org>
 <E8E404FD-420A-45C6-B46B-F1E2A4133F17@oracle.com>
 <20170920144557.GD14329@fieldses.org>
 <202BF722-77BC-4EF2-BD75-9AA42CBF4A94@oracle.com>
 <015601d33224$b7770b40$266521c0$@mindspring.com>
 <1505931425.10427.2.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1505931425.10427.2.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 20, 2017 at 06:17:07PM +0000, Trond Myklebust wrote:
> On Wed, 2017-09-20 at 08:25 -0700, Frank Filz wrote:
> > > > On Sep 20, 2017, at 10:45 AM, J. Bruce Fields <bfields@fieldses.o
> > > > rg>
> > 
> > wrote:
> > > > 
> > > > On Wed, Sep 20, 2017 at 10:40:45AM -0400, Chuck Lever wrote:
> > > > > File handles suddenly change and lock state vanishes after a
> > > > > live
> > > > > migration event, both of which would be catastrophic for
> > > > > hypervisor
> > > > > mount points.
> > > > 
> > > > They're talking about a Ganesha/Ceph backend.  It should be able
> > > > to
> > > > preserve filehandles.
> > > 
> > > That's only one possible implementation. I'm thinking in terms of
> > > what
> > 
> > needs
> > > to be documented for interoperability purposes.
> > 
> > It seems like live migration pretty much requires a back end that
> > will
> > preserve file handles.
> > 
> > > > Lock migration will require server-side implementation work but
> > > > not
> > > > protocol changes that I'm aware of.
> > > > 
> > > > It could be a lot of implementation work, though.
> > > 
> > > Agreed.
> > 
> > I think the lock migration can be handled the way we handle state
> > migration
> > in an HA environment - where we treat it as a server reboot to the
> > client
> > (so SM_NOTIFY to v3 clients, the various errors v4 uses to signal
> > server
> > reboot, in either case, the client will initiate lock reclaim).
> > 
> 
> Mind showing us an architecture for that? As far as I can see, the
> layering is as follows:
> 
> VM client
> --------------
> host knfsd
> --------------
> host client
> --------------
> Storage server
> 
> So how would you notify the VM client that its locks have been
> migrated?

All I've seen mentioned in this thread is

  VM client
  ---------
  host Ganesha
  ---------
  Ceph or Gluster

Did I misunderstand?

NFS proxying would certainly make it all more entertaining.

--b.
