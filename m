Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:52870 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776AbaIKPZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 11:25:55 -0400
Date: Thu, 11 Sep 2014 17:25:53 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, Boaz Harrosh <boaz@plexistor.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
Message-ID: <20140911152553.GD6690@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-9-git-send-email-hch@lst.de> <CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 10:24:04PM +0800, Peng Tao wrote:
> The reason I didn't add it was because PNFS_LAYOUTRET_ON_SETATTR is
> too much for blocks layout. What we really want is to return layouts
> on truncate and chown, instead of _all_ setattr requests.
> 
> Boaz, does object layout require return on setattr for other reasons?
> If not, I'd suggest we change PNFS_LAYOUTRET_ON_SETATTR to return only
> on chown/truncate events.

I was actually going to ask the same question, I can't see a point
why the object layout driver would want it on any other setattr.

In fact it could probably be narrowed down to chown or truncate to a smaller
size.

I'd also love to know why we don't want to do this for the filelayout driver.

