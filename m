From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: whither NFS umount?
Date: Thu, 14 Oct 2010 10:34:08 -0400
Message-ID: <20101014143407.GH24146@fieldses.org>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>
 <1286903046.24878.13.camel@heimdal.trondhjem.org>
 <C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>
 <20101012151826.76b75f52@corrin.poochiereds.net>
 <1286912649.1956.19.camel@heimdal.trondhjem.org>
 <4CB5EF15.5030003@RedHat.com>
 <1286993898.3015.123.camel@heimdal.trondhjem.org>
 <4CB60869.4050004@RedHat.com>
 <20101014140009.GA24146@fieldses.org>
 <1287065841.3015.233.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Jeff Layton <jlayton@redhat.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44411 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202Ab0JNOeS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Oct 2010 10:34:18 -0400
In-Reply-To: <1287065841.3015.233.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 14, 2010 at 10:17:21AM -0400, Trond Myklebust wrote:
> On Thu, 2010-10-14 at 10:00 -0400, J. Bruce Fields wrote:
> > So, on the server side...  As Trond says, we'd like to know which
> > clients have been active recently.  (In the v4 case, the lease gives
> > that a precise meaning.  In the v2/v3 case, I suppose we just pick a
> > number to use as a timeout.  We could use the v4 lease time.)  It's only
> > the kernel that knows which clients have been active recently.  So we'd
> > need a way for the client to export that information to userspace.
> > 
> > Greg's per-client statistics might be a good starting point:
> > 
> > 	http://thread.gmane.org/gmane.linux.nfs/25537/focus=25534
> > 
> > Though that's just per-ip address, which isn't ideal for v4.  (In the v4
> > case the client identifier/owner allows us to distinguish e.g. between
> > multiple clients on the same machine, or behind the same NAT.)  I think
> > that wouldn't be hard to fix.  (Maybe just add on some ascii-escaped
> > representation of the clientid to the end of the same line?)
> 
> Relying on the lease isn't good enough. While an NFSv4.1 client is
> indeed required to renew its lease before it can do any useful work, an
> NFSv4.0 client is only required to establish a lease in order to OPEN a
> file.
> The Linux NFS client will, for instance, defer establishing a lease
> until first open, and will stop renewing that lease when nobody is
> holding any open file state.

Good point, thanks.

--b.

> One alternative to using the lease state is to use the TCP connection
> state and/or the TCP/UDP port number. That's pretty much what we use to
> distinguish separate NFS clients in the replay cache anyway...
