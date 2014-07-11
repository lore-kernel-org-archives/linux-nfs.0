Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:48271 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753421AbaGKPm3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2014 11:42:29 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so1129630qcq.20
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jul 2014 08:42:29 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 11 Jul 2014 11:42:27 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/11] nfsd: deny mode handling overhaul
Message-ID: <20140711114227.2902a15e@tlielax.poochiereds.net>
In-Reply-To: <20140711143128.GA7305@fieldses.org>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
	<20140710201448.GF26561@fieldses.org>
	<20140711074656.GA17661@infradead.org>
	<20140711143128.GA7305@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 11 Jul 2014 10:31:28 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Jul 11, 2014 at 12:46:56AM -0700, Christoph Hellwig wrote:
> > On Thu, Jul 10, 2014 at 04:14:48PM -0400, J. Bruce Fields wrote:
> > > On Thu, Jul 10, 2014 at 02:07:24PM -0400, Jeff Layton wrote:
> > > > Here is the deny mode handling overhaul broken out into a separate
> > > > series, as requested by Christoph. I've tried to address most of
> > > > his review comments, but I may have missed some. Let me know if
> > > > if I did.
> > > 
> > > They look fine to me; I'll merge them soon absent any objections from
> > > Christoph.
> > 
> > The whole series looks good, although I've not tested it yet, just the
> > original full series.
> > 
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> Thanks!
> 

Yes, thanks to both of you. The review and merging are much
appreciated. Only 89 patches to go once these go in!

-- 
Jeff Layton <jlayton@primarydata.com>
