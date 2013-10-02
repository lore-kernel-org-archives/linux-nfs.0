Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41697 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754157Ab3JBVIA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 17:08:00 -0400
Date: Wed, 2 Oct 2013 17:07:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, sandeen@redhat.com
Subject: Re: why is i_ino unsigned long, anyway?
Message-ID: <20131002210736.GA20598@fieldses.org>
References: <20130912160324.GE1462@fieldses.org>
 <20130912193328.GP13318@ZenIV.linux.org.uk>
 <20130929115454.GA3953@infradead.org>
 <20131002142527.GD14808@fieldses.org>
 <20131002160527.GB23875@infradead.org>
 <20131002175328.GF14808@fieldses.org>
 <20131002175727.GA29467@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131002175727.GA29467@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 02, 2013 at 10:57:27AM -0700, Christoph Hellwig wrote:
> > Something like this?
> 
> Looks good, although I'd split it into two separate patches for the VFS
> and exportfs bits.

Hm, this might be to the point of leaving the first patch a little
unmotivated, but OK, maybe so.

Thanks for the review!

--b.
