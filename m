Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20562 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757892Ab0JLUVO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 16:21:14 -0400
Subject: Re: whither NFS umount?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20101012155234.094a87c3@corrin.poochiereds.net>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>
	 <1286903046.24878.13.camel@heimdal.trondhjem.org>
	 <C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>
	 <20101012151826.76b75f52@corrin.poochiereds.net>
	 <1286912649.1956.19.camel@heimdal.trondhjem.org>
	 <20101012155234.094a87c3@corrin.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 12 Oct 2010 16:21:00 -0400
Message-ID: <1286914860.3166.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-10-12 at 15:52 -0400, Jeff Layton wrote:
> On Tue, 12 Oct 2010 15:44:09 -0400
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Tue, 2010-10-12 at 15:18 -0400, Jeff Layton wrote:
> > 
> > > I think the part that causes problems is having userspace do this. In
> > > theory, if the kernel were in charge of sending the UMNT, then it's not
> > > really a problem since it knows when to do it. If we have code that
> > > sends a UMNT already, why not do a best-effort UMNT call from the
> > > kernel when we tear down the sb?
> > 
> > Purely for the pleasure of allowing the server to maintain inaccurate
> > statistics about who is currently mounting what? I think not...
> > 
> > You can get far more accurate results by replacing the MNT/UMNT state
> > counter with a purely server-based scheme to track who accessed one or
> > more files on each exported partition in the past 5 minutes or so. That
> > would even work with NFSv4...
> > 
> 
> True, but for better or worse, UMNT is part of the protocol. It seems
> like we ought to do our best to implement it, even if it is
> fundamentally flawed.
> 

UMNTALL is part of the same protocol, and yet we have never implemented
that. Just because something is documented, it doesn't mean we have to
do it...

The bottom line is that UMNT doesn't do what it advertises itself as
doing, and so we should not waste space supporting it in the kernel. We
shouldn't do so in userspace either.

Trond
