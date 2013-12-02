Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35589 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab3LBPg6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 10:36:58 -0500
Date: Mon, 2 Dec 2013 07:36:54 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>,
        Viro Alexander <viro@ZenIV.linux.org.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Torvalds Linus <torvalds@linux-foundation.org>,
        Eric Biederman <ebiederm@xmission.com>
Subject: Re: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
Message-ID: <20131202153654.GB2804@infradead.org>
References: <20131201131441.790963326@bombadil.infradead.org>
 <20131201181329.GC10323@ZenIV.linux.org.uk>
 <20131202081233.GA6953@infradead.org>
 <3C65EB4C-6592-44F8-B08D-E5A9EFD6C8C6@primarydata.com>
 <529C982B.2030906@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <529C982B.2030906@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 06:24:43PM +0400, Stanislav Kinsbursky wrote:
> I'm sorry, guys, if I'm missing the point.
> But there was the reason, why all this notifier infrastructure was introduced:

And the reason is that you're a lazy bastard who let's others clean up
the poo your sprinkle over the tree, and that the maintainers weren't
strict enought to reject that massive pile of junk, which unfortunately
is the common theme in current Linux development.

> 
> "RPC pipefs mount can't be performed in kernel context since new super block
> will holds networks namespace reference and it's impossible to recognize, when
> and how we have to release this mount point."
> 
> https://lkml.org/lkml/2011/10/17/123
> 
> Circumstances has changed and now all this can be fixed much simplier?

As Al pointed our an easy workaround is easily available, and he's also
asked you about exact namespace semantics to be provided so we can
possibly find a less bad option.

