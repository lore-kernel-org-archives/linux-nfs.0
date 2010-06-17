From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 06/19] SQUASHME: pnfs-submit: merge pnfs4_read_done into
 	nfs4_read_done - part 3
Date: Thu, 17 Jun 2010 11:26:16 -0400
Message-ID: <4C1A3E98.5070004@panasas.com>
References: <4C1A3570.5030709@panasas.com>	<1276786155-12371-1-git-send-email-bhalevy@panasas.com> <AANLkTikvo8qP_B23suRB-lKNCcCQv4W6Vw8kBmPC_6SX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:33547 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753963Ab0FQP0K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 11:26:10 -0400
In-Reply-To: <AANLkTikvo8qP_B23suRB-lKNCcCQv4W6Vw8kBmPC_6SX-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 17, 2010, 11:15 -0400, Fred Isaman <iisaman@umich.edu> wrote:
> On Thu, Jun 17, 2010 at 10:49 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> Do not renew the data server lease.
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4proc.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 77b7182..e8b0f33 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -3164,7 +3164,7 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
>>        }
>>
>>        nfs_invalidate_atime(data->inode);
>> -       if (task->tk_status > 0)
>> +       if (task->tk_status > 0 && client == server->nfs_client)
> 
> Will this test work if there is a dual role MDS/DS?
> 

The filehandle determines the "DS personality"
as per 13.6. Operations Sent to NFSv4.1 Data Servers
so the dual role server should act no different than any
other DS with this respect.

Benny

> Fred
> 
>>                renew_lease(server, data->timestamp);
>>        return 0;
>>  }
>> --
>> 1.6.4.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
