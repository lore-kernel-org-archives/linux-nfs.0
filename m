Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35202 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbaILCWc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 22:22:32 -0400
Received: by mail-qg0-f41.google.com with SMTP id a108so95010qge.0
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 19:22:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140911153631.GA8039@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-4-git-send-email-hch@lst.de>
 <CAKVebiVvenTsjwBTB1=-HO1w5=7WEKEpj6hQkQP9XQJcuWMgag@mail.gmail.com>
 <20140911152058.GA6690@lst.de> <CAKVebiXPaxN5hayCYAdd22vThFk=c+Vf0nHmWAnNssMQzyiLPw@mail.gmail.com>
 <20140911153631.GA8039@lst.de>
From: Peng Tao <bergwolf@primarydata.com>
Date: Fri, 12 Sep 2014 10:22:11 +0800
Message-ID: <CAKVebiX9S1zHVxNNnBguD8BKqyJJVOm3n+XJUhAxcM+8FD5dgg@mail.gmail.com>
Subject: Re: [PATCH 3/9] pnfs: add return_range method
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 11:36 PM, Christoph Hellwig <hch@lst.de> wrote:
> On Thu, Sep 11, 2014 at 11:30:50PM +0800, Peng Tao wrote:
>> It looks dangerous to have extents lurking around without matching
>> layout segments. One example is NFS4ERR_EXPIRED and
>> NFS4ERR_BAD_STATEID in nfs4_layoutget_done(), client needs to drop all
>> layout segments but may keep the layout header, in which case blocks
>> layout would still hold all extents at hand.
>
> We never do I/O without a valid layout, but we keep the extents around
> because we need to keep state like that it's been written to or has
> a commit pending in a single place, and also need to keep it if a layout
> goes away temporarily.
We don't know if layout goes away temporarily or permanently. If
server happens to move the file's data (enterprise NAS does that for a
lot of reasons) in between, next time client does layoutget, it will
get a different extent mapping. I'm not sure if the new extent
tracking code is able to cope with it. The old code will certainly
fail though.

If your concern is current layoutreturn implementation that ignores
pending layoutcommit (and inflight IOs), that needs to be fixed. I
have a patchset to fix it and it is still under internal QA. I'll post
it once it passes testing.
