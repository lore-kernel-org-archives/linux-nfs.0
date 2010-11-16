Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59300 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756452Ab0KPTjX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 14:39:23 -0500
In-Reply-To: <20101012203351.22154.42528.stgit@build.ogc.int>
References: <20101012203332.22154.37230.stgit@build.ogc.int>
	<20101012203351.22154.42528.stgit@build.ogc.int>
Date: Tue, 16 Nov 2010 21:39:20 +0200
Message-ID: <AANLkTik0LkdD-Gm0FAZ-KDS605ZGTewbfejC3GEOK=2x@mail.gmail.com>
Subject: Re: [PATCH 1/2] svcrdma: Change DMA mapping logic to avoid the
 page_address kernel API
From: Or Gerlitz <or.gerlitz@gmail.com>
To: Tom Tucker <tom@ogc.us>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

 Tom Tucker <tom@ogc.us> wrote:

> This patch changes the bus mapping logic to avoid page_address() where necessary

Hi Tom,

Does "when necessary" comes to say that invocations of page_address
which remained in the code after this patch was applied are safe and
no kmap call is needed?

Or.
