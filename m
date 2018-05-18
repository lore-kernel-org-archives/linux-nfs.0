Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:38101 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbeERVCq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 17:02:46 -0400
Received: by mail-vk0-f67.google.com with SMTP id u8-v6so5656456vku.5
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2018 14:02:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <EDBF0CF4-3E94-44EF-8541-9445409F0B9B@oracle.com>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
 <CAN-5tyGDGOqPKXKD+LQq8Ub3CUosmaaAq=ir3Gp7R3LKABwtEQ@mail.gmail.com>
 <DB8E23EF-80A4-48D0-B53C-AD2A4B0076E2@oracle.com> <CAN-5tyFs4nxAwVynpr=Q5d_t+N5s9sa=2+1mj4-pZ-m1Xe3ZRA@mail.gmail.com>
 <EDBF0CF4-3E94-44EF-8541-9445409F0B9B@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 18 May 2018 17:02:44 -0400
Message-ID: <CAN-5tyHH026MJgpX7B11xLa_THMJiikudx-Foo8ZNdcW6AKf-Q@mail.gmail.com>
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 18, 2018 at 4:56 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On May 18, 2018, at 4:11 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Fri, May 18, 2018 at 3:23 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>
>>>> On May 18, 2018, at 2:53 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>
>>>> Hi Chuck,
>>>>
>>>> I'm not convinced that "srchost=" is necessary. I believe that
>>>> everything that is needed is suppose to be encoded in the "target="
>>>> option.
>>>
>>> I don't believe target= has what we want. For NFSv4.0 callback:
>>>
>>>  A. The callback source principal needs to be the same as the client's
>>>     NFS server target principal.
>>
>> Correct and by specifying "nfs" and "*" I think that signals to the
>> gssd to pick the NFS server principal (which is what the client would
>> used as the target for the client to server authentication).
>>
>>>  B. The callback target principal needs to be the same as the client's
>>>     NFS server source principal.
>>>
>>> Today, for NFSv4.0 callbacks, the kernel passes to gssd:
>>>
>>>  target= it uses B for this
>>>
>>>  service= it always sets this to "nfs"
>>>
>>> And gssd "makes up" the hostname part of A using gethostname(3), which
>>> is bogus for multi-homed NFS servers.
>>
>> I agree that's bogus. Instead we should grab the domain from the
>> "target=" string.
>>
>>
>>> So my patch series does the following for NFSv4.0 callbacks:
>>>
>>> 1. It acquires the actual target principal the client used to establish
>>>   it's lease. This is A above.
>>>
>>> 2. Instead of always passing "nfs" as the service= value, it passes
>>>   the non-hostname part of A. That should be "nfs" but it doesn't
>>>   have to be.
>>
>> Ok so yes it has historically have always been "nfs" (even thought
>> it's only RECOMMENDED by the spec) and I don't think this is the case
>> to add complexity to change a well established behavior?
>>
>>> 3. Instead of letting gssd make up the hostname part of the source
>>>   principal, it passes the hostname part of A.
>>
>> I'm arguing that hostname part of A should have been a part of the "target="
>
> For a callback credential upcall:
>
>   target name= client's principal @ client's hostname
>   source name= server's principal @ server's hostname
>
> I don't see how gssd on a multi-homed server could derive "server's
> hostname" correctly from "client's hostname" in every case. As I
> explained below, the kernel retains the correct "server's hostname"
> string in clp->cl_cred even if the client should connect from another
> hostname within the lease expiry period.
>
> Example:
>
> Given a client manet that has
>
> - an interface named manet.domain
> - an interface named manet.other.domain
> - one key in its keytab: host/manet.domain@REALM
>
> And given a server klimt that has
>
> - an interface named klimt.domain
> - an interface named klimt.other.domain
> - a key in its keytab: nfs/klimt.domain@REALM
> - a key in its keytab: nfs/klimt.other.domain@REAM
>
> Now suppose the client manet mounts klimt.other with NFSv4.0 and
> sec=krb5. The client establishes a GSS context using:
>
>    source=host/manet.domain@REALM
>    target=nfs/klimt.other.domain@REALM
>
> and we want the server to establish a GSS context for the callback
> channel that looks like:
>
>    source=nfs/klimt.other.domain@REALM
>    target=host/manet.domain@REALM
>
> How does gssd construct the correct source principal given the
> target host/manet.domain@REALM ? Today it picks
> nfs/klimt.domain@REALM , which is incorrect.
>
> Further, if the client then connects via klimt.domain but continues
> to use the original GSS context and lease, how does gssd know it
> needs to use source=nfs/klimt.other.domain@REALM if it needs to
> re-establish the callback context for some reason?

I agree, if source and target mix "other.domain" with "domain" then
gssd can't do anything. We do need the srchost passed in. I was
confused by your original use- case where I assumed that such domain
mixing would not take place.

> The only way gssd can know these things for certain is if the
> kernel explicitly requests "nfs/klimt.other.domain@REALM" as the
> source principal for this GSS context. srchost= enables the
> kernel to request a specific hostname for the source principal.
>
> Currently our upcall does not specify a REALM for either principal,
> but that should be straightforward to add.
>
> I'm in favor of not having magic in gssd that figures this stuff
> out based on a heuristic, but rather I'd like the kernel ask for
> precisely what it needs every time.
>
>
>>> That should provide the correct source principal in the multi-home
>>> case, and it should be backwards-compatible with older gssd's.
>>>
>>>
>>> Now here's why it's not enough to use getsockname(3) on target=
>>> to predict the correct source hostname:
>>>
>>> If the client has established the lease when mounting from one
>>> particular hostname, and then mounts from another, it will have
>>> to continue managing the lease using the principal it has already
>>> established with the first hostname. NFSD knows what that is, and
>>> can tell gssd what it needs to be. gssd, using only getsockname(3),
>>> would probably pick something that is wrong.
>>>
>>>
>>>> I thought target just needed to correctly identify the domain for
>>>> which authentication is taking place.
>>>
>>> That's what srchost= does. We can call it something else if that
>>> helps.
>>>
>>>
>>>> Then I think more changes should
>>>> be in nfs-utils to make sure that we find credentials for that
>>>> particular domain instead of going by the gethostbyname() results.
>>>
>>> That's a patch to gssd that I didn't post. I will post that later if
>>> we all agree srchost= is OK.
>>>
>>> srchost= is optional. If it's not present in the upcall, gssd will
>>> continue to use the result of gethostname(3) to construct the source
>>> principal.
>>>
>>>
>>>> On Fri, May 18, 2018 at 11:39 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>> I've been experimenting with this series that modifies NFSD to
>>>>> discover and use the correct GSS service principal when constructing
>>>>> its NFSv4.0 callback channels. I'm interested in review of this
>>>>> approach. There are a couple of code comments marked with XXX that
>>>>> also need some attention.
>>>>>
>>>>> The rpc.gssd change mentioned in 1/4 is unremarkable and will be
>>>>> made available once there is consensus about the kernel changes
>>>>> in this series. No gssproxy changes are necessary.
>>>>>
>>>>> ---
>>>>>
>>>>> Chuck Lever (4):
>>>>>     sunrpc: Enable the kernel to specify the hostname part of service principals
>>>>>     sunrpc: Extract target name into svc_cred
>>>>>     nfsd: Use correct credential for NFSv4.0 callback with GSS
>>>>>     nfsd: Remove callback_cred
>>>>>
>>>>>
>>>>> fs/nfsd/nfs4callback.c               |   29 ++++----------
>>>>> fs/nfsd/nfs4state.c                  |   17 +++-----
>>>>> fs/nfsd/state.h                      |    2 -
>>>>> include/linux/sunrpc/svcauth.h       |    3 +
>>>>> net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
>>>>> net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 ++++++++++++++++++++++------------
>>>>> 6 files changed, 80 insertions(+), 61 deletions(-)
>>>>>
>>>>> --
>>>>> Chuck Lever
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> Chuck Lever
>
> --
> Chuck Lever
>
>
>
