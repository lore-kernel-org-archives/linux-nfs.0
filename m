Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:34644 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753416AbaHGHM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2014 03:12:28 -0400
Date: Thu, 7 Aug 2014 09:12:24 +0200
From: Christoph Hellwig <hch@lst.de>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        linux-arm-kernel@lists.infradead.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [BUG] nfs3_list_one_acl oops
Message-ID: <20140807071224.GA17501@lst.de>
References: <20140726162143.GB20396@n2100.arm.linux.org.uk> <20140727131949.GB32153@infradead.org> <CAHQdGtQhEQiuObg48JrNbK5L6=r0mxfSvErVC0JS4TqxxbJy_w@mail.gmail.com> <20140806223441.GU30282@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140806223441.GU30282@n2100.arm.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 06, 2014 at 11:34:41PM +0100, Russell King - ARM Linux wrote:
> What's happening on this?  Did this get fixed for v3.16?

Trond has Andrey's patch queued up for 3.17 with a Cc to stable, so it
will go into a 3.16 stable kernel as soon as it hits Linus' tree.

