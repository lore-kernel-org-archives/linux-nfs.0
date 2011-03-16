Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:42235 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab1CPXvP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 19:51:15 -0400
Date: Wed, 16 Mar 2011 16:51:13 -0700
From: Simon Kirby <sim@hostway.ca>
To: Judith Flo Gaya <jflo@imppc.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: problem with nfs latency during high IO
Message-ID: <20110316235113.GG23526@hostway.ca>
References: <4D7B6DE5.8010008@imppc.org> <526EE4AA-ABD2-4452-9C3A-C000BD3CFC60@oracle.com> <4D7FA11F.5020604@imppc.org> <21A84B17-E061-4441-9181-100AC8E473E2@oracle.com> <4D7FDB14.6090908@imppc.org> <9CC4990D-6969-4788-8B52-BA5AF2743DE3@oracle.com> <4D7FE0E8.5050701@imppc.org> <16BF52F0-4D1A-4B68-ADEE-DC70255A139C@oracle.com> <4D80A2DE.2030507@imppc.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D80A2DE.2030507@imppc.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 16, 2011 at 12:45:34PM +0100, Judith Flo Gaya wrote:

> I made some tests with a value of 10 for the vm_dirty_ratio and indeed  
> the ls-hang-time has decreased a lot, from 3min avg to 1.5min.
> I was wondering what is the minimum number that it is safe to use? I'm  
> sure that you have already dealt with the side-effects/collateral  
> damages of this action,  I don't want to fix a problem creating another  
> one..

For a while, we were running with this on production NFS clients:

vm/dirty_background_bytes = 1048576
vm/dirty_bytes = 2097152

which is totally crazy, but generally seemed to work for the most part,
and penalized the process creating the pages instead of totally hosing
everything else when somebody was just writing back a huge file. Without
it, we were seeing a single "dd" able to cause the load to hit 200,
simply because 200 other processes got stuck in D waiting for RPC slots
due to the slowdown. With those settings, load would stay around 3-4 and
latency was much better.

I think I removed it when trying to figure out the other flush issues,
but it seems the same problem still exists.

Simon-
