Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tundra.namei.org ([65.99.196.166]:41653 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755533Ab2BGX3p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 18:29:45 -0500
Date: Wed, 8 Feb 2012 10:29:39 +1100 (EST)
From: James Morris <jmorris@namei.org>
To: Steve Dickson <steved@redhat.com>
cc: Linux Keyring Mailing list <keyrings@linux-nfs.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Make keys writable on the idmap keyring.
In-Reply-To: <1328619733-30859-1-git-send-email-steved@redhat.com>
Message-ID: <alpine.LRH.2.02.1202081029000.777@tundra.namei.org>
References: <1328619733-30859-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Should this go in via the NFS tree?  I can put it into the security tree 
otherwise.


On Tue, 7 Feb 2012, Steve Dickson wrote:

> To take advantage of the "Allow special keyrings to be
> cleared" keyring patch the NFS keyring has to be writeable.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfs/idmap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index a1bbf77..1d88cdb 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -269,7 +269,7 @@ static ssize_t nfs_idmap_request_key(const char *name, size_t namelen,
>  	}
>  
>  	rcu_read_lock();
> -	rkey->perm |= KEY_USR_VIEW;
> +	rkey->perm |= KEY_USR_VIEW|KEY_USR_WRITE;
>  
>  	ret = key_validate(rkey);
>  	if (ret < 0)
> -- 
> 1.7.7.5
> 

-- 
James Morris
<jmorris@namei.org>
