Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:55382 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807Ab3LBQq6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 11:46:58 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so20425089ieb.25
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 08:46:58 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20131202162716.GA17417@infradead.org>
Date: Mon, 2 Dec 2013 11:46:55 -0500
Cc: Viro Alexander <viro@ZenIV.linux.org.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Torvalds Linus <torvalds@linux-foundation.org>,
        Eric Biederman <ebiederm@xmission.com>
Message-Id: <6454B55B-9C16-4A86-A7B1-4480E965DC6E@primarydata.com>
References: <20131201131441.790963326@bombadil.infradead.org> <20131201181329.GC10323@ZenIV.linux.org.uk> <20131202081233.GA6953@infradead.org> <3C65EB4C-6592-44F8-B08D-E5A9EFD6C8C6@primarydata.com> <20131202153435.GA2804@infradead.org> <BCED1826-0743-4420-AD45-B38D67EF3D99@primarydata.com> <20131202162716.GA17417@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 2, 2013, at 11:27, Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Dec 02, 2013 at 11:00:50AM -0500, Trond Myklebust wrote:
>>> Except for the non-rpc_client users of rpc_pipefs?
>> 
>> There is the idmapper pipe which is created as part of setting up a NFSv4 mount: that could either call rpc_get_mount(), or just rely on the fact that the nfs_client has an rpc_client. Ditto for the DNS resolver pipe.
> 
> We got idmapper, dns, pnfs-block upcall.
> 
> idmapper seems per-nfs_client, the other two are created on module load
> and removed at unload time.

Do they need to be? AFAICS, we can trivially convert the DNS resolver to be created on mount. The pnfs block upcall looks to be a little more difficult, but we should be able to do it in ld_type->set_layoutdriver()/clear_layoutdriver().

> Similarly the pipe in nfsd works globally as well.

Mount the rpc_pipefs in nfs4_state_create_net() and unmount it in nfs4_state_destroy_net()?

Cheers
  Trond