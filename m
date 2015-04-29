Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:51874 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932903AbbD2POR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2015 11:14:17 -0400
Date: Wed, 29 Apr 2015 08:14:04 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH, RFC] backchannel overflows
Message-ID: <20150429151404.GA12936@infradead.org>
References: <20150428202157.GA23972@infradead.org>
 <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 10:55:10AM -0400, Chuck Lever wrote:
> 
> On Apr 28, 2015, at 4:21 PM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> > Currently the client will just crap out if a CB_NULL comes in at the
> > same time as a slot controlled CB_COMPOUND that includes a CB_SEQUENCE.
> 
> Under what circumstances does the server send a CB_NULL while a CB_COMPOUND
> is in flight?

When a client is under heavy loads from fsx or aio-stress, and we lose
the connection (nfsd4_conn_lost is called) while doing heavy recalls.

xfstests against a server offering pnfs layouts for which the client
can't reach the storage devices is an easy reproducer.
