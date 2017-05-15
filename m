Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935069AbdEOQCy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 12:02:54 -0400
Date: Mon, 15 May 2017 12:02:48 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170515160248.GD9697@parsley.fieldses.org>
References: <20170512132721.GA654@stefanha-x1.localdomain>
 <20170512143410.GC17983@parsley.fieldses.org>
 <1494601295.10434.1.camel@primarydata.com>
 <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
 <20170515144306.GB16013@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170515144306.GB16013@stefanha-x1.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 15, 2017 at 03:43:06PM +0100, Stefan Hajnoczi wrote:
> On Fri, May 12, 2017 at 01:00:47PM -0400, Chuck Lever wrote:
> > 
> > > On May 12, 2017, at 11:01 AM, Trond Myklebust <trondmy@primarydata.com> wrote:
> > > Actually, this might be a use case for re-exporting NFS. If the host
> > > could re-export a NFS mount to the guests, then you don't necessarily
> > > need a clustered filesystem.
> > > 
> > > OTOH, this would not solve the problem of migrating locks, which is not
> > > really easy to support in the current state model for NFSv4.x.
> > 
> > Some alternatives:
> > 
> > - Make the local NFS server's exports read-only, NFSv3
> >   only, and do not support locking. Ensure that the
> >   filehandles and namespace are the same on every NFS
> >   server.
> > 
> > - As Trond suggested, all the local NFS servers accessed
> >   via AF_SOCK should re-export NFS filesystems that
> >   are located elsewhere and are visible everywhere.
> > 
> > - Ensure there is an accompanying NFSv4 FS migration event
> >   that moves the client's files (and possibly its open and
> >   lock state) from the local NFS server to the destination
> >   NFS server concurrent with the live migration.
> > 
> >   If the client is aware of the FS migration, it will expect
> >   the filehandles to be the same, but it can reconstruct
> >   the open and lock state on the destination server (if that
> >   server allows GRACEful recovery for that client).
> > 
> >   This is possible in the protocol and implemented in the
> >   Linux NFS client, but none of it is implemented in the
> >   Linux NFS server.
> 
> Great, thanks for the pointers everyone.
> 
> It's clear to me that AF_VSOCK won't get NFS migration for free.
> Initially live migration will not be supported.
> 
> Re-exporting sounds interesting - perhaps the new host could re-export
> the old host's file systems.  I'll look into the spec and code.

I've since forgotten the limitations of the nfs reexport series.

Locking (lock recovery, specifically) seems like the biggest problem to
solve to improve clustered nfs service; without that, it might actually
be easier than reexporting, I don't know.  If there's a use case for
clustered nfs service that doesn't support file locking, maybe we should
look into it.

--b.
