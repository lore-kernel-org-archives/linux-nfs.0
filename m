From: Jeff Layton <jlayton@redhat.com>
Subject: Re: nfs-utils: support/nfs/rpcmisc.c
Date: Wed, 28 Jan 2009 13:17:07 -0500
Message-ID: <20090128131707.401de2f1@tleilax.poochiereds.net>
References: <619E3D97-A202-4F6C-B308-B631F470A8E0@oracle.com>
	<20090128113749.7893533a@tleilax.poochiereds.net>
	<2B35C807-B7FD-4E6E-9660-0F3268CB890A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Olaf Kirch <okir@suse.de>, Neil Brown <neilb@suse.de>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37492 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751518AbZA1SRR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2009 13:17:17 -0500
In-Reply-To: <2B35C807-B7FD-4E6E-9660-0F3268CB890A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 28 Jan 2009 13:05:39 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> On Jan 28, 2009, at 11:37 AM, Jeff Layton wrote:
> > On Tue, 27 Jan 2009 15:20:02 -0500
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> >> I'm considering creating a version of rpc_init() under utils/statd
> >> that strips out all of the unnecessary features, uses note() instead
> >> of xlot(), and then adds support for AF_INET6.
> >>
> >
> > Is there some reason to not just convert statd to use xlog()? It
> > seems like that would be a better long term solution.
> 
> I'm not sure what the advantage of note() vs. xlog() is.
> 
> Be it also noted that sm-notify uses yet another logging mechanism,  
> and I've already coded up patches to move it over to using note().   
> This is because I'm adding some IPv6-enabled RPC handlers that are  
> shared with statd...
> 
> And, the RPC libraries also write directly to stderr.  All of those  
> error messages are lost in the daemon case, but when using -Fd they  
> are useful, and appear on the controlling terminal.
> 
> > For a proof-of-concept sort of thing, that might be reasonable though.
> 
> 
> It could be an additional clean-up once I'm done with the IPv6  
> support.  But I need to look at both implementations to see if one is  
> more appropriate for all of nfs-utils.
> 

FWIW, I don't have any particular attachment to either logging scheme.
It just seems like we could benefit from some standardization in this
area.

Not a high-priority item, but something to keep in mind if you poking
around in the code anyway.

-- 
Jeff Layton <jlayton@redhat.com>
