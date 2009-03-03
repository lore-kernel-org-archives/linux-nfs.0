Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19089 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876AbZCCOQ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2009 09:16:29 -0500
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
 than 120 seconds"
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20090303120848.GV89843@fit.vutbr.cz>
References: <20090110102458.GG47559@fit.vutbr.cz>
	 <1231603200.29646.5.camel@heimdal.trondhjem.org>
	 <20090112090404.GL47559@fit.vutbr.cz>
	 <1231782009.7322.12.camel@heimdal.trondhjem.org>
	 <1231809446.7322.17.camel@heimdal.trondhjem.org>
	 <20090113152201.GD47559@fit.vutbr.cz> <20090116104802.GF47559@fit.vutbr.cz>
	 <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz>
	 <1232465547.7055.3.camel@heimdal.trondhjem.org>
	 <20090303120848.GV89843@fit.vutbr.cz>
Content-Type: text/plain
Date: Tue, 03 Mar 2009 09:16:07 -0500
Message-Id: <1236089767.9631.4.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2009-03-03 at 13:08 +0100, Kasparek Tomas wrote:
> On Tue, Jan 20, 2009 at 10:32:27AM -0500, Trond Myklebust wrote:
> > A binary wireshark dump of the traffic between one such client and the
> > server would help.
> 
> I was able to finally got the tcpdump. I got it from 2.6.27.19 client but
> after several weeks without problems. I include the file and place it on
> http://merlin.fit.vutbr.cz/tmp/nfs/dump_kas2_mat.dump_small (have over 1GB
> of dump, but it's all the time the same SYN+RST packets). The packet rate
> maxed at 260000pps from two clients.
> 
> This dump is taken from server after reset (the server does not respond
> even to keybord) before clients are disconnected/rebooted. To remind it - all
> clients seems to work well with reversed
> e06799f958bf7f9f8fae15f0c6f519953fb0257c

Yes. I saw that behaviour when testing at Connectathon last week. When
one of the servers I was testing against crashed and later came up
again, the patched client went into that same SYN+RST frenzy. I'm
planning to look at this now that I'm back at home.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
