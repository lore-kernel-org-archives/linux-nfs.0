Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:52907 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091AbaIKPgd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 11:36:33 -0400
Date: Thu, 11 Sep 2014 17:36:31 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/9] pnfs: add return_range method
Message-ID: <20140911153631.GA8039@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-4-git-send-email-hch@lst.de> <CAKVebiVvenTsjwBTB1=-HO1w5=7WEKEpj6hQkQP9XQJcuWMgag@mail.gmail.com> <20140911152058.GA6690@lst.de> <CAKVebiXPaxN5hayCYAdd22vThFk=c+Vf0nHmWAnNssMQzyiLPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiXPaxN5hayCYAdd22vThFk=c+Vf0nHmWAnNssMQzyiLPw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 11:30:50PM +0800, Peng Tao wrote:
> It looks dangerous to have extents lurking around without matching
> layout segments. One example is NFS4ERR_EXPIRED and
> NFS4ERR_BAD_STATEID in nfs4_layoutget_done(), client needs to drop all
> layout segments but may keep the layout header, in which case blocks
> layout would still hold all extents at hand.

We never do I/O without a valid layout, but we keep the extents around
because we need to keep state like that it's been written to or has
a commit pending in a single place, and also need to keep it if a layout
goes away temporarily.

I hate the way it has been done in the old client, and tried moving the
extent tracking to a per-layout basis, and spent way too much time on it
but still couldn't get it to work, so I finally gave up.  I think we're
between a rock (the idiocy on rfc5663 that it tracks data in extents and not
in layouts) and a hard place (the forgetful Linux client and it's lose layout
coherency) here.
