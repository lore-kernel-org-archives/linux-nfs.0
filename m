Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:36403 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757316Ab0JUMBO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 08:01:14 -0400
Date: Thu, 21 Oct 2010 08:01:10 -0400
From: Jim Rees <rees@umich.edu>
To: Christoph Hellwig <hch@infradead.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: Check for strlcat/cpy and compile our
 private version only if it's needed.
Message-ID: <20101021120110.GA29219@merit.edu>
References: <20101020213554.GA27541@merit.edu>
 <20101021021437.GA5241@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101021021437.GA5241@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Christoph Hellwig wrote:

  Not that I'd complain, but what Linux libc provides strlcat/cpy?

None that I know of.  The patch seems like a good idea to me, but it does
add a couple of ugly ifdefs to the include file.

There are already quite a few much sillier checks in configure.ac, like
memset, socket, and mkdir.

But I won't object if you want to drop this patch.
