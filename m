Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:57055 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752091Ab0ENSbV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 14:31:21 -0400
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
 file
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jeff Layton <jlayton@redhat.com>
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk,
        jamie@shareable.org
In-Reply-To: <1273859968.4732.22.camel@localhost.localdomain>
References: <4BED195F.3070504@cn.fujitsu.com>
	 <20100514055844.109d2fdc@tlielax.poochiereds.net>
	 <1273857471.4732.7.camel@localhost.localdomain>
	 <20100514133819.5e383485@tlielax.poochiereds.net>
	 <1273859968.4732.22.camel@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 14 May 2010 14:31:12 -0400
Message-ID: <1273861872.4732.34.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-05-14 at 13:59 -0400, Trond Myklebust wrote: 
> Note that the server should also recall the delegation if someone
> attempts to violate the guarantees that are listed in section 9.4: Open
> Delegation
> 
>    When a client has a read open delegation, it may not make any changes
>    to the contents or attributes of the file but it is assured that no
>    other client may do so.  When a client has a write open delegation,
>    it may modify the file data since no other client will be accessing
>    the file's data.  The client holding a write delegation may only
>    affect file attributes which are intimately connected with the file
>    data:  size, time_modify, change.
> 
> IOW: even if you hold a write delegation you are not allowed to change
> the file mode bits, owner, group or acls...

...or the nlink value. So technically, we should also recall the
delegation when someone creates or deletes a hard link. I think I need
to remind Tom that he should add that to the RFC3530bis draft...

Cheers
   Trond

