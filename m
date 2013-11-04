Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:38463 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278Ab3KDVjB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 16:39:01 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>, Steve Dickson <steved@redhat.com>,
        David Quigley <dpquigl@davequigley.com>
Subject: Re: [PATCH 2/5] NFS: __nfs_revalidate_inode() - use the nfs4_label
 to update file security info
Date: Mon, 4 Nov 2013 21:38:59 +0000
Message-ID: <E7A8C8BC-B302-4EAA-8CFE-51FAC8099089@netapp.com>
References: <1383598272-17737-1-git-send-email-Trond.Myklebust@netapp.com>
 <1383598272-17737-2-git-send-email-Trond.Myklebust@netapp.com>
 <0719A451-70BA-4AF8-8A3F-ECF9A221C5BB@netapp.com>
 <20131104162410.2e2580bf@tlielax.poochiereds.net>
In-Reply-To: <20131104162410.2e2580bf@tlielax.poochiereds.net>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2013, at 16:24, Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 4 Nov 2013 21:00:46 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
>> 
>> On Nov 4, 2013, at 15:51, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>> 
>>> Currently, we just discard the nfs4_label information, instead of using it
>>> to update the file LSM security info.
>>> 
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> 
>> I forgot to add a "Reported-by: Jeff Layton <jlayton@redhat.com>”. Fixed now...
>> 
>>> ---
>>> fs/nfs/inode.c | 1 +
>>> 1 file changed, 1 insertion(+)
>>> 
>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>> index 471ba59c42f9..09d4df5f588a 100644
>>> --- a/fs/nfs/inode.c
>>> +++ b/fs/nfs/inode.c
>>> @@ -920,6 +920,7 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
>>> 		goto err_out;
>>> 	}
>>> 
>>> +	nfs_setsecurity(inode, fattr, label);
>>> 	if (nfsi->cache_validity & NFS_INO_INVALID_ACL)
>>> 		nfs_zap_acl_cache(inode);
>>> 
>>> -- 
>>> 1.8.3.1
>>> 
>> 
> 
> No worries -- looks fine.
> 
> Out of curiousity, is there a reason to call nfs_setsecurity prior to
> zapping the ACL cache? The patch I had proposed did it afterward, but I
> didn't think it mattered much either way...

It shouldn’t make a huge difference, no; either way, there be plenty races here…

Trond