Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:58218 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab1IUA3U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 20:29:20 -0400
Date: Tue, 20 Sep 2011 20:29:17 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Benny Halevy <bhalevy@tonian.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
Message-ID: <20110921002917.GA30770@merit.edu>
References: <1316488728-24912-1-git-send-email-rees@umich.edu>
 <1316488728-24912-3-git-send-email-rees@umich.edu>
 <1316558461.15093.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1316558461.15093.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

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

I thought you were the one who asked for this, here:
http://www.spinics.net/lists/linux-nfs/msg22771.html

But looking back on it now, the IO path has changed and I can't tell if the
argument still holds.
