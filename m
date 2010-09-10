Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7323 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997Ab0IJWoL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 18:44:11 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o8AMiACn029279
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 15:44:10 -0700 (PDT)
Subject: Re: [PATCH 12/13] RFC: pnfs: add LAYOUTGET and GETDEVICEINFO
 infrastructure
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTimWALJj=SNEW9NoTWFByGwOytXNUjvf9qdyGTXH@mail.gmail.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	 <1283450419-5648-13-git-send-email-iisaman@netapp.com>
	 <1284149490.10062.107.camel@heimdal.trondhjem.org>
	 <AANLkTimWALJj=SNEW9NoTWFByGwOytXNUjvf9qdyGTXH@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Sep 2010 18:43:47 -0400
Message-ID: <1284158627.14078.85.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-09-10 at 14:47 -0700, Fred Isaman wrote:
> On Fri, Sep 10, 2010 at 1:11 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
> >> From: The pNFS Team <linux-nfs@vger.kernel.org>
> >>  static void
> >>  init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
> >>  {
> >> @@ -191,7 +210,7 @@ destroy_lseg(struct kref *kref)
> >>       struct pnfs_layout_hdr *local = lseg->layout;
> >>
> >>       dprintk("--> %s\n", __func__);
> >> -     kfree(lseg);
> >> +     PNFS_LD_IO_OPS(local)->free_lseg(lseg);
> >
> > Where is PNFS_LD_IO_OPS() defined? Besides, I thought we agreed to get
> > rid of that.
> 
> This is defined in pnfs.h as
> PNFS_NFS_SERVER()->pnfs_curr_ld->ld_io_iops, mainly to save typing.

It may save typing in the short term, but long-term it mainly serves to
hide the various levels of indirection. I'd prefer to have the latter
obvious to people in order to encourage them to think more carefully
about how to avoid recalculating these values over and over again.

Cheers
  Trond
