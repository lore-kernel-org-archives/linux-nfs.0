Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:52658 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752627AbdCIQu3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Mar 2017 11:50:29 -0500
Date: Thu, 9 Mar 2017 08:17:29 -0800
From: "hch@infradead.org" <hch@infradead.org>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: "hch@infradead.org" <hch@infradead.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kolga@netapp.com" <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170309161729.GA11655@infradead.org>
References: <20170308172549.GA32011@infradead.org>
 <7FDA8E80-3C62-48BB-9E2B-195B4BA340C0@netapp.com>
 <20170308195327.GA3492@fieldses.org>
 <85310DA6-7270-49AE-A310-76D73678B1B1@netapp.com>
 <1489004308.3098.10.camel@primarydata.com>
 <20170308203236.GC3492@fieldses.org>
 <1489006194.3098.12.camel@primarydata.com>
 <20170309152948.GB3929@fieldses.org>
 <20170309153559.GA20205@infradead.org>
 <20170309161601.GC3929@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170309161601.GC3929@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 09, 2017 at 11:16:01AM -0500, bfields@fieldses.org wrote:
> I guess I'm just hung up on the EINVAL vs. short copy behavior.  It
> seems more annoying and error-prone to be prepared for both, as opposed
> to trying clone and then explicitly falling back to copy if that doesn't
> work.  Maybe it's not that big a deal.

We can do short copies^H^H^H^H^Hclones for clone just as easily,
at least for local filesystems (NFS would require some tweaks due to the
protocol).
