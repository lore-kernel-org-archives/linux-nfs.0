Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27548 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757195Ab3BVQi1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 11:38:27 -0500
Message-ID: <51279F01.2020000@RedHat.com>
Date: Fri, 22 Feb 2013 11:38:25 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4.2: Added NFS v4.2 support to the NFS client
References: <1361484911-17537-1-git-send-email-steved@redhat.com> <1361484911-17537-2-git-send-email-steved@redhat.com> <20130222151339.GA10157@pad.fieldses.org>
In-Reply-To: <20130222151339.GA10157@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 22/02/13 10:13, J. Bruce Fields wrote:
> On Thu, Feb 21, 2013 at 05:15:10PM -0500, Steve Dickson wrote:
>> This enable NFSv4.2 support. To enable this code the
>> CONFIG_NFS_V4_2 Kconfig define needs to be set and
>> the -o v4.2 mount option need to be used.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  fs/nfs/Kconfig       | 11 ++++++++++-
>>  fs/nfs/callback.c    |  3 +++
>>  fs/nfs/nfs4client.c  |  5 +++++
>>  fs/nfs/nfs4proc.c    |  3 +++
>>  fs/nfs/super.c       |  7 ++++++-
>>  include/linux/nfs4.h |  4 ++++
>>  6 files changed, 31 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>> index 3861a1f..247db6d 100644
>> --- a/fs/nfs/Kconfig
>> +++ b/fs/nfs/Kconfig
>> @@ -104,6 +104,15 @@ config NFS_V4_1
>>  
>>  	  If unsure, say N.
>>  
>> +config NFS_V4_2
>> +	bool "NFS client support for NFSv4.2"
>> +	depends on NFS_V4_1
>> +	help
>> +	  This option enables support for minor version 1 of the NFSv4 protocol
>> +	  (RFC 5661) in the kernel's NFS client.
>> +
>> +	  If unsure, say N.
>> +
>>  config PNFS_FILE_LAYOUT
>>  	tristate
>>  	depends on NFS_V4_1
>> @@ -133,7 +142,7 @@ config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
>>  
>>  config NFS_V4_SECURITY_LABEL
>>  	bool "Provide Security Label support for NFSv4 client"
>> -	depends on NFS_V4 && SECURITY
>> +	depends on NFS_V4_2 && SECURITY
>>  	help
>>  
>>  	Say Y here if you want enable fine-grained security label attribute
>> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
>> index 5088b57..4058ec8 100644
>> --- a/fs/nfs/callback.c
>> +++ b/fs/nfs/callback.c
>> @@ -281,6 +281,9 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv, struct n
>>  		case 1:
>>  			ret = nfs41_callback_up_net(serv, net);
>>  			break;
>> +		case 2:
>> +			ret = nfs41_callback_up_net(serv, net);
>> +			break;
>>  		default:
>>  			printk(KERN_ERR "NFS: unknown callback version: %d\n",
>>  					minorversion);
>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>> index 2e9779b..2987fd6 100644
>> --- a/fs/nfs/nfs4client.c
>> +++ b/fs/nfs/nfs4client.c
>> @@ -66,6 +66,11 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
>>  	if (err)
>>  		goto error;
>>  
>> +	if (cl_init->minorversion > NFS4_MAX_MINOR_VERSION) {
>> +		err = -EINVAL;
>> +		goto error;
>> +	}
> 
> Why wasn't this check needed before?
It was not needed because the checks in nfs_parse_version_string caught
the mismatch minor version... but since minor version 2 is no longer
a mismatch and those checks in nfs_parse_version_string are not
covered by an ifdef this check is now needed... 

> 
>> +		
>>  	spin_lock_init(&clp->cl_lock);
>>  	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
>>  	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 40c1d1f..08fc8e2 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -7136,6 +7136,9 @@ const struct nfs4_minor_version_ops *nfs_v4_minor_ops[] = {
>>  #if defined(CONFIG_NFS_V4_1)
>>  	[1] = &nfs_v4_1_minor_ops,
>>  #endif
>> +#if defined(CONFIG_NFS_V4_2)
>> +	[2] = &nfs_v4_1_minor_ops,
> 
> But then nfs_v4_minor_ops[2]->minor_version = 1.
> 
> I think you want to create another structure--just define an
> nfs_v4_2_minor_ops field that's the same as nfs_v4_1_minor_ops except
> for the minor_version field.
That's how I started out: 

#if defined(CONFIG_NFS_V4_2)
static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
    .minor_version = 2,
    .call_sync = nfs4_call_sync_sequence,
    .match_stateid = nfs41_match_stateid,
    .find_root_sec = nfs41_find_root_sec,
    .reboot_recovery_ops = &nfs41_reboot_recovery_ops,
    .nograce_recovery_ops = &nfs41_nograce_recovery_ops,
    .state_renewal_ops = &nfs41_state_renewal_ops,
};
#endif

but it just seem like such a big waste of space... I could switch back... 

Trond??

steved.

> 
> --b.
> 
>> +#endif
>>  };
>>  
>>  const struct inode_operations nfs4_dir_inode_operations = {
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 4e78f93..d35582c 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -269,7 +269,7 @@ static match_table_t nfs_local_lock_tokens = {
>>  
>>  enum {
>>  	Opt_vers_2, Opt_vers_3, Opt_vers_4, Opt_vers_4_0,
>> -	Opt_vers_4_1,
>> +	Opt_vers_4_1, Opt_vers_4_2,
>>  
>>  	Opt_vers_err
>>  };
>> @@ -280,6 +280,7 @@ static match_table_t nfs_vers_tokens = {
>>  	{ Opt_vers_4, "4" },
>>  	{ Opt_vers_4_0, "4.0" },
>>  	{ Opt_vers_4_1, "4.1" },
>> +	{ Opt_vers_4_2, "4.2" },
>>  
>>  	{ Opt_vers_err, NULL }
>>  };
>> @@ -1143,6 +1144,10 @@ static int nfs_parse_version_string(char *string,
>>  		mnt->version = 4;
>>  		mnt->minorversion = 1;
>>  		break;
>> +	case Opt_vers_4_2:
>> +		mnt->version = 4;
>> +		mnt->minorversion = 2;
>> +		break;
>>  	default:
>>  		return 0;
>>  	}
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index aab8bd8..e9c040a 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -394,11 +394,15 @@ enum lock_type4 {
>>  #define NFS4_VERSION 4
>>  #define NFS4_MINOR_VERSION 0
>>  
>> +#if defined(CONFIG_NFS_V4_2)
>> +#define NFS4_MAX_MINOR_VERSION 2
>> +#else
>>  #if defined(CONFIG_NFS_V4_1)
>>  #define NFS4_MAX_MINOR_VERSION 1
>>  #else
>>  #define NFS4_MAX_MINOR_VERSION 0
>>  #endif /* CONFIG_NFS_V4_1 */
>> +#endif /* CONFIG_NFS_V4_2 */
>>  
>>  #define NFS4_DEBUG 1
>>  
>> -- 
>> 1.8.1.2
>>
