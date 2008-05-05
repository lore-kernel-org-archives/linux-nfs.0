From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: recent failover-by-IP changes
Date: Mon, 5 May 2008 10:46:48 -0400
Message-ID: <798F2369-07C5-4CBD-8D29-131314CCA3DA@oracle.com>
References: <1B257A25-2B59-448F-B11C-637B8688D883@oracle.com> <481B8EE4.8020409@gmail.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:26263 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755616AbYEEOr6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2008 10:47:58 -0400
In-Reply-To: <481B8EE4.8020409@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 2, 2008, at 6:00 PM, Wendy Cheng wrote:
> Chuck Lever wrote:
>> Hi Wendy-
>>
>> Looking at your recent lockd-failover-by-IP changes... I'd like to  
>> make sure I understand this logic before I merge it into my NLM  
>> IPv6 patch set.
>>
>> In fs/lockd/svcsubs.c:
>> > static int
>> > nlmsvc_match_ip(void *datap, struct nlm_host *host)
>> > {
>> > __be32 *server_addr = datap;
>> >
>> > return host->h_saddr.sin_addr.s_addr == *server_addr;
>>
>> h_saddr is the local host's source address, not the server address,  
>> and is used only on multi-interface systems. Is that what you  
>> wanted to compare, or did you mean ->h_addr?
>
> Yes, it is what we want (trying not to change the mainline logic if  
> all possible). Bruce did the merge and he did this *right*. Check  
> out how nlm_lookup_host() fills in the h_saddr (and how  
> nlmsvc_lookup_host passes in "ssin") before our changes. But I'll do  
> the testing over the weekend nevertheless - will report back if I  
> see problems.
>
> We'll let you worry about how to make ipv6 working in this  
> case :) .. (just joking .. will help if needed) ..
>
>> Does it make sense to use nlm_cmp_addr() here as is done in other  
>> places in lockd?
>
> It can - but would suggest leave it as today until your ipv6 patches  
> are ready (are they ready now ?).

Yes.  I plan to test basic functionality next week at Connectathon.

>> > }
>> >
>> > int
>> > nlmsvc_unlock_all_by_ip(__be32 server_addr)
>>
>> Should this be "struct in_addr server_addr" ? It would be even  
>> nicer if this were a "struct sockaddr *".
>
> Yes, it would be nice. But it would be even "nicer" if we let people  
> run this stuff before another round of revising.

Given that the IPv6 support needs to be finished soon (IPv6 support  
will be a purchasing requirement for US government later this year), I  
don't think we can wait.  The changes are not terribly invasive, and  
can be validated with IPv4 testing.

>> > /* get ipv4 address */
>> > if (sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
>> > return -EINVAL;
>> > server_ip = htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
>> >
>> > return nlmsvc_unlock_all_by_ip(server_ip);
>>
>> Why can't you use in4_pton() to convert your IP address?

> I think in4_pton was my original code (?) We changed it because of a  
> legitimate comment from a code review (but I forgot the details from  
> the top of my head at this moment). Will follow up after I check the  
> archives tomorrow.

Yes, I'd like to see the reviewer's comment.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
