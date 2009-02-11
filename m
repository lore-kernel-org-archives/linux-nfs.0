Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60587 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980AbZBKVx4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Feb 2009 16:53:56 -0500
Subject: Re: NFS clients' use of fs_locations?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jeff Garzik <jeff@garzik.org>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
In-Reply-To: <4993435C.2090903@garzik.org>
References: <49932E72.8060209@garzik.org>
	 <1234387040.7423.287.camel@heimdal.trondhjem.org>
	 <4993435C.2090903@garzik.org>
Content-Type: text/plain
Date: Wed, 11 Feb 2009 16:53:51 -0500
Message-Id: <1234389231.7423.319.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-02-11 at 16:30 -0500, Jeff Garzik wrote:
> Trond Myklebust wrote:
> > On Wed, 2009-02-11 at 15:00 -0500, Jeff Garzik wrote:
> >> According to the NFSv4 spec (section 6.1), regarding fs_locations,
> >>
> >> 	On first access of the filesystem, the client should obtain the
> >> 	value of the fs_locations attribute. If, in the future, the
> >> 	client finds the server unresponsive, the client may attempt to
> >> 	use another server specified by fs_locations.
> >>
> >> Does any known client actually fail over to another fs_location, as 
> >> described here?
> >>
> >> I am implementing the server side of this...  AFAICT Linux barely uses 
> >> fs_locations, and Solaris just crashes.
> > 
> > Hi Jeff,
> > 
> > I'm working on finishing the migration code, and expect to have it ready
> > soon.
> 
> Neat!  Will that include the simple fail-over actions described above?

Yes. As well as full state recovery etc on migration...

> > Until that, though, Bruce's suggestion of AIX is probably your best bet.
> > AFAIK, they've had migration support in their client for several years.
> 
> Thanks!  Any idea at all if AIX client supports fail-over, or simply 
> migration based on NFS4ERR_MOVED?
> 
> Time to figure out how to access AIX NFS client......  :)

Maybe Steve French (sfrench@samba.org) can help you out? I think he's
still working for IBM, and I believe his office used to be in the same
complex as the AIX nfs developers in Austin...

Cheers
    Trond

