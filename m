Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:60872 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbaIKQOv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 12:14:51 -0400
Received: by mail-vc0-f170.google.com with SMTP id hy4so5817187vcb.1
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 09:14:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140911154834.GA9280@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de>
	<1410362617-28018-9-git-send-email-hch@lst.de>
	<CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com>
	<20140911152553.GD6690@lst.de>
	<CAHQdGtT79qxn6ka4erSr3bxpZCr91+DVe6xtV6kMPD9QUDLL7w@mail.gmail.com>
	<20140911154834.GA9280@lst.de>
Date: Thu, 11 Sep 2014 12:14:50 -0400
Message-ID: <CAHQdGtR9gVaw7wG0R6JfXHb8W+M3LnqXcwWyuCXe4=oNbXFGMA@mail.gmail.com>
Subject: Re: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Peng Tao <bergwolf@primarydata.com>, Boaz Harrosh <boaz@plexistor.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 11:48 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Thu, Sep 11, 2014 at 11:38:24AM -0400, Trond Myklebust wrote:
>> Why would it be needed? The layout isn't expected to change. If the
>> chown affects permissions then it is up to the DS to enforce that
>> (although POSIX does not require it to do that).
>
> I was wondering about the truncate case.  Even if the DS needs to be
> able to enforce the new size it seems pointless to keep a layout beyond the
> size around.

In the files layout case, it is actually quite common for the server
to hand out an "infinite" sized layout in response to a LAYOUTGET. It
means that the client doesn't need to ask for a new layout in order to
append to the file.

> I don't really see a need to drop on a chown for the blocklayout or
> objlayout drivers either, given that these semantics are enforced at a higher
> level.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
