Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30196 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754792Ab1ENWcN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 May 2011 18:32:13 -0400
Subject: Re: [PATCH] NFS: pnfs IPv6 support
Content-Type: text/plain; charset=us-ascii
From: Dros Adamson <dros@netapp.com>
In-Reply-To: <20110514220109.GA3910@merit.edu>
Date: Sat, 14 May 2011 18:31:56 -0400
Cc: trond@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <ADD52009-1D05-4CFC-A296-C367895C3E11@netapp.com>
References: <1305407199-15206-1-git-send-email-dros@netapp.com> <20110514220109.GA3910@merit.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I thought that was a bit odd as well... I just copied how other addresses are parsed in fs/nfs/

-dros

On May 14, 2011, at 6:01 PM, Jim Rees wrote:

> Weston Andros Adamson wrote:
> 
>  +	if (!rpc_ntop((struct sockaddr *)&ds->ds_addr, buf, sizeof(buf))) {
>  +		dprintk("%s: error printing addr\n", __func__);
>  +		return;
>  +	}
> 
> Interesting.  How come there's no ntop() in net/core/utils.c?

