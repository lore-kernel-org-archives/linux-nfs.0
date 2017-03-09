Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58732 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753861AbdCIQQE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 11:16:04 -0500
Date: Thu, 9 Mar 2017 11:16:01 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "hch@infradead.org" <hch@infradead.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kolga@netapp.com" <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170309161601.GC3929@fieldses.org>
References: <20170308170521.GA1020@fieldses.org>
 <20170308172549.GA32011@infradead.org>
 <7FDA8E80-3C62-48BB-9E2B-195B4BA340C0@netapp.com>
 <20170308195327.GA3492@fieldses.org>
 <85310DA6-7270-49AE-A310-76D73678B1B1@netapp.com>
 <1489004308.3098.10.camel@primarydata.com>
 <20170308203236.GC3492@fieldses.org>
 <1489006194.3098.12.camel@primarydata.com>
 <20170309152948.GB3929@fieldses.org>
 <20170309153559.GA20205@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170309153559.GA20205@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 09, 2017 at 07:35:59AM -0800, hch@infradead.org wrote:
> On Thu, Mar 09, 2017 at 10:29:48AM -0500, bfields@fieldses.org wrote:
> > So I don't understand why it needed to be added to copy_file_range().
> > The copy and clone semantics are different enough that I think callers
> > want to know which they're getting.
> 
> Because if a file systems implements clone is literally is always better
> than doing a copy loop, so using it is an absolute non-brainer.

I guess I'm just hung up on the EINVAL vs. short copy behavior.  It
seems more annoying and error-prone to be prepared for both, as opposed
to trying clone and then explicitly falling back to copy if that doesn't
work.  Maybe it's not that big a deal.

> They do, and the system call has been in the tree for almost a year and
> a half, so we can't simply change it.  Fortunately we do have a flags
> argument that can be used to implement your preferred semantics if you
> care deeply enough about them.

Yeah.

There are also some other offset, length combinations that currently
return -EINVAL, I wonder if any of those could be repurposed e.g. for a
"keep copying to end of file" call.

--b.
