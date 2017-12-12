Return-Path: <BATV+096fce5175ea1cd588ed+5224+infradead.org+hch@bombadil.srs.infradead.org>
Date: Tue, 12 Dec 2017 06:29:00 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 0/3] pNFS blocklayout handling for transient devices
Message-ID: <20171212142900.GB25596@infradead.org>
References: <cover.1512748321.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1512748321.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 08, 2017 at 12:52:56PM -0500, Benjamin Coddington wrote:
> This set improves the blocklayoutdriver's handling of layouts when devices
> are not present on the a client, or become unavailable.  Ideally, clients
> should not continually spam a server with LAYOUTGET for known layouts, and
> GETDEVINFO for known devices, since it may be a common scenario to have some
> clients that have access to the block devices, and some clients that do not.
> 
> In addition to better handling situations where devices are unavailable,
> patches 2 and 3 fix crashes if SCSI devices do not exist or are already have
> existing reservations.

What testcases do you have for this?
