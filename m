Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18174 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751445AbdDNC16 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Apr 2017 22:27:58 -0400
To: Christoph Hellwig <hch@lst.de>
Cc: ooo@electrozaur.com, martin.petersen@oracle.com,
        trond.myklebust@primarydata.com, axboe@kernel.dk,
        osd-dev@open-osd.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-block@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: RFC: drop the T10 OSD code and its users
From: "Martin K. Petersen" <martin.petersen@oracle.com>
References: <20170412160109.10598-1-hch@lst.de>
Date: Thu, 13 Apr 2017 22:27:38 -0400
In-Reply-To: <20170412160109.10598-1-hch@lst.de> (Christoph Hellwig's message
        of "Wed, 12 Apr 2017 18:01:05 +0200")
Message-ID: <yq1inm7wwo5.fsf@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Christoph,

> The only real user of the T10 OSD protocol, the pNFS object layout
> driver never went to the point of having shipping products, and the
> other two users (osdblk and exofs) were simple example of it's usage.
>
> The code has been mostly unmaintained for years and is getting in the
> way of block / SCSI changes, so I think it's finally time to drop it.

No particular objections from me.

-- 
Martin K. Petersen	Oracle Linux Engineering
