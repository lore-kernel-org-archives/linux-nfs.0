From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Invalidating NFS attribute cache
Date: Thu, 9 Jul 2009 10:10:33 -0400
Message-ID: <5440D81E-BC29-4061-92B5-D750CEECFF62@oracle.com>
References: <1247142894.7427.43.camel@cancun.hanskramer.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Hans Kramer <hans.kramer-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:50667 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759070AbZGIOKj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2009 10:10:39 -0400
In-Reply-To: <1247142894.7427.43.camel-6FgEqA8bTCrD1MxPaE+0Y3nhMCiq3JZZ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul 9, 2009, at 8:34 AM, Hans Kramer wrote:
> Hi,
>
> For some silly reason I have an application that needs to poll for the
> existence of a certain file on a NFS share.
> (This is done from Sybase ASE ;-)
>
> Now I run into the issue of attribute caching. Turning of the  
> attribute
> cache with the mount option of -o noac easily solves all the issues.
>
> However, it would be nice if we could still use attribute caching and
> force to invalidate on-demand the attribute cache.

Since you are only concerned with the existence of a file (and not its  
mtime, say). have you considered the new directory cache mount option:  
lookupcache=?

I see it's not mentioned in nfs(8) so you should probably look in  
recent archives of this mailing list for information.

> After a lot of trying, the following solution seems to work for me  
> now:
> (pathname is the test file)
>
> #define _GNU_SOURCE
>
>    char *copy = strdup(pathname);
>    char *path = dirname(copy);
>
>    int fd = open(path, O_DIRECTORY);
>    if (fd >= 0)
>        close(fd);
>
>    free(copy);
>
>    return access(pathname, F_OK);
>
> Just opening the parent directory with O_DIRECTORY seems to do the
> trick.
>
> My questions: Is this hack going to work under every circumstance or
> could it fail in the future with some update. Is there a ioctl call  
> that
> could the the same thing? That is invalidate the parent directory  
> cache.
> Or do I miss something completely ?-)
>
> Thanks in advance
>
> Hans
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




