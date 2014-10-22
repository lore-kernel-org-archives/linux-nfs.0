Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33279 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754727AbaJVTXA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2014 15:23:00 -0400
Date: Wed, 22 Oct 2014 15:22:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfsd4: fix response size estimation for OP_SEQUENCE
Message-ID: <20141022192258.GB5552@fieldses.org>
References: <20141017212446.GC3474@fieldses.org>
 <20141021103631.GB21863@infradead.org>
 <20141021131406.GE9863@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141021131406.GE9863@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 21, 2014 at 09:14:06AM -0400, J. Bruce Fields wrote:
> Also my tests are failing due to an unrelated crash in 18-rc1 which I
> want to track down before sending this in.

There are two bugs:

	- the client is sending SEEK over minorversion 1.
	- this sometimes causes the server to crash.

I'm testing a fix for the latter.

On the former: looks like if 4.2 support is built in, then llseek is set
to nfs4_file_llseek, which unconditionally calls nfs42_proc_llseek().

Does nfs4_file_llseek need an explicit minorversion check, or should it
be handled some other way?

--b.
