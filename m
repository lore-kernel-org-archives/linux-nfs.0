Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13426 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180Ab1KECiq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 22:38:46 -0400
Subject: Re: NFSROOT mount fails on SPARC after 2.6.37
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Miller <davem@davemloft.net>
Cc: chuck.lever@oracle.com, netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux@razik.name
Date: Fri, 04 Nov 2011 22:38:44 -0400
In-Reply-To: <20111104.220334.1213367819937218830.davem@davemloft.net>
References: <1320429339.53513.YahooMailNeo@web24704.mail.ird.yahoo.com>
	 <119BC4C8-E1AB-4415-AF00-B183FC7EB16A@oracle.com>
	 <20111104.220334.1213367819937218830.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320460724.2750.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-04 at 22:03 -0400, David Miller wrote: 
> Should be fixed by:
> 
> commit 3fb72f1e6e6165c5f495e8dc11c5bbd14c73385c
> Author: Micha Nelissen <micha@neli.hopto.org>
> Date:   Thu May 19 10:14:06 2011 +0000
> 
>     ipconfig wait for carrier
>     
>     v3 -> v4: fix return boolean false instead of 0 for ic_is_init_dev
>     
>     Currently the ip auto configuration has a hardcoded delay of 1 second.
>     When (ethernet) link takes longer to come up (e.g. more than 3 seconds),
>     nfs root may not be found.
>     
>     Remove the hardcoded delay, and wait for carrier on at least one network
>     device.

What will happen if there is more than one NIC, but only one if those
NICs is being configured with a static IP address (i.e. no auto
configuration)?

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

