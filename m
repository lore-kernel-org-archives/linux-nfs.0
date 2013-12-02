Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35767 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab3LBQ1T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 11:27:19 -0500
Date: Mon, 2 Dec 2013 08:27:16 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Viro Alexander <viro@ZenIV.linux.org.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Torvalds Linus <torvalds@linux-foundation.org>,
        Eric Biederman <ebiederm@xmission.com>
Subject: Re: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
Message-ID: <20131202162716.GA17417@infradead.org>
References: <20131201131441.790963326@bombadil.infradead.org>
 <20131201181329.GC10323@ZenIV.linux.org.uk>
 <20131202081233.GA6953@infradead.org>
 <3C65EB4C-6592-44F8-B08D-E5A9EFD6C8C6@primarydata.com>
 <20131202153435.GA2804@infradead.org>
 <BCED1826-0743-4420-AD45-B38D67EF3D99@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BCED1826-0743-4420-AD45-B38D67EF3D99@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 11:00:50AM -0500, Trond Myklebust wrote:
> > Except for the non-rpc_client users of rpc_pipefs?
> 
> There is the idmapper pipe which is created as part of setting up a NFSv4 mount: that could either call rpc_get_mount(), or just rely on the fact that the nfs_client has an rpc_client. Ditto for the DNS resolver pipe.

We got idmapper, dns, pnfs-block upcall.

idmapper seems per-nfs_client, the other two are created on module load
and removed at unload time.

Similarly the pipe in nfsd works globally as well.
