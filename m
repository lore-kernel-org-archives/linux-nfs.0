Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755539Ab2JTNqS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Oct 2012 09:46:18 -0400
Date: Sat, 20 Oct 2012 09:46:11 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jan Sanislo <oystr@cs.washington.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsidmap and NFS key timeouts and quotas
Message-ID: <20121020094611.2f0d2c32@tlielax.poochiereds.net>
In-Reply-To: <1350679987/oystr@maui.cs.washington.edu>
References: <1350679987/oystr@maui.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 19 Oct 2012 13:53 PDT
Jan Sanislo <oystr@cs.washington.edu> wrote:

> The man page for nfsidmap says that it will set a default timeout
> of 600 seconds on keys requested by the NFS client.  But the
> keys instantiated are listed a permanent in /proc/keys and it's
> easily possible to run out of key quota in an NFS environment with
> 100s/1000s of uids/gids.
> 
> Nfsidmap's call to keyctl_set_timeout fails with a permission
> error because the call is made *after* the key is instantiated
> and permission to modify the key attributes has been revoked as
> a result.  The following patch seems to be more effective in
> actually setting the key timeout:
> 
> ====================================
> 
> --- nfsidmap.c_orig	2012-10-19 11:32:29.806374240 -0700
> +++ nfsidmap.c	2012-10-19 11:40:06.334674363 -0700
> @@ -320,6 +320,16 @@
>  			key, type, value, timeout);
>  	}
>  
> +	/*
> +	 * Set timeout before instantiation revokes our rights
> +	 * over the key.
> +	 */
> +	if ( timeout > 0 ) {
> +		rc = keyctl_set_timeout(key, timeout);
> +		if ( rc != 0 )
> +			xlog_warn("keyctl_set_timeout key 0x%x failed: %m",key);
> +	}
> +
>  	if (strcmp(type, "uid") == 0)
>  		rc = id_lookup(value, key, USER);
>  	else if (strcmp(type, "gid") == 0)
> @@ -329,10 +339,6 @@
>  	else if (strcmp(type, "group") == 0)
>  		rc = name_lookup(value, key, GROUP);
>  
> -	/* Set timeout to 10 (600 seconds) minutes */
> -	if (rc == 0)
> -		keyctl_set_timeout(key, timeout);
> -
>  	free(arg);
>  	return rc;
>  }
> 

Nice catch. The rpc.idmapd downcall handler does this already in the
kernel:

        ret = nfs_idmap_read_and_verify_message(&im,
                        &idmap->idmap_upcall_data->idmap_msg,
                        cons->key, cons->authkey);
        if (ret >= 0) {
                key_set_timeout(cons->key, nfs_idmap_cache_timeout);
                ret = mlen;
        }

...where nfs_idmap_cache_timeout defaults to 600 and is tunable via
module parameter. Might it be better for consistency's sake to make the
keys API upcall do the same thing?

> ====================================
> 
> Also, it appears that the check for EDQUOT/ENFILE/ENOMEM after the
> keyctl_instantiate call is ineffective.  Those errors seem to be
> handled within the kernel a key_alloc time -- if one of them occurs
> an upcall to nfsidmap is not made.
> 
> Finally, the key LRU discard patch: http://lkml.org/lkml/2012/3/28/144
> looks promising for managing key quotas.  But it only seems to be
> invoked when a key is linked into a destination keyring. fs/nfs/idmap.c
> uses a call to security/keys/request_key which by default provides an
> NULL dest_keyring. Might consider changing the request_key call in nfs/idmap.c
> to request_key_and_link (although I don't pretend to know all the
> implications of making such a change).

Have you tested that? I thought these keys did end up in a keyring
(hence the whole override_creds/revert_creds song-and-dance). I haven't
looked closely at the LRU discard stuff though, so you may be correct
here...

-- 
Jeff Layton <jlayton@redhat.com>
