Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:40038 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751546AbeDKPJU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Apr 2018 11:09:20 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH] clnt_com_create: Restore backwards compatibility with the
 legacy glibc code.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <fea21187-3895-5e5c-7bce-99f59a2c730f@RedHat.com>
Date: Wed, 11 Apr 2018 09:09:01 -0600
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1E69668A-5C3A-49AF-8478-3EF78DB16716@oracle.com>
References: <20180409172825.169380-1-steved@redhat.com>
 <A536D92D-14FF-41B1-9943-A838FF8FCBC1@oracle.com>
 <53cdf0c9-e236-b0e0-bd88-0da487488f6b@RedHat.com>
 <9DA13A82-6D1C-47F3-8E16-6267DE195EAB@oracle.com>
 <5977917e-d9f8-4378-e5be-e83a5e3a3392@RedHat.com>
 <B692EA3A-3B03-48D2-AFD2-941601DF403F@oracle.com>
 <84f65189-360a-11b9-2f80-9fb2296e8dde@RedHat.com>
 <CDDE2827-C3FA-4892-A777-61588B5A9004@oracle.com>
 <fea21187-3895-5e5c-7bce-99f59a2c730f@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 11, 2018, at 8:10 AM, Steve Dickson <SteveD@RedHat.com> wrote:
> 
> 
> 
> On 04/10/2018 06:43 PM, Chuck Lever wrote:
>> 
>> 
>>> On Apr 10, 2018, at 9:21 AM, Steve Dickson <SteveD@RedHat.com> wrote:
>>> 
>>>>> Upstream not 
>>>>> so much... Who really uses raw upstream bits in a stable
>>>>> environment... understood... But this brings me to my point.
>>>>> 
>>>>> What problem is being fixed by changing an 20+ year API? 
>>>> 
>>>> The problem is legacy clients and servers are squatting on
>>>> ports that are assigned to other network services. These
>>>> patches mitigate that problem. There is more to be done.
>>> Any examples of these... The only one I know is rpcbind
>>> which can be fixed in another ways.... 
>> 
>> Yes, as you and I discussed with Trond, statd can squat
>> on a reserved port for it's downcall client to lockd. The
>> fix Trond prefers is for this downcall service to use an
>> AF_LOCAL socket instead.
> But it is careful not to used any ports in /etc/services

There are two sides to this reserved port coin.

- The "heads" side is that long-lived clients shouldn't squat
on a port that is allocated to another service. This includes
IANA-allocated ports below and above 1024.

- The "tails" side is that avoiding IANA-allocated ports below
1024 reduces the already-small pool of reserved ports that can
be selected.

The "heads" part can be addressed by making bindresvport(3)
act more like the current statd downcall client. Even if many
clients are short-lived, we don't have any control over how
long clients live, and even a short-lived client can block
reliable start-up of well-known services temporarily, leading
to annoying non-determinant behavior. Thus making this API
work better is still important. (This is what Guillem was
trying to address in January).

Moreover we have to ensure that bindresvport(3) doesn't fail
to find a port just because the only ports that happen to be
available are IANA-allocated. Thus we should address the
"tails" part of this too, and make libtirpc uses this scarce
shared resource economically. (This is the part Guillem's
patch didn't address, as many reviewers pointed out).

There are some applications that use reserved ports today that
don't need to:

 - Any listener, for example, does not need an arbitrarily-
   assigned reserved port. By using __binddynport, the
   dynamically assigned port avoids all IANA-allocated ports
   (even IANA-allocated ports above 1024).

 - Many client applications, even if they are short-lived, do
   not require a privileged source port. And to avoid an IANA-
   allocated port, they should likewise use __binddynport.
   That really should be the default behavior of the CLNT
   interfaces, because bindresvport(3) is available for the
   few clients that need a privileged source port.

 - As you pointed out, applications that use TCP will leave a
   port in TIME_WAIT, which takes that source port out of the
   pool for 120 seconds. That's painful if the port is reserved.

Fixing these applications helps to address "tails". By changing
the libtirpc client APIs, we address the second and third points
for a fleet of RPC clients.

I don't have much empathy for YP:
- The use of NIS/YP is deprecated
- The use of a privileged source port is security theater
- The API behavior YP relies on is not documented
- There already exist patches available to make YP do this right

In this particular case, although backwards compatibility is
important, IMO reliable system operation is a higher priority.

--
Chuck Lever



