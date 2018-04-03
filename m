Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:43218 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752486AbeDCJpk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Apr 2018 05:45:40 -0400
Date: Tue, 3 Apr 2018 02:45:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: fstests@vger.kernel.org, Scott Mayhew <smayhew@redhat.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH xfstests] generic/035: Override output for NFS testing
Message-ID: <20180403094540.GA2254@infradead.org>
References: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 29, 2018 at 11:34:39AM -0400, Benjamin Coddington wrote:
> We'd like to run generic tests for NFS, but often have slightly different
> output for our results.  One instance is that for the NFS client the
> removal of an open file or directory is handled differently than for a
> local filesystem.  We can expect nlink to be 1 for files, and to receive
> -ESTALE for operations on deleted directories, isn't that silly?

NFS is simply buggy in this case, and we should at least xfail the test
case, not make it look fine.

I'd rather have a file that lists expected fails per file system with an
explanation than a hack like this that papers over the issue.
