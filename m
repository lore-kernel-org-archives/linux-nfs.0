From: Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>
Subject: Re: NFS root lockups with -next 20110113
Date: Thu, 13 Jan 2011 13:35:53 +0000
Message-ID: <20110113133552.GD30351@opensource.wolfsonmicro.com>
References: <20110113120626.GB30351@opensource.wolfsonmicro.com>
 <8138.1294924927@jrobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Santosh Shilimkar <santosh.shilimkar@ti.com>,
	Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: "J. R. Okajima" <hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:43547 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755886Ab1AMNiI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 08:38:08 -0500
In-Reply-To: <8138.1294924927@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 13, 2011 at 10:22:07PM +0900, J. R. Okajima wrote:

> This and a report from Santosh Shilimkar look like the same problem
> which I reported, and I am testing this patch. If you can, please try it
> too.
> Note: Of course this is not offcial fix.

Seems to do the trick:

Tested-by: Mark Brown <broonie-yzvPICuk2AABXRvFM2YniueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>
