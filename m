Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39179 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757861Ab0JUMky (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 08:40:54 -0400
Date: Thu, 21 Oct 2010 08:40:50 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Jim Rees <rees@umich.edu>
Cc: Christoph Hellwig <hch@infradead.org>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: Check for strlcat/cpy and compile our private
 version only if it's needed.
Message-ID: <20101021124050.GA17654@infradead.org>
References: <20101020213554.GA27541@merit.edu>
 <20101021021437.GA5241@infradead.org>
 <20101021120110.GA29219@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101021120110.GA29219@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 21, 2010 at 08:01:10AM -0400, Jim Rees wrote:
> Christoph Hellwig wrote:
> 
>   Not that I'd complain, but what Linux libc provides strlcat/cpy?
> 
> None that I know of.  The patch seems like a good idea to me, but it does
> add a couple of ugly ifdefs to the include file.
> 
> There are already quite a few much sillier checks in configure.ac, like
> memset, socket, and mkdir.
> 
> But I won't object if you want to drop this patch.

I'm just wondering why you submit it.  Do you plan to port nfs-utils to
a non-Linux system?
