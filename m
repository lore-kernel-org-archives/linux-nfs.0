Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f44.google.com ([209.85.220.44]:56538 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbaINKzO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Sep 2014 06:55:14 -0400
Received: by mail-pa0-f44.google.com with SMTP id kx10so4572870pab.31
        for <linux-nfs@vger.kernel.org>; Sun, 14 Sep 2014 03:55:14 -0700 (PDT)
Message-ID: <5415740E.6030202@gmail.com>
Date: Sun, 14 Sep 2014 13:55:10 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@lst.de>
CC: Peng Tao <bergwolf@primarydata.com>, Boaz Harrosh <boaz@plexistor.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
References: <1410362617-28018-1-git-send-email-hch@lst.de>	<1410362617-28018-9-git-send-email-hch@lst.de>	<CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com>	<20140911152553.GD6690@lst.de>	<CAHQdGtT79qxn6ka4erSr3bxpZCr91+DVe6xtV6kMPD9QUDLL7w@mail.gmail.com>	<20140911154834.GA9280@lst.de> <CAHQdGtR9gVaw7wG0R6JfXHb8W+M3LnqXcwWyuCXe4=oNbXFGMA@mail.gmail.com>
In-Reply-To: <CAHQdGtR9gVaw7wG0R6JfXHb8W+M3LnqXcwWyuCXe4=oNbXFGMA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/11/2014 07:14 PM, Trond Myklebust wrote:
<>
> In the files layout case, it is actually quite common for the server
> to hand out an "infinite" sized layout in response to a LAYOUTGET. It
> means that the client doesn't need to ask for a new layout in order to
> append to the file.
> 

You mean to say that: "The Linux files-layout driver only supports infinite
 sized layout, so it is pointless to return a layout which will be returned
 again, exactly the same"

Because I agree that "an infinite sized layout" need not be returned but
an none-infinite should, only we do not have any.

Cheers
Boaz

