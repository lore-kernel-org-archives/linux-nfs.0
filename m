From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 03 Nov 2008 19:38:31 +0200
Message-ID: <490F3717.1030407@panasas.com>
References: <1225724721.2247.29.camel@brian-laptop> <1225731544.6958.6.camel@heimdal.trondhjem.org> <20081103172529.GA9008@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:22859 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751227AbYKCRij (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 12:38:39 -0500
In-Reply-To: <20081103172529.GA9008@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 03, 2008, 19:25 +0200, Jim Rees <rees@umich.edu> wrote:
> Trond Myklebust wrote:
> 
>   BTW: NFSv4 + soft == BAD BAD BAD!
> 
> Maybe this combination should be prohibited.  Does it make any sense given
> the stateful nature of v4?

>From the usage perspective it allows the application to fail rather
than stall.  If it would have been implemented similar to "intr"
and return an error to the app as if the system call had received
an interrupt but under the covers the RPC will be processed to
completion (or graceful cleanup) I think it might still make sense for nfs4.
Until then this combination should at least be warned about.

Benny

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
