Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751960AbdGCQvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Jul 2017 12:51:12 -0400
Subject: Re: [PATCH nfs-utils v2 03/12] mount: present AF_VSOCK addresses
To: Stefan Hajnoczi <stefanha@redhat.com>,
        Felix Janda <felix.janda@posteo.de>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-4-stefanha@redhat.com>
 <dc1bd4ee-621f-d988-2914-61b1c144f146@RedHat.com>
 <20170703090048.GC22607@stefanha-x1.localdomain>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <2730896d-f9d6-352d-e829-d672d8735bd3@RedHat.com>
Date: Mon, 3 Jul 2017 12:51:07 -0400
MIME-Version: 1.0
In-Reply-To: <20170703090048.GC22607@stefanha-x1.localdomain>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/03/2017 05:00 AM, Stefan Hajnoczi wrote:
> On Fri, Jun 30, 2017 at 10:40:49AM -0400, Steve Dickson wrote:
>> On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
>>> Format vsock hosts as "vsock:<cid>" so the addresses can be easily
>>> distinguished from IPv4 and IPv6 addresses.
>>>
>>> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
>>> ---
>>>  utils/mount/network.c | 8 ++++++++
>>>  1 file changed, 8 insertions(+)
>>>
>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>> index 281e935..b5dcaa5 100644
>>> --- a/utils/mount/network.c
>>> +++ b/utils/mount/network.c
>>> @@ -45,6 +45,8 @@
>>>  #include <rpc/pmap_prot.h>
>>>  #include <rpc/pmap_clnt.h>
>>>  
>>> +#include <linux/vm_sockets.h>
>> In the previous patch you had this surrounded by #ifdef AF_VSOCK
>> I'm not keen on sprinkling a bunch ifdefs around since 
>> I think it makes the code harder to read. So my question 
>> is why is the ifdef need in the previous patch and
>> not needed in this patch and are they needed in the
>> previous patch?
> 
> The lack of #ifdef is my mistake.
Fair enough.

> 
> My impression of nfs-utils is that the code is written to work in a
> variety of configurations and still support older kernels.  So I am
> wrapping AF_VSOCK logic with an #ifdef.
> 
> AF_VSOCK has been in Linux since v3.9 in commit
> d021c344051af91f42c5ba9fdedc176740cbd238 ("VSOCK: Introduce VM
> Sockets").
> 
> I'd love to eliminate the #ifdefs, but would it be acceptable to simply
> drop them?
Very good question... 

CC-ing Felix... Would not ifdef-ing AF_VSOCK break compiling 
with the musl libc? 

Are there other implementations out there that would cause breakage?
I'm pretty sure nfs-utils is only used in Linux environments, right?

steved.

> 
