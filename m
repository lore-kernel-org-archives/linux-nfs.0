Return-Path: <hch@lst.de>
Date: Wed, 6 Jul 2016 04:20:29 +0200
From: Christoph Hellwig <hch@lst.de>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        bfields@fieldses.org
Subject: Re: [PATCH] nfsd: allow SCSI layout support without Block layout
Message-ID: <20160706022029.GA1162@lst.de>
References: <74871b1ce0d09b21fb67c1b2176695cc1c19169e.1467624319.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <74871b1ce0d09b21fb67c1b2176695cc1c19169e.1467624319.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 05, 2016 at 06:14:56AM -0400, Benjamin Coddington wrote:
> We shouldn't have to configure both NFSD_BLOCKLAYOUT and NFSD_SCSILAYOUT if
> all we want are SCSI layouts on the server, so define the xfs export
> operations for either configuration.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>

Thanks Benjamin,

this looks good. But I think it needs to go to the xfs list, not the nfs
one.  Can you resend there?
