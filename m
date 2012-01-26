Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22391 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752712Ab2AZV5l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 16:57:41 -0500
Message-ID: <4F21CC52.4080800@netapp.com>
Date: Thu, 26 Jan 2012 16:57:38 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS: Fall back on old idmapper if request_key() fails
References: <1327614865-29322-1-git-send-email-bjschuma@netapp.com> <20120126215615.GF700@fieldses.org>
In-Reply-To: <20120126215615.GF700@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu Jan 26 16:56:15 2012, J. Bruce Fields wrote:
> I'm assuming you meant to send this to Trond, not me?

Oops, that was supposed to go to Trond.  I have two scripts:  
git-submit-nfs and git-submit-nfsd.  My fingers must have been working 
faster than my brain...
>
> --b.
>
> On Thu, Jan 26, 2012 at 04:54:23PM -0500, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> This patch removes the CONFIG_NFS_USE_NEW_IDMAPPER compile option.
>> First, the idmapper will attempt to map the id using /sbin/request-key
>> and nfsidmap.  If this fails (if /etc/request-key.conf is not configured
>> properly) then the idmapper will call the legacy code to perform the
>> mapping.  I left a comment stating where the legacy code begins to make
>> it easier for somebody to remove in the future.
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>> I tested this on both Archlinux with nfs-utils 1.2.5 and on Fedora with
>> nfs-utils 1.2.6-rc6.  It did what was expected in both cases.
>>
>>  fs/nfs/Kconfig            |   11 ------
>>  fs/nfs/idmap.c            |   76 +++++++++++++++------------------------------
>>  fs/nfs/sysctl.c           |    2 -
>>  include/linux/nfs_idmap.h |   25 ---------------
>>  4 files changed, 25 insertions(+), 89 deletions(-)
>>
>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>> index dbcd821..021d2cf 100644
>> --- a/fs/nfs/Kconfig
>> +++ b/fs/nfs/Kconfig
>> @@ -132,14 +132,3 @@ config NFS_USE_KERNEL_DNS
>>  	select DNS_RESOLVER
>>  	select KEYS
>>  	default y
>> -
>> -config NFS_USE_NEW_IDMAPPER
>> -	bool "Use the new idmapper upcall routine"
>> -	depends on NFS_V4 && KEYS
>> -	help
>> -	  Say Y here if you want NFS to use the new idmapper upcall functions.
>> -	  You will need /sbin/request-key (usually provided by the keyutils
>> -	  package).  For details, read
>> -	  <file:Documentation/filesystems/nfs/idmapper.txt>.
>> -
>> -	  If you are unsure, say N.
>> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
>> index 2c05f19..56b1104 100644
>> --- a/fs/nfs/idmap.c
>> +++ b/fs/nfs/idmap.c
>> @@ -142,8 +142,6 @@ static int nfs_map_numeric_to_string(__u32 id, char *buf, size_t buflen)
>>  	return snprintf(buf, buflen, "%u", id);
>>  }
>>  
>> -#ifdef CONFIG_NFS_USE_NEW_IDMAPPER
>> -
>>  #include <linux/cred.h>
>>  #include <linux/sunrpc/sched.h>
>>  #include <linux/nfs4.h>
>> @@ -327,43 +325,7 @@ static int nfs_idmap_lookup_id(const char *name, size_t namelen,
>>  	return ret;
>>  }
>>  
>> -int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
>> -{
>> -	if (nfs_map_string_to_numeric(name, namelen, uid))
>> -		return 0;
>> -	return nfs_idmap_lookup_id(name, namelen, "uid", uid);
>> -}
>> -
>> -int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *gid)
>> -{
>> -	if (nfs_map_string_to_numeric(name, namelen, gid))
>> -		return 0;
>> -	return nfs_idmap_lookup_id(name, namelen, "gid", gid);
>> -}
>> -
>> -int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
>> -{
>> -	int ret = -EINVAL;
>> -
>> -	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
>> -		ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
>> -	if (ret < 0)
>> -		ret = nfs_map_numeric_to_string(uid, buf, buflen);
>> -	return ret;
>> -}
>> -int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf, size_t buflen)
>> -{
>> -	int ret = -EINVAL;
>> -
>> -	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
>> -		ret = nfs_idmap_lookup_name(gid, "group", buf, buflen);
>> -	if (ret < 0)
>> -		ret = nfs_map_numeric_to_string(gid, buf, buflen);
>> -	return ret;
>> -}
>> -
>> -#else  /* CONFIG_NFS_USE_NEW_IDMAPPER not defined */
>> -
>> +/* idmap classic begins here */
>>  #include <linux/module.h>
>>  #include <linux/mutex.h>
>>  #include <linux/init.h>
>> @@ -795,19 +757,27 @@ static unsigned int fnvhash32(const void *buf, size_t buflen)
>>  int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
>>  {
>>  	struct idmap *idmap = server->nfs_client->cl_idmap;
>> +	int ret = -EINVAL;
>>  
>>  	if (nfs_map_string_to_numeric(name, namelen, uid))
>>  		return 0;
>> -	return nfs_idmap_id(idmap, &idmap->idmap_user_hash, name, namelen, uid);
>> +	ret = nfs_idmap_lookup_id(name, namelen, "uid", uid);
>> +	if (ret < 0)
>> +		ret = nfs_idmap_id(idmap, &idmap->idmap_user_hash, name, namelen, uid);
>> +	return ret;
>>  }
>>  
>> -int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
>> +int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *gid)
>>  {
>>  	struct idmap *idmap = server->nfs_client->cl_idmap;
>> +	int ret = -EINVAL;
>>  
>> -	if (nfs_map_string_to_numeric(name, namelen, uid))
>> +	if (nfs_map_string_to_numeric(name, namelen, gid))
>>  		return 0;
>> -	return nfs_idmap_id(idmap, &idmap->idmap_group_hash, name, namelen, uid);
>> +	ret = nfs_idmap_lookup_id(name, namelen, "gid", gid);
>> +	if (ret < 0)
>> +		ret = nfs_idmap_id(idmap, &idmap->idmap_group_hash, name, namelen, gid);
>> +	return ret;
>>  }
>>  
>>  int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
>> @@ -815,22 +785,26 @@ int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, s
>>  	struct idmap *idmap = server->nfs_client->cl_idmap;
>>  	int ret = -EINVAL;
>>  
>> -	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
>> -		ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
>> +	if (!(server->caps & NFS_CAP_UIDGID_NOMAP)) {
>> +		ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
>> +		if (ret < 0)
>> +			ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
>> +	}
>>  	if (ret < 0)
>>  		ret = nfs_map_numeric_to_string(uid, buf, buflen);
>>  	return ret;
>>  }
>> -int nfs_map_gid_to_group(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
>> +int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf, size_t buflen)
>>  {
>>  	struct idmap *idmap = server->nfs_client->cl_idmap;
>>  	int ret = -EINVAL;
>>  
>> -	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
>> -		ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
>> +	if (!(server->caps & NFS_CAP_UIDGID_NOMAP)) {
>> +		ret = nfs_idmap_lookup_name(gid, "group", buf, buflen);
>> +		if (ret < 0)
>> +			ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, gid, buf);
>> +	}
>>  	if (ret < 0)
>> -		ret = nfs_map_numeric_to_string(uid, buf, buflen);
>> +		ret = nfs_map_numeric_to_string(gid, buf, buflen);
>>  	return ret;
>>  }
>> -
>> -#endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
>> diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
>> index 978aaeb..ad4d2e7 100644
>> --- a/fs/nfs/sysctl.c
>> +++ b/fs/nfs/sysctl.c
>> @@ -32,7 +32,6 @@ static ctl_table nfs_cb_sysctls[] = {
>>  		.extra1 = (int *)&nfs_set_port_min,
>>  		.extra2 = (int *)&nfs_set_port_max,
>>  	},
>> -#ifndef CONFIG_NFS_USE_NEW_IDMAPPER
>>  	{
>>  		.procname = "idmap_cache_timeout",
>>  		.data = &nfs_idmap_cache_timeout,
>> @@ -40,7 +39,6 @@ static ctl_table nfs_cb_sysctls[] = {
>>  		.mode = 0644,
>>  		.proc_handler = proc_dointvec_jiffies,
>>  	},
>> -#endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
>>  #endif
>>  	{
>>  		.procname	= "nfs_mountpoint_timeout",
>> diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
>> index 308c188..717fa50 100644
>> --- a/include/linux/nfs_idmap.h
>> +++ b/include/linux/nfs_idmap.h
>> @@ -69,36 +69,11 @@ struct nfs_server;
>>  struct nfs_fattr;
>>  struct nfs4_string;
>>  
>> -#ifdef CONFIG_NFS_USE_NEW_IDMAPPER
>> -
>>  int nfs_idmap_init(void);
>>  void nfs_idmap_quit(void);
>> -
>> -static inline int nfs_idmap_new(struct nfs_client *clp)
>> -{
>> -	return 0;
>> -}
>> -
>> -static inline void nfs_idmap_delete(struct nfs_client *clp)
>> -{
>> -}
>> -
>> -#else /* CONFIG_NFS_USE_NEW_IDMAPPER not set */
>> -
>> -static inline int nfs_idmap_init(void)
>> -{
>> -	return 0;
>> -}
>> -
>> -static inline void nfs_idmap_quit(void)
>> -{
>> -}
>> -
>>  int nfs_idmap_new(struct nfs_client *);
>>  void nfs_idmap_delete(struct nfs_client *);
>>  
>> -#endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
>> -
>>  void nfs_fattr_init_names(struct nfs_fattr *fattr,
>>  		struct nfs4_string *owner_name,
>>  		struct nfs4_string *group_name);
>> -- 
>> 1.7.8.4
>>


