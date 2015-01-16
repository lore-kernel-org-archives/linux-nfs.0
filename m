Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49770 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbAPNjF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jan 2015 08:39:05 -0500
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1YC77B-0000Bg-8W
	for linux-nfs@vger.kernel.org; Fri, 16 Jan 2015 13:39:05 +0000
Date: Fri, 16 Jan 2015 05:39:05 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: Re: xfstests generic/075 failure on recent Linus' tree
Message-ID: <20150116133905.GA473@infradead.org>
References: <20141020173658.GA7552@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141020173658.GA7552@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI, I'm still seeing this in current Linus' HEAD, not just on
a single machine, but also when using multiple VMs on the same host.
I can't actually test multiple physical hosts, so I wonder if anyone
else can still reproduce it, and if yes wit which setup.

On Mon, Oct 20, 2014 at 10:36:58AM -0700, Christoph Hellwig wrote:
> Running 4.1 against a same host server backed off XFS I run into
> a hang in generic/075:
> 
> generic/075 18s ...[  408.796877] nfs: server 127.0.0.1 not responding, still trying
> [  408.799131] nfs: server 127.0.0.1 not responding, still trying
> [  408.801357] nfs: server 127.0.0.1 not responding, still trying
> [  443.676971] nfs: server 127.0.0.1 not responding, timed out
> [  623.837009] nfs: server 127.0.0.1 not responding, timed out
> [  628.716855] nfs: server 127.0.0.1 not responding, timed out
> [  803.996883] nfs: server 127.0.0.1 not responding, timed out
> [  813.783542] nfs: server 127.0.0.1 not responding, timed out
> [  984.156873] nfs: server 127.0.0.1 not responding, timed out
> [  998.876901] nfs: server 127.0.0.1 not responding, timed out
> 
---end quoted text---
