Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:58257 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752093AbaIMTi5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 13 Sep 2014 15:38:57 -0400
Date: Sat, 13 Sep 2014 21:38:54 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/9] pnfs: add return_range method
Message-ID: <20140913193854.GA31909@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-4-git-send-email-hch@lst.de> <CAKVebiVvenTsjwBTB1=-HO1w5=7WEKEpj6hQkQP9XQJcuWMgag@mail.gmail.com> <20140911152058.GA6690@lst.de> <CAKVebiXPaxN5hayCYAdd22vThFk=c+Vf0nHmWAnNssMQzyiLPw@mail.gmail.com> <20140911153631.GA8039@lst.de> <CAKVebiX9S1zHVxNNnBguD8BKqyJJVOm3n+XJUhAxcM+8FD5dgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiX9S1zHVxNNnBguD8BKqyJJVOm3n+XJUhAxcM+8FD5dgg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 12, 2014 at 10:22:11AM +0800, Peng Tao wrote:
> > We never do I/O without a valid layout, but we keep the extents around
> > because we need to keep state like that it's been written to or has
> > a commit pending in a single place, and also need to keep it if a layout
> > goes away temporarily.
> We don't know if layout goes away temporarily or permanently. If
> server happens to move the file's data (enterprise NAS does that for a
> lot of reasons) in between, next time client does layoutget, it will
> get a different extent mapping. I'm not sure if the new extent
> tracking code is able to cope with it. The old code will certainly
> fail though.

A server is expected to do a layout recall with the clora_changed set
to true if it moves data around and thus the layout goes away permanently.
The Linux client currently irgnores that field, but that's something which
needs to fixed in the core pnfs code and not the block layout drivers.

But this isn't one of the cases were we keep the extent around but
not the layout - those are the ones were we have stateid mismatches
or similar (most of them now fixed by me).

We actually have a much bigger elephant in the room, which this series
doesn't address yet:  if a layoutcommit fails we curently don't have
a way to resend the data to the MDS.  This will be more common pnfs core
work as we basically need to keep the data in a state similar to NFS
unstable writes, instead of claiming that we finished a NFS_FILE_SYNC,
which allows the VM to drop the data from the pagecache before the
commit happened.

I'm slowly wading through all these issues - I initially only planned to
write a server but so far fixing up the client has taken way more of my
time compared to the relatively trivial server..

> If your concern is current layoutreturn implementation that ignores
> pending layoutcommit (and inflight IOs), that needs to be fixed. I
> have a patchset to fix it and it is still under internal QA. I'll post
> it once it passes testing.

That's a different issues, but I'm happy to review that as well.
