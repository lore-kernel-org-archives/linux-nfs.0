Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:33997 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753900Ab1AFRkT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jan 2011 12:40:19 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
In-Reply-To: <1294270104.16957.73.camel@mulgrave.site>
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
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 06 Jan 2011 11:40:13 -0600
Message-ID: <1294335614.22825.154.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-05 at 23:28 +0000, James Bottomley wrote:
> Can you explain how the code works? it looks to me like you read the xdr
> stuff through the vmap region then write it out directly to the pages? 

OK, I think I see how this is supposed to work:  It's a sequential loop
of reading in via the pages (i.e. through the kernel mapping) and then
updating those pages via the vmap.  In which case, I think this patch is
what you need.

The theory of operation is that the readdir on pages actually uses the
network DMA operations to perform, so when it's finished, the underlying
page is up to date.  After this you invalidate the vmap range, so we
have no cache lines above it (so it picks up the values from the
uptodate page).  Finally, after the operation on the vmap region has
finished, you flush it so that any updated contents go back to the pages
themselves before the next iteration begins.

Does this look right to people?  I've verified it fixes the issues on
parisc.

James

---

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 996dd89..bde1911 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -587,12 +587,16 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		if (status < 0)
 			break;
 		pglen = status;
+
+		invalidate_kernel_vmap_range(pages_ptr, pglen);
+
 		status = nfs_readdir_page_filler(desc, &entry, pages_ptr, page, pglen);
 		if (status < 0) {
 			if (status == -ENOSPC)
 				status = 0;
 			break;
 		}
+		flush_kernel_vmap_range(pages_ptr, pglen);
 	} while (array->eof_index < 0);
 
 	nfs_readdir_free_large_page(pages_ptr, pages, array_size);


