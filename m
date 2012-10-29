Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33180 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759480Ab2J2PoV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 11:44:21 -0400
MIME-Version: 1.0
In-Reply-To: <20121029132931.GC16391@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-15-git-send-email-levinsasha928@gmail.com> <20121029132931.GC16391@Krystal>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 29 Oct 2012 11:43:59 -0400
Message-ID: <CA+1xoqfRGhPaBEVh228O5_295bWh8FmcyLSOwq8VE5Dm7i3JHg@mail.gmail.com>
Subject: Re: [PATCH v7 15/16] openvswitch: use new hashtable implementation
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org,
        mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Mathieu,

On Mon, Oct 29, 2012 at 9:29 AM, Mathieu Desnoyers
<mathieu.desnoyers@efficios.com> wrote:
> * Sasha Levin (levinsasha928@gmail.com) wrote:
> [...]
>> -static struct hlist_head *hash_bucket(struct net *net, const char *name)
>> -{
>> -     unsigned int hash = jhash(name, strlen(name), (unsigned long) net);
>> -     return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
>> -}
>> -
>>  /**
>>   *   ovs_vport_locate - find a port that has already been created
>>   *
>> @@ -84,13 +76,12 @@ static struct hlist_head *hash_bucket(struct net *net, const char *name)
>>   */
>>  struct vport *ovs_vport_locate(struct net *net, const char *name)
>>  {
>> -     struct hlist_head *bucket = hash_bucket(net, name);
>>       struct vport *vport;
>>       struct hlist_node *node;
>> +     int key = full_name_hash(name, strlen(name));
>>
>> -     hlist_for_each_entry_rcu(vport, node, bucket, hash_node)
>> -             if (!strcmp(name, vport->ops->get_name(vport)) &&
>> -                 net_eq(ovs_dp_get_net(vport->dp), net))
>> +     hash_for_each_possible_rcu(dev_table, vport, node, hash_node, key)
>
> Is applying hash_32() on top of full_name_hash() needed and expected ?

Since this was pointed out in several of the patches, I'll answer it
just once here.

I've intentionally "allowed" double hashing with hash_32 to keep the
code simple.

hash_32() is pretty simple and gcc optimizes it to be almost nothing,
so doing that costs us a multiplication and a shift. On the other
hand, we benefit from keeping our code simple - how would we avoid
doing this double hash? adding a different hashtable function for
strings? or a new function for already hashed keys? I think we benefit
a lot from having to mul/shr instead of adding extra lines of code
here.


Thanks,
Sasha
