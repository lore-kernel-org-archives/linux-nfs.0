Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:35203 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753860AbdDLQBX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Apr 2017 12:01:23 -0400
From: Christoph Hellwig <hch@lst.de>
To: ooo@electrozaur.com, martin.petersen@oracle.com,
        trond.myklebust@primarydata.com, axboe@kernel.dk
Cc: osd-dev@open-osd.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-block@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: RFC: drop the T10 OSD code and its users
Date: Wed, 12 Apr 2017 18:01:05 +0200
Message-Id: <20170412160109.10598-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The only real user of the T10 OSD protocol, the pNFS object layout
driver never went to the point of having shipping products, and the
other two users (osdblk and exofs) were simple example of it's usage.

The code has been mostly unmaintained for years and is getting in the
way of block / SCSI changes, so I think it's finally time to drop it.

These patches are against Jens' block for-next tree as that already
has various modifications of the SCSI code.
