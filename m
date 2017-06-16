Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45198 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751980AbdFPPD6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Jun 2017 11:03:58 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>, mszeredi@redhat.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 2/2] NFS: nfs_rename() - revalidate directories on
 -ERESTARTSYS
Date: Fri, 16 Jun 2017 11:03:54 -0400
Message-ID: <65DC78B9-F245-4E04-9FC0-1A178D6A6FBC@redhat.com>
In-Reply-To: <1497624882.29103.3.camel@redhat.com>
References: <cover.1497620860.git.bcodding@redhat.com>
 <4ce88bdb84d0c2b5cf1db551ff9a90cc23f294ae.1497620860.git.bcodding@redhat.com>
 <1497624882.29103.3.camel@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16 Jun 2017, at 10:54, Jeff Layton wrote:
> On Fri, 2017-06-16 at 09:50 -0400, Benjamin Coddington wrote:
>> diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
>> index 191aa577dd1f..28628dde38b9 100644
>> --- a/fs/nfs/unlink.c
>> +++ b/fs/nfs/unlink.c
>> @@ -288,6 +288,17 @@ static void nfs_async_rename_release(void *calldata)
>>  	if (d_really_is_positive(data->old_dentry))
>>  		nfs_mark_for_revalidate(d_inode(data->old_dentry));
>>
>> +	/* The result of the rename is unknown. Play it safe by
>> +	 * forcing a new lookup */
>> +	if (data->cancelled) {
>> +		spin_lock(&data->old_dir->i_lock);
>> +		nfs_force_lookup_revalidate(data->old_dir);
>> +		spin_unlock(&data->old_dir->i_lock);
>> +		spin_lock(&data->new_dir->i_lock);
>> +		nfs_force_lookup_revalidate(data->new_dir);
>> +		spin_unlock(&data->new_dir->i_lock);
>> +	}
>> +
>
> One more minor nit:
>
> It's quite possible that old_dir == new_dir. If that's the case you'll
> be doing the same operation twice here. Maybe add a check for that and
> only mess with new_dir here if old_dir != new_dir?

Hmm.. yes that would be better, OK!  I'll send it again.

>>  	dput(data->old_dentry);
>>  	dput(data->new_dentry);
>>  	iput(data->old_dir);
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index b28c83475ee8..1aca3d7c1810 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -1533,6 +1533,7 @@ struct nfs_renamedata {
>>  	struct nfs_fattr	new_fattr;
>>  	void (*complete)(struct rpc_task *, struct nfs_renamedata *);
>>  	long timeout;
>> +	bool cancelled;
>>  };
>>
>>  struct nfs_access_entry;
>
> This looks good to me though. You can add this to both patches.
>
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Thanks for all the suggestions and review!

Ben
