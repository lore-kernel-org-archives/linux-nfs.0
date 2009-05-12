From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start
 values are truncated by	the nfs rdma client.
Date: Tue, 12 May 2009 11:11:36 -0500
Message-ID: <4A099FB8.7090603@opengridcomputing.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int>		<49F31A16.2080806@opengridcomputing.com>		<49F4AE86.4090908@opengridcomputing.com>		<49f515a5.1d1e640a.1c82.6677@mx.google.com>		<49F5ED55.1010607@opengridcomputing.com>		<1240855510.8818.9.camel@heimdal.trondhjem.org>		<1240856613.8818.16.camel@heimdal.trondhjem.org>		<49F60845.4010007@opengridcomputing.com>		<1240865214.8818.73.camel@heimdal.trondhjem.org>		<4A08A5C6.7040003@opengridcomputing.com>		<1242082203.1743.11.camel@heimdal.trondhjem.org>		<4A08BF1C.2050204@opengridcomputing.com>		<1242089066.1743.19.camel@heimdal.trondhjem.org>		<4a08cd7b.48c3f10a.6bb1.fffff6d3@mx.google.com>	<1242092150.16618.15.camel@heimdal.trondhjem.org> <4A08E7B2.1010907@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org" <general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:45432 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750825AbZELQLd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 May 2009 12:11:33 -0400
In-Reply-To: <4A08E7B2.1010907@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Wise wrote:

 >Trond Myklebust wrote (earlier in this thread):
 >
 > All I should need to know is that I can advertise either dma handles or
 > kernel VAs, and know that I can choose between two functions, say,
 > ib_send_wr_fastreg_dma_init() and ib_send_wr_fastreg_kva_init() to
 > initialise the ib_send_wr structure correctly.


To align more with the rest of the fast_reg API in ib_verbs.h, I propose:

static inline void ib_init_fast_reg_iova_start_dma(struct ib_send_wr 
*send_wr, dma_addr_t dma);
static inline void ib_init_fast_reg_iova_start_kva(struct ib_send_wr 
*send_wr, void *kva);

Thoughts?


