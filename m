From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 09/19] SQUASHME: pnfs-submit: merge pnfs4_write_done into
 	nfs4_write_done - part 2
Date: Thu, 17 Jun 2010 11:27:25 -0400
Message-ID: <4C1A3EDD.2040509@panasas.com>
References: <4C1A3570.5030709@panasas.com>	<1276786187-12514-1-git-send-email-bhalevy@panasas.com> <AANLkTimHng4urMH5CTn68aZJ_NKIasCH6VJOTCI-2zRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37015 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932948Ab0FQP1T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 11:27:19 -0400
In-Reply-To: <AANLkTimHng4urMH5CTn68aZJ_NKIasCH6VJOTCI-2zRQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 17, 2010, 11:19 -0400, Fred Isaman <iisaman@umich.edu> wrote:
> On Thu, Jun 17, 2010 at 10:49 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> PNFS_NO_RPC.
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4proc.c |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 5948de5..fd2b588 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -3279,6 +3279,9 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
>>                        data->pdata.orig_count);
>>                data->args.count = data->pdata.orig_count;
>>        }
>> +
>> +       if (data->pdata.pnfsflags & PNFS_NO_RPC)
>> +               return 0;
>>  #endif /* CONFIG_NFS_V4_1 */
> 
> Again, this is is a post-submit patch

Right.  sorry for badly naming it.
It will applied against the post-submit pnfs branch.

Benny

> 
> Fred
> 
>>
>>        nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
>> --
>> 1.6.4.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
