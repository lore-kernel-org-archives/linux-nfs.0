Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20594 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991Ab0IJWhX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 18:37:23 -0400
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o8AMb4j7004229
	for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 15:37:07 -0700 (PDT)
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file
 layout driver
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTi=6vcQC1k28B=aKJbN=jRBipoff3+79BpgLxtXw@mail.gmail.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	 <1283450419-5648-9-git-send-email-iisaman@netapp.com>
	 <1284147111.10062.74.camel@heimdal.trondhjem.org>
	 <AANLkTi=6vcQC1k28B=aKJbN=jRBipoff3+79BpgLxtXw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Sep 2010 18:37:03 -0400
Message-ID: <1284158223.14078.78.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-09-10 at 14:11 -0700, Fred Isaman wrote:
> On Fri, Sep 10, 2010 at 12:31 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
> OK
> 
> >> +     .initialize_mountpoint   = filelayout_initialize_mountpoint,
> >> +     .uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
> >> +};
> >> +
> >> +
> >> +struct pnfs_layoutdriver_type filelayout_type = {
> >
> > Ditto.
> 
> This includes a list_head field which is set by the generic layer.
> 
> >
> >> +     .id = LAYOUT_NFSV4_1_FILES,
> >> +     .name = "LAYOUT_NFSV4_1_FILES",
> >> +     .ld_io_ops = &filelayout_io_operations,
> >
> > Why do we need a separate 'struct layoutdriver_io_operations'? Any
> > reason those can't just be embedded in struct pnfs_layoutdriver_type?
> 
> I believe this decision was primarily aesthetics.  However, keeping
> the static io_ops seperate from the variable list_head seems like a
> good idea.

I dunno. They are in a 1-1 correspondence, so I'm not sure I see the
need for a separation.

> Perhaps having a driver structure that includes the io_ops and static
> portions of pnfs_layoutdriver_type, with the generic layer allocating
> a wrapper structure that is basically:
> struct {
>     struct list_head list;
>     struct pnfs_layoutdriver_type *driver_info;

      Should be const...

      struct module *owner = THIS_MODULE;

> }

...although the struct module could probably indeed be part of
pnfs_layoutdriver_type too.

Cheers
  Trond
