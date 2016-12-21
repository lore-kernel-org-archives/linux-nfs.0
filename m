Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46022 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752226AbcLUBz7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 20:55:59 -0500
Date: Tue, 20 Dec 2016 20:55:57 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
Message-ID: <20161221015556.GE9500@parsley.fieldses.org>
References: <148065078775.28046.5506130555300891075.stgit@noble>
 <148065110833.28046.2561331715736018574.stgit@noble>
 <8e72acac-42de-bf02-9069-60e7b6a12c04@RedHat.com>
 <87r35k4rcr.fsf@notabene.neil.brown.name>
 <87mvfqrxsf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87mvfqrxsf.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 21, 2016 at 10:22:24AM +1100, NeilBrown wrote:
> On Wed, Dec 07 2016, NeilBrown wrote:
> 
> > [ Unknown signature status ]
> > On Wed, Dec 07 2016, Steve Dickson wrote:
> >
> >>> +.B nfsd
> >>> +Recognized values:
> >>> +.BR threads ,
> >>> +.BR grace-time ,
> >>> +.BR lease-time ,
> >>> +.BR udp ,
> >>> +.BR tcp ,
> >>> +.BR vers2 ,
> >>> +.BR vers3 ,
> >>> +.BR vers4 ,
> >>> +.BR vers4.0 ,
> >> Do we need both ver4 and ver4.0?
> >
> > "vers4" allows you to enable or disable v4 has a whole.
> > The assumption is that if enabled, all minor versions that the kernel
> > supports will be enabled by default.
> > vers4.x allows individual minor versions to be disabled, so
> >  vers4=yes
> >  vers4.0=no
> > would disable v4.0, just like "-V4 -N4.0"
> 
> What I meant here, of course, is
>    just like "-V4 -N4.0" *should*
> 
> not "just like what it *does*."
> 
> To my surprise, when you actually try "nfsd -N4.0",
> it opens /proc/fs/nfsd/versions and writes "+4.32".
> 
> #define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 1))) 
> 
> That "-1" makes it clear that version 4.0 isn't understood.
> 
> The kernel side seem to understand that '0' is an independent minor version:
> static bool nfsd_supported_minorversions[NFSD_SUPPORTED_MINOR_VERSION + 1] = {
> 	[0] = 1,
> 	[1] = 1,
> 	[2] = 1,
> };
> 
> but refuses to let it be disabled:
> 				if (num != 4)
> 					return -EINVAL;
> 				minor = simple_strtoul(minorp+1, NULL, 0);
> 				if (minor == 0)
> 					return -EINVAL;
> 
> so you can have 4.1 disabled while 4.0 and 4.2 are active, but you
> cannot disable 4.0 as well.
> 
> Should that be fixed?  Do we care?

It's not going to keep me up at night, but we should probably go ahead
and fix it, I can imagine somebody might care some day.

--b.

> 
> At least we should change
> 					int i = atoi(p+1);
> 					if (i > NFS4_MAXMINOR) {
> 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
> 						exit(1);
> 
> in nfsd.c so the test is
>   if (i < NFS4_MINMINOR || i > NFS4_MAXMINOR) {
> 
> I'll send a patch.
> 
> Thanks,
> NeilBrown


