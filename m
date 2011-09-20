Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32487 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190Ab1ITWlD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 18:41:03 -0400
Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: Benny Halevy <bhalevy@tonian.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Date: Tue, 20 Sep 2011 18:41:01 -0400
In-Reply-To: <1316488728-24912-3-git-send-email-rees@umich.edu>
References: <1316488728-24912-1-git-send-email-rees@umich.edu>
	 <1316488728-24912-3-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1316558461.15093.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-09-19 at 23:18 -0400, Jim Rees wrote: 
> From: Peng Tao <bergwolf@gmail.com>
> 
> For layoutdriver io done functions, default workqueue is not a good place as
> the code is executed in IO path. So add a pnfs private workqueue to handle
> them.
> 
> Also change block and object layout code to make use of this private
> workqueue.
> 

Wait, what????

Why is the I/O path (i.e. the nfsiod queue) inappropriate for
layoutdriver io_done functions?

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

