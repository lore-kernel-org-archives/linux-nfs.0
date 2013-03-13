Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56827 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753833Ab3CMKIV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Mar 2013 06:08:21 -0400
Date: Wed, 13 Mar 2013 10:08:17 +0000
From: Mel Gorman <mgorman@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Paul Bolle <pebolle@tiscali.nl>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: drop "select NETVM"
Message-ID: <20130313100817.GB10369@suse.de>
References: <1362844951.3137.3.camel@x61.thuisdomein>
 <20130309175118.GJ31448@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <20130309175118.GJ31448@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 09, 2013 at 12:51:18PM -0500, J. Bruce Fields wrote:
> ACK.
> 
> On Sat, Mar 09, 2013 at 05:02:31PM +0100, Paul Bolle wrote:
> > The Kconfig entry for SUNRPC_SWAP selects NETVM. That select statement
> > was added in commit a564b8f0398636ba30b07c0eaebdef7ff7837249 ("nfs:
> > enable swap on NFS").
> 
> Cc'ing Mel Gorman just in case there was something else going on there.
> 
> --b.
> 
> > But there's no Kconfig symbol NETVM. It apparently
> > was only in used in development versions of the swap over nfs
> > functionality but never entered mainline. Anyhow, it is a nop and can
> > safely be dropped.
> > 

Correct, the NETVM symbol existed in an early version of swap-over-nfs
that I failed to clean up properly. Thanks.

-- 
Mel Gorman
SUSE Labs
