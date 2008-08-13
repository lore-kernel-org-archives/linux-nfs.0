From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 7/7] nfsd: nfs4xdr decode_stateid helper function
Date: Wed, 13 Aug 2008 13:59:09 -0400
Message-ID: <1218650349.9042.20.camel@localhost>
References: <48A1CB0C.4090906@panasas.com>
	 <1218563178-25480-1-git-send-email-bhalevy@panasas.com>
	 <20080812190410.GC30729@fieldses.org> <48A28DEA.5060406@panasas.com>
	 <20080813150329.GF21004@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:52405 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178AbYHMR7X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2008 13:59:23 -0400
In-Reply-To: <20080813150329.GF21004@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-08-13 at 11:03 -0400, J. Bruce Fields wrote:
> On Wed, Aug 13, 2008 at 10:31:54AM +0300, Benny Halevy wrote:
> > On Aug. 12, 2008, 22:04 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > On Tue, Aug 12, 2008 at 08:46:18PM +0300, Benny Halevy wrote:
> > >> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > >> ---
> > >>  fs/nfsd/nfs4xdr.c |   99 +++++++++++++++++++++++++++++-----------------------
> > >>  1 files changed, 55 insertions(+), 44 deletions(-)
> > >>
> > >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > >> index 47ac498..9570b1b 100644
> > >> --- a/fs/nfsd/nfs4xdr.c
> > >> +++ b/fs/nfsd/nfs4xdr.c
> > >>  static __be32
> > >> @@ -929,9 +939,10 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
> > >>  	int len;
> > >>  	DECODE_HEAD;
> > >>  
> > >> -	READ_BUF(sizeof(stateid_opaque_t) + 20);
> > >> -	READ32(write->wr_stateid.si_generation);
> > >> -	COPYMEM(&write->wr_stateid.si_opaque, sizeof(stateid_opaque_t));
> > >> +	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
> > >> +	if (status)
> > >> +		return status;
> > >> +	READ_BUF(16);
> > > 
> > > How did that 20 become a 16?
> > 
> > It was sizeof(stateid_opaque_t) + 20 == sizeof(stateid_t) - 4 + 20 ==
> > sizeof(stateid_t) + 16.
> 
> Whoops!  Even now I still fall into the stateid_opaque_t/stateid_t trap!

Which is a good reason for ditching the entire confusing typedef, and
replacing it with a packed structure instead:

struct stateid {
	__be32 generation;
	char opaque[12];
} __attribute__((packed));

Trond

