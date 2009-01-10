Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34900 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752263AbZAJQAd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Jan 2009 11:00:33 -0500
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
 than 120 seconds"
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20090110102458.GG47559@fit.vutbr.cz>
References: <20081202152256.GI47559@fit.vutbr.cz>
	 <1228232222.3090.5.camel@heimdal.trondhjem.org>
	 <20081202162625.GM47559@fit.vutbr.cz>
	 <1228241407.3090.7.camel@heimdal.trondhjem.org>
	 <20081204102314.GW47559@fit.vutbr.cz>
	 <1229284201.6463.98.camel@heimdal.trondhjem.org>
	 <20081216120547.GS47559@fit.vutbr.cz>
	 <1230071647.17701.27.camel@heimdal.trondhjem.org>
	 <20090109145638.GC47559@fit.vutbr.cz>
	 <1231523966.7179.67.camel@heimdal.trondhjem.org>
	 <20090110102458.GG47559@fit.vutbr.cz>
Content-Type: text/plain
Date: Sat, 10 Jan 2009 11:00:00 -0500
Message-Id: <1231603200.29646.5.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2009-01-10 at 11:24 +0100, Kasparek Tomas wrote:
> > Wait. You're using amd when testing? Could you please rather retry using
> > just a static mount? amd has historically had way too many bugs
> > (particularly w.r.t. tcp) to be considered a reliable test.
> 
> Will try, but with static mount there is one stable TCP connection between
> client and server so this problem can not happen at all isn't it? 

It can. The client will automatically disconnect when the mountpoint has
not used for 5 minutes.

As for amd, I know that older versions used to set absolutely insane
timeouts for tcp connections. They'd use the same defaults as UDP, IOW
timeo=7, retrans=3 ('cat /proc/mounts' should be able to tell you if
that's the case for your setup).

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
