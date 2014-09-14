Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f176.google.com ([209.85.192.176]:48893 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbaINO2y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Sep 2014 10:28:54 -0400
Received: by mail-pd0-f176.google.com with SMTP id y13so4562338pdi.7
        for <linux-nfs@vger.kernel.org>; Sun, 14 Sep 2014 07:28:54 -0700 (PDT)
Message-ID: <5415A621.3020208@plexistor.com>
Date: Sun, 14 Sep 2014 17:28:49 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Boaz Harrosh <openosd@gmail.com>, Christoph Hellwig <hch@lst.de>,
        Peng Tao <bergwolf@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
References: <1410362617-28018-1-git-send-email-hch@lst.de>	<1410362617-28018-9-git-send-email-hch@lst.de>	<CAKVebiUqhCVy4jyzccBOXcHo3dkQNXjF0WsP1sHkOMkdnEAG9Q@mail.gmail.com>	<20140911152553.GD6690@lst.de>	<CAHQdGtT79qxn6ka4erSr3bxpZCr91+DVe6xtV6kMPD9QUDLL7w@mail.gmail.com>	<20140911154834.GA9280@lst.de>	<CAHQdGtR9gVaw7wG0R6JfXHb8W+M3LnqXcwWyuCXe4=oNbXFGMA@mail.gmail.com>	<5415740E.6030202@gmail.com>	<CAABAsM4sAecHt291APP6AZ9e5QvNCRK74WFF-tyje50CNCcY1g@mail.gmail.com>	<54159D6E.7010507@plexistor.com> <CAABAsM4SxAXtBv=1XtUVyOa=jRYK9zTjYoYU9B_0ch9zmqFiaA@mail.gmail.com>
In-Reply-To: <CAABAsM4SxAXtBv=1XtUVyOa=jRYK9zTjYoYU9B_0ch9zmqFiaA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/14/2014 05:16 PM, Trond Myklebust wrote:
<>
> 
> There is no requirement anywhere in RFC5661 to state that a truncate
> must be prefixed by a layout return. Not in section 12 (Parallel NFS)
> nor in section 13 (NFSv4.1 as a Storage Protocol in pNFS: the File
> Layout Type), nor in the ERRATA. Existing pNFS files servers (i.e.
> NetApp) don't need it either.
> 

Yes! which is why it sucks ;-)

> If a future CEPH server wants to add its own requirements, then it is
> free to issue a layoutrecall. However my understanding from
> conversations with Matt (the Ganesha release notes appear to confirm)
> was that the CRUSH algorithm is pretty much impossible to implement as
> a files layout type, so I'm confused as to why it would be a problem
> in the first place.
> 

"impossible to implement" without lo-segments yes. *With* lo-segments it
is my opinion that it is possible. With the contraption of device_id per
segment.

But this argument is mute we both agree that in current code it is not
needed. 

[ If at future time someone will want to implement lo-segments for
 Linux files layout, I think it could be a nice optimization, just as it
 is with objects and blocks.

 Imagine a most simple files MDS that wants to not create filehandles(files)
 on DSs that will not be reached. (Create on demand). In such case deleting
 the DS-files on truncate might make sense no?
]

Xheers
Boaz

