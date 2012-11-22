Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:55376 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556Ab2KVTDt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Nov 2012 14:03:49 -0500
Message-ID: <50ADDCB4.2050603@parallels.com>
Date: Thu, 22 Nov 2012 12:05:08 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>, <linux-nfs@vger.kernel.org>,
        <devel@openvz.org>, <Trond.Myklebust@netapp.com>,
        <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH v2 00/15] NFSd state containerization
References: <20121114152018.4708.63125.stgit@localhost.localdomain> <20121114220036.GD539@fieldses.org> <20121115133408.23db9ebb@corrin.poochiereds.net> <20121121204408.GA23097@fieldses.org>
In-Reply-To: <20121121204408.GA23097@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

22.11.2012 00:44, J. Bruce Fields пишет:
> On Thu, Nov 15, 2012 at 01:34:08PM -0500, Jeff Layton wrote:
>> On Wed, 14 Nov 2012 17:00:36 -0500
>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>
>>> On Wed, Nov 14, 2012 at 06:20:59PM +0300, Stanislav Kinsbursky wrote:
>>>> This patch set is my first attempt to containerize NFSv4 state - i.e. make it
>>>> works in networks namespace context.
>>>> I admit, that some of this new code could be partially rewritten during future
>>>> NFSd containerization.
>>>> But the overall idea look more or less correct to me.
>>>> So, the main things here are:
>>>> 1) making nfs4_client network namespace aware.
>>>> 2) Allocating all hashes (except file_hashtbl and reclaim_str_hashtbl) per
>>>> network namespace context on NFSd start (not init) and destroying on NFSd
>>>> state shutdown.
>>>> 3) Allocating of reclaim_str_hashtbl on legacy tracker start and destroying on
>>>> legacy tracker stop.
>>>> 4) Moving of client_lru and close_lru lists to per-net data.
>>>> 5) Making lundromat network namespace aware.
>>>
>>> These look OK and pass my tests.  Jeff, do the revised recovery bits
>>> look OK?
>>>
>>> Have you done any testing?
>>>
>>> It'd be interesting, for example, to know if there are any pynfs that
>>> fail against the server in a non-init network namespace, but pass
>>> normally.
>>>
>>> --b.
>>>
>>
>> I looked over the patches and they look sane to me. I move that they go
>> into your -next branch to soak for a bit.
>
> Stanislav, actually, I'm unclear, since you labeled these "RFC": do you
> consider these patches ready?
>

Yes, I consider them ready.
I added the "RFC" mark, because I'm not completely sure, this this code wont' be
partially rewritten in future.

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
