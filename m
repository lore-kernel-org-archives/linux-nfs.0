Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42578 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965905AbdEOPVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 11:21:35 -0400
Date: Mon, 15 May 2017 11:21:34 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: hch <hch@lst.de>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: remove function pointer casts and constify function tables
Message-ID: <20170515152134.GC24547@fieldses.org>
References: <20170512161701.22468-1-hch@lst.de>
 <1494620040.19467.1.camel@primarydata.com>
 <20170513072557.GA14602@lst.de>
 <1494691819.31377.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1494691819.31377.1.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 13, 2017 at 04:10:21PM +0000, Trond Myklebust wrote:
> Right, so the alternative is that either Bruce or Anna merges the full
> set, and then both pull that common base into their linux-next branches
> on linux-nfs.org, and we then ask everyone to develop their 4.13
> patches against those branches. That would work too...

I like that.  Christoph, could you just give us a 12-rc1-based branch to
base our 4.13 work on?

--b.
