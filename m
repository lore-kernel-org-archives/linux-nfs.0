Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45498 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755682Ab3KLQJY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 11:09:24 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5281618A.1050604@RedHat.com>
Date: Tue, 12 Nov 2013 11:09:16 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <784A1C68-59DA-4248-AF91-BAF472CDD37E@oracle.com>
References: <1384037221-7224-1-git-send-email-steved@redhat.com> <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com> <52811CBB.3070204@RedHat.com> <E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com> <5281290B.6000201@RedHat.com> <E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com> <52814876.7080604@RedHat.com> <A59DDCD0-5622-4497-A93E-80493EDCED27@oracle.com> <5281618A.1050604@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 11, 2013, at 6:00 PM, Steve Dickson <SteveD@redhat.com> wrote:

> Hey,
> 
> On 11/11/13 16:47, Chuck Lever wrote:
>> 
>> On Nov 11, 2013, at 4:13 PM, Steve Dickson <SteveD@redhat.com> wrote:
>> 
>>> 
>>> 
>>> On 11/11/13 15:33, Chuck Lever wrote:
>>>>>> 
>>>>>> We have workarounds already that work on every kernel since 3.8.
>>>>>> 
>>>>> The one that logs 5 to 20 lines (depending on thins are setup or not)
>>>>> per mount? That does work in some environments but no all. ;-)
>>>> 
>>>> When does running rpc.gssd not work?
>>> Define "work"... ;-) Logging 20 error messages on every mount
>>> when the keytab does not exist is not working or not very well.... IMHO..
>> 
>> At first it was 5 warnings.  Then it was "10-15 errors".  Now it's 20 on every mount!
> Yeah... that happen there is no keytab...

Seems like a gssd bug to me.

> 
>> 
>> How many "-v" options do you specify on your rpc.gssd command line?  I normally run 
>> rpc.gssd with "-vv" or even "-vvv".  Leaving those options off makes it much 
>> quieter, and it's the default.  
> None... Also you if you have a keytab and the server is not known by the KDC, you
> get 5 "ERROR: No credentials found for connection to server XXXXX" 
> I'm not sure why there is 5... I have not investigated it... but I'm
> really hoping the kernel is not doing 5 upcalls as it appears...

I doubt the kernel is doing 5 upcalls.  Another gssd bug, perhaps?

> 
> 
>> Only crazy people crank up the verbosity of rpc.gssd.
> And developers... Does that make us crazy? 8-) 
> 
>> 
>> Is a mount failing in that case?
> No. The mount success after 15 secs.
> 
>> Too many error messages is a nit compared to "no longer mounts."  If gssd error 
>> messages are your only beef, then it seems like the solution is pretty obvious.
> Actually its putting rpc.gssd in the mount path of every NFS mount... The
> daemon is not as harden as a mountd. I'm concern about the stability in
> a lager deployment....

If gssd isn't stable, we have bigger problems than a 15 second delay.

> In the past, if admins want rpc.gssd in the mount path they had to configure it.
> Now we are silently adding, yet another, daemon to the mount path and if 
> rpc.gssd starts falling on its face, I think it will be difficult to debug,
> since the daemon is not expected to be there...

Our only real choice here is to fix gssd.  Anything else is punting the problem down the road.

> 
>> 
>>>> 
>>>>> Or am I missing one? Please tell me I am!!! :-) 
>>>> 
>>>> OK: You're missing one.
>>> Thank you... 
>>> 
>>>> 
>>>> Client configurations that have auth_rpcgss.ko loaded but do not run rpc.gssd are, quite simply, broken.  The gss upcall will not work in that configuration.  There is no reason to load auth_rpcgss.ko if user space does not have rpc.gssd enabled and running.
>>>> 
>>>> This has been a problem for a very long time, but use cases where the 15 second upcall timeout is encountered have until recently been infrequent, and only occur in situations where the mount options don't work anyway, so no one has bothered to address it.
>>>> 
>>>> This broken configuration is due to incorrect system initialization scripts.
>>> Which initialization scripts are you referring to?
>> 
>> The NFS initialization scripts.  What else deals with auth_rpcgss.ko and rpc.gssd?
> I just looked through all the systemd scripts and don't see any explicit
> modprobs... Back in the day yes, but today no... What am I missing or
> not understanding?

