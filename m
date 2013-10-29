Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:48580 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754858Ab3J2Mdt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 08:33:49 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/5] NFSv4: clean up state ref counting in open recover
Date: Tue, 29 Oct 2013 12:33:47 +0000
Message-ID: <AF88BDE0-01D7-4B5C-B50D-A232AE7849AE@netapp.com>
References: <1382375414-5854-1-git-send-email-dros@netapp.com>
 <1382375414-5854-4-git-send-email-dros@netapp.com>
 <1382994367.3314.7.camel@leira.trondhjem.org>
 <24EA4861-1E1E-4904-9E80-322EB0522917@netapp.com>
In-Reply-To: <24EA4861-1E1E-4904-9E80-322EB0522917@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2013, at 8:32 AM, Weston Andros Adamson <dros@netapp.com> wrote:

> On Oct 28, 2013, at 5:06 PM, Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:
> 
>> On Mon, 2013-10-21 at 13:10 -0400, Weston Andros Adamson wrote:
>>> There's already a valid state (the one being recovered), so just
>>> reference it. Also clean up error paths to avoid ref leaks.
>>> 
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> fs/nfs/nfs4proc.c | 13 ++++++++-----
>>> 1 file changed, 8 insertions(+), 5 deletions(-)
>>> 
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 8140366..8ae1589 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -1323,14 +1323,14 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>>> 		goto err;
>>> 	}
>>> 
>>> -	ret = -ENOMEM;
>>> -	state = nfs4_get_open_state(inode, data->owner);
>>> -	if (state == NULL)
>>> +	/* referenced the passed state */
>>> +	ret = -EINVAL;
>>> +	if (state == NULL || !atomic_inc_not_zero(&state->count))
>>> 		goto err;
>> 
>> We already know that state != NULL, and that state->count != 0 here, so
>> I applied a simplified version of this patch that just does an
>> atomic_inc(&state->count) just before the function return.
> 
> I just checked out the simplified patch - it looks good.
> 
> Acked-by: Weston Andros Adamson <dros@netapp.com>

Oh, besides redundant CC lines?

    Cc: stable@vger.kernel.org # 3.7.x: a43ec98b72a: NFSv4: don't fail on missing
    Cc: stable@vger.kernel.org # 3.7.x

-dros

> 
> -dros
> 
> 
>> 
>>> 
>>> 	ret = nfs_refresh_inode(inode, &data->f_attr);
>>> 	if (ret)
>>> -		goto err;
>>> +		goto err_put;
>>> 
>>> 	nfs_setsecurity(inode, &data->f_attr, data->f_label);
>>> 
>>> @@ -1340,9 +1340,12 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
>>> 			    data->o_arg.fmode);
>>> 
>>> 	return state;
>>> +
>>> +err_put:
>>> +	nfs4_put_open_state(state);
>>> +
>>> err:
>>> 	return ERR_PTR(ret);
>>> -
>>> }
>>> 
>>> static struct nfs4_state *
>> 
>> -- 
>> Trond Myklebust
>> Linux NFS client maintainer
>> 
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

