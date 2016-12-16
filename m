Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47798 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757358AbcLPLJK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Dec 2016 06:09:10 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Jeffrey Layton" <jlayton@poochiereds.net>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: nfs_rename() handle -ERESTARTSYS dentry left behind
Date: Fri, 16 Dec 2016 06:09:04 -0500
Message-ID: <7D53DC24-3DA9-40BB-BF6E-6DF03A7A0852@redhat.com>
In-Reply-To: <CC105B3B-3E0E-4266-9BF2-E61A648BD3AD@primarydata.com>
References: <11625082826baa811b3ad5b87e1e6e712c6e582d.1481813137.git.bcodding@redhat.com>
 <CC105B3B-3E0E-4266-9BF2-E61A648BD3AD@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 15 Dec 2016, at 17:38, Trond Myklebust wrote:

>> On Dec 15, 2016, at 09:48, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>>
>> An interrupted rename will leave the old dentry behind if the rename
>> succeeds.  Fix this by forcing a lookup the next time through
>> ->d_revalidate.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>> fs/nfs/dir.c | 14 ++++++++++++--
>> 1 file changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>> index 5f1af4cd1a33..5d409616f77e 100644
>> --- a/fs/nfs/dir.c
>> +++ b/fs/nfs/dir.c
>> @@ -2100,14 +2100,24 @@ int nfs_rename(struct inode *old_dir, struct 
>> dentry *old_dentry,
>> 		d_rehash(rehash);
>> 	trace_nfs_rename_exit(old_dir, old_dentry,
>> 			new_dir, new_dentry, error);
>> -	if (!error) {
>> +
>> +	switch (error) {
>> +	case 0:
>> 		if (new_inode != NULL)
>> 			nfs_drop_nlink(new_inode);
>> 		d_move(old_dentry, new_dentry);
>> 		nfs_set_verifier(new_dentry,
>> 					nfs_save_change_attribute(new_dir));
>> -	} else if (error == -ENOENT)
>> +		break;
>> +	case -ENOENT:
>> 		nfs_dentry_handle_enoent(old_dentry);
>> +		break;
>> +	case -ERESTARTSYS:
>> +		/* The result of the rename is unknown. Play it safe by
>> +		 * forcing a new lookup */
>> +		nfs_force_lookup_revalidate(old_dir);
>> +		nfs_force_lookup_revalidate(new_dir);
>> +	}
>
> Doesn’t this error handling belong in nfs_async_rename_done(), or 
> possibly in its “data->complete()” callback? There isn’t much 
> point in forcing a new lookup until we know the RPC call has run its 
> course.

That would be more correct, however if moved there, we'd be forcing a 
lookup after every rename, not just a rename that was signaled.  Is it 
worth trying to find a way to inform those functions that the wait was 
interrupted?

Ben
