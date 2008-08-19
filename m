From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 7/7] nfsd: nfs4xdr decode_stateid helper function
Date: Tue, 19 Aug 2008 18:44:25 -0400
Message-ID: <20080819224425.GH8331@fieldses.org>
References: <48A1CB0C.4090906@panasas.com> <1218563178-25480-1-git-send-email-bhalevy@panasas.com> <20080812190410.GC30729@fieldses.org> <48A28DEA.5060406@panasas.com> <20080813150329.GF21004@fieldses.org> <1218650349.9042.20.camel@localhost> <48A81339.9010302@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Chuck Lever <chucklever@gmail.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51285 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665AbYHSWof (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2008 18:44:35 -0400
In-Reply-To: <48A81339.9010302@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 17, 2008 at 03:02:01PM +0300, Boaz Harrosh wrote:
> Trond Myklebust wrote:
> > On Wed, 2008-08-13 at 11:03 -0400, J. Bruce Fields wrote:
> >> On Wed, Aug 13, 2008 at 10:31:54AM +0300, Benny Halevy wrote:
> >>> On Aug. 12, 2008, 22:04 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >>>> On Tue, Aug 12, 2008 at 08:46:18PM +0300, Benny Halevy wrote:
> >>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> >>>>> ---
> >>>>>  fs/nfsd/nfs4xdr.c |   99 +++++++++++++++++++++++++++++-----------------------
> >>>>>  1 files changed, 55 insertions(+), 44 deletions(-)
> >>>>>
> >>>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >>>>> index 47ac498..9570b1b 100644
> >>>>> --- a/fs/nfsd/nfs4xdr.c
> >>>>> +++ b/fs/nfsd/nfs4xdr.c
> >>>>>  static __be32
> >>>>> @@ -929,9 +939,10 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
> >>>>>  	int len;
> >>>>>  	DECODE_HEAD;
> >>>>>  
> >>>>> -	READ_BUF(sizeof(stateid_opaque_t) + 20);
> >>>>> -	READ32(write->wr_stateid.si_generation);
> >>>>> -	COPYMEM(&write->wr_stateid.si_opaque, sizeof(stateid_opaque_t));
> >>>>> +	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
> >>>>> +	if (status)
> >>>>> +		return status;
> >>>>> +	READ_BUF(16);
> >>>> How did that 20 become a 16?
> >>> It was sizeof(stateid_opaque_t) + 20 == sizeof(stateid_t) - 4 + 20 ==
> >>> sizeof(stateid_t) + 16.
> >> Whoops!  Even now I still fall into the stateid_opaque_t/stateid_t trap!
> > 
> > Which is a good reason for ditching the entire confusing typedef, and
> > replacing it with a packed structure instead:
> > 
> > struct stateid {
> > 	__be32 generation;
> > 	char opaque[12];
> > } __attribute__((packed));
> > 
> > Trond
> > 
> 
> Please use the "__packed" Kernel macro for better compilers support.
> 
> And Yes I would suggest using "__packed" where ever a struct is defined
> for on-the-wire. Even just for indication to fellow programmers that this 
> is going on the wire as is.

OK.  This all sounds reasonable, but I can't volunteer at the moment,
so: patches welcomed.

--b.
