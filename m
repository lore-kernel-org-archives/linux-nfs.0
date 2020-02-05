Return-Path: <SRS0=/Pif=3Z=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C76AEC35247
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Feb 2020 00:44:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 87FB2214AF
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Feb 2020 00:44:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="kd6tVQK1"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727664AbgBEAon (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Feb 2020 19:44:43 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:60778 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727619AbgBEAom (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Feb 2020 19:44:42 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id 0150dVvC103325;
        Wed, 5 Feb 2020 00:44:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=BkjQptoyYdRjXdr0hJXG1xhtTgjKjMDFrwEGnkOoLrs=;
 b=kd6tVQK17A123wjpF6IPit55A/YPjwm77a5kwMznzV8YtD2sM9ltAyMsumiLS2L2Ntpm
 PNvIDzPJpe/7sIWTJCk5PzEEuJTapgfswimhj2IQaZ9yZo8pGbWnYLoVDgDZmc37WJW3
 19pF1YxEVBLcwT3O/ZqGV/TN2g+ShR7GfNM7Ssc314rpstmDpa0bqaXKboUXksOYpLvg
 7z/Ij3LuXOBuBlb+Ufs4kNh+LA1uq2ZTOHBEiwbdRgJUNtsZ/5UErQjrf5KnT1rETRxg
 bDhjDV2xBJeXB5n4u3GA4i1XnPrPl02qNA4GcWKDPgwjz9VbNzZixl1ds5HVqqPtnOWb +Q== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
        by aserp2120.oracle.com with ESMTP id 2xykbp00f1-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 05 Feb 2020 00:44:38 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
        by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id 0150e1QS115692;
        Wed, 5 Feb 2020 00:44:38 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserp3020.oracle.com with ESMTP id 2xykc30q45-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 05 Feb 2020 00:44:38 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id 0150iWDq010241;
        Wed, 5 Feb 2020 00:44:32 GMT
Received: from Macbooks-MacBook-Pro.local (/10.39.210.16)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 04 Feb 2020 16:44:32 -0800
Subject: Re: [PATCH 2/4] NFS: Directory page cache pages need to be locked
 when read
To:     Trond Myklebust <trondmy@gmail.com>,
        "Schumaker, Anna" <Anna.Schumaker@netapp.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bcodding@redhat.com" <bcodding@redhat.com>
References: <20200202225356.995080-1-trond.myklebust@hammerspace.com>
 <20200202225356.995080-2-trond.myklebust@hammerspace.com>
 <20200202225356.995080-3-trond.myklebust@hammerspace.com>
 <16a7298dacd9fd1d08cd26b7073e9ced62c5fa24.camel@netapp.com>
 <beb3c648da7f641d34f9a1cbef5639ba014de6db.camel@gmail.com>
From:   Dai Ngo <dai.ngo@oracle.com>
Message-ID: <6144757d-ca78-692a-0072-18094e93d529@oracle.com>
Date:   Tue, 4 Feb 2020 16:44:30 -0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:68.0)
 Gecko/20100101 Thunderbird/68.4.2
MIME-Version: 1.0
In-Reply-To: <beb3c648da7f641d34f9a1cbef5639ba014de6db.camel@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9521 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1911140001 definitions=main-2002050001
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9521 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1911140001
 definitions=main-2002050001
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


On 2/3/20 1:18 PM, Trond Myklebust wrote:
> On Mon, 2020-02-03 at 20:31 +0000, Schumaker, Anna wrote:
>> Hi Trond,
>>
>> On Sun, 2020-02-02 at 17:53 -0500, Trond Myklebust wrote:
>>> When a NFS directory page cache page is removed from the page
>>> cache,
>>> its contents are freed through a call to nfs_readdir_clear_array().
>>> To prevent the removal of the page cache entry until after we've
>>> finished reading it, we must take the page lock.
>>>
>>> Fixes: 11de3b11e08c ("NFS: Fix a memory leak in nfs_readdir")
>>> Cc: stable@vger.kernel.org # v2.6.37+
>>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
>>> ---
>>>   fs/nfs/dir.c | 30 +++++++++++++++++++-----------
>>>   1 file changed, 19 insertions(+), 11 deletions(-)
>>>
>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>> index ba0d55930e8a..90467b44ec13 100644
>>> --- a/fs/nfs/dir.c
>>> +++ b/fs/nfs/dir.c
>>> @@ -705,8 +705,6 @@ int nfs_readdir_filler(void *data, struct page*
>>> page)
>>>   static
>>>   void cache_page_release(nfs_readdir_descriptor_t *desc)
>>>   {
>>> -	if (!desc->page->mapping)
>>> -		nfs_readdir_clear_array(desc->page);
>>>   	put_page(desc->page);
>>>   	desc->page = NULL;
>>>   }
>>> @@ -720,19 +718,28 @@ struct page
>>> *get_cache_page(nfs_readdir_descriptor_t
>>> *desc)
>>>   
>>>   /*
>>>    * Returns 0 if desc->dir_cookie was found on page desc-
>>>> page_index
>>> + * and locks the page to prevent removal from the page cache.
>>>    */
>>>   static
>>> -int find_cache_page(nfs_readdir_descriptor_t *desc)
>>> +int find_and_lock_cache_page(nfs_readdir_descriptor_t *desc)
>>>   {
>>>   	int res;
>>>   
>>>   	desc->page = get_cache_page(desc);
>>>   	if (IS_ERR(desc->page))
>>>   		return PTR_ERR(desc->page);
>>> -
>>> -	res = nfs_readdir_search_array(desc);
>>> +	res = lock_page_killable(desc->page);
>>>   	if (res != 0)
>>> -		cache_page_release(desc);
>>> +		goto error;
>>> +	res = -EAGAIN;
>>> +	if (desc->page->mapping != NULL) {
>>> +		res = nfs_readdir_search_array(desc);
>>> +		if (res == 0)
>>> +			return 0;
>>> +	}
>>> +	unlock_page(desc->page);
>>> +error:
>>> +	cache_page_release(desc);
>>>   	return res;
>>>   }
>>>   
>> Can you give me some guidance on how to apply this on top of Dai's v2
>> patch from
>> January 23? Right now I have the nfsi->page_index getting set before
>> the
>> unlock_page():
> Since this needs to be a stable patch, it would be preferable to apply
> them in the opposite order to avoid an extra dependency on Dai's patch.

Hi Trond, does this mean my patch won't make it to the stable backport
this time? This patch is not just a performance enhancement, but fixes
real bug, which in some cases can cause readdir to take very long time
to complete.

Thanks,
-Dai

>
> That said, since the nfsi->page_index is not a per-page variable, there
> is no need to put it under the page lock.
>
>
>> @@ -732,15 +733,24 @@ int find_cache_page(nfs_readdir_descriptor_t
>> *desc)
>>   	if (IS_ERR(desc->page))
>>   		return PTR_ERR(desc->page);
>>   
>> -	res = nfs_readdir_search_array(desc);
>> +	res = lock_page_killable(desc->page);
>>   	if (res != 0)
>>   		cache_page_release(desc);
>> +		goto error;
>> +	res = -EAGAIN;
>> +	if (desc->page->mapping != NULL) {
>> +		res = nfs_readdir_search_array(desc);
>> +		if (res == 0)
>> +			return 0;
>> +	}
>>   
>>   	dentry = file_dentry(desc->file);
>>   	inode = d_inode(dentry);
>>   	nfsi = NFS_I(inode);
>>   	nfsi->page_index = desc->page_index;
>> -
>> +	unlock_page(desc->page);
>> +error:
>> +	cache_page_release(desc);
>>   	return res;
>>   }
>>   
>>
>> Please let me know if there is a better way to handle the conflict!
>>
>> Anna
>>
>>
>>> @@ -747,7 +754,7 @@ int
>>> readdir_search_pagecache(nfs_readdir_descriptor_t
>>> *desc)
>>>   		desc->last_cookie = 0;
>>>   	}
>>>   	do {
>>> -		res = find_cache_page(desc);
>>> +		res = find_and_lock_cache_page(desc);
>>>   	} while (res == -EAGAIN);
>>>   	return res;
>>>   }
>>> @@ -786,7 +793,6 @@ int nfs_do_filldir(nfs_readdir_descriptor_t
>>> *desc)
>>>   		desc->eof = true;
>>>   
>>>   	kunmap(desc->page);
>>> -	cache_page_release(desc);
>>>   	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling ended @
>>> cookie %Lu;
>>> returning = %d\n",
>>>   			(unsigned long long)*desc->dir_cookie, res);
>>>   	return res;
>>> @@ -832,13 +838,13 @@ int uncached_readdir(nfs_readdir_descriptor_t
>>> *desc)
>>>   
>>>   	status = nfs_do_filldir(desc);
>>>   
>>> + out_release:
>>> +	nfs_readdir_clear_array(desc->page);
>>> +	cache_page_release(desc);
>>>    out:
>>>   	dfprintk(DIRCACHE, "NFS: %s: returns %d\n",
>>>   			__func__, status);
>>>   	return status;
>>> - out_release:
>>> -	cache_page_release(desc);
>>> -	goto out;
>>>   }
>>>   
>>>   /* The file offset position represents the dirent entry number.  A
>>> @@ -903,6 +909,8 @@ static int nfs_readdir(struct file *file,
>>> struct
>>> dir_context *ctx)
>>>   			break;
>>>   
>>>   		res = nfs_do_filldir(desc);
>>> +		unlock_page(desc->page);
>>> +		cache_page_release(desc);
>>>   		if (res < 0)
>>>   			break;
>>>   	} while (!desc->eof);
