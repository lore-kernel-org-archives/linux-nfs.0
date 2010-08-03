Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48118 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756142Ab0HCWZC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 18:25:02 -0400
Date: Tue, 3 Aug 2010 18:23:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Jim Rees <rees@umich.edu>, Daniel.Muntz@emc.com, linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100803222337.GA9752@fieldses.org>
References: <201008030401.33552.dreck@vmsd.ath.cx>
 <20100803164318.GB13896@merit.edu>
 <20100803192216.GC31579@fieldses.org>
 <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com>
 <20100803215704.GA15494@merit.edu>
 <1280873719.14520.17.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1280873719.14520.17.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 03, 2010 at 06:15:19PM -0400, Trond Myklebust wrote:
> On Tue, 2010-08-03 at 17:57 -0400, Jim Rees wrote:
> > Daniel.Muntz@emc.com wrote:
> > 
> >   I'll fourth this motion.  The spec goes out of its way to declare this a
> >   violation.  IMHO, the NFSv4.[0-n] specs should adopt the convention that a
> >   uid string consisting of [0-9]+ be interpreted as the string
> >   representation of a numeric UID--just as valid as a "user@domain" string.
> > 
> > I argued for this as an option in the early days but was shouted down.
> > Sorry I can't remember the details, it was many years ago.
> 
> Why is nobody talking about fixing AUTH_SYS? The alternative to using
> numeric uids/gids in NFS would be to use user@domain/group@domain in the
> credential.

I'm not sure what that does to address complaints like original
poster's:

	http://marc.info/?l=linux-nfs&m=128080127215350&w=2

And I'd like it to be possible to make the NFSv3->NFSv4 upgrade as
transparent as possible.

--b.

> 
> I believe that Nico had some proposals for RPCSEC_GSSv3 that addresses
> this issue. If adopted, it would even be backwards compatible with
> NFSv4.0.
> 
> Trond
> 
