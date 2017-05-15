Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:43814 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933896AbdEOPow (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 11:44:52 -0400
Date: Mon, 15 May 2017 17:44:50 +0200
From: hch <hch@lst.de>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: Trond Myklebust <trondmy@primarydata.com>, hch <hch@lst.de>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: remove function pointer casts and constify function tables
Message-ID: <20170515154450.GA18630@lst.de>
References: <20170512161701.22468-1-hch@lst.de> <1494620040.19467.1.camel@primarydata.com> <20170513072557.GA14602@lst.de> <1494691819.31377.1.camel@primarydata.com> <20170515152134.GC24547@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170515152134.GC24547@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 15, 2017 at 11:21:34AM -0400, bfields@fieldses.org wrote:
> On Sat, May 13, 2017 at 04:10:21PM +0000, Trond Myklebust wrote:
> > Right, so the alternative is that either Bruce or Anna merges the full
> > set, and then both pull that common base into their linux-next branches
> > on linux-nfs.org, and we then ask everyone to develop their 4.13
> > patches against those branches. That would work too...
> 
> I like that.  Christoph, could you just give us a 12-rc1-based branch to
> base our 4.13 work on?

    git://git.infradead.org/users/hch/vfs.git nfs-ops

Gitweb:

    http://git.infradead.org/users/hch/vfs.git/shortlog/refs/heads/nfs-ops

> 
> --b.
---end quoted text---
