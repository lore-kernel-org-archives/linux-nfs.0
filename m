From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4 referrals and migration
Date: Fri, 21 Aug 2009 16:57:02 -0400
Message-ID: <082C1E48-797A-40FD-8DE7-24C977043853@oracle.com>
References: <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com> <1250725916.12555.1.camel@heimdal.trondhjem.org> <20090821204706.GB23529@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:36261 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932672AbZHUU5L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 16:57:11 -0400
In-Reply-To: <20090821204706.GB23529@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 21, 2009, at 4:47 PM, J. Bruce Fields wrote:
> On Wed, Aug 19, 2009 at 07:51:56PM -0400, Trond Myklebust wrote:
>> On Wed, 2009-08-19 at 19:38 -0400, Trond Myklebust wrote:
>>> The NFSv4 and NFSv4.1 protocols both allow for the redirection of  
>>> a client
>>> from one server to another in order to support filesystem  
>>> migration and
>>> replication. For full protocol support, we need to add the ability  
>>> to
>>> convert a DNS host name into an IP address that we can feed to the  
>>> RPC
>>> client.
>>>
>>> We'll reuse the sunrpc cache, now that it has been converted to  
>>> work with
>>> rpc_pipefs.
>>
>> Should I merge this too?
>
> It's cute.  If it's expected that more people may want to write
> nfs_cache_getent scripts, maybe it would be useful to them.  But then,
> it's not that hard for them just to call the script by hand.
>
> I guess I probably wouldn't....

I like the idea of including test code, but this looks like it would  
almost never be run.  If the tests were run automatically somehow, it  
might be worth adding.

>
> --b.
>
>>
>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Subject: NFS: Testcase for the DNS resolver
>>
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> ---
>>
>> fs/nfs/Kconfig           |   11 ++++++++++
>> fs/nfs/Makefile          |    4 +++
>> fs/nfs/cache_testcases.c |   53 ++++++++++++++++++++++++++++++++++++ 
>> ++++++++++
>> fs/nfs/dns_resolve.c     |    1 +
>> 4 files changed, 69 insertions(+), 0 deletions(-)
>> create mode 100644 fs/nfs/cache_testcases.c
>>
>>
>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>> index 2a77bc2..13fc471 100644
>> --- a/fs/nfs/Kconfig
>> +++ b/fs/nfs/Kconfig
>> @@ -101,3 +101,14 @@ config NFS_FSCACHE
>> 	help
>> 	  Say Y here if you want NFS data to be cached locally on disc  
>> through
>> 	  the general filesystem cache manager
>> +
>> +config NFS_CACHETEST
>> +	tristate "Test the NFS client DNS cache upcalls"
>> +	depends on NFS_FS
>> +	default N
>> +	help
>> +	  Choose M if you want to build a module that can be used to test
>> +	  the NFS client DNS cache upcall mechanism.
>> +
>> +	  Most people will want to say N
>> +
>> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
>> index da7fda6..4fe5ac2 100644
>> --- a/fs/nfs/Makefile
>> +++ b/fs/nfs/Makefile
>> @@ -17,3 +17,7 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o  
>> nfs4state.o nfs4renewd.o \
>> 			   nfs4namespace.o
>> nfs-$(CONFIG_SYSCTL) += sysctl.o
>> nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
>> +
>> +obj-$(CONFIG_NFS_CACHETEST) += nfs_cachetest.o
>> +nfs_cachetest-objs := cache_testcases.o
>> +
>> diff --git a/fs/nfs/cache_testcases.c b/fs/nfs/cache_testcases.c
>> new file mode 100644
>> index 0000000..2d8810a
>> --- /dev/null
>> +++ b/fs/nfs/cache_testcases.c
>> @@ -0,0 +1,53 @@
>> +/*
>> + * linux/fs/nfs/cache_testcases.c
>> + *
>> + * Testcases for the NFS client cache upcalls
>> + *
>> + * Copyright (c) 2009 Trond Myklebust <Trond.Myklebust@netapp.com>
>> + */
>> +
>> +#include <linux/module.h>
>> +#include <linux/moduleparam.h>
>> +#include <linux/sunrpc/clnt.h>
>> +
>> +#include "dns_resolve.h"
>> +
>> +static char hostname[NFS_DNS_HOSTNAME_MAXLEN] = "";
>> +module_param_string(hostname, hostname, sizeof(hostname), 0600);
>> +MODULE_PARM_DESC(hostname, "DNS hostname to look up");
>> +
>> +static int nfs_lookup_hostname(char *name)
>> +{
>> +	struct sockaddr_storage sa;
>> +	ssize_t salen;
>> +
>> +	if (!name || *name == '\0')
>> +		goto out;
>> +	salen = nfs_dns_resolve_name(name, strlen(name),
>> +			(struct sockaddr *)&sa, sizeof(sa));
>> +	if (salen > 0) {
>> +		char buf[INET6_ADDRSTRLEN+IPV6_SCOPE_ID_LEN+1];
>> +
>> +		rpc_ntop((struct sockaddr *)&sa, buf, sizeof(buf));
>> +		printk(KERN_NOTICE "%15s ", buf);
>> +	} else
>> +		printk(KERN_NOTICE "%15zd ", salen);
>> +	printk("%15s\n", name);
>> +out:
>> +	return 0;
>> +}
>> +
>> +static int nfs_dnstest_init(void)
>> +{
>> +	return nfs_lookup_hostname(hostname);
>> +}
>> +
>> +static void nfs_dnstest_exit(void)
>> +{
>> +}
>> +
>> +MODULE_AUTHOR("Trond Myklebust <Trond.Myklebust@netapp.com>");
>> +MODULE_LICENSE("GPL");
>> +
>> +module_init(nfs_dnstest_init)
>> +module_exit(nfs_dnstest_exit)
>> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
>> index f4d54ba..572d453 100644
>> --- a/fs/nfs/dns_resolve.c
>> +++ b/fs/nfs/dns_resolve.c
>> @@ -322,6 +322,7 @@ ssize_t nfs_dns_resolve_name(char *name, size_t  
>> namelen,
>> 		ret = -ESRCH;
>> 	return ret;
>> }
>> +EXPORT_SYMBOL_GPL(nfs_dns_resolve_name);
>>
>> int nfs_dns_resolver_init(void)
>> {
>>
>> -- 
>> Trond Myklebust
>> Linux NFS client maintainer
>>
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



