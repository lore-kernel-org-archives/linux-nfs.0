Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f176.google.com ([209.85.128.176]:43860 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284Ab3I0UUN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Sep 2013 16:20:13 -0400
Received: by mail-ve0-f176.google.com with SMTP id jx11so2396511veb.35
        for <linux-nfs@vger.kernel.org>; Fri, 27 Sep 2013 13:20:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5245B44B.2080508@panasas.com>
References: <52447EA0.7070004@primarydata.com> <524588C7.9040500@panasas.com>
 <CAEMWVhsD-f2wZJzASMtC10XHPH2aSTzVLtYje3U8ezP_+67rWw@mail.gmail.com> <5245B44B.2080508@panasas.com>
From: Benny Halevy <bhalevy@primarydata.com>
Date: Fri, 27 Sep 2013 16:19:52 -0400
Message-ID: <CAEMWVhtE9TTB4i4iidfayVwWWX5aTtQ7pnKXPfba3YUZ2fapfg@mail.gmail.com>
Subject: Re: [PATCH RFC v0 0/49] pnfsd-dlm
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Lev Solomonov <solo@primarydata.com>,
        Idan Kedar <idank@primarydata.com>,
        Nadav Shemer <nadav@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 27, 2013 at 12:37 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 09/27/2013 09:34 AM, Benny Halevy wrote:
>>> I thought that we said that exofs server is going in first. What happened?
>>
>> exofs requires much more functionality.
>> To help review the code we need to go through this milestone in any case.
>>
>
> That is not true. Look at the way I staged the pnfsd-exofs patches. after
> the LO_GET LO_COMMIT and LO_RETURN patches you have a full functioning
> git cloning exofs. (BTW exofs does not need DEVICELIST)
>
> So OK your patches do not have LO_COMMIT but this code path is trivial
> and what is that contraption of returning "no-layout" for writes and
> then not having the LO_COMMIT support. This is plain hacky and not
> in accord to the pNFS philosophy of things.
>
> And We can farther split my original set to do read-only with out LO_COMMIT
> and add a simple LO_COMMIT stage with enable of write LAYOUTs, easily.
> Which is what you have with much less code.
>
> The recall comes in at a different patch that can be staged later and is
> effectively not needed for normal operations.
>
> Actually the all code including the exofs patches first stage is smaller and
> simpler then the DLM contraption. And it only touches exofs code which
> does not involve other sensitive subsystems.
>
> I have a deja vu about this. Why won't you talk to me before working on such
> DLM crap that is not at all pnfs, but a hack that demonstrates nothing?
>
> Please do the right thing, since you are already putting all this effort. And I can
> help as well with the pnfsd-exofs patches part.
>
> BTW: Thank you for doing this, it is about time someone should put some mainline love
> to the pNFS server
>
> Thanks
> Boaz

Boaz, sorry but the files layout went first to production on the
client side in all major
enterprise distributions so it doesn't make sense to submit exofs first.
As for your patch series, I respect the work you did on it but
a. as you said it is your patch series, not mine
b. the forward port from 3.10 on changed the layout state handling
radically (for the better I hope :)
solving numerous correctness issues.
The motivation behind the dlm based implementation is to have a
minimal useful pnfs implementation
that folks can use and test the client against.
On this basis, writes layout can be added, and further on, exofs
support can submitted as the next stage.

Benny
