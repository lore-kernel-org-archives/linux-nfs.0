Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22253 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755827Ab0LHUpb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 15:45:31 -0500
Subject: Re: NFSv4: "Viminfo file is not writable" -- stat(2) uid/gid
 incorrect
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Flynn <davidf@rd.bbc.co.uk>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101208202009.GH20844@rd.bbc.co.uk>
References: <20101208153340.GD20844@rd.bbc.co.uk>
	 <1291835999.3067.13.camel@heimdal.trondhjem.org>
	 <20101208202009.GH20844@rd.bbc.co.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Dec 2010 15:45:29 -0500
Message-ID: <1291841129.3067.22.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-08 at 20:20 +0000, David Flynn wrote:
> I don't think this is the case. I performed a network trace of the
> transaction and i can see that for all the calls with a user/group in
> they refer to me (davidf@rd.bbc.co.uk, rd@rd.bbc.co.uk).

Yes. I saw your trace, and it looked good.

> I also checked the local idmapper to see what it thought of things, and
> it doesn't get an upcall to map this request, so values have been
> previously cached.

Have you tried running the idmapper with the '-f -v -v' flags so you can
log the translation upcalls? The default cache timeout is 10 minutes, so
you shouldn't have to wait too long.

> Also, the thing about this "race" is that it is very very slow.  its
> utterly reliable.  running vim on "host-B" does not have to occur while
> it runs on "host-A", nor does it seem to need to happen soon
> after/before "host-A" quits/starts vim.
> 
> > I've no idea how to check the Solaris idmapper configuration, but on
> > Linux you want to look at /etc/idmapd.conf (specifically the 'Domain'
> > line).
> 
> That is correct as far as i can tell.  The first part of the transaction
> is OK, however, it fails as soon as stat() is called after open().

While the open() call may indeed fail to set the uid/gid (because to do
so would require an upcall right in the middle of an asynchronous RPC
call), it should normally mark the inode as requiring revalidation if
this is the case.
The ensuing stat() should then trigger a GETATTR call on the wire, which
will correct the uid/gid.

> I can't see any calls that don't use my textual owner / group.  Can you
> confirm this?

Agreed.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

