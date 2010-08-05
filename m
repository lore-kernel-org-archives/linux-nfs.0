Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:37530 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611Ab0HEAwz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 20:52:55 -0400
Subject: Re: Write delegation
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Yudong Gao <stgyd@umich.edu>
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTi=FivAoO+Rqin82h885_8bj1=Ck5mjqPqV2rif4@mail.gmail.com>
References: <AANLkTi=2KYZ-8qaXMG=C_s617q3k1Ocs7h1gyd8=RpY6@mail.gmail.com>
	 <AANLkTimr9QfF0+MJ47hUihJgSLVOfquR=Atp4iV5D2gr@mail.gmail.com>
	 <97A00951-577C-4365-AA38-3C6E2D03B372@netapp.com>
	 <AANLkTimi9CSa=XfoKBMCm-XAKcVQKVi0bEXgtA+XHexE@mail.gmail.com>
	 <1280956937.2865.13.camel@heimdal.trondhjem.org>
	 <AANLkTi=FivAoO+Rqin82h885_8bj1=Ck5mjqPqV2rif4@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 04 Aug 2010 20:52:44 -0400
Message-ID: <1280969564.2865.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-08-04 at 14:40 -0700, Yudong Gao wrote:
> I see. But according to the spec, the write delegation is supposed to
> break the close-to-open consistency so that the client can avoid
> flushing dirty page to server when closing the file. Is this part
> implemented? I can not find it in the source code...

No. We didn't do that. The main reason for continuing to flush the
writes on close is to avoid slow delegation recalls.

> Another question is how the nfs file write interacts with fscache? I
> was not able to find the code that update the page copy in fscache
> when the page in memory is modified.

AFAIK fscache is read-only at this point. I think David has plans to
make it read/write, but I don't know whether he will ever do so for NFS.

Trond

> Thanks a lot!
> 
> best,
> 
> Yudong
> 
> On Wed, Aug 4, 2010 at 2:22 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Wed, 2010-08-04 at 14:11 -0700, Yudong Gao wrote:
> >> Thanks for the reply, Andy!
> >>
> >> So the write delegation can only reduce the unnecessary open/close and
> >> lock/locku. But if a client modify the same page for multiple times,
> >> e.g. editing the file in a editor, is there any optimization to
> >> prevent the client from sending the half-updated pages? Ideally only
> >> the final update need to be put on the wire.
> >>
> >
> > Yes. However that optimisation is not linked to whether or not we hold a
> > write delegation. The NFS client assumes close-to-open cache
> > consistency, and so will cache writes until either the VM tries to
> > reclaim memory by writing out dirty page, or the application calls one
> > of fcntl(F_UNLCK), fsync() or close().
> >
> > Trond
> >
> >> Thanks!
> >>
> >> best,
> >>
> >> Yudong
> >>
> >> On Wed, Aug 4, 2010 at 1:59 PM, Andy Adamson <andros@netapp.com> wrote:
> >> >
> >> > On Aug 4, 2010, at 3:21 PM, Yudong Gao wrote:
> >> >
> >> >> Hi,
> >> >>
> >> >> I am not able to find the implementation of directory delegation,
> >> >> either. Similarly, the callback functions CB_NOTIFY is not
> >> >> implemented, either. I find that in preprocss_nfs41_op() in
> >> >> callback_xdr.c, whenever a CB_NOTIFY is encountered, an
> >> >> NFS4ERR_NOTSUPP is returned directly.
> >> >
> >> > CB_NOTIFY is not currently supported on the Linux NFS client.
> >> >
> >> >>
> >> >> Am I missing something? Or they are just not supported in the current version?
> >> >>
> >> >> Thanks a lot!
> >> >>
> >> >> best,
> >> >>
> >> >> Yudong
> >> >>
> >> >> On Mon, Aug 2, 2010 at 5:17 PM, Yudong Gao <stgyd@umich.edu> wrote:
> >> >>> Hi,
> >> >>>
> >> >>> I am looking at the delegation implementation in the source code of
> >> >>> NFS 4.1 in kernel 2.6.32.15. I can find the code for read delegation,
> >> >>> which is working and can serve the read requests locally. But I can
> >> >>> never find the code about write delegation, which is supposed to cache
> >> >>> the write update locally. I try to look at the functions including
> >> >>> nfs_writepage(s), nfs_file_flush() but none of them checks or uses the
> >> >>> write delegation.
> >> >>>
> >> >>> Is write delegation currently implemented in NFS 4.1?
> >> >
> >> > Write delegation is supported but I don't think write behavior changes - writes are still cached and flushed as without a write delegation. The write delegation does prevent open/close and lock/locku from being put on the wire.
> >> >
> >> > -->Andy
> >> >
> >> >>>
> >> >>> Thanks!
> >> >>>
> >> >>> best,
> >> >>>
> >> >>> Yudong
> >> >>>
> >> >> --
> >> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> >> the body of a message to majordomo@vger.kernel.org
> >> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> >
> >> >
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> >
> >



