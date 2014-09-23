Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53530 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755540AbaIWT3J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 15:29:09 -0400
Date: Tue, 23 Sep 2014 15:29:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923192909.GJ29932@fieldses.org>
References: <1411413608-16462-2-git-send-email-steved@redhat.com>
 <20140922152603.75005941@willson.usersys.redhat.com>
 <54207BCD.70101@RedHat.com>
 <20140922204401.GI26763@fieldses.org>
 <5420911D.6080506@RedHat.com>
 <20140922173239.05c17b2a@willson.usersys.redhat.com>
 <5420A946.4090805@RedHat.com>
 <20140922201927.36fae05c@willson.usersys.redhat.com>
 <5420CA96.6090409@RedHat.com>
 <20140923085245.007533b6@willson.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140923085245.007533b6@willson.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 08:52:45AM -0400, Simo Sorce wrote:
> It will not, but right now gssproxy.service also has:
>  Requires=proc-fs-nfsd.mount
> 
> I want to drop this one.

By the way, I think all you actually want is After=proc-fs-nfsd.mount.

You don't actually want to bail out if fs-nfsd.mount fails, in fact you
don't care if it's activated at all, all you care about is that *if*
it's already activated (because nfsd is), then you want it to start
before you.

And in fact we could instead replace that with a Before=gssproxy.service
in proc-fs-nfsd.mount if you preferred.  I don't know how to decide
which place it goes, or if it matters.

--b.

> 
> > >> 2) Add a After=var-lib-nfs-rpc_pipefs.mount to the
> > >> gssproxy.service file since gssproxy could careless about either
> > >> rpc.gssd or rpc.svcgssd daemons. All it is looking for is the
> > >> sunrpc and auth_rpcgss kernel modules.
> > > 
> > > The correct thing is to add a Before: gssproxy.service to
> > > var-lib-nfs-rpc_pipefs.mount IMO.
> > Again what happen if gssproxy is not installed? Things will 
> > still come up successfully?
> 
> Yes, afaik After and Before are just ordering instruction and do not
> cause any failure if the units are not present at all, or fail to start.
> 
> There are Want and Require directives for strong relationships.
> 
> Simo.
> 
> -- 
> Simo Sorce * Red Hat, Inc * New York
