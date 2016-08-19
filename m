Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:47158 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755669AbcHSPpZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2016 11:45:25 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Kornievskaia Olga <aglo@umich.edu>
CC: Kinglong Mee <kinglongmee@gmail.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] NFSv4: Ensure that we drain the session before
 shutting it down
Date: Fri, 19 Aug 2016 15:45:13 +0000
Message-ID: <9E62B7D6-D683-4F92-BA63-8183D21498FF@primarydata.com>
References: <CAHQdGtTn5me9ZBfv9D8qZOmp6MFc29ppn4DqD8hOuMqRgRY8Rg@mail.gmail.com>
 <1427142109-91216-1-git-send-email-trond.myklebust@primarydata.com>
 <CAN-5tyEK-Ua=-TuGHO=o4Mo7C5bs5Wi0AzmJo6vC6bsTV9czZQ@mail.gmail.com>
In-Reply-To: <CAN-5tyEK-Ua=-TuGHO=o4Mo7C5bs5Wi0AzmJo6vC6bsTV9czZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 19, 2016, at 09:41, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> Hi Trond, Kinglong,
>=20
> What has happened to this patch?

It was dropped, since it should be unnecessary. The delegreturn calls from =
nfs4_evict_inode() should now be synchronous, and other calls should normal=
ly grab a reference to the inode+super block.

>=20
> I believe the lack of this patch is causing the following problem on
> the nfsv4.1 mount:
> 1. client has delegations
> 2. unmount is initiated which as Kinglong points out:
> -- initiates asynchronous DELEGRETURNs.
> -- then in nfs_free_server() it ends up killing ongoing rpc tasks with
> DELEGRETURN.
> -- nfs41_proc_sequence() takes a reference on the client structure.
> However since the RPCs are killed there is no call to nfs_put_client()
> which is done in the nfs4_sequence_release()

task->tk_ops->rpc_release() is guaranteed to be run.

> -- then in nfs_put_client() the reference count doesn't go down to 0
> and DESTROY_SESSION isn't called. The user's umount succeeds but we
> still have the client structure with a session.



