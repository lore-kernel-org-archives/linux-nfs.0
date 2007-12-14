From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Client performance questions
Date: Thu, 13 Dec 2007 19:57:02 -0500
Message-ID: <1197593822.7964.8.camel@heimdal.trondhjem.org>
References: <0a15723c4b267d4eb8b5ad05800315c0@swip.net>
	 <1197328226.25938.7.camel@heimdal.trondhjem.org>
	 <fjshfu$6f6$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Orion Poplawski <orion@cora.nwra.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:33105 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473AbXLNA5I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2007 19:57:08 -0500
In-Reply-To: <fjshfu$6f6$1@ger.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-12-13 at 17:07 -0700, Orion Poplawski wrote:
> Trond Myklebust wrote:
> > 
> > Have you tried increasing the value
> > in /proc/sys/fs/nfs/nfs_congestion_kb ?
> 
> Well, I just came across this message while trying to improve NFS 
> performance locally.  On my F8 client, it is set to 30400 by default. 
> Changing to 60800 kills performance.  Writes go from ~20MB/s to ~5MB/s, 
> reads from ~80MB/s to ~47MB/s as measured by bonnie++.
> 
> Expected?

UDP? If so, then possibly yes. UDP has lousy congestion control, so if
the server gets too busy to respond, then performance dies.

Trond

