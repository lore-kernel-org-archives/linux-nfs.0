Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42425 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742Ab1CRE1T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Mar 2011 00:27:19 -0400
Date: Fri, 18 Mar 2011 15:27:09 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: peter.staubach@emc.com, Trond.Myklebust@netapp.com, bjschuma@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: Use of READDIRPLUS on large directories
Message-ID: <20110318152709.77e2d51b@notabene.brown>
In-Reply-To: <20110317174453.GC30180@fieldses.org>
References: <20110316155528.31913c58@notabene.brown>
	<5E6794FC7B8FCA41A704019BE3C70E8B068397B4@MX31A.corp.emc.com>
	<20110317084038.6d4ea49d@notabene.brown>
	<20110317115522.29020461@notabene.brown>
	<20110317174453.GC30180@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 17 Mar 2011 13:44:53 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Mar 17, 2011 at 11:55:22AM +1100, NeilBrown wrote:
> > Strangely, when I try NFSv4 I don't get what I would expect.
> > 
> > "ls" on an unpatched 2.6.38 takes over 5 seconds rather than around 4.
> > With the patch it does back down to about 2. (still NFSv3 at 1.5).
> > Why would NFSv4 be slower?
> >  On v3 we make 44 READDIRPLUS calls and 284 READDIR calls - total of  328
> >        READDIRPLUS have about 30 names, READDIR have about 100
> >  On v4 we make 633 READDIR calls - nearly double.
> >        Early packed contain about 19 name, later ones about 70
> > 
> > Is nfsd (2.6.32) just not packing enough answers in the reply?
> > Client asks for a dircount of 16384 and a maxcount of 32768, and gets
> > packets which are about 4K long - I guess that is PAGE_SIZE ??
> 
> >From nfsd4_encode_readdir():
> 
> 	maxcount = PAGE_SIZE;
> 	if (maxcount > readdir->rd_maxcount)
> 		maxcount = readdir->rd_maxcount;
> 
> Unfortunately, I don't think the xdr encoding is equipped to deal with
> page boundaries.  It should be.

Bah humbug.
NFSv3 gets it right - it just encodes into the next page and then copies back.

Sounds like a simple afternoon's project .... now if only we could find
someone with a simple afternoon :-)
Getting a realistic upper limit on the size of the reply (which is more
variable for v4 than for v3) would be the only tricky bit..
Though nfsd4_encode_fattr looks fairly idempotent, so you could just
try to encode and if it doesn't fit:
  allocate next page
  encode into there
  copy some into previous page
  copy rest down.

NeilBrown
