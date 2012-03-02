Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030572Ab2CBUk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 15:40:57 -0500
Message-ID: <4F51305A.7030101@RedHat.com>
Date: Fri, 02 Mar 2012 15:40:58 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFS: Consolidate the parsing of the '-ov4.x' and
 '-overs=4.x' mount options
References: <1330715231-20650-1-git-send-email-Trond.Myklebust@netapp.com>  <1330715231-20650-2-git-send-email-Trond.Myklebust@netapp.com>  <1330715231-20650-3-git-send-email-Trond.Myklebust@netapp.com> <1330715866.12731.4.camel@lade.trondhjem.org>
In-Reply-To: <1330715866.12731.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/02/2012 02:17 PM, Myklebust, Trond wrote:
> Steve,
> 
> When testing this patch, I noticed that the 'mount' program seems to be
> adding a 'vers=4' to my mount options.
> 
> IOW: when I tested the following mount command:
> 
>         mount -t nfs -ov4.1 foo:/bar /mnt
> 
> the kernel ended up parsing
> 
>    'v4.1,vers=4,addr=xxx.xxx.xxx.xxx, clientaddr=yyy.yyy.yyy.yyy'
> 
> which caused a bug in my original patches (where I had 'vers=4'
> automatically set minorversion=0).
> 
> Any idea why we're adding that extra vers=4?
Clearly... just to annoy you! 8-) it is Friday!! ;-)

Well when a (known) version is not specified, the
"vers=4" string is appended on the options line. I'm thinking
the reason as twofold. One so its clean communicate to the kernel 
this is a v4 mount and two, so "vers=4" shows up in /proc/mounts.

steved.

> 
> Cheers
>   Trond
> 
> On Fri, 2012-03-02 at 14:07 -0500, Trond Myklebust wrote:
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> ---
>>  fs/nfs/super.c |   31 +++----------------------------
>>  1 files changed, 3 insertions(+), 28 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 7f0c93f..f4ccdae 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -80,7 +80,6 @@ enum {
>>  	Opt_cto, Opt_nocto,
>>  	Opt_ac, Opt_noac,
>>  	Opt_lock, Opt_nolock,
>> -	Opt_v2, Opt_v3, Opt_v4, Opt_v4_0, Opt_v4_1,
>>  	Opt_udp, Opt_tcp, Opt_rdma,
>>  	Opt_acl, Opt_noacl,
>>  	Opt_rdirplus, Opt_nordirplus,
>> @@ -133,11 +132,6 @@ static const match_table_t nfs_mount_option_tokens = {
>>  	{ Opt_noac, "noac" },
>>  	{ Opt_lock, "lock" },
>>  	{ Opt_nolock, "nolock" },
>> -	{ Opt_v2, "v2" },
>> -	{ Opt_v3, "v3" },
>> -	{ Opt_v4, "v4" },
>> -	{ Opt_v4_0, "v4.0" },
>> -	{ Opt_v4_1, "v4.1" },
>>  	{ Opt_udp, "udp" },
>>  	{ Opt_tcp, "tcp" },
>>  	{ Opt_rdma, "rdma" },
>> @@ -183,6 +177,9 @@ static const match_table_t nfs_mount_option_tokens = {
>>  	{ Opt_fscache_uniq, "fsc=%s" },
>>  	{ Opt_local_lock, "local_lock=%s" },
>>  
>> +	/* The following needs to be listed after all other options */
>> +	{ Opt_nfsvers, "v%s" },
>> +
>>  	{ Opt_err, NULL }
>>  };
>>  
>> @@ -1228,28 +1225,6 @@ static int nfs_parse_mount_options(char *raw,
>>  			mnt->flags |= (NFS_MOUNT_LOCAL_FLOCK |
>>  				       NFS_MOUNT_LOCAL_FCNTL);
>>  			break;
>> -		case Opt_v2:
>> -			mnt->flags &= ~NFS_MOUNT_VER3;
>> -			mnt->version = 2;
>> -			break;
>> -		case Opt_v3:
>> -			mnt->flags |= NFS_MOUNT_VER3;
>> -			mnt->version = 3;
>> -			break;
>> -		case Opt_v4:
>> -			mnt->flags &= ~NFS_MOUNT_VER3;
>> -			mnt->version = 4;
>> -			break;
>> -		case Opt_v4_0:
>> -			mnt->flags &= ~NFS_MOUNT_VER3;
>> -			mnt->version = 4;
>> -			mnt->minorversion = 0;
>> -			break;
>> -		case Opt_v4_1:
>> -			mnt->flags &= ~NFS_MOUNT_VER3;
>> -			mnt->version = 4;
>> -			mnt->minorversion = 1;
>> -			break;
>>  		case Opt_udp:
>>  			mnt->flags &= ~NFS_MOUNT_TCP;
>>  			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
> 
