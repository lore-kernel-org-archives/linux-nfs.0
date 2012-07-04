Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:60234 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104Ab2GDHLj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jul 2012 03:11:39 -0400
Received: by lbbgm6 with SMTP id gm6so10733700lbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jul 2012 00:11:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC+fKpJtKcYXGS7LNBTjZwN_fDJN6K+6EoNa+acPHHY4hNCMxQ@mail.gmail.com>
References: <CAC+fKpJCN2GJvA71RW4j9GUW5rw+hAS1SgPUZzBwvNShd098Ag@mail.gmail.com>
	<34DE974E-597D-460F-B2F0-5A6DBE51593F@oracle.com>
	<CAC+fKpJtKcYXGS7LNBTjZwN_fDJN6K+6EoNa+acPHHY4hNCMxQ@mail.gmail.com>
Date: Wed, 4 Jul 2012 08:11:38 +0100
Message-ID: <CAC+fKpKeQN9g-xMhMUANEq=F-JuveXrSfDxDzVDOBLQE0yQbXg@mail.gmail.com>
Subject: Fwd: RPC rpcinfo command PATCH
From: Leandro Meiners <lmeiners@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, I just noticed I replied to Chuck but forgot to CC the list.

Cheers,
Leandro


---------- Forwarded message ----------
From: Leandro Meiners <lmeiners@gmail.com>
Date: Mon, Jul 2, 2012 at 3:52 PM
Subject: Re: RPC rpcinfo command PATCH
To: Chuck Lever <chuck.lever@oracle.com>


Hi,

Guess I did it to follow the same convention as clnt_com_create(), but
for no other particular reason. Basically it was useful because I used
it to determine that the firewall was not filtering UDP connections to
the portmapper (111/udp) but was filtering connections to the TCP
portmapper (111/tcp). This allowed me to enumerate the RPC services
running on the host and determine that the firewall was not blocking
everything it should.

Cheers,

Leandro.-

On Mon, Jul 2, 2012 at 3:43 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Jul 2, 2012, at 10:32 AM, Leandro Meiners wrote:
>
>> Hi,
>>
>> I have written a patch for the rpcinfo command that allows querying
>> the port-mapper via UDP instead of TCP. I added a new parameter
>> (upper-case P) for this functionality. It was helpful for me during a
>> penetration test and I thought it might be worth adding to the
>> project.
>> Signed-off-by: Leandro Meiners <lmeiners@gmail.com>
>
> Instead of passing a string ("tcp") to pmapdump(), why not use IPPROTO_TCP and IPPROTO_UDP ?
>
> Can you say a little bit more about how UDP helped you?



--
Leandro Federico Meiners


-- 
Leandro Federico Meiners
