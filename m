Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46554 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932726AbcJUM0R (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2016 08:26:17 -0400
Date: Fri, 21 Oct 2016 05:26:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Rusty Russell <rusty@rustcorp.com.au>, linux-nfs@vger.kernel.org,
        linux-crypto@vger.kernel.org
Subject: Re: sg_set_buf
Message-ID: <20161021122614.GA28059@infradead.org>
References: <20161018213755.GA10777@fieldses.org>
 <20161020102200.GA6628@infradead.org>
 <20161020132030.GA2868@fieldses.org>
 <20161020133107.GA11993@infradead.org>
 <20161020214219.GC4347@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161020214219.GC4347@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2016 at 05:42:19PM -0400, J. Bruce Fields wrote:
> Turns out there are several places in the kerberos code where it just
> needs to encrypt one small checksum or sequence number, and it's been
> doing that on the stack.
> 
> For now I'll just sprinkle kmalloc()'s all over.  Eventually we'll need
> to find something better.

I agree that it would be nice to be able to hash small objects on the
stack.  But unless I've missed something there is no way to do that
without using struct scatterlist.  I've added linux-crypto to the cc
list to confirm that I really didn't miss anything.
