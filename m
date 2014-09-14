Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f54.google.com ([209.85.220.54]:53929 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbaINNvr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Sep 2014 09:51:47 -0400
Received: by mail-pa0-f54.google.com with SMTP id lj1so4678834pab.13
        for <linux-nfs@vger.kernel.org>; Sun, 14 Sep 2014 06:51:47 -0700 (PDT)
Message-ID: <54159D6E.7010507@plexistor.com>
Date: Sun, 14 Sep 2014 16:51:42 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Boaz Harrosh <openosd@gmail.com>
CC: Christoph Hellwig <hch@lst.de>, Peng Tao <bergwolf@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
References: <1410362617-28018-1-git-send-email-hch@lst.de>	<1410362617-28018-9-git-send-email-hch@lst.de>	<CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com>	<20140911152553.GD6690@lst.de>	<CAHQdGtT79qxn6ka4erSr3bxpZCr91+DVe6xtV6kMPD9QUDLL7w@mail.gmail.com>	<20140911154834.GA9280@lst.de>	<CAHQdGtR9gVaw7wG0R6JfXHb8W+M3LnqXcwWyuCXe4=oNbXFGMA@mail.gmail.com>	<5415740E.6030202@gmail.com> <CAABAsM4sAecHt291APP6AZ9e5QvNCRK74WFF-tyje50CNCcY1g@mail.gmail.com>
In-Reply-To: <CAABAsM4sAecHt291APP6AZ9e5QvNCRK74WFF-tyje50CNCcY1g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/14/2014 04:24 PM, Trond Myklebust wrote:
> On Sun, Sep 14, 2014 at 6:55 AM, Boaz Harrosh <openosd@gmail.com> wrote:
<>
> 
> No Boaz. I mean that it is utterly pointless and stupid to return a
> layout that doesn't preallocate any resources when it isn't necessary
> to do so.
> 

"preallocate any resources" where? at the client it might not but the server
might have allocated resources per lo-segment.
For example a CEPH server allocates a device_id per file-lo-segment. If you
lo_return a truncated segment it might be able to free that device_id.

Cheers
Boaz

