Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:41159 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbaKLKYo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Nov 2014 05:24:44 -0500
Date: Wed, 12 Nov 2014 11:24:40 +0100
From: Christoph Hellwig <hch@lst.de>
To: Dave Chinner <david@fromorbit.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
Message-ID: <20141112102440.GA31344@lst.de>
References: <20141111162849.GA12527@lst.de> <20141111162704.GA12103@lst.de> <20141111222710.GY23575@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141111222710.GY23575@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2014 at 09:27:10AM +1100, Dave Chinner wrote:
> To clarify what Christoph wrote, XFS updates i_version is updated
> once per transaction that modifies the inode. So if a VFS level
> operation results in multiple transactions then each transaction
> will but the version.
> 
> It was implemented that way because nobody could tell me what the
> actual granularity requirement for change detection was.  Hence what
> I implemented was "be able to detect any persistent change that is
> made" to cover all bases.

Honestly the XFS implementation seems most sensible, and easiest to
verify for me.  I don't really understand the rationale behind the
fairly convoluted NFS4_CHANGE_TYPE_IS_VERSION_COUNTER semantics, and
I doubt you could actually implemet them on any Unix-like semantics.

Trond, given that the language in the standard is from you:

 1) how do you expect to use NFS4_CHANGE_TYPE_IS_VERSION_COUNTER
    semantics in the client
 2) what server do you have in mind that could actually implement them?
