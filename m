Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56745 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933024Ab2GKRDf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jul 2012 13:03:35 -0400
Date: Wed, 11 Jul 2012 13:03:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Simo Sorce <simo@redhat.com>, "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120711170331.GE11432@fieldses.org>
References: <1337983796-26476-1-git-send-email-simo@redhat.com>
 <20120710204913.GA6038@fieldses.org>
 <1341957169.17428.4.camel@lade.trondhjem.org>
 <20120710215618.GC6038@fieldses.org>
 <1341958332.17428.12.camel@lade.trondhjem.org>
 <1341959112.17428.19.camel@lade.trondhjem.org>
 <20120710223818.GA6720@fieldses.org>
 <1341961118.17428.29.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1341961118.17428.29.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 10, 2012 at 10:58:40PM +0000, Myklebust, Trond wrote:
> All the documentation in the patches was appearing to imply that it
> affected only nfsd with filenames such as
> "Documentation/filesystems/nfs/knfsd-rpcgss.txt".and patch changelogs
> with titles such as "SUNRPC: Use gssproxy upcall for nfsd's RPCGSS
> authentication."

Fixed locally (and pushed out temporarily to for-3.6-incoming branch at
git://linux-nfs.org/~bfields/linux-topics.git).  Thanks for catching
that.

> > > > How will it behave if I don't run gss proxy?
> > 
> > It will work, but if the server's running on the same machine it will
> > also use svcgssd, and hence won't (for example) be able to handle the
> > larger init_sec_context packets.
> 
> An NFS client callback server is only trying to check that it is talking
> to a machine credential with a name of the form nfs@hostname. It doesn't
> care about PAGs, and anyone who tries to set the machine cred up with
> one is clearly insane anyway...

Yes.  I don't know enough to say that a larger init_sec_context call
could never be required for some other reason--but it sounds unlikely.

Anyway: I was hoping that the old upcall mechanism could be declared a
legacy thing--no new features, bugfixes only for regressions, etc.--and
possibly be removed after a long transition period.

If it's a requirement that the client never use the gssproxy mechanism,
even on the 4.0 backchannel, then that requires committing to develop
both.  I don't think that makes sense.

Given that, the containerization issues seem irrelevant, but:

> > > ...and how will it behave in a net namespace?
> > 
> > It will need the same fixes as we need for rpcbind.
> 
> So basically, it will have to store the path at client creation time?

I think that's right.

> > I'm sure we could allow the callback server and the nfs server to use
> > different authentication upcalls.  But that makes this not worth it.
> 
> The point is that in a containerised environment, the NFS client may not
> know what protocol that an NFS server running in a completely different
> container is using.
> 
> > We should be able to share the same use the same mechanism on all rpc
> > servers, so if a mechanism based on gssproxy calls isn't acceptable for
> > the nfs callback server then I'll drop it.
> 
> I don't see how you can enforce that premise when using containers.

I don't believe there's a requirement that containers be able to use
different upcall mechanisms.  Are we allowing people to choose between
new and old client idmappers per container?

--b.
