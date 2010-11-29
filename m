Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52685 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750998Ab0K2TBY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 14:01:24 -0500
Date: Mon, 29 Nov 2010 14:01:22 -0500
To: Spelic <spelic@shiftmail.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 behaviour on unknown users
Message-ID: <20101129190122.GA31843@fieldses.org>
References: <4CF3ED05.3070401@shiftmail.org>
 <1291054975.12784.17.camel@heimdal.trondhjem.org>
 <4CF3F326.4060608@shiftmail.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CF3F326.4060608@shiftmail.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Nov 29, 2010 at 07:38:30PM +0100, Spelic wrote:
> On 11/29/2010 07:22 PM, Trond Myklebust wrote:
> >On Mon, 2010-11-29 at 19:12 +0100, Spelic wrote:
> >No. That is not allowed by the spec.
> >
> >Trond
> 
> Too bad!! :-((
> Was that spec decision really wise? :-/
> 
> 
> BTW:
> I've just noticed two discussions dated a few months ago in this ML
> regarding this.
> the thread named 'numeric UIDs'

There's also a reference to the spec language there--we'd be violating a
"SHOULD", but I think it would be acceptable if it smooths the v3->v4
upgrade path for users in your situation.

I think steved's changes still need to be ported to libnfsidmap?

--b.

> and more interestingly the thread: "Teach clients to map numeric
> strings into valid uids and gids."
> http://marc.info/?t=128207393000001&r=1&w=2
> 
> Would the patch by Steve Dickson allow us to have numeric UID
> mapping like in NFSv3?
> (Including ability for a non-squashed-root to do chown towards an
> UID which is unknown at server side)
> 
> And if yes, how come this is not against the specs?
> 
> Thank you
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
