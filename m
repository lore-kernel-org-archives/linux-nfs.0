From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 03/33] SUNRPC: Don't attempt to destroy expired
	RPCSEC_GSS credentials..
Date: Mon, 21 Apr 2008 20:00:43 -0400
Message-ID: <1208822443.7767.23.camel@heimdal.trondhjem.org>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080419204047.14124.64969.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <FB8780E7-FE92-40D6-8DFE-0663DF1B0162@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8158 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755191AbYDVAAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Apr 2008 20:00:44 -0400
In-Reply-To: <FB8780E7-FE92-40D6-8DFE-0663DF1B0162@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-04-21 at 13:50 -0400, Chuck Lever wrote:
> Hi Trond-
> 
> On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
> > ..and always destroy using a 'soft' RPC call. Destroying GSS  
> > credentials
> > isn't mandatory; the server can always cope with a few credentials not
> > getting destroyed in a timely fashion.
> 
> These two changes may have different side-effects, but backing out  
> this patch will revert both changes.  Should these be split into  
> separate patches to facilitate git bisect?

See the comment above. Destroying GSS sessions is _not_ mandatory. If
there are any side-effects from not destroying them, then that would be
a server bug, not a client issue.

> > This actually fixes a hang situation. Basically, some servers will  
> > decide
> > that the client is crazy if it tries to destroy an RPC context for  
> > which
> > they have sent an RPCSEC_GSS_CREDPROBLEM, and so will refuse to talk  
> > to it
> > for a while.
> 
> That seems unfriendly.  Is this server-side behavior mandated?  Why  
> wouldn't the server just treat an extraneous context destruction  
> request as a successful no-op?
> 
> You definitely should include an explanation of this server-side  
> behavior in the documenting comment for gss_destroying_context.

RFC-2203 states that servers are supposed to silently discard requests
that they don't recognise (see section 5.3.3.1 - Context Management), so
it is correct server behaviour.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
