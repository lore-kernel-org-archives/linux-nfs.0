Return-Path: linux-nfs-owner@vger.kernel.org
Received: from na01-bl2-obe.ptr.protection.outlook.com ([65.55.169.29]:50195
	"EHLO NA01-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755141Ab3AHW5s convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2013 17:57:48 -0500
From: Tom Talpey <ttalpey@microsoft.com>
To: Joe Perches <joe@perches.com>, "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Tom Tucker <tom@ogc.us>, "steved@redhat.com" <steved@redhat.com>
Subject: RE: [PATCH] sunrpc: verbs: Avoid 1kb stack
Date: Tue, 8 Jan 2013 22:52:10 +0000
Message-ID: <614F550557B82C44AC27C492ADA391AA0443C556@TK5EX14MBXC285.redmond.corp.microsoft.com>
References: <1357587696.21481.48.camel@joe-AO722>
	 <20130108144604.GB16343@fieldses.org> <1357668576.12749.55.camel@joe-AO722>
In-Reply-To: <1357668576.12749.55.camel@joe-AO722>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Tuesday, January 8, 2013 1:10 PM
> To: J. Bruce Fields
> Cc: Trond Myklebust; David S. Miller; linux-nfs@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Tom Tucker;
> steved@redhat.com; Tom Talpey
> Subject: Re: [PATCH] sunrpc: verbs: Avoid 1kb stack
> 
> On Tue, 2013-01-08 at 09:46 -0500, J. Bruce Fields wrote:
> > On Mon, Jan 07, 2013 at 11:41:36AM -0800, Joe Perches wrote:
> > > 16 * 64 is a bit much.
> > > Use kmalloc_array instead.
> >
> > I thought there was some reason we didn't do this.

The value of RPCRDMA_MAX_DATA_SEGS appears to have been increased to allow 256KB operations (64 pages). Not all requests will need this, so you may want to consider dynamically allocating the array only when it's relatively large (*nsegs is >8, perhaps).

IIRC, the ib_phys_buf array is only built because it's passed to the FastRegister verb as a parameter. It's not needed by the xprtrdma layer.

> >
> > Grepping up through the callers....  It looks like the result is
> > xprt_rdma_send_request returns -EIO, and as far as I can tell that gets
> > passed up to the application on the client.   That doesn't sound right.
> 
> No worries, it was just a warning I noticed when I did an allmodconfig
> compilation.
> 
> Perhaps a comment there might be appropriate instead.
> 

