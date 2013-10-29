Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48076 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753589Ab3J2QGf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 12:06:35 -0400
Date: Tue, 29 Oct 2013 12:06:28 -0400
To: Benny Halevy <bhalevy@primarydata.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/7] delegation state fixes and cleanups for 3.13
Message-ID: <20131029160628.GX31322@fieldses.org>
References: <526F81DE.6060704@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <526F81DE.6060704@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"nfsd4: need to destroy revoked delegations in destroy_client" is the
only one that looks to me like it fixes a current bug.

I understand the others may be laying the groundwork for a state lock
change, but I don't have the context to review those yet....

--b.

On Tue, Oct 29, 2013 at 11:37:34AM +0200, Benny Halevy wrote:
> commit c7342d3cf5d5677063cbc6341634ed8cea1b176f
> Author: Benny Halevy <bhalevy@primarydata.com>
> Date:   Tue Oct 15 17:07:31 2013 +0300
> 
>     nfsd4: fix recall_lock use in unhash_delegation
> 
>     Access to dp->dl_perclnt must be synchronized by the recall_lock
> 
>     Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> 
> commit 87174785bcec37371b718757af67dde0f6d083e3
> Author: Benny Halevy <bhalevy@primarydata.com>
> Date:   Tue Oct 15 17:29:13 2013 +0300
> 
>     nfsd4: need to destroy revoked delegations in destroy_client
> 
>     [use list_splice_init]
>     Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> 
> commit 775a7353f9d1e60ebd9096b1a82bfb78fe7f3cc9
> Author: Benny Halevy <bhalevy@primarydata.com>
> Date:   Tue Oct 15 17:41:53 2013 +0300
> 
>     nfsd4: properly hash delegation in nfs4_setlease
> 
>     keep all accesses via dl_perclnt under the recall_lock.
> 
>     Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> 
> commit fdf586869a6b026893f818cb538574a7b77f5604
> Author: Benny Halevy <bhalevy@primarydata.com>
> Date:   Tue Oct 15 21:08:48 2013 +0300
> 
>     nfsd4: hash deleg stateid only on successful nfs4_set_delegation
> 
>     We don't want the stateid to be found in the hash table before the delegation
>     is granted.
> 
>     Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> 
> commit 635a93446fde8d8fb1f4bb825926750d9b6aea9d
> Author: Benny Halevy <bhalevy@primarydata.com>
> Date:   Tue Oct 15 23:46:55 2013 +0300
> 
>     nfsd4: cleanup hash and unhash delegation
> 
>     make sure all atomic ops are under the recall_lock
> 
>     Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> 
> commit 39f26e5974f73b62144abde6793d41b07a32719a
> Author: Benny Halevy <bhalevy@primarydata.com>
> Date:   Tue Oct 15 23:50:30 2013 +0300
> 
>     nfsd4: move nfs4_put_file from unhash to put delegation
> 
>     revoked delegations are unhashed but are kept around in nfsv4.1	and we better
>     hang on to dp_file in this case.
> 
>     Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> 
> commit cd2b2cac09cbd45419ce7d0e354dd94537a4fbfb
> Author: Benny Halevy <bhalevy@primarydata.com>
> Date:   Wed Oct 16 00:17:14 2013 +0300
> 
>     nfsd4: hold recall_lock while accessing nfs4_delegation.dl_recall_lru
> 
>     Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
