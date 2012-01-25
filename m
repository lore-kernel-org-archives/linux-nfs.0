Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52464 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752396Ab2AYPWD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 10:22:03 -0500
Date: Wed, 25 Jan 2012 10:22:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. von Balzac" <jhm.balzac@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 - Linux server, FreeBSD client
Message-ID: <20120125152202.GD17873@fieldses.org>
References: <CAG+vHK+OUSdEc5L=_oeq4Y9iwseusspPTG=jwUvoOQd5587O9Q@mail.gmail.com>
 <20120125143449.GB17873@fieldses.org>
 <4F201D30.8010606@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F201D30.8010606@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2012 at 05:18:08PM +0200, Boaz Harrosh wrote:
> On 01/25/2012 04:34 PM, J. Bruce Fields wrote:
> > Also, "fsid=0" tricks aren't necessary any more: if you just leave out
> > that line, then v4 clients will be able to mount /exp/freebsd/* just as
> > v2/v3 clients would.
> > 
> 
> I suspected this, but have been using fsid=0 since forever and the :/ mounts.
> I'll check it out
> 
> I know it's not your expertise, but is it also true for pnfs. (Benny's tree)
> Or like before pnfs export must have the fsid=0 set?

I'd expect it to work fine without.

> What about multiple SBs / FSs exporting pnfs should that work? I guess I should
> try it.

I'd call it a bug if it doesn't.

--b.
