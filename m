Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36754 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbaA3QzS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 11:55:18 -0500
Received: by mail-ig0-f182.google.com with SMTP id uy17so7481375igb.3
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jan 2014 08:55:17 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 1/3] NFSv4: Fix a slot leak in nfs40_sequence_done
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <5AE747F1-D056-47AB-8416-C37071A35D5B@oracle.com>
Date: Thu, 30 Jan 2014 11:55:13 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2DA614A7-AE5A-47DA-AAB3-79D480540B5E@primarydata.com>
References: <1391016982-10562-1-git-send-email-trond.myklebust@primarydata.com> <5AE747F1-D056-47AB-8416-C37071A35D5B@oracle.com>
To: Lever Charles Edward <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 30, 2014, at 11:49, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jan 29, 2014, at 9:36 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> The check for whether or not we sent an RPC call in nfs40_sequence_done
>> is insufficient to decide whether or not we are holding a session slot,
>> and thus should not be used to decide when to free that slot.
>> 
>> This patch replaces the RPC_WAS_SENT() test with the correct test for
>> whether or not slot == NULL.
>> 
>> Cc: Chuck Lever <chuck.lever@oracle.com>
>> Cc: stable@vger.kernel.org # 3.12+
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> fs/nfs/nfs4proc.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index ae00c3ed733f..493e9cce1f11 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -539,7 +539,7 @@ static int nfs40_sequence_done(struct rpc_task *task,
>> 	struct nfs4_slot *slot = res->sr_slot;
>> 	struct nfs4_slot_table *tbl;
>> 
>> -	if (!RPC_WAS_SENT(task))
>> +	if (slot == NULL)
>> 		goto out;
> 
> When CONFIG_NFS_V4_1 is enabled, nfs4_sequence_done() already does the slot == NULL test, though the other nfs40_sequence_done() call sites do not.  This patch should clean that up?

Unfortunately we can’t touch nfs4_sequence_done: it wants to test for whether or not a NFSv4.1 session exists, which requires it to look at slot->table->session. :-(
--
Trond Myklebust
Linux NFS client maintainer

