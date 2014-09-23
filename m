Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:51646 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756280AbaIWOxw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 10:53:52 -0400
Date: Tue, 23 Sep 2014 15:53:56 +0100
From: Will Deacon <will.deacon@arm.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: WARNING at fs/nfs/write.c:743 nfs_inode_remove_request with -rc6
Message-ID: <20140923145356.GD28608@arm.com>
References: <20140923130352.GK26472@arm.com>
 <2A327753-3E60-46AC-8220-3FF0FF61F08F@primarydata.com>
 <20140923135938.GB28608@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20140923135938.GB28608@arm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 02:59:38PM +0100, Will Deacon wrote:
> On Tue, Sep 23, 2014 at 02:33:06PM +0100, Weston Andros Adamson wrote:
> > Any more info on how to reproduce this would be really great. Unfortunately I don’t
> > have access to an arm64 system.
> 
> I've not spotted a pattern other than using 64k pages, yet. If I manage to
> get a reproducer, I'll let you know.
> 
> > If it’s possible, could we get a packet trace around when this happens? This is pure
> > speculation, but this might have something to do the resend path - a commit fails
> > and all the requests on the commit list have to be resent.
> 
> Sure, once I can reproduce it reliably, then I'll try to do that.

Right, a bunch of DDing from /dev/zero over an ssh session triggers this
very quickly. I've put a binary tcpdump here:

  http://www.willdeacon.ukfsn.org/bitbucket/oopsen/nfs/tcpdump.bin

You may want to filter out the ssh packets. The only `interesting' thing to
me is a retransmission about half way through, but I don't know what I'm
looking for.

The NFS server is 10.1.203.204 and the client is 10.1.203.24.

Will
