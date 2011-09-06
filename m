Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:39026 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270Ab1IFWct (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2011 18:32:49 -0400
Message-ID: <4E669B21.30006@nexenta.com>
Date: Wed, 07 Sep 2011 02:13:53 +0400
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Vitaliy Gusev <gusev.vitaliy@gmail.com>, peng_tao@emc.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com> <1315337382.16274.7.camel@lade.trondhjem.org>
In-Reply-To: <1315337382.16274.7.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>> @@ -1376,7 +1376,8 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
>>
>>   	list_for_each_entry(lseg,&NFS_I(inode)->layout->plh_segs, pls_list) {
>>   		if (lseg->pls_range.iomode == IOMODE_RW&&
>> -		    test_bit(NFS_LSEG_LAYOUTCOMMIT,&lseg->pls_flags))
>> +		    test_bit(NFS_LSEG_LAYOUTCOMMIT,&lseg->pls_flags)&&
>> +		    list_empty(&lseg->pls_lc_list))
>>   			list_add(&lseg->pls_lc_list, listp);
>>   	}
>>   }
>
> If the lseg is already part of one layoutcommit, but we're sending a
> second one for the same range (presumably because we wrote more data in
> the same region), then the above causes the lseg to be excluded.


Yes, lseg is excluded, This patch does exactly only exclusion of lseg. 
lseg is used here only to get/put reference on this lseg, so skipping is 
correct.


However, checking on list_empty can occur (on other CPU) in the middle:

	list_del_init(&lseg->pls_lc_list);
Here >>>>>>
	if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT,
			       &lseg->pls_flags))
		put_lseg(lseg);


So list_del_init must be executed under the same lock as 
pnfs_list_write_lseg, i.e. inode->i_lock.


>
> I agree that the current code causes list corruption, but before
> applying something like the above patch, I'd like to understand why it
> is correct.
>
> Trond
>

