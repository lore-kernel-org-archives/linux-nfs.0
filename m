From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [PATCH 02/15] NFSv4.1: Clean up nfs4_setup_sequence
Date: Tue, 15 Jun 2010 13:32:21 -0400
Message-ID: <1276623141.8767.47.camel@heimdal.trondhjem.org>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
	 <0A97A441BFADC74EA1E299A79C69DF9213D49EB687@orsmsx504.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Gilliam, PaulX J" <paulx.j.gilliam@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:52186 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754302Ab0FORcd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 13:32:33 -0400
In-Reply-To: <0A97A441BFADC74EA1E299A79C69DF9213D49EB687-osO9UTpF0UQ64kNsxIetb7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-06-15 at 09:50 -0700, Gilliam, PaulX J wrote:
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Trond Myklebust
> > Sent: Monday, June 14, 2010 2:51 PM
> > To: linux-nfs@vger.kernel.org
> > Subject: [PATCH 02/15] NFSv4.1: Clean up nfs4_setup_sequence
> > 
> > Firstly, there is little point in first zeroing out the entire struct
> > nfs4_sequence_res, and then initialising all fields save one. Just
> > initialise the last field to zero...
> 
> The reason one may want to zero out the entire struct is that in the future, someone may add elements to the struct.  In that case, 
> 	memset(res, 0, sizeof(*res));
> would not have to be changed, and any new elements will "automatically" be initialized to a known value.
> 
> Just a thought.

That assumes this is a structure that is likely to change and/or be
extended in the future, which is unlikely since the NFSv4.1 protocol
specification is complete and the SEQUENCE results are fully contained
in the current set of fields.

It also assumes that '0' would be a desirable default value for these
new fields.

Trond

