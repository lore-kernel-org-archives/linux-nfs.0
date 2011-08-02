Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31023 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754268Ab1HBRaQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Aug 2011 13:30:16 -0400
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andy Adamson <andros@netapp.com>
Cc: Peng Tao <bergwolf@gmail.com>, Jim Rees <rees@umich.edu>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Date: Tue, 02 Aug 2011 13:30:14 -0400
In-Reply-To: <1312240278.4616.7.camel@lade.trondhjem.org>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
	 <20110729155136.GB28306@infradead.org> <20110729185415.GA23061@merit.edu>
	 <20110729190133.GA10946@infradead.org> <20110729191341.GC23061@merit.edu>
	 <1311988172.16078.15.camel@lade.trondhjem.org>
	 <20110730032621.GB25188@merit.edu>
	 <CA+a=Yy5rmvrUHaDewLb_EbeaDYMKL_xv_E_MmzTvR_55SmYkqA@mail.gmail.com>
	 <1312233006.23392.17.camel@lade.trondhjem.org>
	 <1312238117.23392.19.camel@lade.trondhjem.org>
	 <0A94625F-4E4F-4A88-A0DF-63D429924F66@netapp.com>
	 <1312240278.4616.7.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312306214.2823.10.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-08-01 at 19:11 -0400, Trond Myklebust wrote: 
> On Mon, 2011-08-01 at 18:57 -0400, Andy Adamson wrote: 
> > On Aug 1, 2011, at 6:35 PM, Trond Myklebust wrote:
> > > /*
> > > @@ -433,26 +436,32 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
> > > 			      struct cb_sequenceres *res,
> > > 			      struct cb_process_state *cps)
> > > {
> > > +	struct nfs4_slot_table *tbl;
> > > 	struct nfs_client *clp;
> > > 	int i;
> > > 	__be32 status = htonl(NFS4ERR_BADSESSION);
> > > 
> > > -	cps->clp = NULL;
> > > -
> > > 	clp = nfs4_find_client_sessionid(args->csa_addr, &args->csa_sessionid);
> > > 	if (clp == NULL)
> > > 		goto out;
> > > 
> > > +	tbl = &clp->cl_session->bc_slot_table;
> > > +
> > > +	spin_lock(&tbl->slot_tbl_lock);
> > > 	/* state manager is resetting the session */
> > > 	if (test_bit(NFS4_SESSION_DRAINING, &clp->cl_session->session_state)) {
> > > 		status = NFS4ERR_DELAY;
> >                                  
> > status = htonl(NFS4ERR_DELAY);
> 
> Yep. I'll fix that too... 

Looking at this again, I'm not sure that the above is safe. If you
return NFS4ERR_DELAY on the SEQUENCE operation, then that has a very
specific meaning of "I'm executing your command, but it will take a
while to complete.".
It therefore seems to me that if we return NFS4ERR_DELAY, then we are
basically setting ourselves up for a deadlock: 
      * On the one hand, we're trying to destroy the session 
      * On the other hand, we're telling the server that 'your callback
        is being processed'.
In that situation, it seems to me that it should be perfectly valid for
the server to reject our DESTROY_SESSION call with a
NFS4ERR_BACK_CHAN_BUSY until we process the callback.

Comments?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

