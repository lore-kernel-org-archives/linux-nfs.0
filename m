Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:46343 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753519Ab1JFJ7S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Oct 2011 05:59:18 -0400
Message-ID: <4E8D7BED.6020705@parallels.com>
Date: Thu, 06 Oct 2011 13:59:09 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>,
        "Kirill A. Shutemov" <kas@openvz.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: network-namespace-aware nfsd
References: <20111005150214.GA18449@fieldses.org> <4E8C9363.9030303@parallels.com> <20111005181959.GB18449@fieldses.org>
In-Reply-To: <20111005181959.GB18449@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

05.10.2011 22:19, J. Bruce Fields пишет:
>
> I don't think so.  Here's roughly how nfsd looks up an inode given a
> filehandle:
>
> 	- look up the ip address in the auth.unix.ip cache (filled by
> 	  rpc.mountd) and get a "struct auth_domain", which represents
> 	  some set of clients.  (E.g., "*.example.com").
> 	- extract the part of the filehandle that represents the export
> 	  and look that up in the nfsd.fh cache (also filled by
> 	  rpc.mountd); result is a path, resolved to a (vfsmount,
> 	  dentry) in the context of rpc.mountd.
> 	- look up the (auth_domain, path) pair in the nfsd.export cache
> 	  (again filled by rpc.mountd) to get export options (ro vs rw,
> 	  security requirements, etc.).
>
> As long as we create per-network-namespace auth.unix.ip, nfsd.fh, and
> nfsd.export caches, and as long as nfsd does those lookups in the right
> cache (which should be easy, as it can always reach the namespace from
> rqstp->rq_xprt->xpt_net).... I think it all works.  Do you see any
> problem?
>

I'm not so familiar with NFS server code. So, probably, you are right and no 
problems here at all.

>
> Similarly net/sunrpc/svc.c:svc_process_common(), where the version check
> is normally done, knows what namespace the request is associated with
> (again by looking at xpt_net), and could look up the supported versions
> per-namespace.
>
> As long as everything on the server side is passed a struct svc_rqst, I
> don't think having distinct thread pools would simplify anything.
>
> Do you think I'm missing anything?
>

I realized, that probably no. At least I can't find any issues for now.

> Also, do you think per-namespace version support is important?
>

Actually, yes, I do.
As I see it, nfsd filesystem have to virtualized to provide flexible control for 
server features. If so, then we need to virtualize program as well.

>
> To start with I suspect it would be OK to share the one lockd thread.
>

Yep, I think so too. It just will be harder to implement.
Anyway, thanks for comment.

> Some day I would very much like to allow lockd to be multithreaded.  But
> I don't know that we'd want separate threads per namespace.
>
> --b.


-- 
Best regards,
Stanislav Kinsbursky
