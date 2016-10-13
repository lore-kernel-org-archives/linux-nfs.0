Return-Path: <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH][RESEND] pnfs/blocklayout: fix last_write_offset
 incorrectly set to page boundary
To: Christoph Hellwig <hch@infradead.org>,
        Benjamin Coddington
	<bcodding@redhat.com>
References: <ffe9a2cc97ead5b73b985aa4c16219351cac29d5.1476215430.git.bcodding@redhat.com>
 <20161011201719.GA25383@infradead.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <bf99210e-7aea-74ee-799c-64c7f190b4e4@Netapp.com>
Date: Thu, 13 Oct 2016 16:46:19 -0400
MIME-Version: 1.0
In-Reply-To: <20161011201719.GA25383@infradead.org>
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

Thanks for the patch!  It didn't make it into my initial pull request for 4.9, but I am planning on sending it for an rc along with any bakeathon changes from next week.

I hope that's okay!
Anna

On 10/11/2016 04:17 PM, Christoph Hellwig wrote:
> On Tue, Oct 11, 2016 at 03:53:21PM -0400, Benjamin Coddington wrote:
>> I'm resending this as the original was buried in a thread and I want to make
>> sure it gets picked up.  This fixes a bug that went in v4.8.
> 
> Didn't I already give you my review for this?  Otherwise:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Tested-by: Christoph Hellwig <hch@lst.de>
> 
> should also get a Cc to stable.
> 
