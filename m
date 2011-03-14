Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8509 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813Ab1CNXxc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 19:53:32 -0400
Subject: Re: [PATCH] nfsd: wrong index used in inner loop
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>, roel <roel.kluin@gmail.com>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
In-Reply-To: <20110314222229.GJ25442@fieldses.org>
References: <4D76A06A.4090405@gmail.com>
	 <20110309004955.GD15814@fieldses.org> <4D79A183.8090306@cn.fujitsu.com>
	 <20110314222229.GJ25442@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Mar 2011 19:52:11 -0400
Message-ID: <1300146731.3026.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-03-14 at 18:22 -0400, J. Bruce Fields wrote:
> On Fri, Mar 11, 2011 at 12:13:55PM +0800, Mi Jinlong wrote:
> > 
> > 
> > J. Bruce Fields:
> > > On Tue, Mar 08, 2011 at 10:32:26PM +0100, roel wrote:
> > >> Index i was already used in the outer loop
> > >>
> > >> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> > >> ---
> > >>  fs/nfsd/nfs4xdr.c |    4 ++--
> > >>  1 files changed, 2 insertions(+), 2 deletions(-)
> > >>
> > >> Not 100% sure this one is needed but it looks suspicious.
> > > 
> > > Looks bad to me, thanks.
> > > 
> > > nfsd4_decode_create_session should probably really be broken up a little
> > > bit; if it wasn't so long this would have been more obvious.
> > > 
> > > I'll see if I can slip this into 2.6.38 with a couple other last-minute
> > > patches....  Otherwise, it'll be in 2.6.39.
> > > 
> > > --b.
> > > 
> > >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > >> index 1275b86..615f0a9 100644
> > >> --- a/fs/nfsd/nfs4xdr.c
> > >> +++ b/fs/nfsd/nfs4xdr.c
> > >> @@ -1142,7 +1142,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
> > >>  
> > >>  	u32 dummy;
> > >>  	char *machine_name;
> > >> -	int i;
> > >> +	int i, j;
> > >>  	int nr_secflavs;
> > >>  
> > >>  	READ_BUF(16);
> > >> @@ -1215,7 +1215,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
> > >>  			READ_BUF(4);
> > >>  			READ32(dummy);
> > >>  			READ_BUF(dummy * 4);
> > >> -			for (i = 0; i < dummy; ++i)
> > >> +			for (j = 0; j < dummy; ++j)
> > >>  				READ32(dummy);
> > 
> >   We must not use dummy for index here.
> >   After the first index, READ32(dummy) will change dummy!!!!
> 
> Actually, wait, this is kind of silly.  I don't see why we couldn't just
> skip the loop and do
> 
> 	p += dummy;

This is exactly why I _hate_ the READ*() macros and their ilk, and am
really happy we got rid of them in the client.

READ_BUF() _sets_ p to whatever the value of argp->p is, and then
updates argp->p. It is just very very very hard to see that due to the
lack of transparency.

IOW: You don't need the "p += dummy" either. That happens automatically
when you next invoke READ_BUF().

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

