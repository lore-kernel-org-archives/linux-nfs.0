Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dgate10.ts.fujitsu.com ([80.70.172.49]:53878 "EHLO
	dgate10.ts.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaKFTyL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2014 14:54:11 -0500
From: =?Windows-1252?Q?Str=F6sser=2C_Bodo?=
	<bodo.stroesser@ts.fujitsu.com>
To: NeilBrown <neilb@suse.de>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Date: Thu, 6 Nov 2014 20:54:02 +0100
Subject: RE: [nfs-utils] [PATCH 3/3] rpc.mountd: set libtirpc nonblocking
 mode to avoid DOS
Message-ID: <8B06D1E6480A6747B23FEC34909D2B5EA81B95F6C1@ABGEX70E.FSC.NET>
References: <61eb00$5diu20@dgate20u.abg.fsc.net>
 <20141106093527.33ad43d6@notabene.brown>
In-Reply-To: <20141106093527.33ad43d6@notabene.brown>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: NeilBrown [mailto:neilb@suse.de]
> Sent: Wednesday, November 05, 2014 11:35 PM
> To: Strösser, Bodo
> Cc: linux-nfs@vger.kernel.org; bfields@fieldses.org
> Subject: Re: [nfs-utils] [PATCH 3/3] rpc.mountd: set libtirpc nonblocking mode to avoid
> DOS

...
 
> RPC_MAXDATASIZE is 9000.
> This number is only relevant on the receive size.
> When sending, the "sendsz" passed to svc_tli_create (which default to 64K for
> TCP) is used for the 'record size'.
> When receiving, any 'record' in a tcp connection which is larger than 9000
> bytes will be rejected.
> No message to mountd or statd could ever be that large, so this number
> does not impose a problematic limit.

Thank you for this explanation. That's what I wanted to but didn't know.

Bodo

> 
> As far as I can tell, this patch is safe and is a clear improvement.
> 
> Reviewed-by: NeilBrown <neilb@suse.de>
> 
> Thanks,
> NeilBrown
