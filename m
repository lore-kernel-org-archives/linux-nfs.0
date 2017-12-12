Return-Path: <BATV+096fce5175ea1cd588ed+5224+infradead.org+hch@bombadil.srs.infradead.org>
Date: Tue, 12 Dec 2017 06:38:25 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 2/3] pnfs/blocklayout: Revalidate SCSI disks after
 registration
Message-ID: <20171212143825.GA11132@infradead.org>
References: <cover.1512748321.git.bcodding@redhat.com>
 <7849a32ce8d429791eed114275496ec213dfaeb7.1512748321.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7849a32ce8d429791eed114275496ec213dfaeb7.1512748321.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 08, 2017 at 12:52:58PM -0500, Benjamin Coddington wrote:
> If a SCSI device already has an exclusive access registrants only
> reservation, the device's size cannot be known by the client until after
> registration.  We should therefore delay setting the block device's length
> until after the registration and revalidation of the disk.

Table 13 in sbc4r14.pdf clearly indicates READ CAPACITY is allowed even
for a not registered I_T nexus.  What kind of setup do you see this
problem with?
