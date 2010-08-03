Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40540 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756695Ab0HCWP0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 18:15:26 -0400
Subject: Re: numeric UIDs
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jim Rees <rees@umich.edu>
Cc: Daniel.Muntz@emc.com, bfields@fieldses.org, linux-nfs@vger.kernel.org
In-Reply-To: <20100803215704.GA15494@merit.edu>
References: <201008030401.33552.dreck@vmsd.ath.cx>
	 <20100803164318.GB13896@merit.edu> <20100803192216.GC31579@fieldses.org>
	 <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com>
	 <20100803215704.GA15494@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 Aug 2010 18:15:19 -0400
Message-ID: <1280873719.14520.17.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-08-03 at 17:57 -0400, Jim Rees wrote:
> Daniel.Muntz@emc.com wrote:
> 
>   I'll fourth this motion.  The spec goes out of its way to declare this a
>   violation.  IMHO, the NFSv4.[0-n] specs should adopt the convention that a
>   uid string consisting of [0-9]+ be interpreted as the string
>   representation of a numeric UID--just as valid as a "user@domain" string.
> 
> I argued for this as an option in the early days but was shouted down.
> Sorry I can't remember the details, it was many years ago.

Why is nobody talking about fixing AUTH_SYS? The alternative to using
numeric uids/gids in NFS would be to use user@domain/group@domain in the
credential.

I believe that Nico had some proposals for RPCSEC_GSSv3 that addresses
this issue. If adopted, it would even be backwards compatible with
NFSv4.0.

Trond

