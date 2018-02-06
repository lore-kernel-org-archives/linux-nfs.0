Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40000 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752536AbeBFQhI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Feb 2018 11:37:08 -0500
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180205163647.15822-1-steved@redhat.com>
 <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com>
 <6bd33601-2c59-3d19-ece2-878b885c2940@RedHat.com>
 <C44A49E5-FEA5-482F-B945-BD967841F2FF@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <0f9b020a-4c65-4b3b-42b2-81f8f9ee0941@RedHat.com>
Date: Tue, 6 Feb 2018 11:37:07 -0500
MIME-Version: 1.0
In-Reply-To: <C44A49E5-FEA5-482F-B945-BD967841F2FF@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/05/2018 02:47 PM, Chuck Lever wrote:
> Hi Steve-
> 
>> On Feb 5, 2018, at 2:21 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>>
>>
>>
>> On 02/05/2018 12:02 PM, Chuck Lever wrote:
>>> Heya Steve-
>>>
>>>> On Feb 5, 2018, at 11:36 AM, Steve Dickson <steved@redhat.com> wrote:
>>>>
>>>> Over the weekend I did some experimenting with
>>>> the remote call code in rpcbind. The code does 
>>>> functionally work but is very antiquated when
>>>> it comes to the latest NFS versions. 
>>>>
>>>> Since only UDP sockets are used to do remote calls
>>>> using the documented interfaces pmap_rmtcall() and callrpc()
>>>> calls to NFS will fail (actual times out) since UDP is no 
>>>> longer supported. 
>>>>
>>>> The undocumented interface rpc_call() can be used to 
>>>> call into NFS since the protocol can specified, which 
>>>> also means the PMAPPROC_CALLIT protocol is not used.
>>>>
>>>> It turns out privilege port are not needed to make
>>>> remote calls, at least with my testing.
>>>
>>> It's not quite clear what you are claiming here, but
>>> I'm guessing that what you demonstrated is that the
>>> CALLIT _listener_ does not have to be privileged?
>> Right... 
>>>
>>> I claim that is true for all RPC listeners.
>> It could be true..
> 
> "privileged port" always means a source port, never a
> listener. There is no extra privilege given to a listener
> port that is below 1024.
> 
> svc_tli_create is simply wrong to use bindresvport.
> 
> 
>>>> I'm thinking 
>>>> the only reason privilege ports were being uses was 
>>>> a side effect of create_rmtcall_fd() calling 
>>>> svc_tli_create() with an unbound socket.
>>>
>>> Privileged listener ports are being created because
>>> svc_tli_create is using bindresvport when the passed
>>> in socket is not already bound.
>> Right... So handing svc_tli_create a bound socket will
>> cause the bindresvport not to happen.
> 
> True, and your patch corrects the behavior of rpcbind.
> 
> But I argue that is a workaround: svc_tli_create is
> still doing the wrong thing for any other RPC server
> that does not hand in a pre-bound socket. Fix it there
> and all RPC servers that use libtirpc are fixed.
> 
> 
>>> svc_tli_create should use bind instead, and it needs
>>> to choose a port higher than 49151.Actual it does when a t_bind structure is passed in. 
>> But more to the point, I thought about changing 
>> svc_tli_create but that would effect all the callers
>> of the routine which I didn't think was a good idea 
>> for code that is basically not used.
> 
> I'm not sure what you mean by "code that is basically
> not used."
> 
> svc_tli_create is the bottom of the RPC stack. It is the
> libtirpc API that is used every time an RPC server starts
> a listener. mountd and statd call svc_tli_create
> directly for example, from support/nfs/svc_create.c.
> 
> Thus this is the right place to fix it for all RPC server
> applications.
Actually I believe those application get their ports from /etc/rpc 
via the getrpcbyname() and then hands svc_tli_create a
bound socket which the reason bindresvport is not done.

Side Note: /etc/rpc will be staying in glibc since it is
"backed by the NSS framework"


> 
> 
>> Also, now that libtirpc is the only Linux RPC implementation
>> (the RPC code has been removed from glibc) I'm a bit
>> sensitive to changing functionality unless its a 
>> clear bug or security issue. 
> 
> This is a clear bug.
Lets do this... Please open up a upstream bz that justifies
why the bindresvport was removed from svc_tli_create().

If we break some legacy app I would like something to
point to explaining why the change was made 
  
> 
> - The library should not be allowed to choose ports that
> interfere with well-known services.
> 
> - The library should choose service ports based on well-
> established standards, such as the IANA service names to
> port numbers standard.
> 
> 
>>> https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml
>> Hmm... I have been conveniently ignoring Thorsten's blacklist patch.
>> Maybe we should take another look at that.
>>
>>>
>>>
>>>> So the following patch simply binds the socket
>>>> before calling svc_tli_create() which means a
>>>> non-privilege port will be reserved for remote
>>>> calls. 
>>>>
>>>> I'm thinking this is the simplest way to
>>>> not pollute the privilege port space. 
>>>
>>> This is going in the right direction, but the problem
>>> needs to be addressed in svc_tli_create, not in each
>>> application that calls svc_tli_create.
>>>
>>> This is the same issue that Guillem Jover was trying to
>>> address by making bindresvport skip well-known ports.
>>>
>>> In other words: this code in src/svc_generic.c is wrong:
>> It could be... but the API allows for the bindresvport (or any bind) 
>> to not happen... So changing how it is called I think is 
>> appropriate... Plus its been working this way for a long to so 
>> I'm very resistant to change functionality basically for no reason. 
>>
>> But I do think we should look into bindresvport using a black list
>> since it is already established in SuSE
> 
> IMO a bindresvport blacklist is absolutely the wrong approach.
> We have standards organizations that have explained exactly how
> this needs to work, and we want it to work without installing
> extra files or giving admins more knobs that they really don't
> need.
> 
> This is exactly the problem with distros applying patches
> without upstream review. SuSE fixed this and let their fix sit
> for years without any public bug report or review. IMO SuSE
> should be prepared to take this hit, it should not constrain
> upstream to choose a non-optimal long-term solution. I don't
> see any compelling reason in this particular case that we need
> to be constrained.
> 
> Fixing svc_tli_create to use ports higher than 49151 should be
> completely compatible with any reasonable blacklist, and it
> MUST be compatible with /etc/services, which is based on the
> IANA publication (no well-known fixed ports above 49151).
> 
Let me look into this... 

steved.
