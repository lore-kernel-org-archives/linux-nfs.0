Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52507 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963Ab1CJSIH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Mar 2011 13:08:07 -0500
Date: Thu, 10 Mar 2011 13:08:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: roel <roel.kluin@gmail.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH] nfsd: wrong index used in inner loop
Message-ID: <20110310180800.GA31984@fieldses.org>
References: <4D76A06A.4090405@gmail.com>
 <20110309154230.66bc2c36.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110309154230.66bc2c36.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 09, 2011 at 03:42:30PM -0800, Andrew Morton wrote:
> On Tue, 08 Mar 2011 22:32:26 +0100
> roel <roel.kluin@gmail.com> wrote:
> 
> > Index i was already used in the outer loop
> > 
> > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> > ---
> >  fs/nfsd/nfs4xdr.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > Not 100% sure this one is needed but it looks suspicious.
> > 
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index 1275b86..615f0a9 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -1142,7 +1142,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
> >  
> >  	u32 dummy;
> >  	char *machine_name;
> > -	int i;
> > +	int i, j;
> >  	int nr_secflavs;
> >  
> >  	READ_BUF(16);
> > @@ -1215,7 +1215,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
> >  			READ_BUF(4);
> >  			READ32(dummy);
> >  			READ_BUF(dummy * 4);
> > -			for (i = 0; i < dummy; ++i)
> > +			for (j = 0; j < dummy; ++j)
> >  				READ32(dummy);
> >  			break;
> >  		case RPC_AUTH_GSS:
> 
> ooh, big bug.
> 
> I wonder why it was not previously detected at runtime.  Perhaps
> nr_secflavs is always 1.

Yeah, no client uses this calback security information yet.

Mi Jinlong, do you think this is something we could have caught with
another pynfs test?

--b.
