Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:52076 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752865AbeDJWnn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2018 18:43:43 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH] clnt_com_create: Restore backwards compatibility with the
 legacy glibc code.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <84f65189-360a-11b9-2f80-9fb2296e8dde@RedHat.com>
Date: Tue, 10 Apr 2018 16:43:30 -0600
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CDDE2827-C3FA-4892-A777-61588B5A9004@oracle.com>
References: <20180409172825.169380-1-steved@redhat.com>
 <A536D92D-14FF-41B1-9943-A838FF8FCBC1@oracle.com>
 <53cdf0c9-e236-b0e0-bd88-0da487488f6b@RedHat.com>
 <9DA13A82-6D1C-47F3-8E16-6267DE195EAB@oracle.com>
 <5977917e-d9f8-4378-e5be-e83a5e3a3392@RedHat.com>
 <B692EA3A-3B03-48D2-AFD2-941601DF403F@oracle.com>
 <84f65189-360a-11b9-2f80-9fb2296e8dde@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 10, 2018, at 9:21 AM, Steve Dickson <SteveD@RedHat.com> wrote:
> 
> On 04/09/2018 05:11 PM, Chuck Lever wrote:
>> 
>>> On Apr 9, 2018, at 2:04 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>>> 
>>> On 04/09/2018 02:40 PM, Chuck Lever wrote:
>>>> I'm going to firmly object on this one, unless you have
>>>> a clearly documented breakage that requires the legacy
>>>> server API to use bindresvport(3).
>>> Here is what the man page says "If the socket is not bound to a 
>>> local TCP port, then this routine binds it to an arbitrary port."
>>> 
>>> The point being it also does not talk about creating a 
>>> listening connection either... Changing the (undocumented)
>>> API like this can cause nothing but problems... IMHO...
>> 
>> Please show me one specific breakage that will result
>> in removing bindresvport from svc_com_create. Just one,
>> and I promise I will crawl back into my hole.
> The patch also restores the listen() which is
> something I can see  a server apps depending on. 

I'm not clear there's a problem there. Did you find
that svc_tli_create() was not already doing a listen?


>>> Basically, not making this change will cause a fork with 
>>> all the major distros since it very import for them to be 
>>> backward compatible esp in enterprise worlds.
>> 
>> That sounds like an overstatement. Who claims they won't
>> take libtirpc with an unprivileged svc_com_create? I would
>> really like to understand why.
> I'm just assuming most distros want to be backward compatible
> and not break legacy apps... Maybe I'm wrong...

Of course they don't want to break legacy apps. I just don't
see any backwards compatibility requirement here: servers
never need a reserved port, they need either a specific port,
or any port.

Therefore the libtirpc server-side APIs should not use
bindresvport.


>>> Upstream not 
>>> so much... Who really uses raw upstream bits in a stable
>>> environment... understood... But this brings me to my point.
>>> 
>>> What problem is being fixed by changing an 20+ year API? 
>> 
>> The problem is legacy clients and servers are squatting on
>> ports that are assigned to other network services. These
>> patches mitigate that problem. There is more to be done.
> Any examples of these... The only one I know is rpcbind
> which can be fixed in another ways.... 

Yes, as you and I discussed with Trond, statd can squat
on a reserved port for it's downcall client to lockd. The
fix Trond prefers is for this downcall service to use an
AF_LOCAL socket instead.

We should also update bindresvport(3) to do more to avoid
selecting ports that appear in /etc/services. This will
cover user apps that use the RPC library API.


--
Chuck Lever



