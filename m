From: Jim Rees <rees@umich.edu>
Subject: Re: block layout oops
Date: Thu, 30 Sep 2010 07:59:35 -0400
Message-ID: <20100930115935.GA4098@merit.edu>
References: <20100929172552.GA24460@merit.edu>
 <4CA3F1CE.2070108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Bian Naimeng <biannm@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:43565 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455Ab0I3L7j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 07:59:39 -0400
In-Reply-To: <4CA3F1CE.2070108@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bian Naimeng wrote:

  > I'm getting this when I try to do a block layout mount with benny's new
  > pnfs-all-latest kernel, 2.6.36-rc6-pnfs:
  > 
  > BUG: unable to handle kernel NULL pointer dereference at 00000008
  
    Is this patch can fix it?
  
  ----------------------------------------------------------------------
  We must specify the layout type before initialize mountpoint, so we should try set 
  pnfs_curr_ld earlier.
  
  Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

Yes, that fixed it.  Thanks!  And thanks to Benny for applying to your tree.
