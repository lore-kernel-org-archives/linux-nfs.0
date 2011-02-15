Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49788 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670Ab1BOPDo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 10:03:44 -0500
Subject: Re: [PATCH 10/16] pnfs: wave 3: coelesce across layout stripes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
        Andy Adamon <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>,
        Benny Halevy <bhalevy@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>
In-Reply-To: <AANLkTikRMT=xxXp+7ky9kaYCOn2-y0obpJ7-gW96NkN5@mail.gmail.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
	 <1297711116-3139-11-git-send-email-andros@netapp.com>
	 <1297726920.23841.51.camel@heimdal.trondhjem.org>
	 <AANLkTikRMT=xxXp+7ky9kaYCOn2-y0obpJ7-gW96NkN5@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Feb 2011 10:03:40 -0500
Message-ID: <1297782220.10103.13.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-02-15 at 09:43 -0500, William A. (Andy) Adamson wrote: 
> On Mon, Feb 14, 2011 at 6:42 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Mon, 2011-02-14 at 14:18 -0500, andros@netapp.com wrote:
> >> From: Fred Isaman <iisaman@netapp.com>
> >>
> >> Add a pg_test layout driver hook which is used to avoid coelescing I/O across
> >> layout stripes.
> >
> > Doesn't this belong before [PATCH 09/16] pnfs: wave 3: shift
> > pnfs_update_layout locations?
> 
> The pg_test uses the pg_lseg declared in [PATCH 09/16] pnfs: wave 3:
> shift pnfs_update_layout locations, which is why the patches are
> ordered this way.

What prevents you from moving the pg_lseg declaration into this patch,
and just relying on the initialisation being NULL?

The current ordering means that applying 9/16 without 10/16 gives rise
to broken stripe sizes.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

