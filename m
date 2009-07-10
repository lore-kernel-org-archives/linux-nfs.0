From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs(8): Add description of lookupcache mount option
Date: Fri, 10 Jul 2009 13:20:21 -0400
Message-ID: <20090710172020.GA9927@fieldses.org>
References: <20090709201037.12662.80504.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41356 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751343AbZGJRpR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2009 13:45:17 -0400
In-Reply-To: <20090709201037.12662.80504.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 09, 2009 at 04:11:46PM -0400, Chuck Lever wrote:
> See kernel commit 7973c1f1.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Trond-
> 
> Noted the absense of a description in nfs(8) of the new lookupcache 
> mount option.  Cobbled together this explanation.  Before I submit
> this to Steve, any comments?
> 
>  utils/mount/nfs.man |   86 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 86 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index 13de524..8f1b393 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -422,6 +422,44 @@ NFS mount points allowed on a client, but NFS servers must be configured
>  to allow clients to connect via non-privileged source ports.
>  .IP
>  Refer to the SECURITY CONSIDERATIONS section for important details.
> +.TP 1.5i
> +.BI lookupcache= mode
> +Specifies how the NFS client manages its cache of directory entries.
> +.I mode
> +can be one of
> +.BR all ,
> +.BR none ,
> +.BR pos ,
> +or
> +.BR positive .
> +This option is supported in kernels 2.6.28 and later.
> +.IP
> +The NFS client caches the result of all LOOKUP requests,
> +including results that indicate that a requested directory entry
> +does not exist on the server.
> +If this option is not specified, or if
> +.B all
> +is specified, the client
> +assumes its directory entry cache is valid
> +until the parent directory's cached attributes expire.
> +.IP
> +If
> +.BR pos " or " positive
> +is specified,
> +the client always revalidates entries in its directory cache
> +that indicate that the requested file does not exist on the server
> +before an application can use them.

I find this sentence hard to parse (e.g. I've lost track of what "them"
refers to by the time I get to the end of the sentence).  How about
explicitly defining "negative directory cache entry", and then saying
"the client always revalidates negative directory cache entries before
using them."?

--b.


> +.IP
> +If
> +.B none
> +is specified,
> +the client always revalidates all cached entries in its directory
> +cache before an application can use them,
> +which permits quick detection of files that were created or removed
> +by other clients, but can impact application and server performance.
> +.IP
> +The DATA AND METADATA COHERENCE section contains a
> +detailed discussion of these trade-offs.
>  .SS "Valid options for the nfs file system type"
>  Use these options, along with the options in the above subsection,
>  for mounting the
> @@ -1017,6 +1055,54 @@ If absolute cache coherence among clients is required,
>  applications should use file locking. Alternatively, applications 
>  can also open their files with the O_DIRECT flag
>  to disable data caching entirely.
> +.SS "Directory entry caching"
> +The Linux NFS client caches results of LOOKUP requests
> +to reduce traffic to servers.
> +These days, the client caches lookup results
> +even if the requested directory entry
> +in a LOOKUP request does not exist on the server
> +(in other words, if the server returns ENOENT).
> +This is known as a
> +.IR "cached negative lookup result" .
> +.P
> +The Linux NFS client watches a directory's mtime
> +to detect when directory entries have been added or removed
> +on the server.
> +If the client detects a change in a directory's mtime,
> +the client drops all cached LOOKUP results for that directory.
> +Since the directory's mtime is a cached attribute, it may
> +take some time before a client notices it has changed.
> +See the descriptions of the
> +.BR acdirmin ", " acdirmax ", and " noac
> +mount options for more information about
> +how long a directory's mtime is cached.
> +.P
> +This caching behavior improves the performance of applications that
> +do not share files with applications on other clients.
> +Using cached information about directories can interfere
> +with applications that run concurrently on multiple clients and
> +need to detect the creation or removal of files quickly, however.
> +The
> +.B lookupcache
> +mount option allows some tuning of directory entry caching behavior.
> +.P
> +Previously, the Linux NFS client tracked only successful lookup
> +results, not negative results, with its lookup cache.
> +This permits applications to detect new directory entries
> +created by other clients quickly.
> +If an application depends on the previous lookup caching behavior
> +of the Linux NFS client, you can use
> +.BR lookupcache=positive .
> +.P
> +If the client ignores its cache and validates every application
> +lookup request with the server,
> +that client can immediately detect when a new directory
> +entry has been either created or removed by another client.
> +You can specify this behavior using
> +.BR lookupcache=none .
> +However, the extra NFS requests needed if the client does not
> +cache directory entries can exact a performance penalty.
> +.P
>  .SS "The sync mount option"
>  The NFS client treats the
>  .B sync
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
