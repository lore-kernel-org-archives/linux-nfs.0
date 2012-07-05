Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:51086 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950Ab2GEJqz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jul 2012 05:46:55 -0400
Received: by lbbgm6 with SMTP id gm6so12466310lbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jul 2012 02:46:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1341418670.2950.3.camel@lade.trondhjem.org>
References: <CAC+fKpJCN2GJvA71RW4j9GUW5rw+hAS1SgPUZzBwvNShd098Ag@mail.gmail.com>
	<34DE974E-597D-460F-B2F0-5A6DBE51593F@oracle.com>
	<CAC+fKpJtKcYXGS7LNBTjZwN_fDJN6K+6EoNa+acPHHY4hNCMxQ@mail.gmail.com>
	<CAC+fKpKeQN9g-xMhMUANEq=F-JuveXrSfDxDzVDOBLQE0yQbXg@mail.gmail.com>
	<1341418670.2950.3.camel@lade.trondhjem.org>
Date: Thu, 5 Jul 2012 10:46:54 +0100
Message-ID: <CAC+fKpLXrfhZMS1MA2zRG+r5UCkm1OE=Xrifb62nq-au+f8fnQ@mail.gmail.com>
Subject: Re: Fwd: RPC rpcinfo command PATCH
From: Leandro Meiners <lmeiners@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I was unaware of the rcpinfo option. I knew nmap does RPC, but it is
sometimes more comfortable to run it from rpcinfo than nmap.

Cheers,

On Wed, Jul 4, 2012 at 5:17 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2012-07-04 at 08:11 +0100, Leandro Meiners wrote:
>> Sorry, I just noticed I replied to Chuck but forgot to CC the list.
>>
>> Cheers,
>> Leandro
>>
>>
>> ---------- Forwarded message ----------
>> From: Leandro Meiners <lmeiners@gmail.com>
>> Date: Mon, Jul 2, 2012 at 3:52 PM
>> Subject: Re: RPC rpcinfo command PATCH
>> To: Chuck Lever <chuck.lever@oracle.com>
>>
>>
>> Hi,
>>
>> Guess I did it to follow the same convention as clnt_com_create(), but
>> for no other particular reason. Basically it was useful because I used
>> it to determine that the firewall was not filtering UDP connections to
>> the portmapper (111/udp) but was filtering connections to the TCP
>> portmapper (111/tcp). This allowed me to enumerate the RPC services
>> running on the host and determine that the firewall was not blocking
>> everything it should.
>
> 'rpcinfo -T udp hostname sunrpc' should suffice as a firewall probe.
> 'nmap' has similar functionality.
>
> Cheers
>   Trond
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>



-- 
Leandro Federico Meiners
