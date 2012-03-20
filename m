Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:48927 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953Ab2CTQq6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2012 12:46:58 -0400
Received: by vcqp1 with SMTP id p1so218350vcq.19
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2012 09:46:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1332261586.2963.51.camel@lade.trondhjem.org>
References: <1332260746-8351-1-git-send-email-iisaman@netapp.com>
	<1332260746-8351-2-git-send-email-iisaman@netapp.com>
	<1332261586.2963.51.camel@lade.trondhjem.org>
Date: Tue, 20 Mar 2012 12:46:57 -0400
Message-ID: <CADnza44uph5m4G29YCz-1N=1ojgQ8fPRtvWptqx6sVm0PBgB2w@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFS: ncommit count is being double decremented
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 20, 2012 at 12:39 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Tue, 2012-03-20 at 12:25 -0400, Fred Isaman wrote:
>> The decrement is handled by each call to nfs_request_remove_commit_list,
>> no need to do it again in nfs_scan_commit.
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>>  fs/nfs/write.c |    5 +----
>>  1 files changed, 1 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index 0de19f4..e39ddfd 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -595,12 +595,9 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst)
>>       spin_lock(&inode->i_lock);
>>       if (nfsi->ncommit > 0) {
>>               const int max = INT_MAX;
>> -             int pnfs_ret;
>>
>>               ret = nfs_scan_commit_list(&nfsi->commit_list, dst, max);
>> -             pnfs_ret = pnfs_scan_commit_lists(inode, max - ret);
>> -             ret += pnfs_ret;
>
> No! If we've scanned pNFS pages to commit, then we need to report this
> to nfs_commit_inode. Otherwise it will skip sending the RPC calls.
>

Oops, I got carried away.  I'll resend.

Fred

>> -             nfsi->ncommit -= ret;
>                ^^^^^^^^^^^^^^^^^^^^^^
> I agree with this... I forgot to remove it.
>
>> +             pnfs_scan_commit_lists(inode, max - ret);
>>       }
>>       spin_unlock(&inode->i_lock);
>>       return ret;
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
