From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Attribute timeout handling and wrapping
	u32	jiffies
Date: Wed, 25 Jul 2007 10:00:13 -0400
Message-ID: <1185372013.6585.73.camel@localhost>
References: <20070725030809.GB27619@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <nfs@lists.sourceforge.net>
To: Fabio Olive Leite <fleite@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDhPZ-00006a-5Q
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 07:00:21 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/AaV91ff6Eal9+yXn6QEG5M8pmYjQImzc=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDhPc-0004wz-DD
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 07:00:25 -0700
In-Reply-To: <20070725030809.GB27619@sleipnir.redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-07-25 at 00:08 -0300, Fabio Olive Leite wrote:
> Hi all,
> 
> I would like to discuss the idea that the current checks for attribute
> timeout using time_after are inadequate for 32bit architectures, since
> time_after works correctly only when the two timestamps being compared
> are within 2^31 jiffies of each other. The signed overflow caused by
> comparing values more than 2^31 jiffies apart will flip the result,
> causing incorrect assumptions of validity.
> 
> 2^31 jiffies is a fairly large period of time (~25 days) when compared
> to the lifetime of most kernel data structures, but for long lived NFS
> mounts that can sit idle for months (think that for some reason autofs
> cannot be used), it is easy to compare inode attribute timestamps with
> very disparate or even bogus values (as in when jiffies have wrapped
> many times, where the comparison doesn't even make sense).
> 
> Currently the code tests for attribute timeout by simply adding the
> desired amount of jiffies to the stored timestamp and comparing that
> with the current timestamp of obtained attribute data with time_after.
> This is incorrect, as it returns true for the desired timeout period
> and another full 2^31 range of jiffies.
> 
> I would like to propose a different way for testing for timeouts: we
> first make sure the timestamps are comparable, meaning the "current"
> timestamp is checked for being after the "stored" timestamp (if it is
> before we assume it has wrapped), and after that we check if the
> difference between them is greater than the desired timeout/validity
> period.
> 
> This test does not cast the values to signed, and instead of comparing
> two possibly unrelated points in time, it actually tests if the
> timestamp wrapped, and if the period of time between the two
> timestamps is greater than the period represented by the timeout
> value. It seems to make more sense this way.
> 
> In testing with artificial jumps (several small jumps, not one big
> crank) of the jiffies I was able to reproduce a problem found in a
> server with very long lived NFS mounts, where attributes would not be
> refreshed even after touching files and directories in the server:
> 
> Initial uptime:
> 03:42:01 up 6 min, 0 users, load average: 0.01, 0.12, 0.07
> 
> NFS volume is mounted and time is advanced:
> 03:38:09 up 25 days, 2 min, 0 users, load average: 1.22, 1.05, 1.08
> 
> # ls -l /local/A/foo/bar /nfs/A/foo/bar
> -rw-r--r--  1 root root 0 Dec 17 03:38 /local/A/foo/bar
> -rw-r--r--  1 root root 0 Nov 22 00:36 /nfs/A/foo/bar
> 
> # touch /local/A/foo/bar
> 
> # ls -l /local/A/foo/bar /nfs/A/foo/bar
> -rw-r--r--  1 root root 0 Dec 17 03:47 /local/A/foo/bar
> -rw-r--r--  1 root root 0 Nov 22 00:36 /nfs/A/foo/bar
> 
> We can see the local mtime is updated, but the NFS mount still shows
> the old value. The patch below makes it work:
> 
> Initial setup...
> 07:11:02 up 25 days, 1 min,  0 users,  load average: 0.15, 0.03, 0.04
> 
> # ls -l /local/A/foo/bar /nfs/A/foo/bar
> -rw-r--r--  1 root root 0 Jan 11 07:11 /local/A/foo/bar
> -rw-r--r--  1 root root 0 Jan 11 07:11 /nfs/A/foo/bar
> 
> # touch /local/A/foo/bar
> 
> # ls -l /local/A/foo/bar /nfs/A/foo/bar
> -rw-r--r--  1 root root 0 Jan 11 07:14 /local/A/foo/bar
> -rw-r--r--  1 root root 0 Jan 11 07:14 /nfs/A/foo/bar
> 
> I'd love to hear comments and criticism. Even if this is not the
> correct way to fix it, I'm fairly sure we can agree that there's the
> need for a fix and a proper fix can be found.
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index ea97408..8e85710 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1852,7 +1852,7 @@ int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, struct nfs
>  	cache = nfs_access_search_rbtree(inode, cred);
>  	if (cache == NULL)
>  		goto out;
> -	if (time_after(jiffies, cache->jiffies + NFS_ATTRTIMEO(inode)))
> +	if (timeout_or_wrap(jiffies, cache->jiffies, NFS_ATTRTIMEO(inode)))
>  		goto out_stale;
>  	res->jiffies = cache->jiffies;
>  	res->cred = cache->cred;
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index bca6cdc..f611f95 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -662,7 +662,7 @@ int nfs_attribute_timeout(struct inode *inode)
>  
>  	if (nfs_have_delegation(inode, FMODE_READ))
>  		return 0;
> -	return time_after(jiffies, nfsi->read_cache_jiffies+nfsi->attrtimeo);
> +	return timeout_or_wrap(jiffies, nfsi->read_cache_jiffies, nfsi->attrtimeo);
>  }
>  
>  /**
> @@ -1061,7 +1061,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  		nfs_inc_stats(inode, NFSIOS_ATTRINVALIDATE);
>  		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
>  		nfsi->attrtimeo_timestamp = now;
> -	} else if (time_after(now, nfsi->attrtimeo_timestamp+nfsi->attrtimeo)) {
> +	} else if (timeout_or_wrap(now, nfsi->attrtimeo_timestamp, nfsi->attrtimeo)) {
>  		if ((nfsi->attrtimeo <<= 1) > NFS_MAXATTRTIMEO(inode))
>  			nfsi->attrtimeo = NFS_MAXATTRTIMEO(inode);
>  		nfsi->attrtimeo_timestamp = now;
> diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
> index c080f61..ffda7cb 100644
> --- a/include/linux/jiffies.h
> +++ b/include/linux/jiffies.h
> @@ -115,6 +115,11 @@ static inline u64 get_jiffies_64(void)
>  	 ((long)(a) - (long)(b) >= 0))
>  #define time_before_eq(a,b)	time_after_eq(b,a)
>  
> +#define timeout_or_wrap(a,b,c)	\
> +	(typecheck(unsigned long, a) && \
> +	 typecheck(unsigned long, b) && \
> +	 ((a) < (b) || (a) - (b) > (c)))
> +

Ugly name. Besides, the above macro causes problems at the wraparound
boundary when (b) may indeed be < (a), but we're still in the allowed
range. There is also no guarantee that (c) is unsigned. How about

#define time_in_range(a,b,c) \
	(time_after_eq(a,b) && \
	 time_before_eq(a,c))

instead?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
