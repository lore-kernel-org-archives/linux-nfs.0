Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43234 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbcFPJMm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2016 05:12:42 -0400
Date: Thu, 16 Jun 2016 02:12:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xfs@oss.sgi.com" <xfs@oss.sgi.com>
Subject: Re: [PATCH 10/12] NFS: Do not serialise O_DIRECT reads and writes
Message-ID: <20160616091241.GA15953@infradead.org>
References: <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
 <20160615071343.GC4318@infradead.org>
 <755A2A14-C6A9-4737-8335-0A6785490F6D@primarydata.com>
 <20160615144801.GB18524@infradead.org>
 <C13D01C1-4B83-442A-A0EA-D7624BE8A782@primarydata.com>
 <20160615145638.GC5297@infradead.org>
 <02DCF6B5-AFDF-4E33-A8F2-DBFE67A87E91@primarydata.com>
 <20160615151422.GA28557@infradead.org>
 <E6003989-FB5F-4FE8-A161-C6E52E031091@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E6003989-FB5F-4FE8-A161-C6E52E031091@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 15, 2016 at 03:45:37PM +0000, Trond Myklebust wrote:
> Serialisation is not mandatory in POSIX:
> 
> http://pubs.opengroup.org/onlinepubs/9699919799/functions/write.html
> 
> ???Writes can be serialized with respect to other reads and writes. If a read() of file data can be proven (by any means) to occur after a write() of the data, it must reflect that write(), even if the calls are made by different processes. A similar requirement applies to multiple write operations to the same file position. This is needed to guarantee the propagation of data from write() calls to subsequent read() calls. This requirement is particularly significant for networked file systems, where some caching schemes violate these semantics.???

That is the basic defintion, but once O_DSYNC and friends come into
play it gets more complicated:
