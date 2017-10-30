Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46784 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751582AbdJ3O6v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Oct 2017 10:58:51 -0400
Subject: Re: [PATCH] nlm_shutdown_hosts_net() cleanup
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jeff Layton <jlayton@poochiereds.net>
References: <1d1a25d8-a34b-5175-bb6a-9549041c11f4@virtuozzo.com>
 <20171030144943.GG14098@fieldses.org>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <7beefaa4-c6a5-69c6-f17b-10fa230e2e50@virtuozzo.com>
Date: Mon, 30 Oct 2017 17:58:47 +0300
MIME-Version: 1.0
In-Reply-To: <20171030144943.GG14098@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-10-30 17:49, J. Bruce Fields wrote:
> On Mon, Oct 30, 2017 at 04:47:58PM +0300, Vasily Averin wrote:
>> nlm_complain_hosts() walk through nlm_server_hosts hlist that should be
>> protected by nlm_host_mutex.
> 
> I haven't looked at the NLM locking in ages.  Do we know who else might
> actually be accessing this list concurrently?

Thank you for the question, I'll investigate it.

>> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
>> ---
>>  fs/lockd/host.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>> index d716c99..089c1d7 100644
>> --- a/fs/lockd/host.c
>> +++ b/fs/lockd/host.c
>> @@ -617,9 +617,8 @@ nlm_shutdown_hosts_net(struct net *net)
>>  
>>  	/* Then, perform a garbage collection pass */
>>  	nlm_gc_hosts(net);
>> -	mutex_unlock(&nlm_host_mutex);
>> -
>>  	nlm_complain_hosts(net);
>> +	mutex_unlock(&nlm_host_mutex);
>>  }
>>  
>>  /*
>> -- 
>> 2.7.4
> 
