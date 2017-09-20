Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52350 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750997AbdITNQl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Sep 2017 09:16:41 -0400
Date: Wed, 20 Sep 2017 09:16:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170920131641.GC14329@fieldses.org>
References: <A1844833-18E1-4F03-BB20-A06A6FE4AB62@oracle.com>
 <20170918180927.GD12759@stefanha-x1.localdomain>
 <20170919093140.GF9536@redhat.com>
 <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
 <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <E94E2759-1734-4C52-838F-8906B3F969C0@oracle.com>
 <20170919204224.GA14329@fieldses.org>
 <37604438-9848-47CA-8884-8FD6292EAFC9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <37604438-9848-47CA-8884-8FD6292EAFC9@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 19, 2017 at 05:09:25PM -0400, Chuck Lever wrote:
> 
> > On Sep 19, 2017, at 4:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Tue, Sep 19, 2017 at 03:56:50PM -0400, Chuck Lever wrote:
> >> A proof of concept is nice, but it isn't sufficient for merging
> >> NFS/VSOCK into upstream Linux. Unlike Ceph, NFS is an Internet
> >> standard. We can't introduce changes as we please and expect
> >> the rest of the world to follow us.
> >> 
> >> I know the Ganesha folks chafe at this requirement, because
> >> standardization progress can sometimes be measured in geological
> >> time units.
> > 
> > It doesn't need to be--I think we're only asking for a few pages here,
> > and nothing especially complicated (at the protocol level).
> 
> That would define RPC over VSOCK. I would like to see a problem
> statement here, and we'd want to find a normative reference defining
> VSOCK addressing. Does one exist?
> 
> My sense is that NFS on VSOCK would need more. The proof of concept
> I'm aware of drops a lot of functionality (for example, NFSv2/3 is
> excluded, and so is RPCSEC GSS and NFSv4.0 backchannel) to make NFS
> work on this transport. Interoperability would require that list
> be written somewhere.

I don't think they need to support NFSv2/3 or RPCSEC_GSS, but it could
be worth a little text to explain why not, if they don't.

> We also need to deal with filehandles and lock state during guest
> live migration.

That sounds like a separate issue independent of transport.

I've been assuming there's still some use to them in an implementation
that doesn't support migration at first.  If not it's a bigger project.

--b.

> 
> That feels like more than a few pages to me.
> 
> 
> > That
> > shouldn't take so long.  (Not to be published as an RFC, necessarily,
> > but to get far enough along that we can be pretty certain it won't need
> > incompatible changes.)
> 
> 
> --
> Chuck Lever
