From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [ofa-general] Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are truncated by	the nfs rdma client.
Date: Wed, 13 May 2009 14:35:16 -0700
Message-ID: <adak54kr8iz.fsf@cisco.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int>
	<49F31A16.2080806@opengridcomputing.com>
	<49F4AE86.4090908@opengridcomputing.com>
	<49f515a5.1d1e640a.1c82.6677@mx.google.com>
	<49F5ED55.1010607@opengridcomputing.com>
	<1240855510.8818.9.camel@heimdal.trondhjem.org>
	<1240856613.8818.16.camel@heimdal.trondhjem.org>
	<49F60845.4010007@opengridcomputing.com>
	<1240865214.8818.73.camel@heimdal.trondhjem.org>
	<4A08A5C6.7040003@opengridcomputing.com>
	<1242082203.1743.11.camel@heimdal.trondhjem.org>
	<4A08BF1C.2050204@opengridcomputing.com>
	<1242089066.1743.19.camel@heimdal.trondhjem.org>
	<4a08cd7b.48c3f10a.6bb1.fffff6d3@mx.google.com>
	<1242092150.16618.15.camel@heimdal.trondhjem.org>
	<4A08E7B2.1010907@opengridcomputing.com>
	<4A099FB8.7090603@opengridcomputing.com>
	<4A09A283.3090605@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org,
	"Talpey\, Thomas" <Thomas.Talpey@netapp.com>,
	"general\@lists.openfabrics.org" <general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:60874 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338AbZEMVfQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2009 17:35:16 -0400
In-Reply-To: <4A09A283.3090605@opengridcomputing.com> (Steve Wise's message of
	"Tue, 12 May 2009 11:23:31 -0500")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 > Trond Myklebust wrote (earlier in this thread):
 > >
 > > All I should need to know is that I can advertise either dma handles or
 > > kernel VAs, and know that I can choose between two functions, say,
 > > ib_send_wr_fastreg_dma_init() and ib_send_wr_fastreg_kva_init() to
 > > initialise the ib_send_wr structure correctly.

I skimmed the earlier thread, and I have to say that I don't quite see
what the problem with assigning things to a u64 directly is.  You can
use any address you want, and I don't quite understand why using the
correct cast to avoid sign extension or truncation problems is such a
big maintenance burden?

The code below really just looks like obfuscation to me -- are we going
to want to add something like

/**
 * ib_init_fast_reg_iova_start_u64 - initializes the iova_start field
 *   based on a 64-bit address supplied by the user.
 * @wr - struct ib_send_wr pointer to be initialized
 * @addr - void * address to be used as the iova_start
 */
static inline void ib_init_fast_reg_iova_start_kva(struct ib_send_wr *wr,
						   u64 addr)
{
	wr->wr.fast_reg.iova_start = addr;
}

next, to make sure we don't get confused about assigning a u64 to a u64?
It all looks a bit overcomplicated to me.

 - R.

 > /**
 > + * ib_init_fast_reg_iova_start_dma - initializes the iova_start field
 > + *   based on a dma address supplied by the user.
 > + * @wr - struct ib_send_wr pointer to be initialized
 > + * @addr - dma_addr_t value to be used as the iova_start
 > + */
 > +static inline void ib_init_fast_reg_iova_start_dma(struct ib_send_wr *wr,
 > +                                                  dma_addr_t addr)
 > +{
 > +       wr->wr.fast_reg.iova_start = addr;
 > +}
 > +
 > +/**
 > + * ib_init_fast_reg_iova_start_kva - initializes the iova_start field
 > + *   based on a kernel virtual address supplied by the user.
 > + * @wr - struct ib_send_wr pointer to be initialized
 > + * @addr - void * address to be used as the iova_start
 > + */
 > +static inline void ib_init_fast_reg_iova_start_kva(struct ib_send_wr *wr,
 > +                                                  void *addr)
 > +{
 > +       wr->wr.fast_reg.iova_start = (unsigned long)addr;
 > +}
 > +
 > +/**
 >  * ib_alloc_mw - Allocates a memory window.
 >  * @pd: The protection domain associated with the memory window.
 >  */
