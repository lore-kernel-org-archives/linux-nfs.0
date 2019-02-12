Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94C5EC282CE
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 04:34:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6EE0A21773
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 04:34:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727231AbfBLEex (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 23:34:53 -0500
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:49329 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727166AbfBLEex (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 23:34:53 -0500
Received: from vc1.ecl.ntt.co.jp (vc1.ecl.ntt.co.jp [129.60.86.153])
        by tama500.ecl.ntt.co.jp (8.13.8/8.13.8) with ESMTP id x1C4YldD013722;
        Tue, 12 Feb 2019 13:34:47 +0900
Received: from vc1.ecl.ntt.co.jp (localhost [127.0.0.1])
        by vc1.ecl.ntt.co.jp (Postfix) with ESMTP id 289C0EA7892;
        Tue, 12 Feb 2019 13:34:47 +0900 (JST)
Received: from jcms-pop11.ecl.ntt.co.jp (jcms-pop11.ecl.ntt.co.jp [129.60.87.132])
        by vc1.ecl.ntt.co.jp (Postfix) with ESMTP id 1DB9CEA7364;
        Tue, 12 Feb 2019 13:34:47 +0900 (JST)
Received: from [IPv6:::1] (unknown [129.60.241.122])
        by jcms-pop11.ecl.ntt.co.jp (Postfix) with ESMTPSA id 102EB70C01E0;
        Tue, 12 Feb 2019 13:34:47 +0900 (JST)
Subject: Re: [PATCH] pNFS: Avoid read-modify-write for page-aligned full page
 write
References: <37261782-eebb-b9c5-a480-7ced59b3703f@lab.ntt.co.jp>
 <5905EB17-75B9-494A-B608-F135D6330F49@redhat.com>
 <4332a67f-0d50-cc30-4e2b-8d08a112a76f@lab.ntt.co.jp>
 <17e929a2eea3d2c33dcd3d2c9b8d8a932568be47.camel@hammerspace.com>
From:   Kazuo Ito <ito_kazuo_g3@lab.ntt.co.jp>
Message-ID: <bea45df0-0bf1-048d-e842-7fd7eb0f2b34@lab.ntt.co.jp>
Date:   Tue, 12 Feb 2019 13:34:28 +0900
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <17e929a2eea3d2c33dcd3d2c9b8d8a932568be47.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-CC-Mail-RelayStamp: 1
To:     Trond Myklebust <trondmy@gmail.com>,
        Benjamin Coddington <bcodding@redhat.com>
Cc:     Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org,
        Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>,
        watanabe.hiroyuki@lab.ntt.co.jp
X-TM-AS-MML: disable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2019/02/08 23:58, Trond Myklebust wrote:
> On Fri, 2019-02-08 at 16:54 +0900, 伊藤和夫 wrote:
>> On 2019/02/07 22:37, Benjamin Coddington wrote:
>>> On 7 Feb 2019, at 3:12, Kazuo Ito wrote:
>>> [snipped]
>>>> @@ -299,8 +305,10 @@ static int nfs_want_read_modify_write(struct
>>>> file
>>>> *file, struct page *page,
>>>>       unsigned int end = offset + len;
>>>>
>>>>       if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
>>>> -        if (!PageUptodate(page))
>>>> -            return 1;
>>>> +        if (!PageUptodate(page)) {
>>>> +            if (pglen && (end < pglen || offset))
>>>> +                return 1;
>>>> +        }
>>>>           return 0;
>>>>       }
>>>
>>> This looks right.  I think that a static inline bool
>>> nfs_write_covers_page,
>>> or full_page_write or similar might make sense here, as we do the
>>> same test
>>> just below, and would make the code easier to quickly understand.
>>>
>>> Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
>>   >
>>   > Ben
>>
>> As per Ben's comment, I made the check for full page write a static
>> inline function and both the block-oriented and the non-block-
>> oriented paths call it.
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index 29553fdba8af..458c77ccf274 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -276,6 +276,12 @@ EXPORT_SYMBOL_GPL(nfs_file_fsync);
>>     * then a modify/write/read cycle when writing to a page in the
>>     * page cache.
>>     *
>> + * Some pNFS layout drivers can only read/write at a certain block
>> + * granularity like all block devices and therefore we must perform
>> + * read/modify/write whenever a page hasn't read yet and the data
>> + * to be written there is not aligned to a block boundary and/or
>> + * smaller than the block size.
>> + *
>>     * The modify/write/read cycle may occur if a page is read before
>>     * being completely filled by the writer.  In this situation, the
>>     * page must be completely written to stable storage on the server
>> @@ -291,15 +297,23 @@ EXPORT_SYMBOL_GPL(nfs_file_fsync);
>>     * and that the new data won't completely replace the old data in
>>     * that range of the file.
>>     */
>> -static int nfs_want_read_modify_write(struct file *file, struct page
>> *page,
>> -			loff_t pos, unsigned len)
>> +static bool nfs_full_page_write(struct page *page, loff_t pos,
>> unsigned
>> len)
>>    {
>>    	unsigned int pglen = nfs_page_length(page);
>>    	unsigned int offset = pos & (PAGE_SIZE - 1);
>>    	unsigned int end = offset + len;
>>
>> +	if (pglen && ((end < pglen) || offset))
>> +	    return 0;
>> +	return 1;
>> +}
>> +
>> +static int nfs_want_read_modify_write(struct file *file, struct page
>> *page,
>> +			loff_t pos, unsigned len)
>> +{
>>    	if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
>> -		if (!PageUptodate(page))
>> +		if (!PageUptodate(page) &&
>> +		    !nfs_full_page_write(page, pos, len))
>>    			return 1;
>>    		return 0;
>>    	}
>> @@ -307,8 +321,7 @@ static int nfs_want_read_modify_write(struct
>> file
>> *file, struct page *page,
>>    	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
>>    	    !PageUptodate(page) &&		/* Uptodate? */
>>    	    !PagePrivate(page) &&		/* i/o request already? */
>> -	    pglen &&				/* valid bytes of
>> file? */
>> -	    (end < pglen || offset))		/* replace all valid
>> bytes? */
>> +	    !nfs_full_page_write(page, pos, len))
>>    		return 1;
>>    	return 0;
>>    }
> 
> How about adding a separate
> 
> if (PageUptodate(page) || nfs_full_page_write())
>      return 0;
> 
> before the check for pNFS?
 >
 > That means we won't have to duplicate those for the pNFS block and
 > ordinary case, and it improves code clarity.

Yes, it is much better, and

> BTW: Why doesn't the pNFS case check for PagePrivate(page)? That looks
> like a bug which would cause the existing write to get corrupted.
> If so, we should move that check too into the common code.

It's been that way since the check for
pnfs_ld_read_whole_page(file->f_mapping->host) was added there.
As you pointed out, it shouldn't try to initiate read when there's
an outstanding write.
So, I'll update the patch with these changes, including check for
ongoing I/O, and come up with newer test results in a couple of days.
--
kazuo ito (ito_kazuo_g3@iecl.ntt.co.jp)
NTT OSS Center
