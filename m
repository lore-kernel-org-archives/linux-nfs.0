Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753549Ab1KVNzc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 08:55:32 -0500
Message-ID: <4ECBA9D0.3040001@RedHat.com>
Date: Tue, 22 Nov 2011 08:55:28 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: Re: [Keyrings] [PATCH] KEYS: Allow special keyrings to be cleared
References: <20111111160753.5190.36069.stgit@warthog.procyon.org.uk>	 <4EC66D7B.7030908@RedHat.com> <1321641219.2653.13.camel@lade.trondhjem.org>
In-Reply-To: <1321641219.2653.13.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/18/2011 01:33 PM, Trond Myklebust wrote:
> On Fri, 2011-11-18 at 09:36 -0500, Steve Dickson wrote: 
>> Hey Trond,
>>
>> Could you please add this patch to David's patch set?
> 
> David's patchset is not going upstream through my tree; I believe it is
> supposed to be merged via the security tree.
> 
> That said, you might want to fix up the changelog entry. Something seems
> to be amiss in the second sentence.
Oops... Thanks for point that out... 

David, would you mind adding this to your patch set assuming
there is no objection from Trond?  

Author: Steve Dickson <steved@redhat.com>
Date:   Fri Nov 18 09:29:17 2011 -0500

    KEYS: allow keys to be revoked from the keyring
    
    To aid in cleaning up invalid id mappings add
    the write bit to the key permission. Allowing
    only root to revoke the keys.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 47d1c6f..652238c 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -185,7 +185,7 @@ static ssize_t nfs_idmap_request_key(const char *name, size_t nam
        }
 
        rcu_read_lock();
-       rkey->perm |= KEY_USR_VIEW;
+       rkey->perm |= KEY_USR_VIEW|KEY_USR_WRITE;
 
        ret = key_validate(rkey);
        if (ret < 0)
