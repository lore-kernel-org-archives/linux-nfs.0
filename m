Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([198.137.202.13]:48291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab1KECDp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 22:03:45 -0400
Date: Fri, 04 Nov 2011 22:03:34 -0400 (EDT)
Message-Id: <20111104.220334.1213367819937218830.davem@davemloft.net>
To: chuck.lever@oracle.com
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org, linux@razik.name
Subject: Re: NFSROOT mount fails on SPARC after 2.6.37
From: David Miller <davem@davemloft.net>
In-Reply-To: <119BC4C8-E1AB-4415-AF00-B183FC7EB16A@oracle.com>
References: <1320429339.53513.YahooMailNeo@web24704.mail.ird.yahoo.com>
	<119BC4C8-E1AB-4415-AF00-B183FC7EB16A@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Should be fixed by:

commit 3fb72f1e6e6165c5f495e8dc11c5bbd14c73385c
Author: Micha Nelissen <micha@neli.hopto.org>
Date:   Thu May 19 10:14:06 2011 +0000

    ipconfig wait for carrier
    
    v3 -> v4: fix return boolean false instead of 0 for ic_is_init_dev
    
    Currently the ip auto configuration has a hardcoded delay of 1 second.
    When (ethernet) link takes longer to come up (e.g. more than 3 seconds),
    nfs root may not be found.
    
    Remove the hardcoded delay, and wait for carrier on at least one network
    device.
    
    Signed-off-by: Micha Nelissen <micha@neli.hopto.org>
    Cc: David Miller <davem@davemloft.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>
