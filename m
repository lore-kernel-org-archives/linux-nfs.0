Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36050 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133Ab2GKR1Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jul 2012 13:27:16 -0400
Date: Wed, 11 Jul 2012 13:27:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Simo Sorce <simo@redhat.com>, "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120711172714.GA13610@fieldses.org>
References: <1337983796-26476-1-git-send-email-simo@redhat.com>
 <20120710204913.GA6038@fieldses.org>
 <1341957169.17428.4.camel@lade.trondhjem.org>
 <20120710215618.GC6038@fieldses.org>
 <1341958332.17428.12.camel@lade.trondhjem.org>
 <1341959112.17428.19.camel@lade.trondhjem.org>
 <20120710223818.GA6720@fieldses.org>
 <1341961118.17428.29.camel@lade.trondhjem.org>
 <20120711170331.GE11432@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120711170331.GE11432@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 11, 2012 at 01:03:32PM -0400, J. Bruce Fields wrote:
> On Tue, Jul 10, 2012 at 10:58:40PM +0000, Myklebust, Trond wrote:
> > All the documentation in the patches was appearing to imply that it
> > affected only nfsd with filenames such as
> > "Documentation/filesystems/nfs/knfsd-rpcgss.txt".and patch changelogs
> > with titles such as "SUNRPC: Use gssproxy upcall for nfsd's RPCGSS
> > authentication."
> 
> Fixed locally (and pushed out temporarily to for-3.6-incoming branch at
> git://linux-nfs.org/~bfields/linux-topics.git).  Thanks for catching
> that.
> 
> > > > > How will it behave if I don't run gss proxy?
> > > 
> > > It will work, but if the server's running on the same machine it will
> > > also use svcgssd, and hence won't (for example) be able to handle the
> > > larger init_sec_context packets.
> > 
> > An NFS client callback server is only trying to check that it is talking
> > to a machine credential with a name of the form nfs@hostname. It doesn't
> > care about PAGs, and anyone who tries to set the machine cred up with
> > one is clearly insane anyway...
> 
> Yes.  I don't know enough to say that a larger init_sec_context call
> could never be required for some other reason--but it sounds unlikely.
> 
> Anyway: I was hoping that the old upcall mechanism could be declared a
> legacy thing--no new features, bugfixes only for regressions, etc.--and
> possibly be removed after a long transition period.
> 
> If it's a requirement that the client never use the gssproxy mechanism,
> even on the 4.0 backchannel, then that requires committing to develop
> both.  I don't think that makes sense.

So, if the issue is: you want to be able to choose, in individual
containers, which mechanism to use: whatever, we can probably make that
work.

If you're instead saying: it's not acceptable to use the gssproxy
mechanism to authenticate v4.0 callbacks, the client must only ever use
the existing mechanism: then I'd rather drop this entirely.  I don't
want to merge an rpc server authentication upcall that's not acceptable
for one of the rpc servers.

--b.
