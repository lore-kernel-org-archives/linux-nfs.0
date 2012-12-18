Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:60347 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754307Ab2LRUgk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Dec 2012 15:36:40 -0500
Date: Tue, 18 Dec 2012 15:34:24 -0500
From: Jim Rees <rees@umich.edu>
To: Keith Edmunds <kae@midnighthax.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: NFS access slow
Message-ID: <20121218203424.GA15891@umich.edu>
References: <20121218155248.49dfa1fd@kae.tiger-computing.wbp>
 <20121218185006.GA14716@fieldses.org>
 <20121218194251.5bf674ff@ws.the.cage>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121218194251.5bf674ff@ws.the.cage>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Keith Edmunds wrote:

  OK, I wasn't aware of that. We were only testing that way to try to
  eliminate switches, cables, etc. I've just run a test from another server,
  both connected via 10G links, and I'm getting a read speed of just under
  20BM/s and a write speed of 52MB/s.

Something's wrong. What numbers do you get from iperf, or even something
like wget? Are you setting anything unusual with sysctl?
