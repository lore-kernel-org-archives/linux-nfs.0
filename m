Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:36843 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbbAUWsV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2015 17:48:21 -0500
Received: by mail-vc0-f180.google.com with SMTP id im6so15180636vcb.11
        for <linux-nfs@vger.kernel.org>; Wed, 21 Jan 2015 14:48:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFX02eAzoO3NeRgBuyr8Hp0_xzaLNJ8BMJZ99gJqJmPMQ@mail.gmail.com>
References: <CAN-5tyFX02eAzoO3NeRgBuyr8Hp0_xzaLNJ8BMJZ99gJqJmPMQ@mail.gmail.com>
Date: Wed, 21 Jan 2015 17:48:20 -0500
Message-ID: <CAHQdGtRZx+JhZLUi0JdmB0afO7wkhXHMUK_FFD0G5frdiWHSPQ@mail.gmail.com>
Subject: Re: race between inode eviction with delegation and opening same file
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On Wed, Jan 21, 2015 at 5:29 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> There is a race between return of a delegation (due to resource
> constraints and inode getting evicted) and an open for the same file
> because….
>
> In nfs_inode_return_delegation_noreclaim() we detach that delegation
> from the inode first (nfs_inode_detach_delegation()) and then we send
> a delegreturn. In between of nfs_inode_detach_delegation() and
> nfs_do_return_delegation() an open request comes and it doesn’t see
> any delegations for this inode and thus it sends an open request. At
> the same time eviction thread is working on doing a delegreturn for
> this inode. The server gets request for the open first and returns a
> delegation for it (note: server will issue the same delegation stateid
> but different seqnum as the one currently being returned by the
> client). Then the server processes a delegreturn for this file (from
> its perspective delegation stateid is no longer valid). Yet, on the
> client side as it processes a reply from the server, it adds a “new”
> delegation to the inode and proceeds to use it for an IO request later
> which errors in BAD_STATEID.
>
> I don't see how we can make detaching the delegation and the return of
> it atomic. Instead I propose the following solution:
> I propose to examine the delegation we get on open. If the sequence
> number is not 0 and we don't have a delegation already then we must
> have experienced this race. Therefore, we should return the delegation
> (and ignore if this errors, as the server thinks there is no more
> delegation). Something like this. Disclaimer: it doesn't seem to be
> the actual fix (as it hangs the machine) so I'm still missing
> something ....
>
>
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index b76166b..01bba63 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -368,5 +368,12 @@ int nfs_inode_set_delegation(struct inode *inode,
> struct rpc_cred *cred, struct
>                                 old_delegation, clp);
>                 if (freeme == NULL)
>                         goto out;
> +       } else {
> +               if (be32_to_cpu(delegation->stateid.seqid) > 0) {
> +                       nfs_do_return_delegation(inode, delegation, 0);
> +                       goto out;
> +               }
>         }
>         list_add_rcu(&delegation->super_list, &server->delegations);
>         nfsi->delegation_state = delegation->type;

Shouldn't the seqid always be non-zero? AFAIK, RFC5661 reserves seqid
== 0 for the special case where the client is asking the server to
'please substitute the most recent value' (see section 8.2.2).
Normally, the server is therefore supposed to start with seqid == 1,
and increment so that when the seqid wraps around, it skips over the
value '0'.

Also, please note that nfs_do_return_delegation() may sleep, so you
cannot call it while holding a spinlock.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
