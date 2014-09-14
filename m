Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34216 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbaINOQd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Sep 2014 10:16:33 -0400
Received: by mail-ig0-f170.google.com with SMTP id l13so1293726iga.3
        for <linux-nfs@vger.kernel.org>; Sun, 14 Sep 2014 07:16:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <54159D6E.7010507@plexistor.com>
References: <1410362617-28018-1-git-send-email-hch@lst.de>
	<1410362617-28018-9-git-send-email-hch@lst.de>
	<CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com>
	<20140911152553.GD6690@lst.de>
	<CAHQdGtT79qxn6ka4erSr3bxpZCr91+DVe6xtV6kMPD9QUDLL7w@mail.gmail.com>
	<20140911154834.GA9280@lst.de>
	<CAHQdGtR9gVaw7wG0R6JfXHb8W+M3LnqXcwWyuCXe4=oNbXFGMA@mail.gmail.com>
	<5415740E.6030202@gmail.com>
	<CAABAsM4sAecHt291APP6AZ9e5QvNCRK74WFF-tyje50CNCcY1g@mail.gmail.com>
	<54159D6E.7010507@plexistor.com>
Date: Sun, 14 Sep 2014 10:16:32 -0400
Message-ID: <CAABAsM4SxAXtBv=1XtUVyOa=jRYK9zTjYoYU9B_0ch9zmqFiaA@mail.gmail.com>
Subject: Re: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Boaz Harrosh <openosd@gmail.com>, Christoph Hellwig <hch@lst.de>,
        Peng Tao <bergwolf@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 14, 2014 at 9:51 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
> On 09/14/2014 04:24 PM, Trond Myklebust wrote:
>> On Sun, Sep 14, 2014 at 6:55 AM, Boaz Harrosh <openosd@gmail.com> wrote:
> <>
>>
>> No Boaz. I mean that it is utterly pointless and stupid to return a
>> layout that doesn't preallocate any resources when it isn't necessary
>> to do so.
>>
>
> "preallocate any resources" where? at the client it might not but the server
> might have allocated resources per lo-segment.
> For example a CEPH server allocates a device_id per file-lo-segment. If you
> lo_return a truncated segment it might be able to free that device_id.
>

There is no requirement anywhere in RFC5661 to state that a truncate
must be prefixed by a layout return. Not in section 12 (Parallel NFS)
nor in section 13 (NFSv4.1 as a Storage Protocol in pNFS: the File
Layout Type), nor in the ERRATA. Existing pNFS files servers (i.e.
NetApp) don't need it either.

If a future CEPH server wants to add its own requirements, then it is
free to issue a layoutrecall. However my understanding from
conversations with Matt (the Ganesha release notes appear to confirm)
was that the CRUSH algorithm is pretty much impossible to implement as
a files layout type, so I'm confused as to why it would be a problem
in the first place.
