From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 03/33] SUNRPC: Don't attempt to destroy expired
	RPCSEC_GSS credentials..
Date: Thu, 24 Apr 2008 13:48:29 -0400
Message-ID: <1209059309.7619.2.camel@heimdal.trondhjem.org>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080419204047.14124.64969.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <FB8780E7-FE92-40D6-8DFE-0663DF1B0162@oracle.com>
	 <1208822443.7767.23.camel@heimdal.trondhjem.org>
	 <86898638-C54D-44F7-917E-1EDF6795B56C@oracle.com>
	 <1208876800.11982.6.camel@heimdal.trondhjem.org>
	 <1208960443.7459.9.camel@heimdal.trondhjem.org>
	 <20080423181935.GC5280@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48821 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989AbYDXRsT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Apr 2008 13:48:19 -0400
In-Reply-To: <20080423181935.GC5280@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-04-23 at 14:19 -0400, J. Bruce Fields wrote:
> On Wed, Apr 23, 2008 at 10:20:43AM -0400, Trond Myklebust wrote:
> > 
> > On Tue, 2008-04-22 at 11:11 -0400, Trond Myklebust wrote:
> > > On Tue, 2008-04-22 at 09:38 -0400, Chuck Lever wrote:
> > > > > RFC-2203 states that servers are supposed to silently discard requests
> > > > > that they don't recognise (see section 5.3.3.1 - Context  
> > > > > Management), so
> > > > > it is correct server behaviour.
> > > > 
> > > > 
> > > > Dropping the request to destroy a context is fine.  Temporarily  
> > > > fencing the client is what I was concerned about.
> > > 
> > > I'd agree that is somewhat drastic, and have passed the information on
> > > to the server vendor, however that doesn't change the fact that we have
> > > a client bug too: we should not be using expired creds.
> > > 
> > > The client side performance problem was compounded by the fact that the
> > > RPCSEC_GSS destruction call was sent as a hard RPC call, and the fact
> > > that we impose the NFSv4 rule that we need to drop the connection before
> > > resending a request.
> > 
> > Having thought a bit more about the consequences of this RFC, I think we
> > also need to drop the credential on (major) timeouts, since we need to
> > assume that the timeout may be due to the credential being out of
> > sequence.
> 
> I'm a little confused.  Each resend is done with a new gss sequence
> number.

The point is that if the _server_ gets confused, then it may not tell us
that our context is invalid: it will just start dropping all the
requests that we send it.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
