Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34222 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbbGMI1d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 04:27:33 -0400
Message-ID: <55A37670.5010703@gmail.com>
Date: Mon, 13 Jul 2015 16:27:28 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.com>
CC: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 07/10 v7] sunrpc: Switch to using list_head instead single
 list
References: <55A11010.6050005@gmail.com>	<55A11112.8080502@gmail.com> <20150713113055.2ccf9bcd@noble>
In-Reply-To: <20150713113055.2ccf9bcd@noble>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 7/13/2015 09:30, NeilBrown wrote:
> On Sat, 11 Jul 2015 20:50:26 +0800 Kinglong Mee <kinglongmee@gmail.com>
> wrote:
> 
>> Switch using list_head for cache_head in cache_detail,
>> it is useful of remove an cache_head entry directly from cache_detail.
>>
>> v7, same as v6.
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  include/linux/sunrpc/cache.h |  4 +--
>>  net/sunrpc/cache.c           | 74 ++++++++++++++++++++++++--------------------
>>  2 files changed, 43 insertions(+), 35 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
>> index 04ee5a2..ecc0ff6 100644
>> --- a/include/linux/sunrpc/cache.h
>> +++ b/include/linux/sunrpc/cache.h
>> @@ -46,7 +46,7 @@
>>   * 
>>   */
>>  struct cache_head {
>> -	struct cache_head * next;
>> +	struct list_head	cache_list;
>>  	time_t		expiry_time;	/* After time time, don't use the data */
>>  	time_t		last_refresh;   /* If CACHE_PENDING, this is when upcall 
>>  					 * was sent, else this is when update was received
>> @@ -73,7 +73,7 @@ struct cache_detail_pipefs {
>>  struct cache_detail {
>>  	struct module *		owner;
>>  	int			hash_size;
>> -	struct cache_head **	hash_table;
>> +	struct list_head *	hash_table;
>>  	rwlock_t		hash_lock;
> 
> Given that these lists are chains in a hash table, it would make more
> sense to use hlist_head rather than list_head.  They are designed for
> exactly that purpose - and are smaller.
> 
> Actually, I'd really like to see hlist_bl_head used - so there was one
> bit-spin-lock per chain, and use RCU for protecting searches.
> However that would have to be left for later - no point delaying this
> patch set for some minor performance gains.
> 
> But as you need to change this, I think it would be best to change to
> hlist_head.

Got it.
I will update and test it.

thanks,
Kinglong Mee

> 
> By the way, I see lots of nice clean-ups in this series.  Thanks!
> 
> NeilBrown
