Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:48076 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbaINNYR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Sep 2014 09:24:17 -0400
Received: by mail-ie0-f172.google.com with SMTP id tr6so3263685ieb.31
        for <linux-nfs@vger.kernel.org>; Sun, 14 Sep 2014 06:24:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5415740E.6030202@gmail.com>
References: <1410362617-28018-1-git-send-email-hch@lst.de>
	<1410362617-28018-9-git-send-email-hch@lst.de>
	<CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com>
	<20140911152553.GD6690@lst.de>
	<CAHQdGtT79qxn6ka4erSr3bxpZCr91+DVe6xtV6kMPD9QUDLL7w@mail.gmail.com>
	<20140911154834.GA9280@lst.de>
	<CAHQdGtR9gVaw7wG0R6JfXHb8W+M3LnqXcwWyuCXe4=oNbXFGMA@mail.gmail.com>
	<5415740E.6030202@gmail.com>
Date: Sun, 14 Sep 2014 09:24:17 -0400
Message-ID: <CAABAsM4sAecHt291APP6AZ9e5QvNCRK74WFF-tyje50CNCcY1g@mail.gmail.com>
Subject: Re: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, Peng Tao <bergwolf@primarydata.com>,
        Boaz Harrosh <boaz@plexistor.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 14, 2014 at 6:55 AM, Boaz Harrosh <openosd@gmail.com> wrote:
> On 09/11/2014 07:14 PM, Trond Myklebust wrote:
> <>
>> In the files layout case, it is actually quite common for the server
>> to hand out an "infinite" sized layout in response to a LAYOUTGET. It
>> means that the client doesn't need to ask for a new layout in order to
>> append to the file.
>>
>
> You mean to say that: "The Linux files-layout driver only supports infinite
>  sized layout, so it is pointless to return a layout which will be returned
>  again, exactly the same"
>
> Because I agree that "an infinite sized layout" need not be returned but
> an none-infinite should, only we do not have any.
>

No Boaz. I mean that it is utterly pointless and stupid to return a
layout that doesn't preallocate any resources when it isn't necessary
to do so.
