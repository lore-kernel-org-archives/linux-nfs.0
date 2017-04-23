Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:34033 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1044497AbdDWJgN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Apr 2017 05:36:13 -0400
Subject: Re: [PATCH 3/4] nfs: remove the objlayout driver
To: Trond Myklebust <trondmy@primarydata.com>
References: <20170412160109.10598-1-hch@lst.de>
 <20170412160109.10598-4-hch@lst.de>
 <1492719505.82584.3.camel@primarydata.com>
 <272aea55-0738-5de2-ca97-414e13b478af@electrozaur.com>
 <B6CCD2A9-4691-45DC-AD60-E9A2ECDE22D3@primarydata.com>
Cc: hch <hch@lst.de>, Martin Petersen <martin.petersen@oracle.com>,
        Jens Axboe <axboe@kernel.dk>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Boaz Harrosh <ooo@electrozaur.com>
Message-ID: <e253b5f5-d241-9391-dbeb-8e5f6b25b6c0@electrozaur.com>
Date: Sun, 23 Apr 2017 12:36:09 +0300
MIME-Version: 1.0
In-Reply-To: <B6CCD2A9-4691-45DC-AD60-E9A2ECDE22D3@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/21/2017 05:00 PM, Trond Myklebust wrote:
> Maintenance is not development. It’s about doing all the followup
> _after_ the feature is declared to be developed. That’s been missing
> for quite some time in the case of the OSD pNFS code, which is why
> I’m not even bothering to consider staging. If you are saying you are
> still maintaining exofs, and want to continue doing so, then great,
> but note that there is a file called BUGS in that directory that has
> been untouched since 2008, and that’s why I thing staging is a good
> idea.
> 

No, the BUGS file is just stale. As you said was not ever updated. All
the bugs (1) in there do no longer exist for a long long time.
I will send a patch to remove the file.

Yes I maintain this fs. It has the complete fixture list, of what was
first intended. I keep running it every major kernel release to make
sure it actually runs, and there are no regressions.

If this FS stands in the way of any new development please anyone
contact me and I will help in the conversion. Of exofs and the
osd-uld.

Thanks
Boaz

