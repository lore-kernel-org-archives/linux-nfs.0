Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54309 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755873AbaIWQFk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 12:05:40 -0400
Date: Tue, 23 Sep 2014 12:05:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923160539.GE29932@fieldses.org>
References: <54207BCD.70101@RedHat.com>
 <20140922204401.GI26763@fieldses.org>
 <5420911D.6080506@RedHat.com>
 <20140922223423.GA29932@fieldses.org>
 <5420B78D.6040704@RedHat.com>
 <20140922202655.5e308e58@willson.usersys.redhat.com>
 <20140923015549.GB32712@fieldses.org>
 <54218C85.6040005@RedHat.com>
 <20140923151621.GB29932@fieldses.org>
 <5421972C.4080006@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5421972C.4080006@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 11:52:12AM -0400, Steve Dickson wrote:
> On 09/23/2014 11:16 AM, J. Bruce Fields wrote:
> > On Tue, Sep 23, 2014 at 11:06:45AM -0400, Steve Dickson wrote:
> >> > 
> >> > 
> >> > On 09/22/2014 09:55 PM, J. Bruce Fields wrote:
> >>> > > On Mon, Sep 22, 2014 at 08:26:55PM -0400, Simo Sorce wrote:
> >>>> > >> No, starting before those service in itself achieves nothing.\
> >>>> > >> I think what may cause the module to load maybe the fact
> >>>> > >> gssproxy.service includes:
> >>>> > >> Requires=proc-fs-nfsd.mount
> >>> > > 
> >>> > > I'd expect that to only load the nfsd module.
> >>> > > 
> >>> > > Hm, I think nfsd actually has a dependency on auth_rpcgss.  I wonder if
> >>> > > that's correct.  Maybe that's what's doing it.
> >> > It is... In another thread I clearly showed that....
> > The dependency of nfsd on auth_rpcgss looks to me like an implementation
> > detail.  The client module doesn't have the same dependency.  
> It does... auth_rpcgss and friends are loaded during the mount

They get loaded for other reasons.

The nfs module does not have any static dependency on the auth_rpcgss
module that I can see.

> > We definitely shouldn't depend on it, as the dependency could get removed
> > some day.
> Well if that dependency gets removed (which I can't see why it ever would)
> we'll deal with the then...

No, please don't depend on this implementation detail.

--b.
