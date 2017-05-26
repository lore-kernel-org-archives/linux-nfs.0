Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:41131 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030445AbdEZGKT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 May 2017 02:10:19 -0400
Date: Fri, 26 May 2017 08:10:18 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bart Van Assche <bart.vanassche@sandisk.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Jens Axboe <axboe@fb.com>, Omar Sandoval <osandov@fb.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/19] nfsd: Check private request size before
        submitting a SCSI request
Message-ID: <20170526061018.GG18424@lst.de>
References: <20170525184327.23570-1-bart.vanassche@sandisk.com> <20170525184327.23570-7-bart.vanassche@sandisk.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170525184327.23570-7-bart.vanassche@sandisk.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
