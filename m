From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Fri, 9 Oct 2009 11:39:21 +1100 (EST)
Message-ID: <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org> <4ACB5FC0.7060307@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	linux-fsdevel@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:39889 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755970AbZJIAkZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2009 20:40:25 -0400
In-Reply-To: <4ACB5FC0.7060307@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 6 Oct 2009, Peter Staubach wrote:

> > Three operations are implemented by the new XATTR protocol and map to 
> > syscalls:
> > 
> >  - GETXATTR     getxattr(2)
> >  - LISTXTTR     listxattr(2)
> >  - SETXATTR     setxattr(2) and removexattr(2)
> > 
> > This code passes basic testing of the above syscalls, although there are 
> > some areas which still need work:
> > 
> 
> Is there a set of tests which are used to test this functionality?

No, I just manually run a set of commands to verify basic behavior.

I gather LTP would be the best place to add tests for this?

> >  - Interoperability with other OSs (we probably should at least
> >    discuss with BSD folk)
> > 
> 
> It would be good to include the BSD folks, but I think that more
> valuable targets would be those with volume servers that might be
> encountered at customer sites.  I think that we need NetApp, EMC,
> perhaps Sun, providing some feedback on the protocol and semantics.

Given that IETF activity is closed for v3, I wonder what the best forum 
would be to reach all these folk?

> >  - Caching of xattrs at the client
> > 
> 
> This will need a closer specification for the semantics associated
> with these xattrs.  The need will be how to determine when to
> invalidate cached xattrs.

I suspect user namespace xattrs should be treated like file data wrt 
caching (i.e. they're fully under the control of the user).

> On more bullet that I might suggest is ensuring that the protocol
> is compliant with the RPC and XDR standards.

Thanks, I'll check that.


- James
-- 
James Morris
<jmorris@namei.org>
