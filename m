Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60070 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753626Ab1HCWXY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2011 18:23:24 -0400
Date: Thu, 4 Aug 2011 08:23:11 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Venkateswararao Jujjuri" <jvrao@linux.vnet.ibm.com>,
        "Chuck Lever" <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>
Subject: Re: State of NFSv4 VolatileFilehandles
Message-ID: <20110804082311.21b7e73a@notabene.brown>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778B9B@SACMVEXC2-PRD.hq.netapp.com>
References: <4E37E66D.90102@linux.vnet.ibm.com>
	<45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
	<4E38F894.4070003@linux.vnet.ibm.com>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778B9B@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 3 Aug 2011 05:27:26 -0700 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> > >> - Any discussion/sugestions on the way to implement VFH?  As
> > described in RFC 3530 sections 4.2.3 and 4.2.4?
> > > I think we are avoiding volatile file handles as long as possible.
> > We don't have plans to implement them at the moment.
> > Hrm. How can we achieve the complete migration support without
> volatile
> > filehandle support?
> > What are the reasons for avoiding it? May be we can start looking into
> > this but would like to understand
> > the reasons (if any) for avoiding it.
> 
> POSIX allows the namespace to change at any time (rename() or unlink())
> and so you cannot rely on addressing files by pathname. That was the
> whole reason for introducing filehandles into NFSv2 in the first place.
> 
> Volatile filehandles were introduced in NFSv4 without any attempt to fix
> those shortcomings. There is no real prescription for how to recover in
> a situation where a rename or unlink has occurred prior to the
> filehandle expiring. Nor is there a reliable prescription for dealing
> with the case where a new file of the same name has replaced the
> original.
> Basically, the implication is that volatile filehandles are only really
> usable in a situation where the whole Filesystem is read-only on the
> server.

I substantially agree, though I think the implication can be refined a little.

I would say that the implication is that a VFH is only really usable when the
complete path leading to the file in question is read-only.   We don't need
to assume that other files in other parts of the hierarchy which have stable
file handles are read-only.

So if the server presents us with a VFH, it seems reasonable to assume that
we can use a repeated lookup of the same name to refresh the filehandle
simply because there is no other credible way to respond to a FHEXPIRED.

So while the spec doesn't explicitly say that an expired VFH can be expected
to never be renamed, it does - as you say - strongly imply that so it seems
reasonable to proceed with implementation on that basis...

Is that convincing?

NeilBrown
