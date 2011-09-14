Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:26291 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306Ab1INHxw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Sep 2011 03:53:52 -0400
From: <tao.peng@emc.com>
To: <bhalevy@tonian.com>
CC: <Trond.Myklebust@netapp.com>, <bergwolf@gmail.com>,
        <gusev.vitaliy@nexenta.com>, <gusev.vitaliy@gmail.com>,
        <linux-nfs@vger.kernel.org>
Date: Wed, 14 Sep 2011 03:53:30 -0400
Subject: RE: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
Message-ID: <F19688880B763E40B28B2B462677FBF805C3F7A911@MX09A.corp.emc.com>
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
  <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com>
  <1315348373.19556.22.camel@lade.trondhjem.org>
  <F19688880B763E40B28B2B462677FBF805C3299CA3@MX09A.corp.emc.com>
  <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED3DF@SACMVEXC2-PRD.hq.netapp.com>
  <CA+a=Yy71JNEgG4q0e69BWEjxqh71CTcfise6KKTyYkXGUM68Tw@mail.gmail.com>
  <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED4C8@SACMVEXC2-PRD.hq.netapp.com>
  <F19688880B763E40B28B2B462677FBF805C3299D2F@MX09A.corp.emc.com>
  <1315592430.17611.15.camel@lade.trondhjem.org>
  <4E6B0E48.7050208@tonian.com>
  <CA+a=Yy5fMHPcSU4EoSo1uiOUCfi8vjRVPAjEYGZ+M00CwZ8Z9g@mail.gmail.com>
  <4E6E6C3B.2040605@tonian.com> <1315861851.8350.11.camel@lade.trondhjem.org>
 <4E6F0B61.4050907@tonian.com>
 <F19688880B763E40B28B2B462677FBF805C3299FA6@MX09A.corp.emc.com>
 <4E704D05.6020406@tonian.com>
In-Reply-To: <4E704D05.6020406@tonian.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@tonian.com]
> Sent: Wednesday, September 14, 2011 2:43 PM
> To: Peng, Tao
> Cc: Trond.Myklebust@netapp.com; bergwolf@gmail.com;
> gusev.vitaliy@nexenta.com; gusev.vitaliy@gmail.com; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
> 
> On 2011-09-13 10:32, tao.peng@emc.com wrote:
> >> -----Original Message-----
> >> From: Benny Halevy [mailto:bhalevy@tonian.com]
> >> Sent: Tuesday, September 13, 2011 3:51 PM
> >> To: Trond Myklebust
> >> Cc: Peng Tao; Peng, Tao; gusev.vitaliy@nexenta.com; gusev.vitaliy@gmail.com;
> >> linux-nfs@vger.kernel.org
> >> Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
> >>
> >> On 2011-09-12 14:10, Trond Myklebust wrote:
> >>> On Mon, 2011-09-12 at 13:31 -0700, Benny Halevy wrote:
> >>>> On 2011-09-12 07:56, Peng Tao wrote:
> >>>>>> The layout segments are not really in use while in LAYOUTCOMMIT.
> >>>>>> We only need to get the stateid right with respect to concurrent layout
> recalls.
> >>>>> LAYOUTCOMMIT takes lseg reference to mark them as in use so that
> >>>>> layoutrecall cannot free them.
> >>>>>
> >>>>
> >>>> And if layoutrecall would have freed layout segments during layoutcommit,
> >>>> what is your specific concern?
> >>>
> >>> That layoutcommit is supposed to return NFS4ERR_BAD_LAYOUT in that case
> >>> according to section 18.42.3 of RFC5661. I can't find anything in the
> >>> errata that changes that requirement.
> >>>
> >>
> >> Right. That tells me there no need to strictly serialize LAYOUTCOMMITs
> >> with CB_LAYOUTRECALL, as long as the layout stateid sent with LAYOUTCOMMIT
> >> atomically represents the state when the operation was prepared.
> >>
> >> That said, since we do want the LAYOUTCOMMIT to succeed, it would be
> beneficial
> >> for the client to reply to a CB_LAYOUTRECALL received while a conflicting
> >> LAYOUTCOMMIT is in progress with NFS4ERR_DELAY.
> > I agree. How about adding a new flag to nfsi->flags for this? We can use the same
> flag on to ensure serialization of multiple layoutcommit.
> nfs_commit_set_lock/nfs_commit_clear_lock may not fit for this.
> >
> 
> Sounds good in principle.
> Can you take a stab at a patch that does this?
OK, I will spend some time on it this week.

Thanks,
Tao
> 
> Benny
> 
> >>
> >> The server, on its side, should prevent a distributed deadlock by avoiding
> >> blocking of a LAYOUTCOMMIT on an outstanding CB_LAYOUTRECALL for the
> same
> >> client that sent the LAYOUTCOMMIT.  I'm not sure what error would be best to
> >> return.  Maybe NFS4ERR_RECALL_CONFLICT if it would be allowed (it isn't listed
> >> for LAYOUTCOMMIT at the moment).  Just returning NFS4ER_DELAY might lead
> to
> >> a live lock situation where neither the LAYOUTCOMMIT not the
> CB_LAYOUTRECALL
> >> complete.
> >>
> >> Benny
> >

