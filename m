Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:36508 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab3BEFiH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2013 00:38:07 -0500
Message-ID: <51109AAE.5000502@parallels.com>
Date: Tue, 5 Feb 2013 09:37:50 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
        <Trond.Myklebust@netapp.com>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [PATCH 2/4] SUNRPC: remove cache_detail->cache_upcall callback
References: <20130115080402.2996.74320.stgit@localhost.localdomain> <20130115080936.2996.1659.stgit@localhost.localdomain> <20130204115002.7eec67fc@tlielax.poochiereds.net>
In-Reply-To: <20130204115002.7eec67fc@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

04.02.2013 20:50, Jeff Layton пишет:
> On Tue, 15 Jan 2013 11:09:36 +0300
> Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
>
>> This callback is redundant since all that its' implementations are doing is
>> calling sunrpc_cache_pipe_upcall() with proper function address argument. This
>> function address is now stored on cache_detail structure and thus all the code
>> can be simplified.
>>
>> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>> ---
>>   fs/nfsd/export.c                  |   12 ------------
>>   fs/nfsd/nfs4idmap.c               |   14 --------------
>>   include/linux/sunrpc/cache.h      |    3 ---
>>   net/sunrpc/auth_gss/svcauth_gss.c |    7 -------
>>   net/sunrpc/cache.c                |    6 +++---
>>   net/sunrpc/svcauth_unix.c         |   12 ------------
>>   6 files changed, 3 insertions(+), 51 deletions(-)
>>
>> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
>> index 63ee3bc..6f030a5 100644
>> --- a/fs/nfsd/export.c
>> +++ b/fs/nfsd/export.c
>> @@ -67,11 +67,6 @@ static void expkey_request(struct cache_detail *cd,
>>   	(*bpp)[-1] = '\n';
>>   }
>>
>> -static int expkey_upcall(struct cache_detail *cd, struct cache_head *h)
>> -{
>> -	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
>> -}
>> -
>>   static struct svc_expkey *svc_expkey_update(struct cache_detail *cd, struct svc_expkey *new,
>>   					    struct svc_expkey *old);
>>   static struct svc_expkey *svc_expkey_lookup(struct cache_detail *cd, struct svc_expkey *);
>> @@ -245,7 +240,6 @@ static struct cache_detail svc_expkey_cache_template = {
>>   	.hash_size	= EXPKEY_HASHMAX,
>>   	.name		= "nfsd.fh",
>>   	.cache_put	= expkey_put,
>> -	.cache_upcall	= expkey_upcall,
>>   	.cache_request	= expkey_request,
>>   	.cache_parse	= expkey_parse,
>>   	.cache_show	= expkey_show,
>> @@ -338,11 +332,6 @@ static void svc_export_request(struct cache_detail *cd,
>>   	(*bpp)[-1] = '\n';
>>   }
>>
>> -static int svc_export_upcall(struct cache_detail *cd, struct cache_head *h)
>> -{
>> -	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
>> -}
>> -
>>   static struct svc_export *svc_export_update(struct svc_export *new,
>>   					    struct svc_export *old);
>>   static struct svc_export *svc_export_lookup(struct svc_export *);
>> @@ -712,7 +701,6 @@ static struct cache_detail svc_export_cache_template = {
>>   	.hash_size	= EXPORT_HASHMAX,
>>   	.name		= "nfsd.export",
>>   	.cache_put	= svc_export_put,
>> -	.cache_upcall	= svc_export_upcall,
>>   	.cache_request	= svc_export_request,
>>   	.cache_parse	= svc_export_parse,
>>   	.cache_show	= svc_export_show,
>> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
>> index 9033dfd..d9402ea 100644
>> --- a/fs/nfsd/nfs4idmap.c
>> +++ b/fs/nfsd/nfs4idmap.c
>> @@ -140,12 +140,6 @@ idtoname_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
>>   }
>>
>>   static int
>> -idtoname_upcall(struct cache_detail *cd, struct cache_head *ch)
>> -{
>> -	return sunrpc_cache_pipe_upcall(cd, ch, cd->cache_request);
>> -}
>> -
>> -static int
>>   idtoname_match(struct cache_head *ca, struct cache_head *cb)
>>   {
>>   	struct ent *a = container_of(ca, struct ent, h);
>> @@ -192,7 +186,6 @@ static struct cache_detail idtoname_cache_template = {
>>   	.hash_size	= ENT_HASHMAX,
>>   	.name		= "nfs4.idtoname",
>>   	.cache_put	= ent_put,
>> -	.cache_upcall	= idtoname_upcall,
>>   	.cache_request	= idtoname_request,
>>   	.cache_parse	= idtoname_parse,
>>   	.cache_show	= idtoname_show,
>> @@ -322,12 +315,6 @@ nametoid_request(struct cache_detail *cd, struct cache_head *ch, char **bpp,
>>   }
>>
>>   static int
>> -nametoid_upcall(struct cache_detail *cd, struct cache_head *ch)
>> -{
>> -	return sunrpc_cache_pipe_upcall(cd, ch, cd->cache_request);
>> -}
>> -
>> -static int
>>   nametoid_match(struct cache_head *ca, struct cache_head *cb)
>>   {
>>   	struct ent *a = container_of(ca, struct ent, h);
>> @@ -366,7 +353,6 @@ static struct cache_detail nametoid_cache_template = {
>>   	.hash_size	= ENT_HASHMAX,
>>   	.name		= "nfs4.nametoid",
>>   	.cache_put	= ent_put,
>> -	.cache_upcall	= nametoid_upcall,
>>   	.cache_request	= nametoid_request,
>>   	.cache_parse	= nametoid_parse,
>>   	.cache_show	= nametoid_show,
>> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
>> index 4f1c858..249e73a 100644
>> --- a/include/linux/sunrpc/cache.h
>> +++ b/include/linux/sunrpc/cache.h
>> @@ -80,9 +80,6 @@ struct cache_detail {
>>   	char			*name;
>>   	void			(*cache_put)(struct kref *);
>>
>> -	int			(*cache_upcall)(struct cache_detail *,
>> -						struct cache_head *);
>> -
>>   	void			(*cache_request)(struct cache_detail *cd,
>>   						 struct cache_head *ch,
>>   						 char **bpp, int *blen);
>> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
>> index 82437f9..1bd18af 100644
>> --- a/net/sunrpc/auth_gss/svcauth_gss.c
>> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
>> @@ -182,12 +182,6 @@ static void rsi_request(struct cache_detail *cd,
>>   	(*bpp)[-1] = '\n';
>>   }
>>
>> -static int rsi_upcall(struct cache_detail *cd, struct cache_head *h)
>> -{
>> -	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
>> -}
>> -
>> -
>>   static int rsi_parse(struct cache_detail *cd,
>>   		    char *mesg, int mlen)
>>   {
>> @@ -275,7 +269,6 @@ static struct cache_detail rsi_cache_template = {
>>   	.hash_size	= RSI_HASHMAX,
>>   	.name           = "auth.rpcsec.init",
>>   	.cache_put      = rsi_put,
>> -	.cache_upcall   = rsi_upcall,
>>   	.cache_request  = rsi_request,
>>   	.cache_parse    = rsi_parse,
>>   	.match		= rsi_match,
>> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>> index fc2f7aa..ee6b5dd 100644
>> --- a/net/sunrpc/cache.c
>> +++ b/net/sunrpc/cache.c
>> @@ -196,9 +196,9 @@ EXPORT_SYMBOL_GPL(sunrpc_cache_update);
>>
>>   static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h)
>>   {
>> -	if (!cd->cache_upcall)
>> +	if (!cd->cache_request)
>>   		return -EINVAL;
>> -	return cd->cache_upcall(cd, h);
>> +	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
>>   }
>>
>>   static inline int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
>> @@ -1605,7 +1605,7 @@ static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
>>   	if (p == NULL)
>>   		goto out_nomem;
>>
>> -	if (cd->cache_upcall || cd->cache_parse) {
>> +	if (cd->cache_request || cd->cache_parse) {
>>   		p = proc_create_data("channel", S_IFREG|S_IRUSR|S_IWUSR,
>>   				     cd->u.procfs.proc_ent,
>>   				     &cache_file_operations_procfs, cd);
>> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
>> index 6b03cc1..002ddd9 100644
>> --- a/net/sunrpc/svcauth_unix.c
>> +++ b/net/sunrpc/svcauth_unix.c
>> @@ -157,11 +157,6 @@ static void ip_map_request(struct cache_detail *cd,
>>   	(*bpp)[-1] = '\n';
>>   }
>>
>> -static int ip_map_upcall(struct cache_detail *cd, struct cache_head *h)
>> -{
>> -	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
>> -}
>> -
>>   static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class, struct in6_addr *addr);
>>   static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
>>
>> @@ -470,11 +465,6 @@ static void unix_gid_request(struct cache_detail *cd,
>>   	(*bpp)[-1] = '\n';
>>   }
>>
>> -static int unix_gid_upcall(struct cache_detail *cd, struct cache_head *h)
>> -{
>> -	return sunrpc_cache_pipe_upcall(cd, h, cd->cache_request);
>> -}
>> -
>>   static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, uid_t uid);
>>
>>   static int unix_gid_parse(struct cache_detail *cd,
>> @@ -577,7 +567,6 @@ static struct cache_detail unix_gid_cache_template = {
>>   	.hash_size	= GID_HASHMAX,
>>   	.name		= "auth.unix.gid",
>>   	.cache_put	= unix_gid_put,
>> -	.cache_upcall	= unix_gid_upcall,
>>   	.cache_request	= unix_gid_request,
>>   	.cache_parse	= unix_gid_parse,
>>   	.cache_show	= unix_gid_show,
>> @@ -875,7 +864,6 @@ static struct cache_detail ip_map_cache_template = {
>>   	.hash_size	= IP_HASHMAX,
>>   	.name		= "auth.unix.ip",
>>   	.cache_put	= ip_map_put,
>> -	.cache_upcall	= ip_map_upcall,
>>   	.cache_request	= ip_map_request,
>>   	.cache_parse	= ip_map_parse,
>>   	.cache_show	= ip_map_show,
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
> I'm seeing a build break from this patch when CONFIG_NFS_USE_KERNEL_DNS
> is not set:
>
>    CC [M]  fs/nfs/dns_resolve.o
> fs/nfs/dns_resolve.c: In function ‘nfs_dns_resolver_cache_init’:
> fs/nfs/dns_resolve.c:377:4: error: ‘struct cache_detail’ has no member named ‘cache_upcall’
> fs/nfs/dns_resolve.c:377:35: warning: left-hand operand of comma expression has no effect [-Wunused-value]
> fs/nfs/dns_resolve.c:377:35: warning: value computed is not used [-Wunused-value]
> fs/nfs/dns_resolve.c:377:35: warning: value computed is not used [-Wunused-value]
> fs/nfs/dns_resolve.c:377:35: warning: value computed is not used [-Wunused-value]
> fs/nfs/dns_resolve.c:377:35: warning: value computed is not used [-Wunused-value]
> fs/nfs/dns_resolve.c:377:35: warning: value computed is not used [-Wunused-value]
> fs/nfs/dns_resolve.c:377:35: warning: value computed is not used [-Wunused-value]
> fs/nfs/dns_resolve.c: At top level:
> fs/nfs/dns_resolve.c:129:13: warning: ‘nfs_dns_request’ defined but not used [-Wunused-function]
> make[1]: *** [fs/nfs/dns_resolve.o] Error 1
> make: *** [_module_fs/nfs] Error 2
>
> ...looks like you need to convert that cache_detail to use your new
> scheme as well?
>

Yes, thanks, Jeff!
Have a look at the second version of this series.

-- 
Best regards,
Stanislav Kinsbursky
