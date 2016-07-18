Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43126 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbcGRUBW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jul 2016 16:01:22 -0400
Date: Mon, 18 Jul 2016 16:01:21 -0400
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/8] mountd: remove 'dev_missing' checks
Message-ID: <20160718200121.GC12304@fieldses.org>
References: <20160714021310.5874.22953.stgit@noble>
 <20160714022643.5874.84409.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160714022643.5874.84409.stgit@noble>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 14, 2016 at 12:26:43PM +1000, NeilBrown wrote:
> I now think this was a mistaken idea.
> 
> If a filesystem is exported with the "mountpoint" or "mp" option, it
> should only be exported if the directory is a mount point.  The
> intention is that if there is a problem with one filesystem on a
> server, the others can still be exported, but clients won't
> incorrectly see the empty directory on the parent when accessing the
> missing filesystem, they will see clearly that the filesystem is
> missing.
> 
> It is easy to handle this correctly for NFSv3 MOUNT requests, but what
> is the correct behavior if a client already has the filesystem mounted
> and so has a filehandle?  Maybe the server rebooted and came back with
> one device missing.  What should the client see?
> 
> The "dev_missing" code tries to detect this case and causes the server
> to respond with silence rather than ESTALE.  The idea was that the
> client would retry and when (or if) the filesystem came back, service
> would be transparently restored.
> 
> The problem with this is that arbitrarily long delays are not what
> people would expect, and can be quite annoying.  ESTALE, while
> unpleasant, it at least easily understood.  A device disappearing is a
> fairly significant event and hiding it doesn't really serve anyone.

It could also be a filesystem disappearing because it failed to mount in
time on a reboot.

> So: remove the code and allow ESTALE.

I'm not completely sure I understand the justification.

I don't like the current behavior either--I'd be happy if we could
deprecate "mountpoint" entirely--but changing it now would seem to risk
regressions if anyone depends on it.

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  utils/mountd/cache.c |   12 ------------
>  1 file changed, 12 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ec86a22613cf..346a8b3af8b5 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -687,7 +687,6 @@ static void nfsd_fh(int f)
>  	char *found_path = NULL;
>  	nfs_export *exp;
>  	int i;
> -	int dev_missing = 0;
>  	char buf[RPC_CHAN_BUF_SIZE], *bp;
>  	int blen;
>  
> @@ -754,11 +753,6 @@ static void nfsd_fh(int f)
>  			if (!is_ipaddr_client(dom)
>  					&& !namelist_client_matches(exp, dom))
>  				continue;
> -			if (exp->m_export.e_mountpoint &&
> -			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
> -					   exp->m_export.e_mountpoint:
> -					   exp->m_export.e_path))
> -				dev_missing ++;
>  
>  			if (!match_fsid(&parsed, exp, path))
>  				continue;
> @@ -801,12 +795,6 @@ static void nfsd_fh(int f)
>  		/* FIXME we need to make sure we re-visit this later */
>  		goto out;
>  	}
> -	if (!found && dev_missing) {
> -		/* The missing dev could be what we want, so just be
> -		 * quite rather than returning stale yet
> -		 */
> -		goto out;
> -	}
>  
>  	if (found)
>  		if (cache_export_ent(buf, sizeof(buf), dom, found, found_path) < 0)
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
