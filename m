Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41848 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751184AbdIOLwZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Sep 2017 07:52:25 -0400
Date: Fri, 15 Sep 2017 12:52:23 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: David Noveck <davenoveck@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Steve Dickson <steved@redhat.com>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>
Subject: Re: [nfsv4] [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170915115223.GB14994@stefanha-x1.localdomain>
References: <20170913102650.10377-1-stefanha@redhat.com>
 <20170913162111.GA14389@infradead.org>
 <CADaq8jd2VaHUX=9rVbG41tTPj+9R8Grkjnaoh1hfKv8sVn5-GA@mail.gmail.com>
 <EE7BAC64-DE4E-4A46-B692-08C0D7FE9D72@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <EE7BAC64-DE4E-4A46-B692-08C0D7FE9D72@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 13, 2017 at 11:21:36AM -0700, Chuck Lever wrote:
> 
> > On Sep 13, 2017, at 11:18 AM, David Noveck <davenoveck@gmail.com> wrote:
> > 
> > > and how to ask IESG to assign it?
> > 
> > The way to get the IESG to assign it would be to write an RFC and get it approved as a Proposed Standard but I don't think you need to do that.  There is a portion of the netid registry that is assigned on a first-come-first-served basis (see RFCs 5665 and 5226) and if you are OK with that, the IESG doesn't have to be involved.  You simply have to ask IANA to assign it, providing the information (pretty limited) mentioned in those RFCs.
> 
> Stefan also needs to define a universal address format.
> 
> And somewhere we need to specify how this new RPC transport works.
> In hand-waving mode, it's basically TCP (with the same connection
> and record-marking semantics) but using a different address family.
> 
> So it may not be as simple as a single IANA action.

Thanks Christoph, David, and Chuck.  I'll reread the RFCs and try to
make progress on this.

Stefan
