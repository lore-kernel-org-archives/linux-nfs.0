From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] nodmask.h: remove macro any_online_node
Date: Mon, 01 Feb 2010 13:05:58 +1100
Message-ID: <1264989958.8287.13.camel@pasglop>
References: <201001061624.59118.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, devicetree-discuss@lists.ozlabs.org,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, rientjes@google.com,
	kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org, mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org,
	lee.schermerhorn@hp.com, paulus@samba.org, dave@linux.vnet.ibm.com,
	miltonm-ogEGBHC/i9Y@public.gmane.org, nfont-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org, geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org, bfields@fieldses.org, neilb@suse.de,
	Trond.Myklebust@netapp.com, davem@davemloft.net,
	bhalevy@panasas.com, chuck.lever@oracle.com,
	Ricardo.Labiaga@netapp.com
To: H Hartley Sweeten <hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55909 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940Ab0BACKM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 31 Jan 2010 21:10:12 -0500
In-Reply-To: <201001061624.59118.hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-01-06 at 16:24 -0700, H Hartley Sweeten wrote:
> nodmask.h: remove macro any_online_node
> 
> The macro any_online_node is prone to producing sparse warnings
> due to the local symbol 'node'. Since all the in-tree users are really
> requesting the first online node (the mask argument is either
> NODE_MASK_ALL or node_online_map) just use the first_online_node
> macro and remove the any_online_node macro since there are no users.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Milton Miller <miltonm-ogEGBHC/i9Y@public.gmane.org>
> Cc: Nathan Fontenot <nfont-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
> Cc: Geoff Levand <geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org>
> Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Benny Halevy <bhalevy@panasas.com>
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Cheers,
Ben.


