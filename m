Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:45053 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193AbaIPIcY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Sep 2014 04:32:24 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so8436383pad.6
        for <linux-nfs@vger.kernel.org>; Tue, 16 Sep 2014 01:32:22 -0700 (PDT)
Message-ID: <5417F590.7020708@plexistor.com>
Date: Tue, 16 Sep 2014 11:32:16 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>
CC: Benny Halevy <bhalevy@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: layoutcommit space reservation for the objlayout driver
References: <20140914164655.GB13467@lst.de> <5416ABF3.3040403@plexistor.com> <20140915171212.GA23765@lst.de>
In-Reply-To: <20140915171212.GA23765@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/15/2014 08:12 PM, Christoph Hellwig wrote:
> On Mon, Sep 15, 2014 at 12:05:55PM +0300, Boaz Harrosh wrote:
>> I do not understand. This used to work just fine. Please point me to
>> the patch that broke it?
>> (And since when are we allowed to brake old code?)
> 
> I bet it still works the same way it does as commited, which doesn't
> make it right.  The way the NFS XDR buffer allocations work seems to be
> that you can actually slightly overun it without things falling apart,
> but that doesn't make it right.  E.g. it took a fairly larger overrun
> in the block layout driver to finally find the issues, and most of the
> time it was just silent truncations, real corruption happened less
> often.
> 
> But to make sure things work properly in the long run you'd really want
> to have the proper allocation.
> 

Thanks Christoph for explaining. OK make sense what you said. Actually I
know why it works. You know that extra page we have at nfs-xdr for if
a struct spans two pages than the xdr code will memcpy it it a spare
buffer contiguous and return that. Ha, no, that is for decoding.

But I bet for encoding there is spare buffers as well.

I will try to push for a two 64bit growth at the core reservation for
pnf-obj. No point in adding a full page for extra 16 bytes. I bet it
will not change anything because of the reserved space.

I'm not familiar with this code, I'll try to find where
core reservation is allocated for layout update?

Thanks
Boaz

