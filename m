Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:12277 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810Ab1BWW10 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 17:27:26 -0500
Date: Wed, 23 Feb 2011 23:26:36 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: Chuck Lever <chuck.lever@oracle.com>, Milton Miller <miltonm@bga.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Neil Brown <neilb@suse.de>, bfields@fieldses.org
Subject: Re: [PATCH] Fix size argument to memset call in nfsacl_encode
In-Reply-To: <1296770110.12342.6.camel@heimdal.trondhjem.org>
Message-ID: <alpine.LNX.2.00.1102232326130.28678@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1102032012540.15101@swampdragon.chaosbits.net>  <1296761330.3015.22.camel@heimdal.trondhjem.org>  <alpine.LNX.2.00.1102032035280.15101@swampdragon.chaosbits.net>  <705C97E5-E273-45AA-9714-2BF409DE1322@oracle.com>
 <1296763614.3015.26.camel@heimdal.trondhjem.org>  <67867FEF-6C10-4A35-8952-4EB56EAB79B9@oracle.com> <1296770110.12342.6.camel@heimdal.trondhjem.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 3 Feb 2011, Trond Myklebust wrote:

> On Thu, 2011-02-03 at 15:29 -0500, Chuck Lever wrote: 
> > Sorry, I wasn't clear.  IMO, data that is destined for the network is an important case where we have to be careful about the rule of using either assignments or memset(), not both, when initializing a data structure.
> > 
> > If the compiler doesn't pack the fields in struct posix_acl, there is unused space between them.  Memory for acl2 comes from the stack, which contains arbitrary data when this function is invoked.  The areas between the structure fields are not affected by the variable assignments used here.  If the data in acl2 is then simply memcpy'd to the XDR buffer, that old stack data can possibly appear on the wire.
> > 
> > I agree that the current memset() is incorrect.  My conditional ACK was more about what happens in xdr_encode_array2() rather than how the posix_acl acl2 is initialized.  I think in that regard we are also safe, if the array encoding operates by data type rather than by simply doing a blanket memcpy.  See xdr_nfsace_encode().  It's always possible I misunderstood how ACEs are XDR encoded.
> 
> We shouldn't ever be memcopying entire structures directly to or from
> the XDR buffer, and as far as I know, the current code will always copy
> them element by element.
> 
Ok. So, could we merge the patch that kills the memcpy() ? 

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Plain text mails only, please.
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html

