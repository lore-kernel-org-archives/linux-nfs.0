Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:62320 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbbAHUlj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 15:41:39 -0500
Received: by mail-qg0-f52.google.com with SMTP id i50so4664800qgf.11
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 12:41:38 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 8 Jan 2015 12:41:31 -0800
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 14/18] nfsd: pNFS block layout driver
Message-ID: <20150108124131.4dc27026@synchrony.poochiereds.net>
In-Reply-To: <20150107102802.GA28783@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
	<1420561721-9150-15-git-send-email-hch@lst.de>
	<20150106171658.GD12067@fieldses.org>
	<20150106173957.GA16200@lst.de>
	<20150106193949.GD28003@fieldses.org>
	<20150106114205.4151269c@synchrony.poochiereds.net>
	<20150107102802.GA28783@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 7 Jan 2015 11:28:02 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Tue, Jan 06, 2015 at 11:42:05AM -0800, Jeff Layton wrote:
> > Or maybe an "on" switch?
> > 
> > We have some patches (not posted currently) that add a "pnfs" export
> > option. Maybe we should add that and only enable pnfs on exports that
> > have that option present?
> 
> I would defintively prefer the off switch.  I can add one if people want
> it, but export options are a little annoying as they require support
> not only in the kernel but also in nfs-utils.

True, it is a pain, but I think it's realistic to expect someone who
wants to do pnfs to have an updated nfs-utils. It wouldn't take too
long for it to trickle out to the various distros and adding new export
options is fairly simple to do.

If we do want to go that route, it might be nice to do the option with
a list of layout types. For example:

    pnfs=block:file:flexfiles

...so we could potentially support more than one layout type per
export.

-- 
Jeff Layton <jlayton@primarydata.com>
