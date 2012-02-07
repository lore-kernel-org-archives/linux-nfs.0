Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:39126 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818Ab2BGSWN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2012 13:22:13 -0500
Message-ID: <4F316BC4.4030504@panasas.com>
Date: Tue, 7 Feb 2012 20:21:56 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Weston Andros Adamson <dros@netapp.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: add mount options 'v4.0' and 'v4.1'
References: <1328633351-1741-1-git-send-email-dros@netapp.com> <A5356E85-1E22-4C4C-A30C-58A912AE3C9F@oracle.com>
In-Reply-To: <A5356E85-1E22-4C4C-A30C-58A912AE3C9F@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/07/2012 06:59 PM, Chuck Lever wrote:
> Hi-
> 
> On Feb 7, 2012, at 11:49 AM, Weston Andros Adamson wrote:
>> 
>> NFS: add mount options 'v4.0' and 'v4.1'

Good god thanks, that'll be nice.

Why did we have to suffer for 5 years without it? ;-)

>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> Updated to add 'v4.0' as trond requested.
>>
>> We'll talk about this change at connectathon.
>>
>> This 'just works' with mount.nfs(8) -- v.* options are passed to the 
>> kernel with no modifications needed.
> 
> I'm more concerned about version auto-negotation.
> 

If we are at it can we also have a "this-version-only" option which
disables "auto-negotation"

I know that's an hard one

OK we'll talk at CON12.

Thanks Andy
Boaz

>>
>> fs/nfs/super.c |   14 +++++++++++++-
>> 1 files changed, 13 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index b88e023..d89cee2 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -80,7 +80,7 @@ enum {
>> 	Opt_cto, Opt_nocto,
>> 	Opt_ac, Opt_noac,
>> 	Opt_lock, Opt_nolock,
>> -	Opt_v2, Opt_v3, Opt_v4,
>> +	Opt_v2, Opt_v3, Opt_v4, Opt_v4_0, Opt_v4_1,
>> 	Opt_udp, Opt_tcp, Opt_rdma,
>> 	Opt_acl, Opt_noacl,
>> 	Opt_rdirplus, Opt_nordirplus,
>> @@ -136,6 +136,8 @@ static const match_table_t nfs_mount_option_tokens = {
>> 	{ Opt_v2, "v2" },
>> 	{ Opt_v3, "v3" },
>> 	{ Opt_v4, "v4" },
>> +	{ Opt_v4_0, "v4.0" },
>> +	{ Opt_v4_1, "v4.1" },
>> 	{ Opt_udp, "udp" },
>> 	{ Opt_tcp, "tcp" },
>> 	{ Opt_rdma, "rdma" },
>> @@ -1172,6 +1174,16 @@ static int nfs_parse_mount_options(char *raw,
>> 			mnt->flags &= ~NFS_MOUNT_VER3;
>> 			mnt->version = 4;
>> 			break;
>> +		case Opt_v4_0:
>> +			mnt->flags &= ~NFS_MOUNT_VER3;
>> +			mnt->version = 4;
>> +			mnt->minorversion = 0;
>> +			break;
>> +		case Opt_v4_1:
>> +			mnt->flags &= ~NFS_MOUNT_VER3;
>> +			mnt->version = 4;
>> +			mnt->minorversion = 1;
>> +			break;
>> 		case Opt_udp:
>> 			mnt->flags &= ~NFS_MOUNT_TCP;
>> 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
>> -- 
>> 1.7.4.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

