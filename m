Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747AbaDCLU4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 07:20:56 -0400
Date: Thu, 3 Apr 2014 07:20:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Tom Tucker <tom@opengridcomputing.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, <swise@opengridcomputing.com>,
        Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH] svcrdma: fix offset calculation for non-page aligned
 sge entries
Message-ID: <20140403072043.44525cee@tlielax.poochiereds.net>
In-Reply-To: <533D2D24.40107@panasas.com>
References: <1394635867-19089-1-git-send-email-jlayton@redhat.com>
	<5320C6DE.4090807@opengridcomputing.com>
	<20140312171832.33f04ee8@tlielax.poochiereds.net>
	<533D2D24.40107@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 3 Apr 2014 12:43:00 +0300
Boaz Harrosh <bharrosh@panasas.com> wrote:

> On 03/12/2014 11:18 PM, Jeff Layton wrote:
> > 
> > Ok, I may need to rejigger that logic to account for that case. I'll do
> > that and send a v2 once I test it out...
> > 
> 
> Hi Jeff in obj-layout we have this code:
> 
> 	if (*p_pgbase > PAGE_SIZE) {
> 		dprintk("%s: pgbase(0x%x) > PAGE_SIZE\n", __func__, *p_pgbase);
> 		*p_pages += *p_pgbase >> PAGE_SHIFT;
> 		*p_pgbase &= ~PAGE_MASK;
> 	}
> 
> ie. advance the page_array pointer and keep the pgbase within page.
> 
> if I recall correctly this case happens when you return a short read/write
> then the retry comes again with same page_array but with base jumping over
> the previous short IO, and length with the reminder.
> 
> I'm not sure what is the code path that feeds your xdr stuff but it
> might not filter out the way we do in obj-lo. the ORE is the same
> it assumes pgbase < PAGE_SIZE.
> 
> Cheers
> Boaz
> 

Thanks Boaz,

After I had a fresh look at the logic in dma_map_xdr(), I figured out
that the logic in there should cover all of the cases we care about. It
was just the the page_base wasn't being respected. The updated patch is
this one-liner that I sent to the list:

     [PATCH v2] svcrdma: fix offset calculation for non-page aligned sge entries

That seems to fix the broken testcase that I had, which was that
sub-page DIO reads would get corrupted. Does that patch look ok to you,
or have I missed any cases?

-- 
Jeff Layton <jlayton@redhat.com>
