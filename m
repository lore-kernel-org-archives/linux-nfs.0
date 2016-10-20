Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42286 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753520AbcJTVmV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Oct 2016 17:42:21 -0400
Date: Thu, 20 Oct 2016 17:42:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, linux-nfs@vger.kernel.org
Subject: Re: sg_set_buf
Message-ID: <20161020214219.GC4347@fieldses.org>
References: <20161018213755.GA10777@fieldses.org>
 <20161020102200.GA6628@infradead.org>
 <20161020132030.GA2868@fieldses.org>
 <20161020133107.GA11993@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161020133107.GA11993@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2016 at 06:31:07AM -0700, Christoph Hellwig wrote:
> On Thu, Oct 20, 2016 at 09:20:30AM -0400, J. Bruce Fields wrote:
> > The crypto code isn't actually doing that though, is it?
> > 
> > (Or is there a chance it could be passing the data to separate crypto
> > hardware?  Do people do that these days?)
> 
> Yes, there are tons of crypto accelarators, and they are built around
> using struct scatterlist.

OK, thanks.

Turns out there are several places in the kerberos code where it just
needs to encrypt one small checksum or sequence number, and it's been
doing that on the stack.

For now I'll just sprinkle kmalloc()'s all over.  Eventually we'll need
to find something better.

--b.
