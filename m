Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:22111 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754316Ab0IOQFq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 12:05:46 -0400
Message-ID: <4C90EECB.9050103@parallels.com>
Date: Wed, 15 Sep 2010 20:05:31 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
References: <4C90BADB.10700@parallels.com> <4C90E6D2.3030008@panasas.com>
In-Reply-To: <4C90E6D2.3030008@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/15/2010 07:31 PM, Boaz Harrosh wrote:
> On 09/15/2010 02:23 PM, Pavel Emelyanov wrote:
>> Hello everyone!
>>
>> I would like to prepare the sunrpc layer for working in a containerized
>> environments. The ultimate goal is to make both nfs client and server
>> work in containers. Hopefully you won't object :)
>>
>> Not to look like an idle talker I've prepared this set which makes the
>> /proc/net/rpc appear in net namespaces and made the ip_map_cache be per-net.
>>
>> I do not have any plans about when this patches appear at Linus tree and
>> thus do not know which git tree to hack on. That said I prepared the patches
>> against the net-next tree (I have some custom netns debugging code in it
>> and don't want to port it around in vain).
>>
>> Looking forward to your feedback.
>>
> 
> We are very curios people and would like to know more.

Sure.

> What does it mean to work in containers? Why is it better for
> the client why is it better for the server? who and how to enjoy
> this benefits. Does it have any effects on the operation of nfs/nfsd?
> What problem does it solve?

That's an old question actually. What does it mean, why is it better, who
and how to enjoy etc. were answered years ago. Do you want me to google these
articles for you?

If I misunderstood your question, please rephrase.

Thanks
Pavel

> Thanks
> Boaz
> 
>> Thanks,
>> Pavel
> 

