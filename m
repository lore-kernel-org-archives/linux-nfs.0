From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Wed, 24 Sep 2008 12:59:42 -0400
Message-ID: <1222275582.7390.8.camel@localhost>
References: <48D15DF0.4000406@panasas.com>
	 <20080917231018.GA5723@fieldses.org> <48D193EE.2020805@panasas.com>
	 <48D19C74.8000303@panasas.com> <48D2AAF7.6060808@panasas.com>
	 <20080924163528.GB5772@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:51142 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635AbYIXQ7z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 12:59:55 -0400
In-Reply-To: <20080924163528.GB5772@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-09-24 at 12:35 -0400, J. Bruce Fields wrote:
> On Thu, Sep 18, 2008 at 02:24:39PM -0500, Benny Halevy wrote:
> > From: Benny Halevy <bhalevy@panasas.com>
> > 
> > since commit ff7d9756b501744540be65e172d27ee321d86103
> > "nfsd: use static memory for callback program and stats"
> > do_probe_callback uses a static callback program
> > (NFS4_CALLBACK) rather than the one set in clp->cl_callback.cb_prog
> > as passed in by the client in setclientid (4.0)
> > or create_session (4.1).
> > 
> > This patches allows allocating cb_program (and cb_stats) dynamically
> > and setting a free_rpc_program function pointer to be
> > called when the rpc_clnt structure is destroyed.
> 
> So that means we handle two cases:
> 
> 	- free_rpc_program = NULL: We assume the program and stats are
> 	  in static memory (or module memory--which might be a problem
> 	  if we shut down the server and remove the nfsd module in quick
> 	  succession.  I assume there's a similar (probably very
> 	  hard-to-hit) bug on the client too, but haven't looked
> 	  carefully.).
> 	- free_rpc_program != NULL: We assume this rpc_client is the
> 	  last user of the program.
> 
> It seems a little ad hoc, but I can't see why it wouldn't solve the
> problem.
> 
> I'd want Trond's ack.

Well the current implementation is certainly broken. Look at what
happens if I clone the rpc_clnt...

  Trond

