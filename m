Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:59182 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbbAGK2G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2015 05:28:06 -0500
Date: Wed, 7 Jan 2015 11:28:02 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: [PATCH 14/18] nfsd: pNFS block layout driver
Message-ID: <20150107102802.GA28783@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-15-git-send-email-hch@lst.de> <20150106171658.GD12067@fieldses.org> <20150106173957.GA16200@lst.de> <20150106193949.GD28003@fieldses.org> <20150106114205.4151269c@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150106114205.4151269c@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 11:42:05AM -0800, Jeff Layton wrote:
> Or maybe an "on" switch?
> 
> We have some patches (not posted currently) that add a "pnfs" export
> option. Maybe we should add that and only enable pnfs on exports that
> have that option present?

I would defintively prefer the off switch.  I can add one if people want
it, but export options are a little annoying as they require support
not only in the kernel but also in nfs-utils.
