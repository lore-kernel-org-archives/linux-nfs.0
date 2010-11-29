Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42938 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921Ab0K2TJf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 14:09:35 -0500
Subject: Re: NFSv4 behaviour on unknown users
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Spelic <spelic@shiftmail.org>, linux-nfs@vger.kernel.org
In-Reply-To: <20101129190122.GA31843@fieldses.org>
References: <4CF3ED05.3070401@shiftmail.org>
	 <1291054975.12784.17.camel@heimdal.trondhjem.org>
	 <4CF3F326.4060608@shiftmail.org>  <20101129190122.GA31843@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 29 Nov 2010 14:09:07 -0500
Message-ID: <1291057747.12784.38.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-11-29 at 14:01 -0500, J. Bruce Fields wrote:
> On Mon, Nov 29, 2010 at 07:38:30PM +0100, Spelic wrote:
> > On 11/29/2010 07:22 PM, Trond Myklebust wrote:
> > >On Mon, 2010-11-29 at 19:12 +0100, Spelic wrote:
> > >No. That is not allowed by the spec.
> > >
> > >Trond
> > 
> > Too bad!! :-((
> > Was that spec decision really wise? :-/
> > 
> > 
> > BTW:
> > I've just noticed two discussions dated a few months ago in this ML
> > regarding this.
> > the thread named 'numeric UIDs'
> 
> There's also a reference to the spec language there--we'd be violating a
> "SHOULD", but I think it would be acceptable if it smooths the v3->v4
> upgrade path for users in your situation.
> 
> I think steved's changes still need to be ported to libnfsidmap?

I don't see how steved's changes will fix this problem. If the client
has a mapping, it will (MUST) send the mapped uid/gid and the server
still has to make sense of that. Ditto if the server has a mapping, and
the client does not.

steved's patches only help if neither the client nor the server can map
the uid/gids to a name@domain format.

Trond

> --b.
> 
> > and more interestingly the thread: "Teach clients to map numeric
> > strings into valid uids and gids."
> > http://marc.info/?t=128207393000001&r=1&w=2
> > 
> > Would the patch by Steve Dickson allow us to have numeric UID
> > mapping like in NFSv3?
> > (Including ability for a non-squashed-root to do chown towards an
> > UID which is unknown at server side)
> > 
> > And if yes, how come this is not against the specs?
> > 
> > Thank you
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

