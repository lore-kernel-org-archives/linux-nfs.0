From: Or Gerlitz <ogerlitz-hKgKHo2Ms0FWk0Htik3J/w@public.gmane.org>
Subject: Re: [ofa-general] Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start
 values are truncated by	the nfs rdma client.
Date: Thu, 14 May 2009 16:45:26 +0300
Message-ID: <4A0C2076.8010702@Voltaire.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int>	<49F31A16.2080806@opengridcomputing.com>	<49F4AE86.4090908@opengridcomputing.com>	<49f515a5.1d1e640a.1c82.6677@mx.google.com>	<49F5ED55.1010607@opengridcomputing.com>	<1240855510.8818.9.camel@heimdal.trondhjem.org>	<1240856613.8818.16.camel@heimdal.trondhjem.org>	<49F60845.4010007@opengridcomputing.com>	<1240865214.8818.73.camel@heimdal.trondhjem.org>	<4A08A5C6.7040003@opengridcomputing.com>	<1242082203.1743.11.camel@heimdal.trondhjem.org>	<4A08BF1C.2050204@opengridcomputing.com>	<1242089066.1743.19.camel@heimdal.trondhjem.org>	<4a08cd7b.48c3f10a.6bb1.fffff6d3@mx.google.com>	<1242092150.16618.15.camel@heimdal.trondhjem.org>	<4A08E7B2.1010907@opengridcomputing.com>	<4A099FB8.7090603@opengridcomputing.com>	<4A09A283.3090605@opengrid
 computing.com> <adak54kr8iz.fsf@cisco.com>	<4A0BC6A6.1070002@voltaire.com> <4A0C1F72.8050503@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	"general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org" <general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:52253 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752420AbZENNpe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 May 2009 09:45:34 -0400
In-Reply-To: <4A0C1F72.8050503@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Wise wrote:
> The NFSRDMA transport uses Fast Register Memory Regions.  In this
> particular section of code, the NFSRDMA client is building a fastreg
> work request to bind a page list to a fastreg mr.  You can read about
> this in the IBTA spec on memory management extensions, or in the RDMA Verbs draft.

Hi Steve,

I was aware for the context being fastreg work request. I was thinking
that the spec mandates either dma addr or kva on the iova but from your reply
I assume to be wrong, thanks.

Or.
