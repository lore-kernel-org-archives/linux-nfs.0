Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37048 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab3LKQbx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Dec 2013 11:31:53 -0500
Date: Wed, 11 Dec 2013 11:31:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 3/3] nfsd: convert DRC code to use list_lru
Message-ID: <20131211163148.GD29300@fieldses.org>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
 <1386241253-5781-4-git-send-email-jlayton@redhat.com>
 <20131205134129.GE3381@infradead.org>
 <20131205084825.2bf1726d@tlielax.poochiereds.net>
 <20131205155823.GD30113@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131205155823.GD30113@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 05, 2013 at 10:58:23AM -0500, J. Bruce Fields wrote:
> On Thu, Dec 05, 2013 at 08:48:25AM -0500, Jeff Layton wrote:
> > On Thu, 5 Dec 2013 05:41:29 -0800
> > Christoph Hellwig <hch@infradead.org> wrote:
> > > All together doesn't seem to helpful as long as the DRC keeps
> > > it's own timing based purge and similar bits unfortunatel.
> > 
> > Agreed. It might make sense to do this in the context of a larger
> > redesign but otherwise I can't get too excited about this set, TBH...
> 
> Well, patch 1/3 still deletes some code and doesn't have any obvious
> downsides.

I'm applying that one patch and dropping the rest for now.

I understand Christoph's request to remove the one-off cache pruning but
first want to be convinced that's safe.

--b.
