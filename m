Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:60476 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433Ab1HBM4L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Aug 2011 08:56:11 -0400
Date: Tue, 2 Aug 2011 08:56:08 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Peng Tao <bergwolf@gmail.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110802125608.GA1362@merit.edu>
References: <20110729191341.GC23061@merit.edu>
 <1311988172.16078.15.camel@lade.trondhjem.org>
 <20110730032621.GB25188@merit.edu>
 <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com>
 <1312233006.23392.17.camel@lade.trondhjem.org>
 <1312238117.23392.19.camel@lade.trondhjem.org>
 <20110802022144.GA18157@merit.edu>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778575@SACMVEXC2-PRD.hq.netapp.com>
 <20110802032320.GA18296@merit.edu>
 <1312288134.4616.21.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1312288134.4616.21.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  Any idea which file that thread is deleting, and why that might be
  hanging?

The test is a copy of the part of the mount command that writes /etc/mtab.
So it's doing some sequence of link, write, flock.  It does this thousands
of times, much of it in parallel.  I'll get a trace of a single instance of
this so we can see what the actual syscalls are.  I'll also see about
turning on the mutex debug.  Give me a couple of hours.

If you want to look at the source code for the test, clone this:
git://oss.sgi.com/xfs/cmds/xfstests

and it's in src/t_mtab.c.  It's driven by the "089" script.
