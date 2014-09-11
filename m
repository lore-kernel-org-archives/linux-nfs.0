Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:49376 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbaIKPi2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 11:38:28 -0400
Received: by mail-vc0-f179.google.com with SMTP id im17so6054159vcb.10
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 08:38:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140911152553.GD6690@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de>
	<1410362617-28018-9-git-send-email-hch@lst.de>
	<CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com>
	<20140911152553.GD6690@lst.de>
Date: Thu, 11 Sep 2014 11:38:24 -0400
Message-ID: <CAHQdGtT79qxn6ka4erSr3bxpZCr91+DVe6xtV6kMPD9QUDLL7w@mail.gmail.com>
Subject: Re: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Peng Tao <bergwolf@primarydata.com>, Boaz Harrosh <boaz@plexistor.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 11:25 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Thu, Sep 11, 2014 at 10:24:04PM +0800, Peng Tao wrote:
>> The reason I didn't add it was because PNFS_LAYOUTRET_ON_SETATTR is
>> too much for blocks layout. What we really want is to return layouts
>> on truncate and chown, instead of _all_ setattr requests.
>>
>> Boaz, does object layout require return on setattr for other reasons?
>> If not, I'd suggest we change PNFS_LAYOUTRET_ON_SETATTR to return only
>> on chown/truncate events.
>
> I was actually going to ask the same question, I can't see a point
> why the object layout driver would want it on any other setattr.
>
> In fact it could probably be narrowed down to chown or truncate to a smaller
> size.
>
> I'd also love to know why we don't want to do this for the filelayout driver.
>

Why would it be needed? The layout isn't expected to change. If the
chown affects permissions then it is up to the DS to enforce that
(although POSIX does not require it to do that).

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
