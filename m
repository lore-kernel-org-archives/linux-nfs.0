Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:49889 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751052AbdFRHej (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Jun 2017 03:34:39 -0400
Date: Sun, 18 Jun 2017 00:34:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 19/19] sunrpc: Disable splice for krb5i
Message-ID: <20170618073438.GA15358@infradead.org>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
 <20170616152254.14210.48071.stgit@klimt.1015granger.net>
 <20170617150705.GA27917@infradead.org>
 <A573E1EB-48DB-4E4A-B710-34914B0CF016@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A573E1EB-48DB-4E4A-B710-34914B0CF016@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 17, 2017 at 01:23:24PM -0400, Chuck Lever wrote:
> 
> > On Jun 17, 2017, at 11:07 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > On Fri, Jun 16, 2017 at 11:22:54AM -0400, Chuck Lever wrote:
> >> Running a multi-threaded 8KB fio test (70/30 mix), three or four out
> >> of twelve of the jobs fail when using krb5i. The failure is an EIO
> >> on a read.
> > 
> > Just curious: what is the backing fs that you tested with?  I'd be
> > curious if you see this on XFS for example.
> 
> I was able to reproduce this with a tmpfs share and
> with an XFS share on NVMe LUNs.

Interesting.  XFS actually locks out all writes while doing a buffered
read, so we end up with two different read instance for the hash vs
the data, which does indeed sound dangerous.