The next thing to try is reverting upstream kernel commit 71afa85e.

If what I said yesterday is correct (that loading auth_rpcgss.ko is worse than useless if rpc.gssd is not running) then the kernel should never autoload auth_rpcgss.ko.


> 
>> 
>>> 
>>>> 
>>>> If an administrator chooses not to run rpc.gssd, then auth_rpcgss.ko should not be loaded.  The kernel deals quite correctly when auth_rpcgss.ko is not loaded -- GSS flavors are simply not supported, and the kernel uses AUTH_SYS by default for everything.  (Right there is your magical administrative interface for controlling what security flavors are used and supported).
>>>> 
>>>> But the current init scripts load auth_rpcgss.ko unconditionally.  Thus any gss upcall will fail until rpc.gssd is started.
>>>> 
>>>> With upstream kernel commit 4edaa308 (and following) I added a use case that exposes the upcall timeout much more often.  It's a latent bug, but we now hit it during the first mount after every client reboot, so it is noticeable to anyone who leaves nfs-secure.service disabled.
>>>> 
>>>> Therefore the scenario we want to avoid is where auth_rpcgss.ko is loaded, but rpc.gssd is not running.  There are two obvious ways to avoid this scenario:
>>>> 
>>>> A.  If auth_rpcgss.ko is loaded unconditionally, make sure rpc.gssd is running unconditionally (and cull the warnings)
>>>> 
>>>> B.  If you do not want to run rpc.gssd, make sure auth_rpcgss.ko is not loaded
>>> Isn't the case that nfsd will also loads auth_rpcgss. So if server was started we
>>> would be right back to the 15 sec delay?
>> 
>> Only if NFSD wants to make GSS upcalls and rpc.gssd isn't running.  Is that ever the case?
> Well the reason I asked was I started the server and did a 
>  lsmod | grep rpc
> which showed
> 
> rpcsec_gss_krb5        31477  1 
> auth_rpcgss            59369  3 nfsd,rpcsec_gss_krb5
> sunrpc                280214  47 nfs,nfsd,rpcsec_gss_krb5,auth_rpcgss,lockd,nfsv
> 
> Now for me to do a rmmod auth_rpcgs, to test your theory, I had to do a 
> rmmod nfsd... Maybe that's just another bug on how things are depended 
> on each other 
> 
> BTW, when I did rmmod auth_rpcgs and did a mount... the mount still hung 
> logging the 
>    RPC: AUTH_GSS upcall timed out.                          
>    Please check user daemon is running. 
> messages... 

Those messages come from auth_rpcgss.  So, obviously, "rmmod auth_rpcgss" did nothing, probably because it was already pinned.


> 
>> 
>> The point is we currently have a very direct method of telling the kernel 
>> NFS components not to use GSS or make upcalls.  We should use it.
> Yes, I agree... 
> 
> steved.
> 
>> 
>> 
>>> 
>>> steved.
>>> 
>>>> 
>>>> Both of these workarounds are configuration changes, not code changes.  B. is accomplished simply by blacklisting auth_rpcgss.ko.
>>>> 
>>>> We could go a step further and remove the module alias added by upstream kernel commit 71afa85e to prevent the kernel from loading auth_rpcgss.ko automatically, and then make sure the nfs-secure.service script (and the server-side equivalent) loads auth_rpcgss.ko before starting rpc.gssd.
>>>> 
>>>> Since you are opposed to running rpc.gssd, blacklisting auth_rpcgss.ko is the easy choice.  Adding auth_rpcgss.ko to the module blacklist is no more difficult than setting a kernel module parameter or toggling nfs-secure.service.
>>>> 
>>>> However, IMO, in the long run Linux should be installed with rpc.gssd running unconditionally, or dynamically start-able by mount.nfs (like statd works today).  We cannot guess a priori whether a user or administrator will want NFS support for GSS flavors, just as we cannot guess a priori whether the user wants support for NFSv3.
>>>> 
>>>> Yet we always have NFSv3 support available.  Likewise, support for GSS should always be available, and there really is no good reason any more not to leave it running all the time.
>>>> 
>>>> As Trond points out, NFSv4 implementations are required to implement GSS security.
>>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




