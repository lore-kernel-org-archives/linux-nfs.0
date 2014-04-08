Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51353 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756900AbaDHQkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 12:40:31 -0400
Date: Tue, 8 Apr 2014 12:40:24 -0400
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Layton Jeff <jlayton@redhat.com>, NFS <linux-nfs@vger.kernel.org>,
        Adamson William Andros <androsadamson@gmail.com>,
        Lever Charles Edward <chuck.lever@oracle.com>
Subject: Re: v4.0 CB_COMPOUND authentication failures
Message-ID: <20140408164024.GH3882@fieldses.org>
References: <20140408082140.340c1328@tlielax.poochiereds.net>
 <20140408123501.GA3532@fieldses.org>
 <20140408094903.33e42de2@tlielax.poochiereds.net>
 <20140408140333.GD3882@fieldses.org>
 <6CC79B2A-8AE2-4A36-BB57-380C2F9813C0@primarydata.com>
 <20140408144652.GE3882@fieldses.org>
 <ECD8245B-CDEE-442E-A41A-BECE08BEEDA1@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <ECD8245B-CDEE-442E-A41A-BECE08BEEDA1@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 
> > But, I don't know, I'm frankly confused about our security design for
> > the NFSv4 state.
> > 
> > When we insist on krb5 (and checked the server name correctly), and
> > failed without it, then I feel like I understand what we're doing.  Once
> > we start trying it and then falling back (as I understand happens for
> > the krb5 state in the auth_sys case) I get confused.
> 
> Now you have me confused. I’m aware that we call nfs_create_rpc_client() with a krb5i argument and then fall back to auth_sys if the RPC layer says that we don’t have a running gss daemon or that we can’t load the rpcsec_gss_krb5 module. I’m not aware of us falling back if rpc.gssd is running and tells us that security negotiation failed; we should be returning a mount error in that case.

Oh, good, that sounds fine--I'd forgotten it worked that way.

So the problem occurs just because gssd and/or the kerberos libraries
are allowing us to establish state using a different name and then we're
not accepting it on the return.

So:

On Tue, Apr 08, 2014 at 12:22:51PM -0400, Trond Myklebust wrote:
> How is it not better just to rip out that hostname comparison in the
> back channel?

Rip it out entirely?

At that point anyone who can get a credential in the right realm can
send a recall.  RFC made this requirement to prevent that.

But we've already decided we don't care about that in the 4.1 case, so,
hey, maybe.  I guess it wouldn't bother me.

--b.
