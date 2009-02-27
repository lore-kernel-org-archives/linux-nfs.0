From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/7] lockd: Use AF_INET6 listener only when IPv6 support is built in
Date: Fri, 27 Feb 2009 13:55:00 -0500
Message-ID: <EB5C1941-4A2F-439F-AD3E-FBCA6096F68B@oracle.com>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net> <20090130201041.22301.60941.stgit@ingres.1015granger.net> <1233347546.9741.31.camel@heimdal.trondhjem.org> <130964B3-CDE1-440F-B0E0-33620036E239@oracle.com> <1233350290.9741.42.camel@heimdal.trondhjem.org> <F0ED35C3-3E01-42E2-BE71-1C1273C1B495@oracle.com> <1233352740.9741.64.camel@heimdal.trondhjem.org> <59D3726F-FB24-4624-891F-55877239B011@oracle.com> <1233355782.9741.95.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:20960 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390AbZB0SzT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2009 13:55:19 -0500
In-Reply-To: <1233355782.9741.95.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 30, 2009, at Jan 30, 2009, 5:49 PM, Trond Myklebust wrote:
> On Fri, 2009-01-30 at 17:27 -0500, Chuck Lever wrote:
>> On Jan 30, 2009, at Jan 30, 2009, 4:59 PM, Trond Myklebust wrote:
>>> On Fri, 2009-01-30 at 16:30 -0500, Chuck Lever wrote:
>>>>> If so, it sounds to me as if
>>>>> we _must_ have lockd and the callback server set up IPv6 sockets
>>>>> whenever they are available.
>>>>
>>>> That's what the code does now.  The problem is exactly what does
>>>> "whenever they are available" mean?
>>>>
>>>> Are you suggesting we shouldn't ever fall back to AF_INET?  (I'm OK
>>>> with that answer, but would like a discussion).  This means that  
>>>> if I
>>>> try an IPv4 mount on a system built with an IPv6 module, but the
>>>> module is unloadable, all mounts (even IPv4) fail outright.
>>>> Apparently a lot of folks blacklist their IPv6 modules.
>>>
>>> I'd rather advocate that we try to use AF_INET6 at service set up
>>> time,
>>> then fall back on AF_INET only if the former isn't available. I'm  
>>> not
>>> sure that we should allow the user to change the service once it has
>>> been set up, since it would appear that would force you to close the
>>> current socket, and then reopen a new one of a different type.  
>>> That's
>>> both racy and constitutes an interruption of service.
>>
>> The listeners will pin the ipv6 module while they exist.  At some
>> point, if the listeners are stopped, the ipv6 module can be
>> blacklisted.  Subsequent NFS mounts will fail at that point, but a
>> reboot (or perhaps unloading the lockd and nfs modules) will make it
>> right again.
>>
>> Seems like a good argument for separate listeners.
>
> My point was that you might lose the IPv4 port, however that's moot  
> when
> you can set up an IPV6_V6ONLY socket. Note that this appears to be the
> technique favoured by ssh.

I've been thinking more about this, and having separate listeners has  
some appeal.  At least as far as I've thought about it, separate  
listeners simplify the cases where the kernel RPC services have to  
adapt at run-time to what kind of networking is available in the kernel.

inet6 netids do not support mapped IPv4, as far as I can tell, so if  
we have an AF_INET listener and an IPV6ONLY AF_INET6 listener, they  
will get separate traffic streams.  It means we avoid entirely having  
to compare AF_INET addresses to mapped IPv4 AF_INET6 addresses during  
NFSv4 and NLM callbacks.  And, we can always start an AF_INET  
listener, and start AF_INET6 listeners only if IPv6 support is  
available in the kernel.

This looks more like TI-RPC's IPv6 support.

> That said, I think I'd prefer the single socket solution that we have
> now. It would certainly make life easier for migration events, and
> possibly pnfs. In neither of these cases do you know at mount time  
> what
> kind of callback service you will need later, so setting up an IPv4- 
> only
> service might turn out wrong.

I'm not familiar enough with the issues around migration to comment.   
Do you have an example of a migration event that might be problematic  
with separate listeners?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
