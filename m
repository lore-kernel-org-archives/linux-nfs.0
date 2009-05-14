From: Or Gerlitz <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>
Subject: Re: [ofa-general] Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start
 values are truncated by	the nfs rdma client.
Date: Thu, 14 May 2009 10:22:14 +0300
Message-ID: <4A0BC6A6.1070002@voltaire.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int>	<49F31A16.2080806@opengridcomputing.com>	<49F4AE86.4090908@opengridcomputing.com>	<49f515a5.1d1e640a.1c82.6677@mx.google.com>	<49F5ED55.1010607@opengridcomputing.com>	<1240855510.8818.9.camel@heimdal.trondhjem.org>	<1240856613.8818.16.camel@heimdal.trondhjem.org>	<49F60845.4010007@opengridcomputing.com>	<1240865214.8818.73.camel@heimdal.trondhjem.org>	<4A08A5C6.7040003@opengridcomputing.com>	<1242082203.1743.11.camel@heimdal.trondhjem.org>	<4A08BF1C.2050204@opengridcomputing.com>	<1242089066.1743.19.camel@heimdal.trondhjem.org>	<4a08cd7b.48c3f10a.6bb1.fffff6d3@mx.google.com>	<1242092150.16618.15.camel@heimdal.trondhjem.org>	<4A08E7B2.1010907@opengridcomputing.com>	<4A099FB8.7090603@opengridcomputing.com>	<4A09A283.3090605@opengrid
 computing.com> <adak54kr8iz.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Steve Wise <swise@opengridcomputing.com>,
	linux-nfs@vger.kernel.org,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	"general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org" <general-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:40434 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751714AbZENHWX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 May 2009 03:22:23 -0400
In-Reply-To: <adak54kr8iz.fsf-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Trond Myklebust wrote 
>> All I should need to know is that I can advertise either dma handles or kernel VAs

Maybe its obvious to some people here, but may I ask why there's a need 
to post either dma address or kernel virtual address? is it application 
need? hardware (e.g IB vs iWARP vs  vendor implementation) specific? or 
something else?

Or.


