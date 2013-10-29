Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28261 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752508Ab3J2Mc2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 08:32:28 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/5] NFSv4: clean up state ref counting in open recover
Date: Tue, 29 Oct 2013 12:32:26 +0000
Message-ID: <24EA4861-1E1E-4904-9E80-322EB0522917@netapp.com>
References: <1382375414-5854-1-git-send-email-dros@netapp.com>
 <1382375414-5854-4-git-send-email-dros@netapp.com>
 <1382994367.3314.7.camel@leira.trondhjem.org>
In-Reply-To: <1382994367.3314.7.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 28, 2013, at 5:06 PM, Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-10-21 at 13:10 -0400, Weston Andros Adamson wrote:
>> There's already a valid state (the one being recovered), so just
>> reference it. Also clean up error paths to avoid ref leaks.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfs/nfs4proc.c | 13 ++++++++-----
>> 1 file changed, 8 insertions(+), 5 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 8140366..8ae1589 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1323,14 +1323,14 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>> 		goto err;
>> 	}
>> 
>> -	ret = -ENOMEM;
>> -	state = nfs4_get_open_state(inode, data->owner);
>> -	if (state == NULL)
>> +	/* referenced the passed state */
>> +	ret = -EINVAL;
>> +	if (state == NULL || !atomic_inc_not_zero(&state->count))
>> 		goto err;
> 
> We already know that state != NULL, and that state->count != 0 here, so
> I applied a simplified version of this patch that just does an
> atomic_inc(&state->count) just before the function return.

I just checked out the simplified patch - it looks good.

Acked-by: Weston Andros Adamson <dros@netapp.com>

-dros


> 
>> 
>> 	ret = nfs_refresh_inode(inode, &data->f_attr);
>> 	if (ret)
>> -		goto err;
>> +		goto err_put;
>> 
>> 	nfs_setsecurity(inode, &data->f_attr, data->f_label);
>> 
>> @@ -1340,9 +1340,12 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>> 			    data->o_arg.fmode);
>> 
>> 	return state;
>> +
>> +err_put:
>> +	nfs4_put_open_state(state);
>> +
>> err:
>> 	return ERR_PTR(ret);
>> -
>> }
>> 
>> static struct nfs4_state *
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

