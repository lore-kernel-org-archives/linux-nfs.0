From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Mon, 8 Dec 2008 18:34:21 -0500
Message-ID: <C1353488-3689-4EFE-9DB8-3B31C408B101@oracle.com>
References: <20081202175403.5206.91389.stgit@ingres.1015granger.net> <493D253C.2040809@RedHat.com> <2DC7493B-E0E5-43C8-8FD1-A9C0C5EFA821@oracle.com> <493DA5EC.5090805@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:40038 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729AbYLHXeo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Dec 2008 18:34:44 -0500
In-Reply-To: <493DA5EC.5090805-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 8, 2008, at Dec 8, 2008, 5:55 PM, Steve Dickson wrote:
> Chuck Lever wrote:
>> On Dec 8, 2008, at Dec 8, 2008, 8:46 AM, Steve Dickson wrote:
>>> Chuck Lever wrote:
>>>> Hi Steve-
>>>>
>>>> Here's the next step.
>>>>
>>>> This small series of patches rewires probe_bothports() to support
>>>> AF_INET6 addresses, now that the underlying functions can handle  
>>>> them.
>>>>
>>>> Since legacy code in other parts of the mount command still use
>>>> probe_bothports() and the clnt_addr_t data type, I've added a new
>>>> function call to do the IPv6 duties.  The old API still exists and
>>>> continues to support only AF_INET, but under the covers it calls  
>>>> the
>>>> new code.
>>>>
>>>> Again, for the time being, this is used only for the legacy binary
>>>> mount(2) interface.  We will need this for umount later, and that  
>>>> is
>>>> used to support both binary and text-based mounts.
>>>>
>>>> ---
>>>>
>>>> Chuck Lever (3):
>>>>     mount command: AF_INET6 support for probe_bothports()
>>>>     mount command: support AF_INET6 in probe_nfsport() and
>>>> probe_mntport()
>>>>     mount command: full support for AF_INET6 addresses in  
>>>> probe_port()
>>>>
>>> Question: in the clnt_addr_t typedef:
>>>
>>> typedef struct {
>>>   char **hostname;
>>>   struct sockaddr_in saddr;
>>>   struct pmap pmap;
>>> } clnt_addr_t;
>>>
>>> Why isn't saddr a struct sockaddr instead of a struct sockaddr_in?
>>
>> Conventionally, "struct sockaddr" is supposed to be used only for
>> pointers, not for declaring storage to store addresses.   
>> sockaddr_in can
>> be used for either declaring storage or for a pointer declaration.
> Yes... one does pass pointers of struct sockaddr to the majority
> of the network system call such as bind().. but conventionally
> I've seen a lot of declare struct sockaddr as memory then typecasting
> that memory into a struct sockaddr_in pointer...
>
>>
>> What is defined here is a "struct sockaddr_in", not a pointer.
> Understood...
>
>>
>> If we wanted to store a generic address rather than a pointer, the
>> convention is to use struct sockaddr_storage, which is large enough  
>> to
>> store an IPv4, IPv6 or even a Unix address.  But that would change  
>> the
>> offsets of the following fields in clnt_addr_t, and that would break
>> other legacy mount code.
>>
>>> It seems at the beginning of each routine saddr is always being
>>> typecast into a struct sockaddr pointer....
>>
>> More likely it is:
>>
>>  struct sockaddr *sap = (struct sockaddr *)&saddr;
>>
>> Which is appropriate and normal.
> More to the point, I see a number of
>
>    struct sockaddr *nfs_saddr = (struct sockaddr *)&nfs_server->saddr;
>
> at the top of routines in the patch set you recently posted. To me it
> seems like it would make more sense if saddr would was a struct  
> sockaddr
> to start with instead of always doing those typecasts... but its truly
> just a nit...

The point of all this is that I wanted to leave probe_bothports()  
legacy callers alone.  I looked into this kind of change, but it would  
have required some extensive modification of legacy code in nfsmount.c  
that is better left alone.

So I created a new API for an IPv6-enabled probe_bothports().  The old  
probe_bothports() is for legacy callers (right now, just  
nfs_call_mount() in nfsmount.c).  It converts the incoming clnt_addr_t  
into pointers to each of its fields.  The new call,  
nfs_probe_bothports(), is for new callers which may want to pass in a  
"struct sockaddr *" that might point to either an IPv4 or IPv6 address.

Both APIs share the same underlying code.  The underlying code uses  
"struct sockaddr *", thus the old legacy interface has to convert from  
clnt_addr_t to "struct sockaddr *".

To me, changing clnt_addr_t would be penny-wise but pound-foolish.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
