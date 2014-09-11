Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:52946 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752218AbaIKPsh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 11:48:37 -0400
Date: Thu, 11 Sep 2014 17:48:34 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, Peng Tao <bergwolf@primarydata.com>,
        Boaz Harrosh <boaz@plexistor.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
Message-ID: <20140911154834.GA9280@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-9-git-send-email-hch@lst.de> <CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com> <20140911152553.GD6690@lst.de> <CAHQdGtT79qxn6ka4erSr3bxpZCr91+DVe6xtV6kMPD9QUDLL7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtT79qxn6ka4erSr3bxpZCr91+DVe6xtV6kMPD9QUDLL7w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 11:38:24AM -0400, Trond Myklebust wrote:
> Why would it be needed? The layout isn't expected to change. If the
> chown affects permissions then it is up to the DS to enforce that
> (although POSIX does not require it to do that).

I was wondering about the truncate case.  Even if the DS needs to be
able to enforce the new size it seems pointless to keep a layout beyond the
size around.

I don't really see a need to drop on a chown for the blocklayout or
objlayout drivers either, given that these semantics are enforced at a higher
level.
