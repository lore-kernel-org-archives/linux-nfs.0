Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static-209-166-131-148.expedient.com ([209.166.131.148]:35436
	"EHLO natasha.panasas.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751032AbaDCJnR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Apr 2014 05:43:17 -0400
Message-ID: <533D2D24.40107@panasas.com>
Date: Thu, 3 Apr 2014 12:43:00 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>, Tom Tucker <tom@opengridcomputing.com>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
        <swise@opengridcomputing.com>, Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH] svcrdma: fix offset calculation for non-page aligned
 sge entries
References: <1394635867-19089-1-git-send-email-jlayton@redhat.com>	<5320C6DE.4090807@opengridcomputing.com> <20140312171832.33f04ee8@tlielax.poochiereds.net>
In-Reply-To: <20140312171832.33f04ee8@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/12/2014 11:18 PM, Jeff Layton wrote:
> 
> Ok, I may need to rejigger that logic to account for that case. I'll do
> that and send a v2 once I test it out...
> 

Hi Jeff in obj-layout we have this code:

	if (*p_pgbase > PAGE_SIZE) {
		dprintk("%s: pgbase(0x%x) > PAGE_SIZE\n", __func__, *p_pgbase);
		*p_pages += *p_pgbase >> PAGE_SHIFT;
		*p_pgbase &= ~PAGE_MASK;
	}

ie. advance the page_array pointer and keep the pgbase within page.

if I recall correctly this case happens when you return a short read/write
then the retry comes again with same page_array but with base jumping over
the previous short IO, and length with the reminder.

I'm not sure what is the code path that feeds your xdr stuff but it
might not filter out the way we do in obj-lo. the ORE is the same
it assumes pgbase < PAGE_SIZE.

Cheers
Boaz

