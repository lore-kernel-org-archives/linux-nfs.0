Return-Path: <BATV+f53f61f65086c731f931+4807+infradead.org+hch@bombadil.srs.infradead.org>
Date: Fri, 21 Oct 2016 05:18:47 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Benjamin Coddington <bcodding@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH][RESEND] pnfs/blocklayout: fix last_write_offset
 incorrectly set to page boundary
Message-ID: <20161021121847.GA13905@infradead.org>
References: <ffe9a2cc97ead5b73b985aa4c16219351cac29d5.1476215430.git.bcodding@redhat.com>
 <20161011201719.GA25383@infradead.org>
 <bf99210e-7aea-74ee-799c-64c7f190b4e4@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <bf99210e-7aea-74ee-799c-64c7f190b4e4@Netapp.com>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 13, 2016 at 04:46:19PM -0400, Anna Schumaker wrote:
> Hi Ben,
> 
> Thanks for the patch!  It didn't make it into my initial pull request for 4.9, but I am planning on sending it for an rc along with any bakeathon changes from next week.

Any progress on that?  I'd really like to get the fix in before at least
-rc2.
