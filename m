Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53254 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750919AbdISRhG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Sep 2017 13:37:06 -0400
Date: Tue, 19 Sep 2017 18:37:04 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "Daniel P. Berrange" <berrange@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170919173704.GC5744@stefanha-x1.localdomain>
References: <20170915133145.GA23557@fieldses.org>
 <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com>
 <20170915164223.GE23557@fieldses.org>
 <A1844833-18E1-4F03-BB20-A06A6FE4AB62@oracle.com>
 <20170918180927.GD12759@stefanha-x1.localdomain>
 <20170919093140.GF9536@redhat.com>
 <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
 <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170919164427.GV9536@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 19, 2017 at 05:44:27PM +0100, Daniel P. Berrange wrote:
> On Tue, Sep 19, 2017 at 11:48:10AM -0400, Chuck Lever wrote:
> > 
> > > On Sep 19, 2017, at 11:10 AM, Daniel P. Berrange <berrange@redhat.com> wrote:
> > > 
> > > On Tue, Sep 19, 2017 at 10:35:49AM -0400, Chuck Lever wrote:
> > >> 
> > >>> On Sep 19, 2017, at 5:31 AM, Daniel P. Berrange <berrange@redhat.com> wrote:
> > >>> 
> > >>> On Mon, Sep 18, 2017 at 07:09:27PM +0100, Stefan Hajnoczi wrote:
> > >>>> There are 2 main use cases:
> > >>>> 
> > >>>> 1. Easy file sharing between host & guest
> > >>>> 
> > >>>>  It's true that a disk image can be used but that's often inconvenient
> > >>>>  when the data comes in individual files.  Making throwaway ISO or
> > >>>>  disk image from those files requires extra disk space, is slow, etc.
> > >>> 
> > >>> More critically, it cannot be easily live-updated for a running guest.
> > >>> Not all of the setup data that the hypervisor wants to share with the
> > >>> guest is boot-time only - some may be access repeatedly post boot &
> > >>> have a need to update it dynamically. Currently OpenStack can only
> > >>> satisfy this if using its network based metadata REST service, but
> > >>> many cloud operators refuse to deploy this because they are not happy
> > >>> with the guest and host sharing a LAN, leaving only the virtual disk
> > >>> option which can not support dynamic update.
> > >> 
> > >> Hi Daniel-
> > >> 
> > >> OK, but why can't the REST service run on VSOCK, for instance?
> > > 
> > > That is a possibility, though cloud-init/OpenStack maintainers are
> > > reluctant to add support for new features for the metadata REST
> > > service, because the spec being followed is defined by Amazon (as
> > > part of EC2), not by OpenStack. So adding new features would be
> > > effectively forking the spec by adding stuff Amazon doesn't (yet)
> > > support - this is why its IPv4 only, with no IPv6 support too,
> > > as Amazon has not defined a standardized IPv6 address for the
> > > metadata service at this time.
> > 
> > You guys are asking the NFS community for a similar kind of
> > specification change here. We would prefer that you seek that change
> > with the relevant authority (the IETF) first before trying to merge
> > an implementation of it.
> > 
> > As a first step we have to define RPC operation on VSOCK transports.
> > That's the smallest piece of it. Dealing with some of the NFS issues
> > (like, what happens to filehandles and lock state during a live
> > guest migration) is an even larger challenge.
> > 
> > Sorry, but you can't avoid one interoperability problem (Amazon)
> > by introducing another (NFS).
> 
> Agreed, I can't argue with that. It does feel overdue to get NFS-over-VSOCK
> defined as a formal spec, especially since it was already implemented in
> the NFS-ganesha userspace server.

Getting the RPC over AF_VSOCK details through the IETF process is my
next goal.

Stefan
