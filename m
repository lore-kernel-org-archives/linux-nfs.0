Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:38436 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753213Ab1AFVID (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jan 2011 16:08:03 -0500
Subject: Re: still nfs problems [Was: Linux 2.6.37-rc8]
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        Parisc List <linux-parisc@vger.kernel.org>, linux-arch@vger.kernel.org
In-Reply-To: <1294338341.22825.216.camel@mulgrave.site>
References: <20110105200008.GJ8638@n2100.arm.linux.org.uk>
	 <1294259637.16957.25.camel@mulgrave.site>
	 <AANLkTimzzBsdtWcZtP5E_CH1hUZugGMoaHOiMdQJf764@mail.gmail.com>
	 <20110105210448.GM8638@n2100.arm.linux.org.uk>
	 <AANLkTi=EXXBTW7oWHq3D+PHsx=thF1CpkRjn0ax2p5rm@mail.gmail.com>
	 <1294262208.2952.4.camel@heimdal.trondhjem.org>
	 <AANLkTi=3Gu-rz=-OdNtUXn4qw60Df6=YePnzvB=s-+Ov@mail.gmail.com>
	 <1294268808.2952.18.camel@heimdal.trondhjem.org>
	 <1294270104.16957.73.camel@mulgrave.site>
	 <1294335614.22825.154.camel@mulgrave.site>
	 <20110106180530.GI31708@n2100.arm.linux.org.uk>
	 <1294337670.22825.199.camel@mulgrave.site>
	 <1294338341.22825.216.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 06 Jan 2011 15:07:58 -0600
Message-ID: <1294348078.22825.346.camel@mulgrave.site>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-01-06 at 12:25 -0600, James Bottomley wrote:
> OK, so thinking about this, it seems that the only danger is actually
> what NFS is doing: reading cache pages via a vmap.  In that case, since
> the requirement is to invalidate the vmap range to prepare for read, we
> could have invalidate_kernel_vmap_range loop over the underlying pages
> and flush them through the kernel alias if the architecture specific
> flag indicates their contents might be dirty.
> 
> The loop adds expense that is probably largely unnecessary to
> invalidate_kernel_vmap_range() but the alternative is adding to the API
> proliferation with something that only flushes the kernel pages if the
> arch specific flag says they're dirty.

This is what I think the arm patch would look like (example only: I
can't compile it).  Is something like this too expensive? the loop can't
be optimised away because of the need to check the pages (and
vmalloc_to_page is a three level page table lookup).

James

---

diff --git a/arch/arm/include/asm/cacheflush.h b/arch/arm/include/asm/cacheflush.h
index 3acd8fa..34469ca 100644
--- a/arch/arm/include/asm/cacheflush.h
+++ b/arch/arm/include/asm/cacheflush.h
@@ -414,8 +414,17 @@ static inline void flush_kernel_vmap_range(void *addr, int size)
 }
 static inline void invalidate_kernel_vmap_range(void *addr, int size)
 {
-	if ((cache_is_vivt() || cache_is_vipt_aliasing()))
-	  __cpuc_flush_dcache_area(addr, (size_t)size);
+	if ((cache_is_vivt() || cache_is_vipt_aliasing())) {
+		void *cursor = addr;
+
+		for ( ; cursor < addr + size; cursor += PAGE_SIZE) {
+			struct page *page = vmalloc_to_page(cursor);
+
+			if (!test_and_set_bit(PG_dcache_clean, &page->flags))
+				__flush_dcache_page(page_mapping(page), page);
+		}
+		__cpuc_flush_dcache_area(addr, (size_t)size);
+	}
 }
 
 #define ARCH_HAS_FLUSH_ANON_PAGE


