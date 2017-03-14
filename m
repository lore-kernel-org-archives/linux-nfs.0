Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42378 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750977AbdCNWZ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 18:25:57 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: git "make test" fails in t9200-git-cvsexportcommit.sh
Date: Tue, 14 Mar 2017 18:25:55 -0400
Message-ID: <5E4A3C66-5123-446D-9556-0E59E546283D@redhat.com>
In-Reply-To: <12A85CA0-A715-4379-81D5-58A9CB001266@oracle.com>
References: <12A85CA0-A715-4379-81D5-58A9CB001266@oracle.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 14 Mar 2017, at 11:07, Chuck Lever wrote:

> Hi Ben!
>
> After addressing some IB stack issues that arose in v4.11-rc1,
> I was finally able to run my standard suite of NFS tests with
> v4.11-rc2. I found that part of the git regression suite fails
> with this kernel.
> ...
> A wire capture shows that some GETATTR operations receive
> an NFS3ERR_STALE response from the server. I looked at one
> of these, and it's against a renamed file "index.lock".
>
> So I reverted:
>
> commit 920b4530fb80430ff30ef83efe21ba1fa5623731
> Author:     Benjamin Coddington <bcodding@redhat.com>
> Date: Wed Feb 1 00:00:07 2017 -0500
>
> NFS: nfs_rename() handle -ERESTARTSYS dentry left behind
>
> And t9200 now passes:

Yep, something seems to be wrong with calling
nfs_mark_for_revalidate(old_inode) in rpc_call_done instead of after
rpc_release.  Thanks for catching this.  I'm out of time today, and will
look at this in the morning.

Ben
