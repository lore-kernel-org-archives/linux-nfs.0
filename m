Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17606 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756856AbaDHR3G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 13:29:06 -0400
Subject: Re: v4.0 CB_COMPOUND authentication failures
From: Simo Sorce <simo@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        NFS <linux-nfs@vger.kernel.org>,
        Adamson William Andros <androsadamson@gmail.com>,
        Lever Charles Edward <chuck.lever@oracle.com>
In-Reply-To: <20140408124428.5152ae8b@tlielax.poochiereds.net>
References: <20140408082140.340c1328@tlielax.poochiereds.net>
	 <20140408123501.GA3532@fieldses.org>
	 <20140408094903.33e42de2@tlielax.poochiereds.net>
	 <20140408140333.GD3882@fieldses.org>
	 <6CC79B2A-8AE2-4A36-BB57-380C2F9813C0@primarydata.com>
	 <20140408144652.GE3882@fieldses.org>
	 <ECD8245B-CDEE-442E-A41A-BECE08BEEDA1@primarydata.com>
	 <20140408124428.5152ae8b@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Apr 2014 13:27:01 -0400
Message-ID: <1396978021.14203.163.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-04-08 at 12:44 -0400, Jeff Layton wrote:
> 
> I think that's what happens. We only fall back to using AUTH_SYS if
> nfs_create_rpc_client returns -EINVAL. In the event that the security
> negotiation fails, we should get back -EACCES and that should bubble
> back up to userland.
> 
> The real problem is that gssd (and also the krb5 libs themselves) will
> try to canonicalize the name. The resulting host portion of the SPN
> may bear no resemblance to the hostname in the device string. In fact,
> if you mount using an IP address then you're pretty much SOL.

If you mount by IP do you really care about krb5 ? Probably not, maybe
that's a clue we should not even try ...

> I haven't tried it yet, but it looks reasonably trivial to fix gssd
> not to bother with DNS at all and just rely on the hostname. That
> won't stop the krb5 libs from doing their canonicalization though. I'm
> not sure if there's some way to ask the krb5 libs to avoid doing that.

[libdefaults]
rdns = false

And I think we change the default to false in Fedora/RHEL lately ...

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

