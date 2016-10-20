Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42178 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933643AbcJTNbJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2016 09:31:09 -0400
Date: Thu, 20 Oct 2016 06:31:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Rusty Russell <rusty@rustcorp.com.au>, linux-nfs@vger.kernel.org
Subject: Re: sg_set_buf
Message-ID: <20161020133107.GA11993@infradead.org>
References: <20161018213755.GA10777@fieldses.org>
 <20161020102200.GA6628@infradead.org>
 <20161020132030.GA2868@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161020132030.GA2868@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2016 at 09:20:30AM -0400, J. Bruce Fields wrote:
> The crypto code isn't actually doing that though, is it?
> 
> (Or is there a chance it could be passing the data to separate crypto
> hardware?  Do people do that these days?)

Yes, there are tons of crypto accelarators, and they are built around
using struct scatterlist.
