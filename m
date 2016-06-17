Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34533 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbcFQNxb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2016 09:53:31 -0400
Received: by mail-oi0-f68.google.com with SMTP id a64so13849915oii.1
        for <linux-nfs@vger.kernel.org>; Fri, 17 Jun 2016 06:53:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1463755437-17649-1-git-send-email-andros@netapp.com>
References: <1463755437-17649-1-git-send-email-andros@netapp.com>
From: Martin Houry <martinhoury@gmail.com>
Date: Fri, 17 Jun 2016 15:53:10 +0200
Message-ID: <CAEUt8V+tLAgkkuFZSDfAW+0gZcP5=HYrhnv5rVeFRkmCH-xn3g@mail.gmail.com>
Subject: Re: [PATCH Version 5 00/10] NFSV4.1,2 session trunking
To: andros@netapp.com
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        anna.schumaker@netapp.com, Bruce Fields <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Olivier Hault <olivier.hault@level-it.be>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greeting,

I have just tested the new version of the patch. I tried to shutdown
an interface to see how it react. I have seen that the transfert is
suspended until I up the interface back. This is a threat and I would
like to share with you some clue to resolve it.
1 - Could we use the depth of the requests queue to analyse if it stay
at the same value during a determined amout of time. If this time is
too long, we switch all the requests of this queue to another.
2 - Stay aware of the state of each TCP connection and switch all the
request of this queue to another if the TCP connection goes down.
3 - Check the RTT of the request and consider the connection down if
the RTT is too long. If it's too long  switch all the request of this
queue to another.

What do you think of these propositions?


Martin

2016-05-20 16:43 GMT+02:00  <andros@netapp.com>:
> From: Andy Adamson <andros@netapp.com>
>
> Version-5
> ---------
>
> Responded to Anna's code cleanup comments.
>
> --> Andy
>
> Version-4
> ---------
>
> This patch set enables session trunking configured two ways.
>
> The NFSv4 minorversion > 0 pseudo-fs is probed
> with a GETATTR(fs_locations) to retrieve a replicas list.
> Each replica address is tested for session trunking. Those
> that pass are added as aliases to the mount rpc client.
>
> Try all multipath addresses for a data server. The first address that
> successfully connects and creates a session is the mount address.
> All subsequent addresses are tested for session trunking and
> added as aliases.
>
> TODO:
>
> - Periodically probe the pseudo-fs with the GETATTR(fs_locations)
> to pick up server multipath changes. This is why the
> GETATTR(fs_locations) is a stand alone call.
>
> - Call BIND_CONN_TO_SESSION for session trunking addresses
> established under SP4_MACH_CRED or SP4_SSV. SP4_NONE established
> addresses do not require BIND_CONN_TO_SESSION.
>
> TESTING:
>
> The pseudo-fs GETATTR(fs_locations) probe session trunking
> was tested against a Linux server with a pseudo-fs
> export stanza (e.g. a stanza with the fsid=0 or fsid=root
> export option) and a replicas= export option
> (replicas=<path1>@<server1>:<path2>@<server2>..)
> Note that this configuration is for testing only. A future
> patchset will add the replicas= configuration to the
> NFSEXP_V4ROOT nfsd and mountd processing.
>
> The pNFS DS multipath session trunking was tested against a
> pynfs server which provides DS multipath configuration.
>
>
> Andy Adamson (10):
>   NFS rename default callback ops
>   NFS refactor nfs4_match_clientids
>   NFS refactor nfs4_check_serverowner_major_id
>   NFS detect session trunking
>   NFS refactor _nfs4_proc_exchange_id for session trunking
>   SUNRPC add flag to rpc_task_release_client
>   NFS probe pseudo-fs for replicas
>   NFS test and add multipaths for session trunking
>   NFS test pnfs data server multipath session trunking aliases
>   NFS add multiaddr to nfs_show_nfsv4_options
>
>  fs/nfs/internal.h           |   2 +
>  fs/nfs/nfs4_fs.h            |   9 ++
>  fs/nfs/nfs4client.c         | 102 +++++++++++++++++---
>  fs/nfs/nfs4getroot.c        |   3 +
>  fs/nfs/nfs4proc.c           | 222 ++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfs/nfs4xdr.c            |  38 +++-----
>  fs/nfs/pnfs_nfs.c           |  51 +++++++---
>  fs/nfs/super.c              |  26 ++++++
>  include/linux/nfs_xdr.h     |   4 +-
>  include/linux/sunrpc/clnt.h |   2 +-
>  net/sunrpc/clnt.c           |   6 +-
>  net/sunrpc/sched.c          |   2 +-
>  net/sunrpc/xprtmultipath.c  |   4 +
>  13 files changed, 406 insertions(+), 65 deletions(-)
>
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
