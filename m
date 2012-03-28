Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55164 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758843Ab2C1XqU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 19:46:20 -0400
Date: Wed, 28 Mar 2012 19:46:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd4: use auth_unix unconditionally on backchannel
Message-ID: <20120328234617.GB13231@fieldses.org>
References: <20120323121208.GA3219@fieldses.org>
 <20120323133111.GA2991@fieldses.org>
 <1332516024.3087.1.camel@lade.trondhjem.org>
 <20120323152220.GA4953@fieldses.org>
 <1332516863.3087.10.camel@lade.trondhjem.org>
 <20120323115337.28bff808@corrin.poochiereds.net>
 <20120323121218.74461807@corrin.poochiereds.net>
 <20120323170405.GA6089@fieldses.org>
 <20120328230931.GA13231@fieldses.org>
 <1332976613.19172.25.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1332976613.19172.25.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2012 at 11:16:49PM +0000, Myklebust, Trond wrote:
> On Wed, 2012-03-28 at 19:09 -0400, J. Bruce Fields wrote:
> > This is a bandaid.
> > 
> > I have a series of patches that actually implement the correct behavior,
> > but that may not quite be ready for 3.4.
> > 
> > --b.
> > 
> > commit 2f026867c76171d26f003b211063ff0562097d5e
> > Author: J. Bruce Fields <bfields@redhat.com>
> > Date:   Wed Mar 28 14:18:16 2012 -0400
> > 
> >     nfsd4: use auth_unix unconditionally on backchannel
> >     
> >     This isn't actually correct, but it works with the Linux client, and
> >     agrees with the behavior we used to have before commit 80fc015bdfe.
> 
> Question: does the Linux client ever send you anything other than
> AUTH_SYS credentials for the csa_sec_parms argument in CREATE_SESSION?
> Anything other than that would be a bug, since our client doesn't
> actually support RPCSEC_GSS in the callback channel.

Right, I've never seen anything else, so I think the client's behaving
as expected.

But the server needs to be fixed to deal with the range of possible
csa_sec_parms possibilities regardless.

The only thing I find odd about the client behavior is why it even
bothers with auth_sys when auth_null would work just as well and be even
slightly simpler.

--b.

> 
> >     Later patches will implement the spec-mandated behavior (which is to use
> >     the security parameters explicitly given by the client in create_session
> >     or backchannel_ctl).
> >     
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
