Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38086 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752024AbbGTUoR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jul 2015 16:44:17 -0400
Date: Mon, 20 Jul 2015 16:44:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: New counter for generating client confirm verifier
Message-ID: <20150720204416.GA11050@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A38505.6040405@gmail.com>
 <20150715204748.GA21669@fieldses.org>
 <20150715204950.GB21669@fieldses.org>
 <55A726A0.5090907@gmail.com>
 <55A72A1F.7060507@gmail.com>
 <20150717155846.GC6263@fieldses.org>
 <20150717134243.7bf809fa@tlielax.poochiereds.net>
 <55A990CB.6020201@gmail.com>
 <20150718081608.5a92fa6d@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150718081608.5a92fa6d@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 18, 2015 at 08:16:08AM -0400, Jeff Layton wrote:
> On Sat, 18 Jul 2015 07:33:31 +0800
> Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
> > If using clientid_counter, gen_confirm will generate same verifier
> > in one second.
> > 
> > A new counter for client confirm verifier make sure gen_confirm
> > generating different each calling for the same clientid.
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > ---
> >  fs/nfsd/netns.h     | 1 +
> >  fs/nfsd/nfs4state.c | 2 +-
> >  2 files changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> > index ea6749a..d8b16c2 100644
> > --- a/fs/nfsd/netns.h
> > +++ b/fs/nfsd/netns.h
> > @@ -110,6 +110,7 @@ struct nfsd_net {
> >  	unsigned int max_connections;
> >  
> >  	u32 clientid_counter;
> > +	u32 clverifier_counter;
> >  
> >  	struct svc_serv *nfsd_serv;
> >  };
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 61dfb33..5a64757e 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -1894,7 +1894,7 @@ static void gen_confirm(struct nfs4_client *clp, struct nfsd_net *nn)
> >  	 * __force to keep sparse happy
> >  	 */
> >  	verf[0] = (__force __be32)get_seconds();
> > -	verf[1] = (__force __be32)nn->clientid_counter;
> > +	verf[1] = (__force __be32)nn->clverifier_counter++;
> >  	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
> >  }
> >  
> 
> Reviewed-by: Jeff Layton <jlayton@poochiereds.net>

Thanks.--b.
