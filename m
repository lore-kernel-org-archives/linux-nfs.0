Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:43608 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932098Ab3LDLTg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 06:19:36 -0500
Date: Wed, 4 Dec 2013 03:19:33 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Antti T?nkyr? <daedalus@pingtimeout.net>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
Message-ID: <20131204111933.GA20218@infradead.org>
References: <529CEBC3.8060505@pingtimeout.net>
 <20131204083118.GA30216@infradead.org>
 <529F0EDD.1070403@pingtimeout.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <529F0EDD.1070403@pingtimeout.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 04, 2013 at 01:15:41PM +0200, Antti T?nkyr? wrote:
> On 2013-12-04 10:31, Christoph Hellwig wrote:
> >Please just fix ntfs to do the mapping for you, EILSEQ is not an
> >error the VFS or applications expect either.
> >
> How would you propose the mapping to be done? Are you sure about
> EILSEQ not being an error that VFS/applications expect, my userspace
> tools seem to handle local filesystem returning EILSEQ just fine?

EILSEQ doesn't have a specified meaning for VFS operations.  Of course
your app could handle it in some way, but that's your implementation
specific way that has not base for it.

> Moreover I think we really should see why nfs goes into permanent
> I/O error state when this is triggered. I don't really mind seeing
> nfs unhandled error codes in my kernel log and I/O error on the nfs
> client when trying to write badly named files but the fact we cannot
> recover from the situation (without closing all handles to the open
> share) is alarming.

No argument on that.  Just saying that the mapping you proposed is not a
good idea.

