Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:55060 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726465AbeJSXln (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Oct 2018 19:41:43 -0400
Subject: Re: [aarch64] refcount_t: use-after-free in NFS with 64k pages
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        anna.schumaker@netapp.com
References: <c8b0e53b-eccf-5914-af8d-ee47dccd3bcd@arm.com>
 <87va5yvubk.fsf@e105922-lin.cambridge.arm.com>
From: Cristian Marussi <cristian.marussi@arm.com>
Message-ID: <abf58cfc-a575-cb36-47a1-b1135f080362@arm.com>
Date: Fri, 19 Oct 2018 16:35:04 +0100
MIME-Version: 1.0
In-Reply-To: <87va5yvubk.fsf@e105922-lin.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Punit

On 19/10/18 16:18, Punit Agrawal wrote:
> Hi Cristian,
> 
[...]
> 
> The stacktrace suggests it's the same issue that I'd reported earlier -
> 
>      https://lkml.org/lkml/2018/6/29/209
> 
> though without the analysis below.
> 
> [...]
> 
>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> index bb5476a6d264..171813f9a291 100644
>> --- a/fs/nfs/pagelist.c
>> +++ b/fs/nfs/pagelist.c
>> @@ -432,6 +432,15 @@ void nfs_free_request(struct nfs_page *req)
>>
>>   void nfs_release_request(struct nfs_page *req)
>>   {
>> +       /* WORKAROUND */
>> +       if ((kref_read(&req->wb_kref) == 1) &&
>> +           (req->wb_list.prev != &req->wb_list ||
>> +            req->wb_list.next != &req->wb_list)) {
> 
> Are the last two conditions just checking that wb_list is not empty?

yes ... I basically check if the nfs_page element is still linked 
somewhere just before putting the kref to zero (which will result in a 
final nfs_page_free() on an nfs_page which is instead still used).

I checked both here instead of using list_empty() because list_empty 
just check next pointer (READ_ONCE(head->next) == head;) and I was 
overly paranoid while investigating this initially since I didn't know 
really if it was some race on the list handling itself...

Since nfs_list_remove_request() wrapper func issue a list_del_init(),
once the item is unlinked wb_list list_head should point to itself...if 
it is not ... it still could be accessed after being freed...and it 
happens in fact...while does NOT happen in all the cases in which the
refcount is properly accounted...(I have a ton of Ftracing :D)


Thanks

Cristian
