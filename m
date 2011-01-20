Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16209 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755760Ab1ATPTU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 10:19:20 -0500
Subject: Re: Callback slot table overflowed
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <20110120030707.GA10667@merit.edu>
Date: Thu, 20 Jan 2011 10:19:03 -0500
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Message-Id: <2CC1D543-3750-4536-A817-3D48B7C994BA@netapp.com>
References: <20110120030707.GA10667@merit.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Examine the CREATE_SESSION that created the fore channel, the back channel limits are set there.  Also note that since this is the back channel server setting the CREATE_SESSION backchannel attributes that the back channel client (e.g. the server) can not increase any of the limits.

-->Andy

On Jan 19, 2011, at 10:07 PM, Jim Rees wrote:

> Is this bad?
> Jan 19 21:53:27 pdsi7 kernel: Callback slot table overflowed
> 
> All I can tell from the code is that xprt_alloc_bc_request() failed, and the
> slots are "preallocated during the backchannel setup".  Is there a hard
> limit on these slots?  Where is it set?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

