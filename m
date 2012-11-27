Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:55006 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757643Ab2K0Hyt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2012 02:54:49 -0500
Message-ID: <50B471B6.2010407@parallels.com>
Date: Tue, 27 Nov 2012 11:54:30 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSd state: nfs4_lock_state() and nfs4_lock_state()
References: <50A622AE.3080809@parallels.com> <20121116165845.GA32183@fieldses.org> <50A9F03B.1010909@parallels.com> <20121119124618.GA30084@fieldses.org> <50AF5E7F.2010006@parallels.com> <20121126223639.GC18186@fieldses.org>
In-Reply-To: <20121126223639.GC18186@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

27.11.2012 02:36, bfields@fieldses.org пишет:
> On Fri, Nov 23, 2012 at 03:31:11PM +0400, Stanislav Kinsbursky wrote:
>> 19.11.2012 16:46, bfields@fieldses.org пишет:
>>> On Mon, Nov 19, 2012 at 12:39:23PM +0400, Stanislav Kinsbursky wrote:
>>>> 16.11.2012 20:58, bfields@fieldses.org пишет:
>>>>>
>>>>> A patch follows: note it's a two-line patch, with 20 lines of changelog
>>>>> showing that I looked at what state might be shared by other threads and
>>>>> explaining why I think this is safe.
>>>>>
>>>>
>>>> Acked-by: Stanislav Kinsburskiy <skinsbursky@parallels.com>
>>>>
>>>>> I think that's what we need to do: little patches that remove it from
>>>>> one or another part of the code with careful explanation of why it
>>>>> works.
>>>>>
>>>>
>>>> Yes, thanks. I'll also try to simplify nfsd_open() by little patches.
>>>> In general it looks like client_mutex protect two different things:
>>>> open owner state (which is containerised already, actually) and
>>>> files access.
>>>> So, probably, this client mutex have to be converted into two:
>>>> per-net one, which protects open owner state, and static one, which
>>>> protects files operations.
>>>> What do you think about it?
>>>
>>> That sounds right.
>>>
>>
>> Looked into the code, and few more questions raised.
>> So, currently, this mutex protects different NFS4 state structures and VFS file operations (like open, read, write, etc.).
>> I would like this mutex to be converted into per-net one. Since NFS4
>> state structures are per-net already (with my previous patch set),
>> the only thing left is VFS operations.
>> But do we really need to protect them somehow from concurrent access?
>> I.e. do we have some RPCs, which does more that one file manipulation, but this manipulations sequence have to be "atomic" in NFSd terms?
>
> Probably not, but open is the most likely problem, as it does several
> things which are not all atomic from the point of view of the vfs.  The
> mutex can't prevent races between an nfs client and a local user, but it
> can at least prevent races between nfs clients.
>

Ok then.
You said, that you are going to optimize open a bit?
I think client_mutex containerization can be delayed for a while.
Thnaks.

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
