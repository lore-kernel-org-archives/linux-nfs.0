Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33902 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbbEYPNR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 May 2015 11:13:17 -0400
Date: Mon, 25 May 2015 08:13:10 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin ESTRABAUD <be@mpstor.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bc@mpstor.com" <bc@mpstor.com>, Christoph Hellwig <hch@infradead.org>
Subject: Re: Issue running buffered writes to a pNFS (NFS 4.1 backed by SAN)
 filesystem.
Message-ID: <20150525151310.GA18386@infradead.org>
References: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com>
 <20150515192037.GB29627@fieldses.org>
 <555CB5EE.2@mpstor.com>
 <555CD2F0.6080408@mpstor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <555CD2F0.6080408@mpstor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 20, 2015 at 07:31:12PM +0100, Benjamin ESTRABAUD wrote:
> After 25 iterations (after creating a 25GiB file, for a cumulative total of
> 325GiB if including the testfile.1G -> testfile.24G) the issue occured
> again. The IO rate to the SAN LUN dropped severely to a real 3MiB/sec
> (measured at the SAN LUN block device level).
> 
> Also I've noticed that a kernel process is taking up 100% of one core at
> least:
> 
> 516 root      20   0       0      0      0 R 100.0  0.0  11:09.72
> kworker/u49:4

Can you send me the output of "perf record -ag" for that run?

Also can you send the output from trace-cmd for tracing all nfsd.layout*
tracepoints for such a run?

> Would the 25GiB figure ring any bells to you? Would there be a way for me to
> identify this workqueue (figure out if it is pNFS related)?

Perf record should help by looking at the cycles spent.
