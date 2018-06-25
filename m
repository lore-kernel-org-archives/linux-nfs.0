Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60868 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753049AbeFYPv7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Jun 2018 11:51:59 -0400
Subject: Re: [PATCH] Stop mounts hanging in upcalls to rpc.gssd.
To: Trond Myklebust <trondmy@gmail.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180618172542.45519-1-steved@redhat.com>
 <0e1aa697-e0ee-d150-3720-3cdda2d2f700@RedHat.com>
 <80bc2e24a8f4168ba144ee4757817dc749a441d8.camel@gmail.com>
 <17b2fd3e-c9f4-6804-363a-1d49ca990940@RedHat.com>
 <B3A9BE44-BA84-49E6-A72E-A3EBABCFE093@gmail.com>
 <2f89b1e5-7e3d-c584-9f09-78b6f3e8a6f4@RedHat.com>
 <CAABAsM7m6FgOSdC2Nzm-+gsZQcCGBt2HBgw3Yp6vuFbrFV_6gw@mail.gmail.com>
 <26557818-3e4f-684b-c4a2-5fc63959930c@RedHat.com>
 <CAABAsM5Y=N7tG8CnVn8f=U6a4MU4EXYCC8e2MkyM6=-mxXg0Wg@mail.gmail.com>
 <919983d5-5e20-887d-eac7-822fd801106a@RedHat.com>
 <8EFFA012-4DF5-4B94-AB9F-DCCEDD646D02@gmail.com>
 <05786ef7-5382-5a6b-09e8-514668c3c812@RedHat.com>
 <B8735945-084F-4112-AEA6-EB3E758B6CE7@oracle.com>
 <1843936cc56ae782dd4e96fd3b3a2a40476c78f0.camel@gmail.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <eddaa5b5-95dc-5876-45df-c3b343d5e92b@RedHat.com>
