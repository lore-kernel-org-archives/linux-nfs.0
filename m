From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH RFC 02/10] nfsd41: sunrpc: Added rpc server-side
	backchannel handling
Date: Mon, 24 Aug 2009 19:51:33 -0400
Message-ID: <20090824235133.GG8532@fieldses.org>
References: <4A8C9992.2000505@panasas.com> <1250728463-28511-1-git-send-email-bhalevy@panasas.com> <20090824233419.GE8532@fieldses.org> <1251157347.6325.364.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org, Rahul Iyer <iyer@netapp.com>,
	Mike Sager <sager@netapp.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Andy Adamson <andros@netapp.com>,
	Alexandros Batsakis <batsakis@netapp.com>,
	Trond Myklebust <trond@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753679AbZHXXvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2009 19:51:31 -0400
In-Reply-To: <1251157347.6325.364.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 24, 2009 at 07:42:27PM -0400, Trond Myklebust wrote:
> On Mon, 2009-08-24 at 19:34 -0400, J. Bruce Fields wrote:
> > On Thu, Aug 20, 2009 at 03:34:23AM +0300, Benny Halevy wrote:
> > > From: Rahul Iyer <iyer@netapp.com>
> > > 
> > > Signed-off-by: Rahul Iyer <iyer@netapp.com>
> > > Signed-off-by: Mike Sager <sager@netapp.com>
> > > Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
> > > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > > Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> > 
> > This patch needs an ACK from Trond.
> > 
> > > 
> > > When the call direction is a reply, copy the xid and call direction into the
> > > req->rq_private_buf.head[0].iov_base otherwise rpc_verify_header returns
> > > rpc_garbage.
> > 
> > Looks mostly OK, though blocking the client rpciod on the
> > bc_send_request method may be a problem--rpciod normally tries not to
> > sleep, and the other send_request methods look like they avoid it.
> 
> Agreed. Blocking on sending is unacceptable inside rpciod. Please either
> use non-blocking I/O, or use a different thread context for this.

We did some work to avoid having to spawn a thread on the server for
every recall, and I'd still prefer to avoid that.

But I'm not sure what's required to make the server send routine
non-blocking.

--b.
