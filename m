Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:51512 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaHBNwH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Aug 2014 09:52:07 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so7151964pdb.31
        for <linux-nfs@vger.kernel.org>; Sat, 02 Aug 2014 06:52:05 -0700 (PDT)
Message-ID: <53DCECE0.4070309@gmail.com>
Date: Sat, 02 Aug 2014 21:51:28 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jeff.layton@primarydata.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 31/38] nfsd: Move the open owner hash table into struct
 nfs4_client
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>	<1406684083-19736-32-git-send-email-jlayton@primarydata.com>	<53DCBFDB.5060808@gmail.com>	<CAHQdGtTGNZsqZTCQhUboG1kE+bzb7p3K+5BxmusFG+qWMrVJzg@mail.gmail.com> <20140802092356.2c8bf1c8@tlielax.poochiereds.net>
In-Reply-To: <20140802092356.2c8bf1c8@tlielax.poochiereds.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/2/2014 21:23, Jeff Layton wrote:
> On Sat, 2 Aug 2014 09:11:25 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> On Sat, Aug 2, 2014 at 6:39 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>>> On 7/30/2014 09:34, Jeff Layton wrote:
>>>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>>>>
>>>> Preparation for removing the client_mutex.
>>>>
>>>> Convert the open owner hash table into a per-client table and protect it
>>>> using the nfs4_client->cl_lock spin lock.
>>>>
>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>>> ---
>>>>  fs/nfsd/netns.h     |   1 -
>>>>  fs/nfsd/nfs4state.c | 187 ++++++++++++++++++++++++----------------------------
>>>>  fs/nfsd/state.h     |   1 +
>>>>  3 files changed, 86 insertions(+), 103 deletions(-)
>>>>
>>>> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
>>>> index a71d14413d39..e1f479c162b5 100644
>>>> --- a/fs/nfsd/netns.h
>>>> +++ b/fs/nfsd/netns.h
>>>> @@ -63,7 +63,6 @@ struct nfsd_net {
>>>>       struct rb_root conf_name_tree;
>>>>       struct list_head *unconf_id_hashtbl;
>>>>       struct rb_root unconf_name_tree;
>>>> -     struct list_head *ownerstr_hashtbl;
>>>
>>> I send a patch "NFSD: Rervert "knfsd: locks: flag NFSv4-owned locks"" before,
>>> http://comments.gmane.org/gmane.linux.nfs/64382
>>>
>>> nfsd needs the hashtbl to find the lockowner for locking by owner from
>>> fl->fl_owner stored in struct file_lock, but without nfs_client.
>>
>> Why? We're not currently doing that.
>>
>>> If moving the hashtbl to nfs_client, it's hard to finding the lockowner for locking.
>>
> 
> I think there's a fundamental flaw in your original patch.
> 
> You're casting fl->fl_owner to a struct nfs4_lockowner pointer, and
> then dereferencing that pointer to get to the lo->lo_hashval field. The
> problem there is that conflock might refer to a lock that is not a
> nfsv4 lock, and in that case there is zero guarantee that the
> fl_owner_t is a pointer at all, so that method could end up causing
> oopses.

Yes, you are right, the old patch has the problem.

> 
> The fl_owner is really intended to be an opaque token, and you can't
> turn it back into a pointer without knowing for a fact what sort of
> lock it is. In the v4 case, we use the fl_lmops field to try and
> designate that.

Got it.

> 
> Perhaps you need to change it so that the conflocks get fl_lmops set
> properly instead of changing things like you are in that patch?

OK, I will sends a new patch coping fl_lmops to conflocks for this problem.

thanks,
Kinglong Mee

> 
