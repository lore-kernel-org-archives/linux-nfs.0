From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 1/1] Don't check exchange flags unless using v4.1
Date: Wed, 6 Oct 2010 12:10:41 -0400
Message-ID: <79707019-52A4-42C4-A73D-A1DF9322D497@netapp.com>
References: <1286380572-4558-1-git-send-email-iisaman@netapp.com> <4CAC9D83.2090406@panasas.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47692 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759285Ab0JFQKr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Oct 2010 12:10:47 -0400
In-Reply-To: <4CAC9D83.2090406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 6, 2010, at 12:02 PM, Benny Halevy wrote:

> On 2010-10-06 11:56, Fred Isaman wrote:
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>> fs/nfs/pnfs.c |    4 +++-
>> 1 files changed, 3 insertions(+), 1 deletions(-)
>> 
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 7013916..64baf20 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -141,7 +141,9 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
>> 
>> 	if (id == 0)
>> 		goto out_no_driver;
>> -	if (!(server->nfs_client->cl_exchange_flags &
>> +	if ((server->nfs_client->rpc_ops->version == 4) &&
>> +	    (server->nfs_client->cl_minorversion == 1) &&
>> +	    !(server->nfs_client->cl_exchange_flags &
>> 		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
>> 		printk(KERN_ERR "%s: id %u cl_exchange_flags 0x%x\n", __func__,
>> 		       id, server->nfs_client->cl_exchange_flags);
> 
> Actually, it'd better to disable just the warning printout in this case,
> not the entire block.
> 
> Benny

Bah.  I sent out the wrong version.  See next email.

Fred

