Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47817 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752791Ab2CWQAG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Mar 2012 12:00:06 -0400
Date: Fri, 23 Mar 2012 12:00:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v10 3/8] sunrpc: create nfsd dir in rpc_pipefs
Message-ID: <20120323160003.GA5675@fieldses.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
 <1332337929-18580-4-git-send-email-jlayton@redhat.com>
 <20120323121208.GA3219@fieldses.org>
 <20120323133111.GA2991@fieldses.org>
 <1332516024.3087.1.camel@lade.trondhjem.org>
 <20120323152220.GA4953@fieldses.org>
 <1332516863.3087.10.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1332516863.3087.10.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 23, 2012 at 03:34:21PM +0000, Myklebust, Trond wrote:
> On Fri, 2012-03-23 at 11:22 -0400, J. Bruce Fields wrote:
> > On Fri, Mar 23, 2012 at 03:20:21PM +0000, Myklebust, Trond wrote:
> > > On Fri, 2012-03-23 at 09:31 -0400, J. Bruce Fields wrote:
> > > > On Fri, Mar 23, 2012 at 08:12:08AM -0400, J. Bruce Fields wrote:
> > > > > On Wed, Mar 21, 2012 at 09:52:04AM -0400, Jeff Layton wrote:
> > > > > > Add a new top-level dir in rpc_pipefs to hold the pipe for the clientid
> > > > > > upcall.
> > > > > 
> > > > > After applying this patch, my tests consistently hang.  The hang happens
> > > > > in excltest (of the special connectaton tests), over nfs4.1 and krb5.
> > > > > Looking at the wire traffic, I'm seeing DELAY returned from a setattr
> > > > > for mode on a newly-created (with EXCLUSIVE4_1) file.  That open got a
> > > > > delegation, so presumably that's what's causing the DELAY, though I'm
> > > > > not seeing the server send a recall.  That could be a krb5 bug.
> > > > > 
> > > > > Whatever bug there is here, it's hard to tell why this patch in
> > > > > particular would make it more likely.
> > > > > 
> > > > > So, still investigating!
> > > > 
> > > > Reproduceable by:
> > > > 
> > > > 	mount -osec=krb5,minorversion=1 server:/export/ /mnt/
> > > > 	cp cthon04/special/excltest /mnt/
> > > > 	cd /mnt
> > > > 	./excltest
> > > 
> > > Umm... When would you ever get a DELAY in the above scenario? I can see
> > > getting an NFS4ERR_OPENMODE, but not DELAY.
> > 
> > There's a setattr for mode right after the open.  Is that unexpected?
> 
> Well yes, it is. The NFSv4.1 exclusive open should always be sending a
> full set of attributes as part of the OPEN operation. The session replay
> cache is now supposed to guarantee the only-once semantics that the
> verifier used to provide.

Looking at the trace.... The client is passing a zero attribute set on
the EXCLUSIVE4_1 open.

Hm, I wonder if our support for suppattr_exclreat has a bug.  On a quick
check, the code looks like it should do the right thing.

> > The server doesn't really have to recall the delegation in that case (it
> > only needs to recall *other* clients' delegations) but I don't think
> > it's wrong to.
> 
> Then why isn't it allowing the operation?  Any sane client would normally
> interpret NFS4ERR_DELAY to mean that the server is doing something to
> fix whatever situation is preventing the operation from completing
> (presumably by recalling delegations in this case). Just replying DELAY
> and doing nothing is not helpful...

Yes, there's a backchannel bug of some kind.

Actually I doubt the server's 4.1 krb5 implementation handles the
backchannel correctly at all.

--b.
