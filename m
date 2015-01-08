Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37247 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020AbbAHUyW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2015 15:54:22 -0500
Date: Thu, 8 Jan 2015 15:54:20 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 14/18] nfsd: pNFS block layout driver
Message-ID: <20150108205420.GF14674@fieldses.org>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <1420561721-9150-15-git-send-email-hch@lst.de>
 <20150106171658.GD12067@fieldses.org>
 <20150106173957.GA16200@lst.de>
 <20150106193949.GD28003@fieldses.org>
 <20150106114205.4151269c@synchrony.poochiereds.net>
 <20150107102802.GA28783@lst.de>
 <20150108124131.4dc27026@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150108124131.4dc27026@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2015 at 12:41:31PM -0800, Jeff Layton wrote:
> On Wed, 7 Jan 2015 11:28:02 +0100
> Christoph Hellwig <hch@lst.de> wrote:
> 
> > On Tue, Jan 06, 2015 at 11:42:05AM -0800, Jeff Layton wrote:
> > > Or maybe an "on" switch?
> > > 
> > > We have some patches (not posted currently) that add a "pnfs" export
> > > option. Maybe we should add that and only enable pnfs on exports that
> > > have that option present?
> > 
> > I would defintively prefer the off switch.  I can add one if people want
> > it, but export options are a little annoying as they require support
> > not only in the kernel but also in nfs-utils.
> 
> True, it is a pain, but I think it's realistic to expect someone who
> wants to do pnfs to have an updated nfs-utils. It wouldn't take too
> long for it to trickle out to the various distros and adding new export
> options is fairly simple to do.
> 
> If we do want to go that route, it might be nice to do the option with
> a list of layout types. For example:
> 
>     pnfs=block:file:flexfiles
> 
> ...so we could potentially support more than one layout type per
> export.

I like the goal of making this as close to zero-configuration as
possible, and I'd rather wait for a demonstrated need till we add
per-export or multiple-layout-type configuration.  A global off switch
sounds OK to me.

--b.
