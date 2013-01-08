Return-Path: linux-nfs-owner@vger.kernel.org
Received: from perches-mx.perches.com ([206.117.179.246]:59167 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756765Ab3AHSJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2013 13:09:35 -0500
Message-ID: <1357668576.12749.55.camel@joe-AO722>
Subject: Re: [PATCH] sunrpc: verbs: Avoid 1kb stack
From: Joe Perches <joe@perches.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tom Tucker <tom@ogc.us>, steved@redhat.com,
        Tom Talpey <ttalpey@microsoft.com>
Date: Tue, 08 Jan 2013 10:09:36 -0800
In-Reply-To: <20130108144604.GB16343@fieldses.org>
References: <1357587696.21481.48.camel@joe-AO722>
	 <20130108144604.GB16343@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-08 at 09:46 -0500, J. Bruce Fields wrote:
> On Mon, Jan 07, 2013 at 11:41:36AM -0800, Joe Perches wrote:
> > 16 * 64 is a bit much.
> > Use kmalloc_array instead.
> 
> I thought there was some reason we didn't do this.
> 
> Grepping up through the callers....  It looks like the result is
> xprt_rdma_send_request returns -EIO, and as far as I can tell that gets
> passed up to the application on the client.   That doesn't sound right.

No worries, it was just a warning I noticed when I
did an allmodconfig compilation.

Perhaps a comment there might be appropriate instead.


