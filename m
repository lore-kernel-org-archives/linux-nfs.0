Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757921Ab1FVWae (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2011 18:30:34 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p5MMUXFu024407
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2011 18:30:34 -0400
Message-ID: <4E026D08.5070309@RedHat.com>
Date: Wed, 22 Jun 2011 18:30:32 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] mountd: don't automatically add subexports to kernel
 cache
References: <1308063492-30103-1-git-send-email-bfields@redhat.com> <1308063492-30103-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1308063492-30103-5-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Bruce,

This patch breaks cross mounts... Here is my set up

/home/fs1 two different file systems:

Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/mapper/VolGroup00-HomeDirs
                      15236080   9439036   5010612  66% /home
RedHat# df /home/fs1
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/mapper/VolGroup00-FS1
                      10321208    154468   9642452   2% /home/fs1

The export is:
  /home *(rw,crossmnt,nohide,sec=sys:krb5:krb5i:krb5p)

when I mount from a f15 client
    mount -v -o v3 redhat:/home/fs1/tmp/tophat /mnt/tmp
I get:
    mount.nfs: mount(2): Stale NFS file handle

When I revert the patch, the mount works.

Unfortunately I'm going to be taking the next few days off
so I am not going be able to debug this... So I'm going to 
wait on the entire patch series until we can sort this out...

steved.

On 06/14/2011 10:58 AM, J. Bruce Fields wrote:
> Given a crossmnt export and a child path, search for all mountpoints in
> between and add exports for them to the kernel.
> 
> This isn't necessary; if the the kernel needs one of the subexports, it
> can always ask.
> 
> It might be some sort of minor optimization to add exports preemptively.
> But if so, why not just add them all?  Why this particular subset?
> 
> Given the chance to delete some code I can't justify, I'll take it.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  utils/mountd/cache.c |   42 +-----------------------------------------
>  1 files changed, 1 insertions(+), 41 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index d2ae4563..c77eb27 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -945,53 +945,13 @@ static int cache_export_ent(char *domain, struct exportent *exp, char *path)
>  	if (!f)
>  		return -1;
>  
> -	err = dump_to_cache(f, domain, exp->e_path, exp);
> +	err = dump_to_cache(f, domain, path, exp);
>  	if (err) {
>  		xlog(L_WARNING,
>  		     "Cannot export %s, possibly unsupported filesystem or"
>  		     " fsid= required", exp->e_path);
>  	}
>  
> -	while (err == 0 && (exp->e_flags & NFSEXP_CROSSMOUNT) && path) {
> -		/* really an 'if', but we can break out of
> -		 * a 'while' more easily */
> -		/* Look along 'path' for other filesystems
> -		 * and export them with the same options
> -		 */
> -		struct stat stb;
> -		size_t l = strlen(exp->e_path);
> -		__dev_t dev;
> -
> -		if (strlen(path) <= l || path[l] != '/' ||
> -		    strncmp(exp->e_path, path, l) != 0)
> -			break;
> -		if (stat(exp->e_path, &stb) != 0)
> -			break;
> -		dev = stb.st_dev;
> -		while(path[l] == '/') {
> -			char c;
> -			/* errors for submount should fail whole filesystem */
> -			int err2;
> -
> -			l++;
> -			while (path[l] != '/' && path[l])
> -				l++;
> -			c = path[l];
> -			path[l] = 0;
> -			err2 = lstat(path, &stb);
> -			path[l] = c;
> -			if (err2 < 0)
> -				break;
> -			if (stb.st_dev == dev)
> -				continue;
> -			dev = stb.st_dev;
> -			path[l] = 0;
> -			dump_to_cache(f, domain, path, exp);
> -			path[l] = c;
> -		}
> -		break;
> -	}
> -
>  	fclose(f);
>  	return err;
>  }
