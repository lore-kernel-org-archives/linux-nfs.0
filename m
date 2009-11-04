From: Martin Wilck <martin.wilck@ts.fujitsu.com>
Subject: Re: [PATCH] sunrpc: replace large table of slots with mempool
Date: Wed, 04 Nov 2009 18:17:23 +0100
Message-ID: <4AF1B723.1030106@ts.fujitsu.com>
References: <19178.32618.958277.726234@notabene.brown>    <1256932398.15679.0.camel@heimdal.trondhjem.org> <4f145776da1d0765ddc46cdb4be28b76.squirrel@neil.brown.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dgate10.ts.fujitsu.com ([80.70.172.49]:14715 "EHLO
	dgate10.ts.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbZKDR1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Nov 2009 12:27:05 -0500
In-Reply-To: <4f145776da1d0765ddc46cdb4be28b76.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown wrote:

> I think I would still recommend using mempools as they are a well tested
> and understood concept.
> I think the key difference that you are proposing is that instead of
> a single mempool with 256 slots preallocated, we have a separate mempool
> for each client with 4 slots preallocated.
> I think that would be a good change.  The 'struct mempool_s' isn't very
> large, only about 8 pointers, so havng them per-client is not a big cost.

You also need to create a slab cache for each client - /proc/slabinfo 
could grow quite a bit.

How about mempool_resize()? We could have a single pool and increase it 
by 4 for every new client. I would prefer to avoid shrinking the pool 
when connections are terminated, though. Thus it might be best to track 
the number of simultaneously active clients and increase the pool when 
it increases above the previous maximum value.

Martin

-- 
Dr. Martin Wilck
PRIMERGY System Software Engineer
x86 Server Engineering

Fujitsu Technology Solutions GmbH
Heinz-Nixdorf-Ring 1
33106 Paderborn, Germany

Phone:			++49 5251 525 2796
Fax:			++49 5251 525 2820
Email:			martin.wilck@ts.fujitsu.com
Internet:		http://ts.fujitsu.com
Company Details:	http://de.ts.fujitsu.com/imprint.html
