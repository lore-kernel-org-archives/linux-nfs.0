Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:56070 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab3I0Qhn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Sep 2013 12:37:43 -0400
Message-ID: <5245B44B.2080508@panasas.com>
Date: Fri, 27 Sep 2013 12:37:31 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@primarydata.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Lev Solomonov <solo@primarydata.com>,
        Idan Kedar <idank@primarydata.com>,
        Nadav Shemer <nadav@primarydata.com>
Subject: Re: [PATCH RFC v0 0/49] pnfsd-dlm
References: <52447EA0.7070004@primarydata.com> <524588C7.9040500@panasas.com> <CAEMWVhsD-f2wZJzASMtC10XHPH2aSTzVLtYje3U8ezP_+67rWw@mail.gmail.com>
In-Reply-To: <CAEMWVhsD-f2wZJzASMtC10XHPH2aSTzVLtYje3U8ezP_+67rWw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/27/2013 09:34 AM, Benny Halevy wrote:
>> I thought that we said that exofs server is going in first. What happened?
> 
> exofs requires much more functionality.
> To help review the code we need to go through this milestone in any case.
> 

That is not true. Look at the way I staged the pnfsd-exofs patches. after
the LO_GET LO_COMMIT and LO_RETURN patches you have a full functioning
git cloning exofs. (BTW exofs does not need DEVICELIST)

So OK your patches do not have LO_COMMIT but this code path is trivial
and what is that contraption of returning "no-layout" for writes and
then not having the LO_COMMIT support. This is plain hacky and not
in accord to the pNFS philosophy of things.

And We can farther split my original set to do read-only with out LO_COMMIT
and add a simple LO_COMMIT stage with enable of write LAYOUTs, easily.
Which is what you have with much less code.

The recall comes in at a different patch that can be staged later and is
effectively not needed for normal operations.

Actually the all code including the exofs patches first stage is smaller and
simpler then the DLM contraption. And it only touches exofs code which
does not involve other sensitive subsystems.

I have a deja vu about this. Why won't you talk to me before working on such
DLM crap that is not at all pnfs, but a hack that demonstrates nothing?

Please do the right thing, since you are already putting all this effort. And I can
help as well with the pnfsd-exofs patches part.

BTW: Thank you for doing this, it is about time someone should put some mainline love
to the pNFS server

Thanks
Boaz
