Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44064 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642Ab1BEQqy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Feb 2011 11:46:54 -0500
Received: by iyj8 with SMTP id 8so754246iyj.19
        for <linux-nfs@vger.kernel.org>; Sat, 05 Feb 2011 08:46:53 -0800 (PST)
In-Reply-To: <AANLkTi=GcLNguekTEnapQ-tzJ6ojWddhwM=VyMoE=enr@mail.gmail.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
	<1296855242-2592-2-git-send-email-andros@netapp.com>
	<1296855242-2592-3-git-send-email-andros@netapp.com>
	<1296855242-2592-4-git-send-email-andros@netapp.com>
	<1296855242-2592-5-git-send-email-andros@netapp.com>
	<1296855242-2592-6-git-send-email-andros@netapp.com>
	<1296855242-2592-7-git-send-email-andros@netapp.com>
	<1296855242-2592-8-git-send-email-andros@netapp.com>
	<1296855242-2592-9-git-send-email-andros@netapp.com>
	<1296855242-2592-10-git-send-email-andros@netapp.com>
	<1296855242-2592-11-git-send-email-andros@netapp.com>
	<1296855242-2592-12-git-send-email-andros@netapp.com>
	<1296855242-2592-13-git-send-email-andros@netapp.com>
	<1296855242-2592-14-git-send-email-andros@netapp.com>
	<1296855242-2592-15-git-send-email-andros@netapp.com>
	<1296855242-2592-16-git-send-email-andros@netapp.com>
	<1296855242-2592-17-git-send-email-andros@netapp.com>
	<1296855242-2592-18-git-send-email-andros@netapp.com>
	<1296855242-2592-19-git-send-email-andros@netapp.com>
	<1296855242-2592-20-git-send-email-andros@netapp.com>
	<1296855242-2592-21-git-send-email-andros@netapp.com>
	<1296855242-2592-22-git-send-email-andros@netapp.com>
	<1296855242-2592-23-git-send-email-andros@netapp.com>
	<1296855242-2592-24-git-send-email-andros@netapp.com>
	<AANLkTi=GcLNguekTEnapQ-tzJ6ojWddhwM=VyMoE=enr@mail.gmail.com>
Date: Sat, 5 Feb 2011 11:46:53 -0500
Message-ID: <AANLkTikGXQrhLXi9-irp92io0DzHB+H3adD+1CdUX7W_@mail.gmail.com>
Subject: Re: [PATCH 23/40] SQUASHME pnfs-submit wave3 new function for ds
 expired lease
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Feb 4, 2011 at 4:51 PM, Fred Isaman <iisaman@netapp.com> wrote:
> On Fri, Feb 4, 2011 at 4:33 PM,  <andros@netapp.com> wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> áfs/nfs/nfs4proc.c | á 11 ++++++++---
>> á1 files changed, 8 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 9c50be7..fb22cbf 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1574,7 +1574,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
>> á á á áreturn 0;
>> á}
>>
>> -int nfs4_recover_expired_lease(struct nfs_client *clp)
>> +static int nfs4_client_recover_expired_lease(struct nfs_client *clp)
>> á{
>> á á á áunsigned int loop;
>> á á á áint ret;
>> @@ -1593,6 +1593,11 @@ int nfs4_recover_expired_lease(struct nfs_client *clp)
>> á}
>> áEXPORT_SYMBOL(nfs4_recover_expired_lease);
>>
>> +static int nfs4_recover_expired_lease(struct nfs_server *server)
>> +{
>> + á á á return nfs4_client_recover_expired_lease(server->nfs_client);
>> +}
>> +
>
> Why are we doing this extra indirection?

As Trond pointed out, it is a lot less intrusive to the existing code.

-->Andy

>
> Fred
>
>> á/*
>> á* OPEN_EXPIRED:
>> á* á á reclaim state on the server after a network partition.
>> @@ -1680,7 +1685,7 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, in
>> á á á á á á á ádprintk("nfs4_do_open: nfs4_get_state_owner failed!\n");
>> á á á á á á á ágoto out_err;
>> á á á á}
>> - á á á status = nfs4_recover_expired_lease(server->nfs_client);
>> + á á á status = nfs4_recover_expired_lease(server);
>> á á á áif (status != 0)
>> á á á á á á á ágoto err_put_state_owner;
>> á á á áif (path->dentry->d_inode != NULL)
>> @@ -5075,7 +5080,7 @@ int nfs4_init_session(struct nfs_server *server)
>> á á á ásession->fc_attrs.max_rqst_sz = wsize + nfs41_maxwrite_overhead;
>> á á á ásession->fc_attrs.max_resp_sz = rsize + nfs41_maxread_overhead;
>>
>> - á á á ret = nfs4_recover_expired_lease(server->nfs_client);
>> + á á á ret = nfs4_recover_expired_lease(server);
>> á á á áif (!ret)
>> á á á á á á á áret = nfs4_check_client_ready(clp);
>> á á á áreturn ret;
>> --
>> 1.6.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at áhttp://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
