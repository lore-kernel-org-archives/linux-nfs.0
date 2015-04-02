Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:34769 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753172AbbDBIhK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2015 04:37:10 -0400
Date: Thu, 2 Apr 2015 10:37:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: add support for the "pnfs" export option
Message-ID: <20150402083707.GA12653@lst.de>
References: <1427876113-27004-1-git-send-email-hch@lst.de> <20150401174808.GB3040@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150401174808.GB3040@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2015 at 01:48:09PM -0400, J. Bruce Fields wrote:
> On Wed, Apr 01, 2015 at 10:15:13AM +0200, Christoph Hellwig wrote:
> > This goes along with the patch just sent to Bruce to make pnfs
> > support conditional.
> 
> Could we get an update of utils/exportfs/exports.man too?

Yes, v3 will follow ASAP.  Should have read my whole inbox before starting to
update the patch..
