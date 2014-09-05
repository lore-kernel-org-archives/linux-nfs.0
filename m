Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:38938 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932147AbaIENgU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 09:36:20 -0400
Received: by mail-qc0-f173.google.com with SMTP id w7so12119916qcr.4
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2014 06:36:19 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 5 Sep 2014 09:36:17 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 17/17] locks: clean up comments over fl_owner_t
 definition
Message-ID: <20140905093617.2eba5693@tlielax.poochiereds.net>
In-Reply-To: <20140904175334.GH16935@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-18-git-send-email-jlayton@primarydata.com>
	<20140904175334.GH16935@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 4 Sep 2014 10:53:34 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Sep 04, 2014 at 08:38:43AM -0400, Jeff Layton wrote:
> > The contents of an fl_owner_t have morphed a bit over the years, fix up
> > the comments to account for the changes.
> 
> Instead of listing all the owners I'd just put something in like:
> 
> /* legacy typedef, will go away soon */

For some definition of "soon" ;)? How about:

   /* legacy typedef, should eventually go away */

I'll change it to read that and probably squash this change in with
another patch.

-- 
Jeff Layton <jlayton@primarydata.com>
