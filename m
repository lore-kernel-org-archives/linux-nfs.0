Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36422 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752526AbcK2UrX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 15:47:23 -0500
Date: Tue, 29 Nov 2016 15:47:22 -0500
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, fstests@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/4] Add copy_file_range() tests
Message-ID: <20161129204722.GA9331@fieldses.org>
References: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
 <20161026082638.GA19419@infradead.org>
 <20161125080509.GA6082@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161125080509.GA6082@infradead.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 25, 2016 at 12:05:10AM -0800, Christoph Hellwig wrote:
> On Wed, Oct 26, 2016 at 01:26:38AM -0700, Christoph Hellwig wrote:
> > On Wed, Sep 07, 2016 at 03:56:15PM -0400, Anna Schumaker wrote:
> > > These tests exercise the copy_file_range() system call, and check copying
> > > data to both a new file and overwriting data inside an existing file.  I use
> > > the xfs_io "copy_range" command for the actual copies, so running these
> > > tests requires an up-to-date version of xfsprogs.
> > 
> > Hi Anna,
> > 
> > what's the status of these tests?  Did you get a chance to look
> > into xfs_io copyfile support?
> 
> Another month, another ping - it would be really sad to not have any
> real testing for copy_file_range.

Agreed, Anna, are you still planning on doing this?

--b.

> I've been holding a pending change
> for it back for month now because I want to verify it more than cursory,
> but I guess I'll just have to send it anyway.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