Date: Mon, 25 Jun 2018 11:51:58 -0400
MIME-Version: 1.0
In-Reply-To: <1843936cc56ae782dd4e96fd3b3a2a40476c78f0.camel@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/25/2018 11:38 AM, Trond Myklebust wrote:
> On Mon, 2018-06-25 at 11:10 -0400, Chuck Lever wrote:
>>> On Jun 25, 2018, at 9:54 AM, Steve Dickson <SteveD@redhat.com>
>>> wrote:
>>>
>>> Hello,
>>>
>>> This was a private email Trond and I were having
>>> about adding a timeout to upcalls to the rpc.gssd
>>> so the kernel will not hang, forever, when
>>> rpc.gssd goes south.
>>>
>>> On 06/24/2018 07:52 PM, Trond Myklebust wrote:
>>>>
>>>>
>>>>> On Jun 24, 2018, at 19:26, Steve Dickson <SteveD@RedHat.com
>>>>> <mailto:SteveD@RedHat.com>> wrote:
>>>>>
>>>>>
>>>>>
>>>>> On 06/24/2018 06:54 PM, Trond Myklebust wrote:
>>>>>> On Sun, 24 Jun 2018 at 17:16, Steve Dickson <SteveD@redhat.co
>>>>>> m <mailto:SteveD@redhat.com>> wrote:
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> On 06/24/2018 03:24 PM, Trond Myklebust wrote:
>>>>>>>> On Sun, 24 Jun 2018 at 14:55, Steve Dickson <SteveD@redha
>>>>>>>> t.com <mailto:SteveD@redhat.com>> wrote:
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> On 06/24/2018 02:35 PM, Trond Myklebust wrote:
>>>>>>>>>> I’m talking about the racy behaviour we used to have
>>>>>>>>>> at startup when the rpc.gssd client was slow to
>>>>>>>>>> initialise, which caused the NFS client to time out
>>>>>>>>>> and then renegotiate the security flavour. We added
>>>>>>>>>> the gssd_running() variable in order to avoid that
>>>>>>>>>> problem by having gssd register itself when it starts
>>>>>>>>>> up.
>>>>>>>>>
>>>>>>>>> I think we have taken care of the slow start up with
>>>>>>>>> Olga's work
>>>>>>>>> making rpc.gssd multi thread... An new thread is create
>>>>>>>>> for every
>>>>>>>>> upcall (which actually caused the bug in gssproxy).
>>>>>>>>>
>>>>>>>>> As I remember it.. we added gssd_running() because if
>>>>>>>>> rpc.gssd
>>>>>>>>> was not running all mounts would hang when we change
>>>>>>>>> the
>>>>>>>>> SECINFO to use krb5i... I could be wrong on that.
>>>>>>>>>
>>>>>>>>
>>>>>>>> They were not hanging. They were timing out, but it took
>>>>>>>> too long.
>>>>>>>
>>>>>>> Where did the timeout come from? Once the upcall was in the
>>>>>>> for (;;) loop in gss_cred_init() the only thing that would
>>>>>>> break that loop is a signal... did the RPC layer send a
>>>>>>> signal?
>>>>>>>
>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> IOW: what I’m worried about is unwanted automatic
>>>>>>>>>> security re-negotiation during 'mount', and that
>>>>>>>>>> people end up with sec=sys when they would normally
>>>>>>>>>> expect strong security.
>>>>>>>>>
>>>>>>>>> I tested this... When the sec is not specified on the
>>>>>>>>> mount, the
>>>>>>>>> mount will roll back to a sys sec. But when the sec is
>>>>>>>>> specified
>>>>>>>>> (aka sec=krb5), the mount will fail.
>>>>>>>>
>>>>>>>> ...and that's the problem: the "mount will roll back to
>>>>>>>> sys sec"
>>>>>>>> issue. If we pass the gssd_running() test, then we should
>>>>>>>> not be
>>>>>>>> rolling back to auth_sys.
>>>>>>>
>>>>>>> But if the mount is a non secure mount (aka -o sec=krb5 is
>>>>>>> not specified)
>>>>>>> why shouldn't we roll back to auth_sys?
>>>>>>
>>>>>> Because we want _predictable_ behaviour, not behaviour that
>>>>>> is subject
>>>>>> to randomness. If I have configured rpc.gssd, then I want the
>>>>>> result
>>>>>> of the security negotiation to depend _only_ on whether or
>>>>>> not the
>>>>>> server also supports gssd.
>>>>>
>>>>> I think the problem is this... You don't configure rpc.gssd to
>>>>> come up.
>>>>> If /etc/krb5.conf exists then rpc.gssd comes up... auto-
>>>>> majestically
>>>>> Which turns all NFS mounts into secure mounts whether you
>>>>> wanted
>>>>> or not.. Due to the SECINFO default.
>>>>>
>>>>> So the predictable behavior is, in a kerberos configured env,
>>>>> when
>>>>> secure mounts are *not* specified, secure mount will not by
>>>>> tried.
>>>>>
>>>>> But that is not the case... Due to to the SECINFO default and
>>>>> the fact
>>>>> rpc.gssd exists... a secure SECINFO (via an upcall) will be
>>>>> tried.
>>>>>
>>>>> Now in the same environment, and a secure mount is tried... it
>>>>> will
>>>>> fail if the server and client are not married via kerberos... 
>>>>>
>>>>> Again, in the same environment, kerberos is configured and the
>>>>> client
>>>>> and server not married via the KDC and rpc.gssd is off in the
>>>>> woods
>>>>> due to some kerberos issue.. A non secured mount should not
>>>>> hang forever. 
>>>>> It should time out and use a auth_sys flavor. no?
>>>>
>>>> If rpc.gssd does not come up, then nothing is going to be
>>>> listening or writing on the rpc_pipefs pseudo files, and so
>>>> gssd_running() returns ‘false’, we return ‘EACCES’ on all upcalls
>>>> and all is hunky dory. This is the case today with or without any
>>>> further kernel changes.
>>>>
>>>> If rpc.gssd crashes and all the rpc_pipefs connections are
>>>> closed, then we call gss_pipe_release(), which causes all pending
>>>> gss messages to exit with the error EPIPE.
>>>
>>> Right... In those two cases, a crash or not coming up, work just
>>> fine.
>>> Its the case when rpc.gssd does come up but hangs in the libkrb5
>>> code
>>> or the gssproxy code... Adding a timeout handles that case.
>>>
>>>>
>>>>>
>>>>>> con
>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> Concerning Simo’s comment, the answer is that we
>>>>>>>>>> don’t support renegotiating security on the fly in
>>>>>>>>>> the kernel, and if the user specifies a hard mount,
>>>>>>>>>> then the required kernel behaviour if rpc.gssd dies
>>>>>>>>>> is to wait+retry forever for recovery.
>>>>>>>>>
>>>>>>>>> I agree there should not be "renegotiating security on
>>>>>>>>> the fly" when
>>>>>>>>> the security is specified the mount should fail, not
>>>>>>>>> hang... which
>>>>>>>>> happens today.
>>>>>>>>>
>>>>>>>>> When a sec is not specified, I think the mount should
>>>>>>>>> succeed when
>>>>>>>>> rpc.gssd is off in the wood, as a sys sec mount.
>>>>>>>>>
>>>>>>>>> But currently there is no "wait+retry". There is just a
>>>>>>>>> wait... no retry.
>>>>>>>>> This patch does introduce a retry... but not forever.
>>>>>>>>>
>>>>>>>>> But I think we both agree that rpc.gssd should not hang
>>>>>>>>> mounts
>>>>>>>>> forever when a sec is not specified... right?
>>>>>>>>
>>>>>>>> If rpc.gssd is up and running, and is connected to
>>>>>>>> rpc_pipefs, then we
>>>>>>>> should not hang. If rpc.gssd is up and running, but is
>>>>>>>> just being
>>>>>>>> slow, then the mount should hang until it gets a
>>>>>>>> response.
>>>>>>>
>>>>>>> But if rpc.gssd does hang... it hangs forever... There is
>>>>>>> not timeout
>>>>>>> in the kernel, and I thinking there should be, esp for non
>>>>>>> secure mounts.
>>>>>>>
>>>>>>
>>>>>> I don't understand. Is this by design or is it a bug?
>>>>>
>>>>> A bug in the userland space... The flux capacitor breaks and
>>>>> everything hangs... :-) 
>>>>>
>>>>>>
>>>>>> If it is by design, then what's the reason for that design?
>>>>>> If it's a
>>>>>> bug, then why are we talking about changing the kernel
>>>>>> instead of
>>>>>> fixing the problem in gssd?
>>>>>
>>>>> Its fixing the kernel not to hang on buggy userland (aka
>>>>> kerberos) apps
>>>>> when when those apps are not even required
>>>>
>>>> No, I don’t accept that argument. rpc.gssd is a dedicated program
>>>> that has exactly one purpose: to supply the kernel with GSS
>>>> sessions on demand because the kernel cannot do so itself. If it
>>>> hangs, then the kernel cannot make progress, and so the services
>>>> which depend on GSS will hang too.
>>>
>>> Fine... when the -o sec=krb5 is specified all mounts needed that
>>> service
>>> should hang (when rpc.gssd hangs)... I agree with that... But
>>>
>>> The mounts that don't specify a sec should not get hung up
>>> in a service it is not asking for... IMHO... which is the case
>>> today.
>>
>> That's the operational issue, but gssd is code we have 100% control
>> over. This is not arbitrary user space code. I have less sympathy
>> with the "kernel should work around user bugs" argument in this case.
> 
> Precisely.
Hell... I say anything I need to say... ;-) You know that! 

