Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:24936 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932560Ab2FTS1b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 14:27:31 -0400
Message-ID: <4FE215FE.6010406@netapp.com>
Date: Wed, 20 Jun 2012 14:27:10 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Andre Tomt <andre@tomt.net>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        Fengguang Wu <fengguang.wu@intel.com>,
        David Howells <dhowells@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: BUG in __key_instantiate_and_link(): unable to handle kernel
 paging request at 0000632e6472616f
References: <20120601034114.GA9248@localhost> <4FDBF056.7040404@tomt.net>   <4FDCD3C7.5080503@tomt.net> <1339876739.8267.96.camel@lade.trondhjem.org>  <4FDEEF38.8030101@tomt.net> <1340026127.2451.7.camel@lade.trondhjem.org> <4FDF533A.2090901@netapp.com>
In-Reply-To: <4FDF533A.2090901@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andre,

Have you had a chance to test my patch (below) yet?

- Bryan

On 06/18/2012 12:11 PM, Bryan Schumaker wrote:
> On 06/18/2012 09:28 AM, Myklebust, Trond wrote:
>> On Mon, 2012-06-18 at 11:04 +0200, Andre Tomt wrote:
>>> On 16. juni 2012 21:59, Myklebust, Trond wrote:
>>>> It looks to me as if the legacy upcall code is assuming that there can
>>>> be no more than 1 upcall at a time: there is only a single
>>>> idmap->idmap_key_cons, which gets assigned in nfs_idmap_legacy_upcall
>>>> and then read in idmap_pipe_downcall.
>>>>
>>>> Bryan, can you look into this? I suspect that we need a mutex or
>>>> something like that (for the legacy upcall case only) to ensure that
>>>> nobody overwrites the idmap->idmap_key_cons while an upcall is in
>>>> progress.
>>>>
>>>> Andre, if you want idmapper scalability, then you should rather use the
>>>> new idmapper upcall. You need a recent version of the nfs-utils package,
>>>> the keyutils package, and they you should add an 'id_resolver' line
>>>> to /etc/request-keys.conf as per the nfsidmap manpage.
>>>
>>> Indeed, using keyutils did avoid the crashes here, 40 hours and counting.
>>>
>>> Are there any downsides of having keyutils w/ id_resolver on by default 
>>> in a distribution? Would it break older kernels or nfs-utils (just not 
>>> getting used is fine, obviously)?
>>
>> Older kernels aren't able to use the keyutils mechanism, so they will
>> still require you to run the idmapd daemon, but there should be no
>> problems with just enabling it in /etc/request-key.conf.
>> Fedora 17 is supposed to install the id_resolver by default.
>>
> 
> Hi Andre,
> 
> Can you please check if this patch fixes the old idmapper?
> 
> - Bryan
> 
>>From 3bef58765c7308965d06d9e9d7707c7ca55648ee Mon Sep 17 00:00:00 2001
> From: Bryan Schumaker <bjschuma@netapp.com>
> Date: Mon, 18 Jun 2012 12:01:25 -0400
> Subject: [PATCH] NFS: Force the legacy idmapper to be single threaded
> 
> It was initially coded under the assumption that there would only be one
> request at a time, so use a lock to enforce this requirement..
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/idmap.c |   13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index b5b86a0..864c51e 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -57,6 +57,11 @@ unsigned int nfs_idmap_cache_timeout = 600;
>  static const struct cred *id_resolver_cache;
>  static struct key_type key_type_id_resolver_legacy;
>  
> +struct idmap {
> +	struct rpc_pipe		*idmap_pipe;
> +	struct key_construction	*idmap_key_cons;
> +	struct mutex		idmap_mutex;
> +};
>  
>  /**
>   * nfs_fattr_init_names - initialise the nfs_fattr owner_name/group_name fields
> @@ -310,9 +315,11 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
>  					    name, namelen, type, data,
>  					    data_size, NULL);
>  	if (ret < 0) {
> +		mutex_lock(&idmap->idmap_mutex);
>  		ret = nfs_idmap_request_key(&key_type_id_resolver_legacy,
>  					    name, namelen, type, data,
>  					    data_size, idmap);
> +		mutex_unlock(&idmap->idmap_mutex);
>  	}
>  	return ret;
>  }
> @@ -354,11 +361,6 @@ static int nfs_idmap_lookup_id(const char *name, size_t namelen, const char *typ
>  /* idmap classic begins here */
>  module_param(nfs_idmap_cache_timeout, int, 0644);
>  
> -struct idmap {
> -	struct rpc_pipe		*idmap_pipe;
> -	struct key_construction	*idmap_key_cons;
> -};
> -
>  enum {
>  	Opt_find_uid, Opt_find_gid, Opt_find_user, Opt_find_group, Opt_find_err
>  };
> @@ -469,6 +471,7 @@ nfs_idmap_new(struct nfs_client *clp)
>  		return error;
>  	}
>  	idmap->idmap_pipe = pipe;
> +	mutex_init(&idmap->idmap_mutex);
>  
>  	clp->cl_idmap = idmap;
>  	return 0;
> 


