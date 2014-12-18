Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:35483 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751722AbaLRXQF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2014 18:16:05 -0500
Date: Fri, 19 Dec 2014 10:15:48 +1100
From: Dave Chinner <david@fromorbit.com>
To: "J. R. Okajima" <hooanon05g@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@primarydata.com>
Subject: Re: [PATCH] dcache: return -ESTALE not -EBUSY on distributed fs race
Message-ID: <20141218231548.GF15665@dastard>
References: <20141217195911.GF9617@fieldses.org>
 <20141217200153.GG9617@fieldses.org>
 <12689.1418917838@jrobl>
 <20141218155838.GD18179@fieldses.org>
 <13170.1418920034@jrobl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <13170.1418920034@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 19, 2014 at 01:27:14AM +0900, J. R. Okajima wrote:
> 
> "J. Bruce Fields":
> > Why do you think -EBUSY's the right error in the local filesystem case?
> 
> This busy_or_stale() is another bandaid, based upon your patch, EBUSY
> --> ESTALE.
> Because the msg string of ESTALE is "Stale NFS file handle" on many
> systems, I don't think it a good idea to return it for local fs. If you

We use file handles on local filesystems. They have exactly the same
semantics as NFS file handles and so local filesystems have the same
ESTALE exposure as "distributed" filesystems to this problem. i.e:

$ man open_by_handle_at
.....
	ESTALE	The specified handle is not valid.  This error will
		occur if, for example, the file has been deleted.

We've been doing this on XFS since before it was ported to linux 15
years ago... ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
