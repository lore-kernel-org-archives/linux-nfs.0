Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hurricane.elijah.cs.cmu.edu ([128.2.209.191]:59020 "EHLO
        hurricane.elijah.cs.cmu.edu" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727354AbeJDV7p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Oct 2018 17:59:45 -0400
Date: Thu, 04 Oct 2018 10:42:07 -0400
In-Reply-To: <28763.1538662213@warthog.procyon.org.uk>
References: <153861496327.30373.10501882399296347125.stgit@noble> <153861471803.30373.6184444014227748848.stgit@noble> <28763.1538662213@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Subject: Re: [PATCH 1/3] VFS: introduce MAY_ACT_AS_OWNER
To: David Howells <dhowells@redhat.com>, NeilBrown <neilb@suse.com>
CC: dhowells@redhat.com, "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        linux-nfs@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, coda@cs.cmu.edu,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
From: Jan Harkes <jaharkes@cs.cmu.edu>
Message-ID: <3D5BB0E9-E43C-43D1-86E9-96E409A17D54@cs.cmu.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Same for Coda.

uid/gid/mode don't mean anything, access is based on the directory ACL and the authentication token that is held by the userspace cache manager and ultimately decided by the servers.

Unless someone broke this recently and made permission checks uid based I would expect no change. If this is broken by a recent commit I expect something similar to what NFS is trying to do by allowing the actual check to be passed down.

Jan

On October 4, 2018 10:10:13 AM EDT, David Howells <dhowells@redhat.com> wrote:
>NeilBrown <neilb@suse.com> wrote:
>
>> diff --git a/fs/afs/security.c b/fs/afs/security.c
>> index 81dfedb7879f..ac2e39de8bff 100644
>> --- a/fs/afs/security.c
>> +++ b/fs/afs/security.c
>> @@ -349,6 +349,16 @@ int afs_permission(struct inode *inode, int
>mask)
>>  	if (mask & MAY_NOT_BLOCK)
>>  		return -ECHILD;
>>  
>> +	/* Short-circuit for owner */
>> +	if (mask & MAY_ACT_AS_OWNER) {
>> +		if (inode_owner_or_capable(inode))
>
>You don't know that inode->i_uid in meaningful.  You may have noticed
>that
>afs_permission() ignores i_uid and i_gid entirely.  It queries the
>server (if
>this information is not otherwise cached) to ask what permits the user
>is
>granted - where the user identity is defined by the key returned from
>afs_request_key()[*].
>
>So, NAK for the afs piece.
>
>David
>
>[*] If there's no appropriate key, anonymous permits will be used.
