Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:49775 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbaG2TwQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 15:52:16 -0400
Received: by mail-vc0-f182.google.com with SMTP id hy4so283152vcb.41
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 12:52:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53D7EA62.3070204@RedHat.com>
References: <53D7EA62.3070204@RedHat.com>
Date: Tue, 29 Jul 2014 15:52:15 -0400
Message-ID: <CAHQdGtQ2DU4GnMXy=n9JQzUhGkEC=+UEM8NVm=MviBt0+RJzBA@mail.gmail.com>
Subject: Re: nfs4_state_manager() vs. nfs_server_remove_lists()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2014 at 2:39 PM, Steve Dickson <SteveD@redhat.com> wrote:
> Hello,
>
> I've been seeing a panic where nfs4_state_manager()
> ends up processing an v3 nfs client pointer.
>
> The panic happens at the top of nfs4_state_manager()
> because clp->cl_mvops == NULL;
>
> Looking at the pointer (via crash) it becomes obvious
> it is  a V3 client point (AKA rpc_ops = nfs_v3_clientop)
>
> Now the reason we are in the state manager code is a NFSv4
> mount doing server discovery so it is waking the client list
> in nfs41_walk_client_list()
>
> Now looking at the at the entire stack with crash, the
> only time that v3 client pointer appears is after
> nfs41_walk_client_list() has been called so I'm 99%
> sure the pointer is coming from the cl_share_link list.
>
> So the question is how is that v3 client pointer on that
> list, in non NFS_CS_READY state.
>
> Well, simultaneously a V3 mount is happening. In nfs_fs_mount_common()
> it notices there is already a existing supper block sit decides to
> free its server pointer so nfs_server_remove_lists() is called.
>
> What  nfs_server_remove_lists() and nfs41_walk_client_list()
> have in common is the nfs_client_lock spin lock.
>
> Also the client pointer in the server pointer being freed is
> in a non NFS_CS_READY state
>
> To answer the question, the v3 client pointer, in a non
> NFS_CS_READY state, is found by nfs41_walk_client_list()
> because it beat nfs_server_remove_lists() to the
> nfs_client_lock spin lock.
>
> nfs41_walk_client_list() finds the uninitialized client
> pointer nfs_server_remove_lists() is trying to free and
> processes it and then fall over...
>
> Note this was very hard to reproduce since a very large client
> (many cores) is needed and a very fast server and a few
> hours...
>
> Question, since both v3 and v4 clients are on the cl_share_link
> list should there be a check in nfs41_walk_client_list() to
> process only v4 clients?
>

Hi Steve,

Let's just move up the test for "pos->rpc_ops != new->rpc_ops",
"pos->cl_minorversion != new->cl_minorversion" and "pos->cl_proto !=
new->cl_proto" so that they all happen before we try to test the value
of cl_cons_state.
As far as I can tell, all those values are guaranteed to be set as
part of the struct nfs_client allocators, before we ever put the
result on the cl_share_link list.

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
