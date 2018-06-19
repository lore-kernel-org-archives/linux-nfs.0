Return-Path: <hch@lst.de>
Date: Tue, 19 Jun 2018 16:11:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: bfields@fieldses.org, Jeff Layton <jlayton@kernel.org>,
	Bart Van Assche <bart.vanassche@sandisk.com>,
	Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: don't advertise a SCSI layout for an unsupported
	request_queue
Message-ID: <20180619141106.GB13089@lst.de>
References: <be316794f70ba6e4b2e0314cd6fca9ad2447cdc2.1529398437.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <be316794f70ba6e4b2e0314cd6fca9ad2447cdc2.1529398437.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 19, 2018 at 04:57:24AM -0400, Benjamin Coddington wrote:
> Commit 30181faae37f ("nfsd: Check queue type before submitting a SCSI
> request") did the work of ensuring that we don't send SCSI requests to a
> request queue that won't support them, but that check is in the
> GETDEVICEINFO path.  Let's not set the SCSI layout in fs_layout_type in the
> first place, and then we'll have less clients sending GETDEVICEINFO for
> non-SCSI request queues and less unnecessary WARN_ONs.
> 
> While we're in here, remove some outdated comments that refer to
> "overwriting" layout seletion because commit 8a4c3926889e ("nfsd: allow
> nfsd to advertise multiple layout types") changed things to no longer
> overwrite the layout type.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
