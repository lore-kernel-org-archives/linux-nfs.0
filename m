Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:60644 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932112AbeDCMZc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Apr 2018 08:25:32 -0400
Date: Tue, 3 Apr 2018 05:25:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, fstests@vger.kernel.org,
        Scott Mayhew <smayhew@redhat.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH xfstests] generic/035: Override output for NFS testing
Message-ID: <20180403122531.GA30598@infradead.org>
References: <e82df2bc4db926b051307ba4066d77b616c79b0c.1522337478.git.bcodding@redhat.com>
 <20180403094540.GA2254@infradead.org>
 <DA98114C-755B-4DA2-B188-3C6E27A44E93@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <DA98114C-755B-4DA2-B188-3C6E27A44E93@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 03, 2018 at 08:10:36AM -0400, Benjamin Coddington wrote:
> No, having nlink == 1 is not a bug and we should expect that behavior, the
> same with the -ESTALE return for a directory.  This is true, at least, for
> the linux client.

In terms of Linux semantics is plain and simple is a bug.  It is an
expected bug in NFS, but that doesn't make it correct.
