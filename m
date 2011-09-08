Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:55204 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132Ab1IHPAt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2011 11:00:49 -0400
Received: by vxi9 with SMTP id 9so263023vxi.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Sep 2011 08:00:49 -0700 (PDT)
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED3DF@SACMVEXC2-PRD.hq.netapp.com>
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
 <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com>
 <1315348373.19556.22.camel@lade.trondhjem.org> <F19688880B763E40B28B2B462677FBF805C3299CA3@MX09A.corp.emc.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED3DF@SACMVEXC2-PRD.hq.netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 8 Sep 2011 23:00:28 +0800
Message-ID: <CA+a=Yy71JNEgG4q0e69BWEjxqh71CTcfise6KKTyYkXGUM68Tw@mail.gmail.com>
Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: tao.peng@emc.com, gusev.vitaliy@nexenta.com, gusev.vitaliy@gmail.com,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 8, 2011 at 8:01 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>> -----Original Message-----
>> From: tao.peng@emc.com [mailto:tao.peng@emc.com]
>> Sent: Thursday, September 08, 2011 6:21 AM
>> To: Myklebust, Trond; gusev.vitaliy@nexenta.com
>> Cc: gusev.vitaliy@gmail.com; linux-nfs@vger.kernel.org
>> Subject: RE: [PATCH] nfs: fix inifinite loop at
>> nfs4_layoutcommit_release
>>
>> Hi, Trond,
>>
>> Sorry for the late response.
>>
>> > -----Original Message-----
>> > From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com]
>> > Sent: Wednesday, September 07, 2011 6:33 AM
>> > To: Vitaliy Gusev
>> > Cc: Vitaliy Gusev; Peng, Tao; linux-nfs@vger.kernel.org
>> > Subject: Re: [PATCH] nfs: fix inifinite loop at
>> nfs4_layoutcommit_release
>> >
>> > On Wed, 2011-09-07 at 02:13 +0400, Vitaliy Gusev wrote:
>> > > >> @@ -1376,7 +1376,8 @@ static void pnfs_list_write_lseg(struct
>> inode *inode,
>> > struct list_head *listp)
>> > > >>
>> > > >>        list_for_each_entry(lseg,&NFS_I(inode)->layout->plh_segs,
>> pls_list) {
>> > > >>                if (lseg->pls_range.iomode == IOMODE_RW&&
>> > > >> -                  test_bit(NFS_LSEG_LAYOUTCOMMIT,&lseg->pls_flags))
>> > > >> +                  test_bit(NFS_LSEG_LAYOUTCOMMIT,&lseg-
>> >pls_flags)&&
>> > > >> +                  list_empty(&lseg->pls_lc_list))
>> > > >>                        list_add(&lseg->pls_lc_list, listp);
>> > > >>        }
>> > > >>   }
>> > > >
>> > > > If the lseg is already part of one layoutcommit, but we're
>> sending a
>> > > > second one for the same range (presumably because we wrote more
>> data in
>> > > > the same region), then the above causes the lseg to be excluded.
>> > >
>> > >
>> > > Yes, lseg is excluded, This patch does exactly only exclusion of
>> lseg.
>> > > lseg is used here only to get/put reference on this lseg, so
>> skipping is
>> > > correct.
>> >
>> > Are you sure? As far as I can see, pnfs_list_write_lseg() actually
>> > assigns the lseg to a particular layoutcommit call.
>> >
>> > My questions are: if I write to an area described by that lseg
>> _after_
>> > it has been assigned to that layoutcommit RPC call (and the latter
>> has
>> > already been dispatched to the metadata server), then
>> >      A. shouldn't it be assigned to a second layoutcommit call too?
>> >      B. If not, what are we doing to ensure mutual exclusion between
>> >         layoutcommit RPC calls and pNFS writes to the data server?
>> I think it depends on the purpose of layoutcommit.
>> 1. for updating atime/mtime. In this case, we don't need mutual
>> exclusion
>
> Agreed.
>
>> between layoutcommit RPC and pNFS writes to data server.
>> 2. for updating LD specific state. In this case, LD should decide what
>> to commit
>> (and actually ignores the range of lseg). Take block layout for
>> example. It maintains
>> blocksized extent state inside LD and determines what to encode inside
>> layoutcommit
>> RPC whenever there is a generic layer layoutcommit call. So when an
>> extent is being
>> layoutcommitted, client can still write to the same range, as long as
>> the lseg is held by client.
>
> Yes, but as far as I can see, even in the blocks case there can be multiple extents per layout segment. What if I write to one uninitialised extent, layoutcommit, then write to another uninitialized extent in the same layout segment and layoutcommit? In my reading of the code, there is a chance that the second layoutcommit will fail to pick up the layout segment, and so will fail to notify the MDS that the second extent now contains data.

blocklayout does not decide what to layoutcommit according to the lseg
list. Instead, it keeps track of each extent's state at the
granularity of blocksize, and encode whatever needs layoutcommitted in
the layoutcommit call. So in your above case, as long as the second
layoutcommit is issued, blocklayout will encode the newly written
extent in the second layoutcommit call, even if the lseg is not
attached to the second layoutcommit.

But that leads to another two question:
1. How do we protect against layoutrecall if lseg is not linked to
layoutcommit? For this one, can we just reject layoutrecall if there
is inflight layoutcommit? It will be less parallel but can guarantee
current implementation correctness.
2. blocklayout ONLY: bl_committing may be overloaded by several
layoutcommit calls and we don't have information in
cleanup_layoutcommit() on how many entry should be removed from
bl_committing. Maybe we can add a (void*) to struct
nfs4_layoutcommit_data, so that LD can pass some private information
between encode_layoutcommit() and cleanup_layoutcommit()?

Thanks,
Tao
