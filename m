Return-Path: <BATV+aa64373767b091c5de5f+4797+infradead.org+hch@bombadil.srs.infradead.org>
Date: Tue, 11 Oct 2016 13:17:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH][RESEND] pnfs/blocklayout: fix last_write_offset
 incorrectly set to page boundary
Message-ID: <20161011201719.GA25383@infradead.org>
References: <ffe9a2cc97ead5b73b985aa4c16219351cac29d5.1476215430.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ffe9a2cc97ead5b73b985aa4c16219351cac29d5.1476215430.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 11, 2016 at 03:53:21PM -0400, Benjamin Coddington wrote:
> I'm resending this as the original was buried in a thread and I want to make
> sure it gets picked up.  This fixes a bug that went in v4.8.

Didn't I already give you my review for this?  Otherwise:

Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Christoph Hellwig <hch@lst.de>

should also get a Cc to stable.
