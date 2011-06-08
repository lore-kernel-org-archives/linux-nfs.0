Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:43088 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429Ab1FHHGo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 03:06:44 -0400
Received: by vws1 with SMTP id 1so141539vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jun 2011 00:06:43 -0700 (PDT)
In-Reply-To: <4DEED8FC.4000000@panasas.com>
References: <cover.1307464381.git.rees@umich.edu>
	<8d4549ecda23f5ada0c88677c9505cba2830dad5.1307464382.git.rees@umich.edu>
	<4DEED8FC.4000000@panasas.com>
Date: Wed, 8 Jun 2011 15:06:43 +0800
Message-ID: <BANLkTimeDdSUZusf8RgpncSyW5K21UyhXw@mail.gmail.com>
Subject: Re: [PATCH 88/88] NFS41: do not update isize if inode needs layoutcommit
From: Peng Tao <bergwolf@gmail.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 6/8/11, Benny Halevy <bhalevy@panasas.com> wrote:
> Better send generic patches separately.
> This patch needs to go upstream and to stable 2.6.39
It has been sent separately before. please see
http://www.spinics.net/list/linux-nfs/msg21586.html

>
> Benny
>
> On 2011-06-07 13:36, Jim Rees wrote:
>> From: Peng Tao <bergwolf@gmail.com>
>>
>> Layout commit is supposed to set server file size similiar to nfs pages.
>> We should not update client file size for the same reason.
>> Otherwise we will lose what we have at hand.
>>
>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>> Signed-off-by: Jim Rees <rees@umich.edu>
>> ---
>>  fs/nfs/inode.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 144f2a3..3f1eb81 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -1294,7 +1294,8 @@ static int nfs_update_inode(struct inode *inode,
>> struct nfs_fattr *fattr)
>>  		if (new_isize != cur_isize) {
>>  			/* Do we perhaps have any outstanding writes, or has
>>  			 * the file grown beyond our last write? */
>> -			if (nfsi->npages == 0 || new_isize > cur_isize) {
>> +			if ((nfsi->npages == 0 && !test_bit(NFS_INO_LAYOUTCOMMIT,
>> &nfsi->flags)) ||
>> +			     new_isize > cur_isize) {
>>  				i_size_write(inode, new_isize);
>>  				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
>>  			}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Thanks,
-Bergwolf
