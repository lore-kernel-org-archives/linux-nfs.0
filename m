Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-out.m-online.net ([212.18.0.9]:33587 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965200Ab2JDO6D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Oct 2012 10:58:03 -0400
From: Marek Vasut <marex@denx.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] net: sunrpc: xdr: Change message to pr_debug level
Date: Thu, 4 Oct 2012 16:57:58 +0200
Cc: Fabio Estevam <fabio.estevam@freescale.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <1349360495-29325-1-git-send-email-fabio.estevam@freescale.com> <201210041625.23710.marex@denx.de> <4FA345DA4F4AE44899BD2B03EEEC2FA9090049AD@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9090049AD@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Message-Id: <201210041657.59046.marex@denx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Myklebust, Trond,

> > -----Original Message-----
> > From: Marek Vasut [mailto:marex@denx.de]
> > Sent: Thursday, October 04, 2012 7:25 AM
> > To: Fabio Estevam
> > Cc: davem@davemloft.net; Myklebust, Trond; netdev@vger.kernel.org;
> > linux-nfs@vger.kernel.org
> > Subject: Re: [PATCH] net: sunrpc: xdr: Change message to pr_debug level
> > 
> > Dear Fabio Estevam,
> > 
> > > commit 49f6189 (SUNRPC: Optimise away unnecessary data moves in
> > > xdr_align_pages) has added a pr_info that floods dmesg when booting
> > > via NFS.
> > > 
> > > There is also a note in the commit log: "Warning! Contains debugging
> > > printks!"
> 
> ...which meant that it contained debugging code, and was obviously not
> appropriate for merging upstream. The final version has already dropped
> the debugging printks.

Uh oh, the version with debug prints made it into -next .

Best regards,
Marek Vasut
