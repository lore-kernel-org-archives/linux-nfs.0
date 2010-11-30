Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:54621 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754606Ab0K3ACG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 19:02:06 -0500
Received: by gxk3 with SMTP id 3so25530gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 29 Nov 2010 16:02:05 -0800 (PST)
From: "Spencer Shepler" <spencer.shepler@gmail.com>
To: "'Trond Myklebust'" <Trond.Myklebust@netapp.com>
Cc: <Daniel.Muntz@emc.com>, <spelic@shiftmail.org>,
        <linux-nfs@vger.kernel.org>
References: <1291054975.12784.17.camel@heimdal.trondhjem.org> <DE966DA98A4ABE438D726BDF1699CF610437B188C9@MX05A.corp.emc.com> <067101cb9018$d70ba2f0$8522e8d0$@gmail.com> <1291072571.20567.26.camel@heimdal.trondhjem.org> <1291073174.20567.31.camel@heimdal.trondhjem.org> <068901cb901d$61395630$23ac0290$@gmail.com> <1291074002.20567.38.camel@heimdal.trondhjem.org>
In-Reply-To: <1291074002.20567.38.camel@heimdal.trondhjem.org>
Subject: RE: NFSv4 behaviour on unknown users
Date: Mon, 29 Nov 2010 16:02:01 -0800
Message-ID: <068f01cb9021$d1c10700$75431500$@gmail.com>
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



> -----Original Message-----
> From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com]

<trim>

> > > servers.
> > >
> > > The other problem is that when you use the naked uid or gid you are
> > > losing information about which domain the user belongs to.
> > >
> > > While that may be fine when you are authenticating using the
> > > AUTH_SYS security flavour, it is just plain wrong when you are
> > > authenticating using RPCSEC_GSS principals (which is what the NFSv4
> > > spec assumes that you will use).
> >
> > Then the administrator will not use that option.
> >
> > The use case that was presented did not use Kerberos (at least in my
> quick reading).
> >
> > I agree that users that use Kerberos will be unhappy and that they
> > should use something that maps more in align with their Kerberos
> > realms but that is not the pain point under discussion.  A variation
> > of the id mapping work under discussion by Andy would/could address
> > Kerberos and other deployment scenarios.  But for the original "works
> > for NFSv3 and doesn't for NFSv4" crowd something simple will suffice
> > and they will be happy and stop bitching about this and move onto the
> > next thing that pisses them off. :-)
> 
> It would not be backwards compatible: the linux server will currently
> reject any uid/gid usage by the client.
> 
> That said, I can imagine that for 'sec=sys', we might be able to change
> the client to use the uid/gid format by default, and then change back to
> doing name@domain upon receiving the first NFS4ERR_BADOWNER error from the
> server.
> It the server changes to match this, then that might suffice solve the
> current problem that we have with doing nfsroot on NFSv4...

IMO: I wouldn't worry about the mixed scenarios to start with.
Provide the option on the client and server to use the straight-up
uid/gid to string mappings and this will satisfy these simple
deployments that are or will have trouble.  In the mixed environments,
there is more work but at least there is something available for
admins to get started with.

Spencer


> 
> Trond
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com


