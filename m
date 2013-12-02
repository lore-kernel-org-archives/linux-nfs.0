Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:57573 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab3LBQEs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 11:04:48 -0500
Received: by mail-ie0-f182.google.com with SMTP id as1so21469791iec.13
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 08:04:48 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20131202155722.GE10323@ZenIV.linux.org.uk>
Date: Mon, 2 Dec 2013 11:04:46 -0500
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Torvalds Linus <torvalds@linux-foundation.org>,
        Eric Biederman <ebiederm@xmission.com>
Message-Id: <7A4180B4-04D9-4D3C-87AC-820C395599C8@primarydata.com>
References: <20131201131441.790963326@bombadil.infradead.org> <20131201181329.GC10323@ZenIV.linux.org.uk> <20131202081233.GA6953@infradead.org> <3C65EB4C-6592-44F8-B08D-E5A9EFD6C8C6@primarydata.com> <20131202155722.GE10323@ZenIV.linux.org.uk>
To: Viro Alexander <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 2, 2013, at 10:57, Al Viro <viro@ZenIV.linux.org.uk> wrote:

> Trond, am I right interpreting you as "that filesystem has non-empty
> contents only when there is at least one rpc_client in that netns;
> after rpc_client removal there won't be any accesses to data structures
> associated with it (due to rpc_close_pipes() and friends, presumably),
> so there won't be any need to keep netns alive after that"?
> 
> If so and if rpc_client really can't outlive netns, then yes, having each 
> of them hold an internal vfsmount reference pinning rpc_pipefs down would
> suffice.

We do have some “external” users but in practice their lifetimes are bounded by the lifetimes of the rpc_clients (See my reply to Christoph’s mail).

So yes, I believe that it is the case that we need at least one rpc_client in a given nets for the filesystem to be non-empty.

Cheers,
  Trond