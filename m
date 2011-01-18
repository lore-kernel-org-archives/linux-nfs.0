Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:56065 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139Ab1ARRrt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 12:47:49 -0500
From: <Daniel.Muntz@emc.com>
To: <trond.myklebust@fys.uio.no>, <rees@umich.edu>
CC: <androsadamson@gmail.com>, <linux-nfs@vger.kernel.org>
Date: Tue, 18 Jan 2011 12:44:40 -0500
Subject: RE: 4.1 no-pnfs mount option?
Message-ID: <DE966DA98A4ABE438D726BDF1699CF61043985B53F@MX05A.corp.emc.com>
References: <20110114151945.GA21629@merit.edu>
	 <AANLkTimSp6BTgk1YQonXd6HuVS-JEpQUWqsny7JymJsd@mail.gmail.com>
	 <20110114153846.GA21766@merit.edu>
 <1295019712.3576.1.camel@heimdal.trondhjem.org>
In-Reply-To: <1295019712.3576.1.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

 

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org 
> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Trond Myklebust
> Sent: Friday, January 14, 2011 7:42 AM
> To: Jim Rees
> Cc: William A. (Andy) Adamson; linux-nfs@vger.kernel.org
> Subject: Re: 4.1 no-pnfs mount option?
> 
> On Fri, 2011-01-14 at 10:38 -0500, Jim Rees wrote: 
> > William A. (Andy) Adamson wrote:
> > 
> >   No mount option - just configure your machine to not load any pnfs
> >   layoutdriver modules.
> > 
> > That works, thanks, but I was hoping for a way to have 
> layout and non-layout
> > mounts going on at the same time.
> 
> Different VMs?
> 
> Trond

Would there be any objections to adding a "nopnfs" mount option to force this behavior?  It could be useful at least for testing, possibly for working around server problems, or if an admin knows that certain clients' usage patterns would be better served by disabling pnfs.

  -Dan

> 
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 