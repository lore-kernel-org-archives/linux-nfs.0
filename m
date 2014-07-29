Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:53575 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240AbaG2V6F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 17:58:05 -0400
Received: by mail-vc0-f173.google.com with SMTP id hy10so549367vcb.4
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 14:58:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53D806C1.9030206@RedHat.com>
References: <53D7EA62.3070204@RedHat.com>
	<CAHQdGtQ2DU4GnMXy=n9JQzUhGkEC=+UEM8NVm=MviBt0+RJzBA@mail.gmail.com>
	<53D806C1.9030206@RedHat.com>
Date: Tue, 29 Jul 2014 17:58:03 -0400
Message-ID: <CAHQdGtRkbjKXvzBSQvEyrnOvmiWSrwHMe+9eiEvvDz5Pm6WGNA@mail.gmail.com>
Subject: Re: nfs4_state_manager() vs. nfs_server_remove_lists()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2014 at 4:40 PM, Steve Dickson <SteveD@redhat.com> wrote:
> On 29/07/14 15:52, Trond Myklebust wrote:
>> Let's just move up the test for "pos->rpc_ops != new->rpc_ops",
>> "pos->cl_minorversion != new->cl_minorversion" and "pos->cl_proto !=
>> new->cl_proto" so that they all happen before we try to test the value
>> of cl_cons_state.
>> As far as I can tell, all those values are guaranteed to be set as
>> part of the struct nfs_client allocators, before we ever put the
>> result on the cl_share_link list.
>
> The check for
>    if (pos->cl_cons_state > NFS_CS_READY)
>
> then right after that check is:
>
>    if (pos->cl_cons_state != NFS_CS_READY)
>          continue;
>
> confuses me... Is the second check even needed?
>
> steved.

Yes. The result of the lease_recovery could be that the nfs_client is
left in a state of error if, say, we get a NFS4ERR_CLID_INUSE beastie.

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
