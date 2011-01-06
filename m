Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from Mycroft.westnet.com ([216.187.52.7]:33635 "EHLO
	mycroft.westnet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763Ab1AFUgG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jan 2011 15:36:06 -0500
Content-Type: text/plain; charset=us-ascii
Message-ID: <19750.9173.909359.319214@quad.stoffel.home>
Date: Thu, 6 Jan 2011 15:19:33 -0500
From: "John Stoffel" <john@stoffel.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
In-Reply-To: <1294335614.22825.154.camel@mulgrave.site>
References: <1294254337.16957.13.camel@mulgrave.site>
	<AANLkTi=VZUxNFd7n-qwf5aiOeK5rkk8qBmo+kOpgg7up@mail.gmail.com>
	<1294256169.16957.18.camel@mulgrave.site>
	<20110105200008.GJ8638@n2100.arm.linux.org.uk>
	<1294259637.16957.25.camel@mulgrave.site>
	<AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
	<20110105210448.GM8638@n2100.arm.linux.org.uk>
	<AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
	<1294262208.2952.4.camel@heimdal.trondhjem.org>
	<AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>
	<1294268808.2952.18.camel@heimdal.trondhjem.org>
	<1294270104.16957.73.camel@mulgrave.site>
	<1294335614.22825.154.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>>>>> "James" == James Bottomley <James.Bottomley@HansenPartnership.com> writes:

James> On Wed, 2011-01-05 at 23:28 +0000, James Bottomley wrote:
>> Can you explain how the code works? it looks to me like you read the xdr
>> stuff through the vmap region then write it out directly to the pages? 

James> OK, I think I see how this is supposed to work: It's a
James> sequential loop of reading in via the pages (i.e. through the
James> kernel mapping) and then updating those pages via the vmap.  In
James> which case, I think this patch is what you need.

James> The theory of operation is that the readdir on pages actually
James> uses the network DMA operations to perform, so when it's
James> finished, the underlying page is up to date.  After this you
James> invalidate the vmap range, so we have no cache lines above it
James> (so it picks up the values from the uptodate page).  Finally,
James> after the operation on the vmap region has finished, you flush
James> it so that any updated contents go back to the pages themselves
James> before the next iteration begins.

You need to re-spin this patch to include the above description into
the magic steps your taking here, or at least document it more clearly
somewhere why you need to make these funky steps.  

John


James> James

James> ---

James> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
James> index 996dd89..bde1911 100644
James> --- a/fs/nfs/dir.c
James> +++ b/fs/nfs/dir.c
James> @@ -587,12 +587,16 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
James>  		if (status < 0)
James>  			break;
James>  		pglen = status;
James> +
James> +		invalidate_kernel_vmap_range(pages_ptr, pglen);
James> +
James>  		status = nfs_readdir_page_filler(desc, &entry, pages_ptr, page, pglen);
James>  		if (status < 0) {
James>  			if (status == -ENOSPC)
James>  				status = 0;
James>  			break;
James>  		}
James> +		flush_kernel_vmap_range(pages_ptr, pglen);
James>  	} while (array->eof_index < 0);
 
James>  	nfs_readdir_free_large_page(pages_ptr, pages, array_size);


James> --
James> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
James> the body of a message to majordomo@vger.kernel.org
James> More majordomo info at  http://vger.kernel.org/majordomo-info.html
James> Please read the FAQ at  http://www.tux.org/lkml/

-- 
