From: "Sager, Mike" <Mike.Sager@netapp.com>
Subject: RE: [pnfs] [PATCH v2 15/47] nfsd41: exchange_id operation
Date: Wed, 1 Apr 2009 11:53:36 -0400
Message-ID: <7A6A58246D5F0B4EA127BEA555B3A9AD72ED6F@RTPMVEXC1-PRD.hq.netapp.com>
References: <20090401150147.GC5018@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Benny Halevy" <bhalevy@panasas.com>, <linux-nfs@vger.kernel.org>,
	<pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20584 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761719AbZDAPy3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 11:54:29 -0400
In-Reply-To: <20090401150147.GC5018@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes, I guess it should be removed.  It's in there in an attempt to
detect a client collision (case 3: same client owner, different ip, flag
not set), but as you and Benny have pointed out, basing it on an ip
check is flawed anyways...

Mike 

-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org] 
Sent: Wednesday, April 01, 2009 11:02 AM
To: Sager, Mike
Cc: Benny Halevy; linux-nfs@vger.kernel.org; pnfs@linux-nfs.org
Subject: Re: [pnfs] [PATCH v2 15/47] nfsd41: exchange_id operation


> > +		if (ip_addr != conf->cl_addr &&
> > +		    !(exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A))
> {
> > +			/* Client collision. 18.35.4 case 3 */
> > +			status = nfserr_clid_inuse;
> > +			goto out;
> > +		}
> > +		/*
> > +		 * Set bit when the owner id and verifier map to an
> already
> > +		 * confirmed client id (18.35.3).
> > +		 */
> > +		exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
> > +
> > +		/*
> > +		 * Falling into 18.35.4 case 2, possible router replay.
> 

I wrote:
> Checking the spec: case 2 says: "If the server has the following 
> confirmed record, and the request does not have 
> EXCHGID4_FLAG_UPD_CONFIRMED_REC_A set,..."
> 
> But that flag *is* set when we get to this code.
> 

On Tue, Mar 31, 2009 at 04:59:38PM -0400, Sager, Mike wrote:
> Isn't this case 6?
> 
> I don't think EXCHGID4_FLAG_UPD_CONFIRMED_REC_A is necessarily set 
> when we get here.  If the verifier, credentials, and ip addresses 
> match,  we can get here without the flag being set.  The comment 
> should be updated, but I think it actually covers both cases 2 and 6 
> here with the code snippet under out_copy.  It doesn't seem to make 
> sense to essentially ignore the value of the flag, but I think the end

> result is the same...at least based on my interpretation of the spec 
> :)

OK, maybe--though in that case the ip_addr/exid->flags conditional
should probably just be removed entirely?

In any case someone needs to take a careful look at this function.

--b.
