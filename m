Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:40869 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932933AbaHYOnn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2014 10:43:43 -0400
Date: Mon, 25 Aug 2014 16:43:40 +0200
From: Christoph Hellwig <hch@lst.de>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 16/19] pnfs/blocklayout: rewrite extent tracking
Message-ID: <20140825144340.GA16701@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-17-git-send-email-hch@lst.de> <53FB49D9.1060803@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53FB49D9.1060803@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 25, 2014 at 10:36:09AM -0400, Anna Schumaker wrote:
> Whoa, I like the amount of code you manage to remove in this patch!  However, there is a lot going on here.  Any way this patch could be split into incremental changes?  (it's okay to say "no"!)

The answer really is no - it's a wholesale replacement of three tracking
structures with an integrated one that is managed very differently.  The only
thing I had split out ealier where various trivial bug fixes like sector
truncations in code that gets ripped out entirely later, so I decided to
fold those again, which didn't increase the patch size by more than 10 lines.

