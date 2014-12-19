Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:48738 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbaLSUqu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2014 15:46:50 -0500
Received: by mail-vc0-f179.google.com with SMTP id le20so619583vcb.10
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 12:46:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFBgkFQUhH9aNsmYmfZn2RBtD8_7qYbMcLHBJr4OZ8m3A@mail.gmail.com>
References: <CAHQdGtQ_aHRknHzebarn8NUos_wBf4BZOCeg627FsLzcK3erOA@mail.gmail.com>
	<1419015154-91037-1-git-send-email-trond.myklebust@primarydata.com>
	<CAHQdGtTqO02BWwTOsXn2s641_KBdawBexG5+kGwmJKWaAmewtA@mail.gmail.com>
	<CAN-5tyFBgkFQUhH9aNsmYmfZn2RBtD8_7qYbMcLHBJr4OZ8m3A@mail.gmail.com>
Date: Fri, 19 Dec 2014 15:46:50 -0500
Message-ID: <CAHQdGtR3Pj+QRqVoicpy8Ru31ZQC0O5qpH90Zcunko0RkadEKg@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] NFSv4: Deal with atomic upgrades of an existing delegation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 19, 2014 at 3:39 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Fri, Dec 19, 2014 at 3:31 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Fri, Dec 19, 2014 at 1:52 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> Ensure that we deal correctly with the case where the server sends us a
>>> newer instance of the same delegation. If the stateids match, but the
>>> sequence numbers differ, then treat the new delegation as if it were
>>> an atomic upgrade.
>>>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@primarydata.com>
>>> ---
>>>  fs/nfs/delegation.c | 21 ++++++++++++++++++---
>>>  1 file changed, 18 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>>> index 7f3f60641344..02b5b2a6d557 100644
>>> --- a/fs/nfs/delegation.c
>>> +++ b/fs/nfs/delegation.c
>>> @@ -301,6 +301,19 @@ nfs_inode_detach_delegation(struct inode *inode)
>>>         return nfs_detach_delegation(nfsi, delegation, server);
>>>  }
>>>
>>> +static void
>>> +nfs_update_inplace_delegation(struct nfs_inode *nfsi,
>>> +               struct nfs_delegation *delegation,
>>> +               struct nfs_delegation *update)
>>> +{
>>> +       if (nfs4_stateid_is_newer(&update->stateid, &delegation->stateid))
>>
>> ...and the above comparison should be reversed.
>
> do you mean: if(!nfs4_stateid_is_newer())
>
> but if we received a delegation stateid with sequence number lower
> than what we have, shouldn't that be some kind of an error?

See the v3 patch. Yes, it would be a bug if the server sent us
something with a lower number, so we ignore that and don't update the
delegation. Ditto if it sends us something with the same sequence
number.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
