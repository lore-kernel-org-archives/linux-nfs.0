Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:33429 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440Ab1IWMWs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 08:22:48 -0400
Date: Fri, 23 Sep 2011 08:22:45 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 06/10] pnfsblock: init pg_bsize properly
Message-ID: <20110923122245.GA15997@merit.edu>
References: <1316742617-14766-1-git-send-email-rees@umich.edu>
 <1316742617-14766-7-git-send-email-rees@umich.edu>
 <4E7C1766.1080501@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E7C1766.1080501@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  On 09/23/2011 04:50 AM, Jim Rees wrote:
  > From: Peng Tao <bergwolf@gmail.com>
  > 
  > pg_bsize is server->wsize/rsize by default. We would want to use the lseg
  > length.
  > 
  > Signed-off-by: Peng Tao <peng_tao@emc.com>
  > Signed-off-by: Jim Rees <rees@umich.edu>
  
  If you want to get lazy about this patch and take the easy way out.
  The least you can do is supply the same fix to that other place
  that has the same bug.
  
  This is not nice. You have identified a deficiency in the generic
  layer, You know that objects would have the same bug, (because I told you)
  and you just don't care. I have spent plenty of times slaving over
  blocks code when changing or fixing generic layer. (And Benny even more
  then me)
  
  And when you will actually send a patch that does exactly the same in
  two places, which access only generic members, you might see that it
  might be better to fix it in a single place at the generic layer.
  
  NACK. I'm ok with getting lazy like below, but only if you also
  add the same code to objio_osd.c

Sorry, I sent the wrong patch.  Trond, please drop this one.
