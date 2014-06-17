Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:63404 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049AbaFQLXG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 07:23:06 -0400
Received: by mail-qa0-f51.google.com with SMTP id j7so7751251qaq.38
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2014 04:23:05 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 17 Jun 2014 07:23:03 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: sparse endianness warning cleanups
Message-ID: <20140617072303.11040696@tlielax.poochiereds.net>
In-Reply-To: <20140617102812.GA32216@infradead.org>
References: <1403000146-31394-1-git-send-email-jlayton@primarydata.com>
	<20140617102812.GA32216@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 17 Jun 2014 03:28:12 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > @@ -581,8 +581,8 @@ static void gen_boot_verifier(nfs4_verifier *verifier, struct net *net)
> >  	__be32 verf[2];
> >  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> >  
> > -	verf[0] = (__be32)nn->nfssvc_boot.tv_sec;
> > -	verf[1] = (__be32)nn->nfssvc_boot.tv_usec;
> > +	verf[0] = (__force __be32)nn->nfssvc_boot.tv_sec;
> > +	verf[1] = (__force __be32)nn->nfssvc_boot.tv_usec;
> >  	memcpy(verifier->data, verf, sizeof(verifier->data));
> 
> Given that the verifier should be opaque is there any reason not to
> simple do the byte swap here?  If not I think the rule that no __force
> cast should be without a comment applies here.
> 

The only real reason would be efficiency. Since it's opaque, doing a
byte swap doesn't really buy us anything.

> > -	verf[0] = (__be32)get_seconds();
> > -	verf[1] = (__be32)i++;
> > +	verf[0] = (__force __be32)get_seconds();
> > +	verf[1] = (__force __be32)i++;
> >  	memcpy(clp->cl_confirm.data, verf,
> > sizeof(clp->cl_confirm.data));
> 
> Same here.
> 
> In general I think one patch per issue also would better, and some
> comments of what's fixed (trivial for the places adding static, not so
> trivial for various __force overrides)

Fair enough. I'll break this up some and resend.

-- 
Jeff Layton <jlayton@primarydata.com>
