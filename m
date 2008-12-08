From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Mon, 08 Dec 2008 17:55:40 -0500
Message-ID: <493DA5EC.5090805@RedHat.com>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net> <493D253C.2040809@RedHat.com> <2DC7493B-E0E5-43C8-8FD1-A9C0C5EFA821@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51484 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752885AbYLHW56 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2008 17:57:58 -0500
In-Reply-To: <2DC7493B-E0E5-43C8-8FD1-A9C0C5EFA821@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Dec 8, 2008, at Dec 8, 2008, 8:46 AM, Steve Dickson wrote:
>> Chuck Lever wrote:
>>> Hi Steve-
>>>
>>> Here's the next step.
>>>
>>> This small series of patches rewires probe_bothports() to support
>>> AF_INET6 addresses, now that the underlying functions can handle them.
>>>
>>> Since legacy code in other parts of the mount command still use
>>> probe_bothports() and the clnt_addr_t data type, I've added a new
>>> function call to do the IPv6 duties.  The old API still exists and
>>> continues to support only AF_INET, but under the covers it calls the
>>> new code.
>>>
>>> Again, for the time being, this is used only for the legacy binary
>>> mount(2) interface.  We will need this for umount later, and that is
>>> used to support both binary and text-based mounts.
>>>
>>> ---
>>>
>>> Chuck Lever (3):
>>>      mount command: AF_INET6 support for probe_bothports()
>>>      mount command: support AF_INET6 in probe_nfsport() and
>>> probe_mntport()
>>>      mount command: full support for AF_INET6 addresses in probe_port()
>>>
>> Question: in the clnt_addr_t typedef:
>>
>> typedef struct {
>>    char **hostname;
>>    struct sockaddr_in saddr;
>>    struct pmap pmap;
>> } clnt_addr_t;
>>
>> Why isn't saddr a struct sockaddr instead of a struct sockaddr_in?
> 
> Conventionally, "struct sockaddr" is supposed to be used only for
> pointers, not for declaring storage to store addresses.  sockaddr_in can
> be used for either declaring storage or for a pointer declaration.
Yes... one does pass pointers of struct sockaddr to the majority 
of the network system call such as bind().. but conventionally 
I've seen a lot of declare struct sockaddr as memory then typecasting 
that memory into a struct sockaddr_in pointer...

> 
> What is defined here is a "struct sockaddr_in", not a pointer.
Understood...

> 
> If we wanted to store a generic address rather than a pointer, the
> convention is to use struct sockaddr_storage, which is large enough to
> store an IPv4, IPv6 or even a Unix address.  But that would change the
> offsets of the following fields in clnt_addr_t, and that would break
> other legacy mount code.
> 
>> It seems at the beginning of each routine saddr is always being
>> typecast into a struct sockaddr pointer....
> 
> More likely it is:
> 
>   struct sockaddr *sap = (struct sockaddr *)&saddr;
> 
> Which is appropriate and normal.
More to the point, I see a number of

    struct sockaddr *nfs_saddr = (struct sockaddr *)&nfs_server->saddr;

at the top of routines in the patch set you recently posted. To me it
seems like it would make more sense if saddr would was a struct sockaddr
to start with instead of always doing those typecasts... but its truly
just a nit... 

steved.




