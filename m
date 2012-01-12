Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34357 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755016Ab2ALT21 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jan 2012 14:28:27 -0500
Date: Thu, 12 Jan 2012 14:28:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [patch] svcrdma: endian bug in send_write_chunks()
Message-ID: <20120112192821.GA9592@fieldses.org>
References: <20120112064722.GB2408@elgon.mountain>
 <20120112162141.GC6563@fieldses.org>
 <1326395759.6198.7.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1326395759.6198.7.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 12, 2012 at 02:15:59PM -0500, Trond Myklebust wrote:
> On Thu, 2012-01-12 at 11:21 -0500, J. Bruce Fields wrote: 
> > On Thu, Jan 12, 2012 at 09:47:22AM +0300, Dan Carpenter wrote:
> > > Sparse complains because arg_ch->rs_length is declared as network
> > > endian but we're treating it as CPU endian.
> > 
> > This looks like it would actually change behavior on a little endian
> > architecture, so how did this work before?
> > 
> > >From some quick grepping, I see assignments both of the form
> > 
> > 	...rs_length = ntohl(...)
> > 
> > and
> > 
> > 	...rs_length = htonl(...)
> > 
> > but only see one declaration for a field named rs_length.
> > 
> > So my best guess would be that the code is ugly but working as is, and
> > needs cleanup by someone who knows how this field was intended to be
> > used.
> 
> It looks to me as if rs_handle and rs_offset are being similarly abused.
> Basically, we need a serious clean up in svc_rdma_marshall.c to separate
> out those variables that are in XDR-encoded form and those that are not.

(Here everybody takes one step back and pretends to be engrossed in some
other thread.)

--b.
