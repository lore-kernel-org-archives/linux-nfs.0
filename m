Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from esa2.hgst.iphmx.com ([68.232.143.124]:15291 "EHLO
        esa2.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033988AbdEYUTt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 May 2017 16:19:49 -0400
From: Bart Van Assche <Bart.VanAssche@sandisk.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "hch@lst.de" <hch@lst.de>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
        "osandov@fb.com" <osandov@fb.com>, "axboe@fb.com" <axboe@fb.com>,
        "axboe@kernel.dk" <axboe@kernel.dk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 06/19] nfsd: Check private request size before submitting
 a SCSI request
Date: Thu, 25 May 2017 20:19:47 +0000
Message-ID: <1495743585.2615.6.camel@sandisk.com>
References: <20170525184327.23570-1-bart.vanassche@sandisk.com>
         <20170525184327.23570-7-bart.vanassche@sandisk.com>
         <20170525184851.GD4298@fieldses.org>
In-Reply-To: <20170525184851.GD4298@fieldses.org>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-05-25 at 14:48 -0400, J . Bruce Fields wrote:
> On Thu, May 25, 2017 at 11:43:14AM -0700, Bart Van Assche wrote:
> > Since using scsi_req() is only allowed against request queues for
> > which struct scsi_request is the first member of their private
> > request data, refuse to submit SCSI commands against a queue for
> > which this is not the case.
>=20
> Is it possible we could catch this earlier and avoid giving out the
> layout in the first place?

Hello Christoph,

According to what I see in commit 8650b8a05850 you are the author of this
code? Can the blk_queue_scsi_pdu(q) test fail in nfsd4_scsi_identify_device=
()?
If so, can nfsd4_layout_verify() be modified in such a way that it prevents
that nfsd4_scsi_proc_getdeviceinfo() is ever called for a non-SCSI queue?
Can you recommend an approach?

Thanks,

Bart.=
