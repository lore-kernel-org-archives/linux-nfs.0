Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52144 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754800Ab0FORxk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 13:53:40 -0400
Date: Tue, 15 Jun 2010 13:53:36 -0400
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "Gilliam, PaulX J" <paulx.j.gilliam@intel.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/15] NFSv4.1: Clean up nfs4_setup_sequence
Message-ID: <20100615175336.GB20757@fieldses.org>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com> <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com> <0A97A441BFADC74EA1E299A79C69DF9213D49EB687@orsmsx504.amr.corp.intel.com> <1276623141.8767.47.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1276623141.8767.47.camel@heimdal.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 15, 2010 at 01:32:21PM -0400, Trond Myklebust wrote:
> On Tue, 2010-06-15 at 09:50 -0700, Gilliam, PaulX J wrote:
> > > -----Original Message-----
> > > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Trond Myklebust
> > > Sent: Monday, June 14, 2010 2:51 PM
> > > To: linux-nfs@vger.kernel.org
> > > Subject: [PATCH 02/15] NFSv4.1: Clean up nfs4_setup_sequence
> > > 
> > > Firstly, there is little point in first zeroing out the entire struct
> > > nfs4_sequence_res, and then initialising all fields save one. Just
> > > initialise the last field to zero...
> > 
> > The reason one may want to zero out the entire struct is that in the future, someone may add elements to the struct.  In that case, 
> > 	memset(res, 0, sizeof(*res));
> > would not have to be changed, and any new elements will "automatically" be initialized to a known value.
> > 
> > Just a thought.
> 
> That assumes this is a structure that is likely to change and/or be
> extended in the future, which is unlikely since the NFSv4.1 protocol
> specification is complete and the SEQUENCE results are fully contained
> in the current set of fields.
> 
> It also assumes that '0' would be a desirable default value for these
> new fields.

Also, the memset's/kzalloc's mean that "git grep <structure field name>"
doesn't turn up the initialization of the field.  Not a huge deal, but
it trips me up sometimes.

--b.
