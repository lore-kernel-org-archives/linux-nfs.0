Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp109.prem.mail.ac4.yahoo.com ([76.13.13.92]:46275 "HELO
	smtp109.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753554Ab0IAUTb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Sep 2010 16:19:31 -0400
Date: Wed, 1 Sep 2010 15:19:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: Kian Mohageri <kian.mohageri@gmail.com>, davidr@ressman.org,
        linux-nfs@vger.kernel.org
Subject: Re: fsync/wb deadlocks in 2.6.32
In-Reply-To: <1283314832.5220.31.camel@heimdal.trondhjem.org>
Message-ID: <alpine.DEB.2.00.1009011517260.16464@router.home>
References: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com>  <AANLkTi=gj901aF_84+40j9MhvAwNJSNB8qRnpY8o0gBZ@mail.gmail.com>  <AANLkTinEoMgXLvN4MvfnCHjHtHCwV1HDP67BoKQ3ZbQx@mail.gmail.com>  <alpine.DEB.2.00.1008301101560.10316@router.home>
 <AANLkTinieSM_-x4qra7_HOCsONFAdyjn3LQbyBDJRebT@mail.gmail.com>  <alpine.DEB.2.00.1008310934150.867@router.home> <1283314832.5220.31.camel@heimdal.trondhjem.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 1 Sep 2010, Trond Myklebust wrote:

> >From what I could see in your original email to me, you appear to be
> using NFS over UDP on IPoIB on a 2.6.32-18 kernel. Is that still the
> case? If so, does anything change if you change to use TCP and/or an
> ordinary NIC?

It is still the case. We have changed to udp from tcp and saw no change.
We have not tried to use an Ethernet NIC instead.

> Your link to https://bugs.launchpad.net/ubuntu/+source/linux/+bug/561210
> appears to be the kswapd bug, which should be hacked around in later
> 2.6.32 stable versions.

We are runing 2.6.32.18 which should have the fix. But the issue is still
there.

Is there any other patch available?

