Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:37608 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754754Ab1IMHDA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 03:03:00 -0400
From: <tao.peng@emc.com>
To: <bhalevy@tonian.com>, <bergwolf@gmail.com>
CC: <Trond.Myklebust@netapp.com>, <gusev.vitaliy@nexenta.com>,
        <gusev.vitaliy@gmail.com>, <linux-nfs@vger.kernel.org>
Date: Tue, 13 Sep 2011 03:02:32 -0400
Subject: RE: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
Message-ID: <F19688880B763E40B28B2B462677FBF805C3299F6D@MX09A.corp.emc.com>
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
 <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com>
 <1315348373.19556.22.camel@lade.trondhjem.org>
 <F19688880B763E40B28B2B462677FBF805C3299CA3@MX09A.corp.emc.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED3DF@SACMVEXC2-PRD.hq.netapp.com>
 <CA+a=Yy71JNEgG4q0e69BWEjxqh71CTcfise6KKTyYkXGUM68Tw@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED4C8@SACMVEXC2-PRD.hq.netapp.com>
 <F19688880B763E40B28B2B462677FBF805C3299D2F@MX09A.corp.emc.com>
 <1315592430.17611.15.camel@lade.trondhjem.org> <4E6B0E48.7050208@tonian.com>
 <CA+a=Yy5fMHPcSU4EoSo1uiOUCfi8vjRVPAjEYGZ+M00CwZ8Z9g@mail.gmail.com>
 <4E6E6C3B.2040605@tonian.com>
In-Reply-To: <4E6E6C3B.2040605@tonian.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@tonian.com]
> Sent: Tuesday, September 13, 2011 4:32 AM
> To: Peng Tao
> Cc: Trond Myklebust; Peng, Tao; gusev.vitaliy@nexenta.com;
> gusev.vitaliy@gmail.com; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
> 
> On 2011-09-12 07:56, Peng Tao wrote:
> > On Sat, Sep 10, 2011 at 3:14 PM, Benny Halevy <bhalevy@tonian.com> wrote:
> >> On 2011-09-09 11:20, Trond Myklebust wrote:
> >>> On Thu, 2011-09-08 at 23:11 -0400, tao.peng@emc.com wrote:
> >>>> HI, Trond,
> >>>>
> >>>>> -----Original Message-----
> >>>>> From: Myklebust, Trond [mailto:Trond.Myklebust@netapp.com]
> >>>>> Sent: Friday, September 09, 2011 1:05 AM
> >>>>> To: Peng Tao
> >>>>> Cc: Peng, Tao; gusev.vitaliy@nexenta.com; gusev.vitaliy@gmail.com;
> >>>>> linux-nfs@vger.kernel.org
> >>>>> Subject: RE: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
> >>>>>
> >>>>>> -----Original Message-----
> >>>>>> From: Peng Tao [mailto:bergwolf@gmail.com]
> >>>>>> Sent: Thursday, September 08, 2011 11:00 AM
> >>>>>> To: Myklebust, Trond
> >>>>>> Cc: tao.peng@emc.com; gusev.vitaliy@nexenta.com;
> >>>>>> gusev.vitaliy@gmail.com; linux-nfs@vger.kernel.org
> >>>>>> Subject: Re: [PATCH] nfs: fix inifinite loop at
> >>>>>> nfs4_layoutcommit_release
> >>>>>>
> >>>>>> On Thu, Sep 8, 2011 at 8:01 PM, Myklebust, Trond
> >>>>>> <Trond.Myklebust@netapp.com> wrote:
> >>>>>>>> -----Original Message-----
> >>>>>>
> >>>>>>>
> >>>>>>> Yes, but as far as I can see, even in the blocks case there can be
> >>>>>> multiple extents per layout segment. What if I write to one
> >>>>>> uninitialised extent, layoutcommit, then write to another uninitialized
> >>>>>> extent in the same layout segment and layoutcommit? In my reading of
> >>>>>> the code, there is a chance that the second layoutcommit will fail to
> >>>>>> pick up the layout segment, and so will fail to notify the MDS that the
> >>>>>> second extent now contains data.
> >>>>>>
> >>>>>> blocklayout does not decide what to layoutcommit according to the lseg
> >>>>>> list. Instead, it keeps track of each extent's state at the
> >>>>>> granularity of blocksize, and encode whatever needs layoutcommitted in
> >>>>>> the layoutcommit call. So in your above case, as long as the second
> >>>>>> layoutcommit is issued, blocklayout will encode the newly written
> >>>>>> extent in the second layoutcommit call, even if the lseg is not
> >>>>>> attached to the second layoutcommit.
> >>>>>>
> >>>>>> But that leads to another two question:
> >>>>>> 1. How do we protect against layoutrecall if lseg is not linked to
> >>>>>> layoutcommit? For this one, can we just reject layoutrecall if there
> >>>>>> is inflight layoutcommit? It will be less parallel but can guarantee
> >>>>>> current implementation correctness.
> >>>>>> 2. blocklayout ONLY: bl_committing may be overloaded by several
> >>>>>> layoutcommit calls and we don't have information in
> >>>>>> cleanup_layoutcommit() on how many entry should be removed from
> >>>>>> bl_committing. Maybe we can add a (void*) to struct
> >>>>>> nfs4_layoutcommit_data, so that LD can pass some private information
> >>>>>> between encode_layoutcommit() and cleanup_layoutcommit()?
> >>>>>
> >>>>> 3. What is the purpose of pinning the layout segment at all if neither blocks,
> nor
> >>>>> objects nor files cares?
> >>>> I believe it is for protecting against layoutrecall. But since we are seperating
> lseg and LD specific layout information management, it is actually not working as
> expected.
> >>>>
> >>
> >> The layout segments are not really in use while in LAYOUTCOMMIT.
> >> We only need to get the stateid right with respect to concurrent layout recalls.
> > LAYOUTCOMMIT takes lseg reference to mark them as in use so that
> > layoutrecall cannot free them.
> >
> 
> And if layoutrecall would have freed layout segments during layoutcommit,
> what is your specific concern?
In layoutcommit_release, blocklayout need to access the corresponding extents to convert their states. If the layout segments are freed by layoutrecall, it can cause problems.

> 
> Benny