> 
>>>> If you want to put a policy around timeouts, then killing
>>>> rpc.gssd will do just as well (see above), will work with legacy
>>>> kernels, and allows you to keep the policy entirely in userland.
>>>> IOW: Add a watchdog timer that kills rpc.gssd if it hangs and
>>>> fails to reset the timer. You can even put that timer inside
>>>> rpc.gssd itself (add a call to setitimer() and add a signal
>>>> handler for SIGALARM that just kills the program).
>>>
>>> With this approach there is no history... Meaning when the 
>>> SIGALARM pops, the thread will not know if it or is not 
>>> making process... With timeouts there is history because 
>>> there has been timeouts and retries... 
> 
> ...and POLICY, which we do our very very best to keep out of the
> kernel. The problem here is that as soon as we add yet another timeout,
> there is always someone somewhere who wants to tweak the timeout
> policy.
I'll have you know... I scientifically pick that timeout value! 8-)
 
> 
> Now for some things, it is hard to avoid putting the policy in the
> kernel (e.g. attribute cache timeout control). With other things, like
> this, we have a choice of implementing the policy in userland, where it
> is easy to add tweaks, and then putting really dumb controls in the
> kernel (i.e. is someone listening on the rpc_pipefs pseudofiles or
> should I report an error).
> We already have those dumb controls in the kernel. The bit we haven't
> implemented is the tweak policy in userland.
So are you saying if the timeout value in the kernel from
userland, you are good with doing the timeout in the kernel?

steved.

> 
> 
>>> How about this... When the timeout occurs and the -o sec was
>>> not specified, the mount will still fail instead of becoming a 
>>> auth_sys mount. This would tell mount there is a problem
>>> and have it do the appropriate thing, whatever that is.
>>>
>>> Basically have the kernel says "Houston we have a problem"
>>> then let Houston go fix it... :-)
>>
>> Philosophical agreement that a problem should be reported whenever
>> the kernel expects a quick reply and does not get one. Without that
>> it is difficult to address operational problems in gssd (either
>> local configuration issues, network failures, or real bugs).
> 
