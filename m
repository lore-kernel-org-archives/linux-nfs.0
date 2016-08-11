Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062AbcHKSOw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Aug 2016 14:14:52 -0400
Date: Thu, 11 Aug 2016 14:14:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trondmy@primarydata.com>
Subject: Re: [PATCH] nfsd: don't set a FL_LAYOUT lease for flexfiles layouts
Message-ID: <20160811181400.GA2114@fieldses.org>
References: <1470936982-14409-1-git-send-email-jlayton@redhat.com>
 <20160811173846.GA26263@lst.de>
 <1470937318.30238.44.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1470937318.30238.44.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 11, 2016 at 01:41:58PM -0400, Jeff Layton wrote:
> On Thu, 2016-08-11 at 19:38 +0200, Christoph Hellwig wrote:
> > This looks fine to me, although it might be a good idea to just
> > have a flags field in the layout_ops structure for additional
> > quirks in the future instead of the boolean.
> 
> 
> Sure...that's reasonable. If and when the need arises for more flags we
> can always do the conversion to a flags field then as well.
> 
> I'll Bruce make the call on which he'd rather see...

I don't really care, so... I'll take your version as is barring other
objections.

--b.
