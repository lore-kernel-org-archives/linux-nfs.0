Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64710 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab0K3Wdj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 17:33:39 -0500
Subject: Re: NFSv4 behaviour on unknown users
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, Spelic <spelic@shiftmail.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <20101130222651.GB5054@fieldses.org>
References: <4CF3ED05.3070401@shiftmail.org>
	 <1291054975.12784.17.camel@heimdal.trondhjem.org>
	 <4CF3F326.4060608@shiftmail.org> <20101129190122.GA31843@fieldses.org>
	 <1291057747.12784.38.camel@heimdal.trondhjem.org>
	 <4CF519F2.8080900@RedHat.com>
	 <1291155578.2998.38.camel@heimdal.trondhjem.org>
	 <20101130222651.GB5054@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Nov 2010 17:33:34 -0500
Message-ID: <1291156414.4393.2.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-11-30 at 17:26 -0500, J. Bruce Fields wrote:
> On Tue, Nov 30, 2010 at 05:19:38PM -0500, Trond Myklebust wrote:
> > On Tue, 2010-11-30 at 10:36 -0500, Steve Dickson wrote:
> > > 
> > > On 11/29/2010 02:09 PM, Trond Myklebust wrote:
> > > > On Mon, 2010-11-29 at 14:01 -0500, J. Bruce Fields wrote:
> > > >> On Mon, Nov 29, 2010 at 07:38:30PM +0100, Spelic wrote:
> > > >>> On 11/29/2010 07:22 PM, Trond Myklebust wrote:
> > > >>>> On Mon, 2010-11-29 at 19:12 +0100, Spelic wrote:
> > > >>>> No. That is not allowed by the spec.
> > > >>>>
> > > >>>> Trond
> > > >>>
> > > >>> Too bad!! :-((
> > > >>> Was that spec decision really wise? :-/
> > > >>>
> > > >>>
> > > >>> BTW:
> > > >>> I've just noticed two discussions dated a few months ago in this ML
> > > >>> regarding this.
> > > >>> the thread named 'numeric UIDs'
> > > >>
> > > >> There's also a reference to the spec language there--we'd be violating a
> > > >> "SHOULD", but I think it would be acceptable if it smooths the v3->v4
> > > >> upgrade path for users in your situation.
> > > >>
> > > >> I think steved's changes still need to be ported to libnfsidmap?
> > > > 
> > > > I don't see how steved's changes will fix this problem. If the client
> > > > has a mapping, it will (MUST) send the mapped uid/gid and the server
> > > > still has to make sense of that. Ditto if the server has a mapping, and
> > > > the client does not.
> > > I actually thought it did... 
> > 
> > How? The userland library has no concept of whether or not the server
> > accepts unmapped uids and gids.
> > 
> > > Now that the libnfsidmap maintainership has been handed over to me 
> > > and I'm about to enable the new nfsidmapper when I commit the 
> > > "libnfsidmap: Add numerical string translation" patch... Its 
> > > probably time I take a second look at those patches to see
> > > if we can ease some of this pain...
> > 
> > Some reasons for doing this in the kernel are:
> > 
> > 1) it is easy to do so.
> > 2) it allows the kernel to take action to recover
> > 3) it fixes the nfsroot problem, provided that the server also sends
> > uids/gids in this situation.
> 
> Makes sense to me.
> 
> The server side might still be easiest to do in idmapd/libnfsidmap.

The NFS server has to be able to tell the idmapper which variety of
mapping it wants. The reason is, as I said, that we want to handle
RPCSEC_GSS based authentication (and possibly AUTH_NULL too) differently
from AUTH_SYS. The idmapper by itself has no way to distinguish what
authentication the client used.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

