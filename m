Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35888 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1039868AbdDUNRu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Apr 2017 09:17:50 -0400
Subject: Re: [PATCH 3/4] nfs: remove the objlayout driver
To: Trond Myklebust <trondmy@primarydata.com>, hch <hch@lst.de>,
        "martin.petersen@oracle.com" <martin.petersen@oracle.com>,
        "axboe@kernel.dk" <axboe@kernel.dk>
References: <20170412160109.10598-1-hch@lst.de>
 <20170412160109.10598-4-hch@lst.de>
 <1492719505.82584.3.camel@primarydata.com>
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "osd-dev@open-osd.org" <osd-dev@open-osd.org>,
        "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Boaz Harrosh <ooo@electrozaur.com>
Message-ID: <272aea55-0738-5de2-ca97-414e13b478af@electrozaur.com>
Date: Fri, 21 Apr 2017 16:17:41 +0300
MIME-Version: 1.0
In-Reply-To: <1492719505.82584.3.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/20/2017 11:18 PM, Trond Myklebust wrote:
<>
> 
> OK. I'm applying this patch for the 4.12 merge window. 

That is understandable this code was not tested for a long while

> If, as Boaz
> suggests, there is still an interest in exofs, then I suggest we put
> that to the test by moving it into the STAGING area, to see if someone
> will step up to maintain it.
> 

I do not understand what you mean by "someone will maintain it"
What is it that is missing in exofs that you see needs development?

As I said I regularly run and test this FS and update as things advance
there where no new fixtures for a while, but no regressions either.

Please explain what it means "will maintain it"

> Cheers
>   Trond
> 

Thanks
Boaz

