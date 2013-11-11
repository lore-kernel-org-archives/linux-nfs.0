Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:20720 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab3KKUdV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 15:33:21 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5281290B.6000201@RedHat.com>
Date: Mon, 11 Nov 2013 15:33:14 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
References: <1384037221-7224-1-git-send-email-steved@redhat.com> <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com> <52811CBB.3070204@RedHat.com> <E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com> <5281290B.6000201@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 11, 2013, at 1:59 PM, Steve Dickson <SteveD@redhat.com> wrote:

> On 11/11/13 13:30, Chuck Lever wrote:
>> 
>> On Nov 11, 2013, at 1:06 PM, Steve Dickson <SteveD@redhat.com> wrote:
>> 
>>> 
>>> 
>>> On 09/11/13 18:12, Myklebust, Trond wrote:
>>>> One alternative to the above scheme, which I believe that I’ve 
>>>> suggested before, is to have a permanent entry in rpc_pipefs 
>>>> that rpc.gssd can open and that the kernel can use to detect 
>>>> that it is running. If we make it /var/lib/nfs/rpc_pipefs/gssd/clnt00/gssd, 
>>>> then AFAICS we don’t need to change nfs-utils at all, since all newer 
>>>> versions of rpc.gssd will try to open for read anything of the form 
>>>> /var/lib/nfs/rpc_pipefs/*/clntXX/gssd...
>>> 
>>> After further review I am going going have to disagree with you on this.
>>> Since all the context is cached on the initial mount the kernel
>>> should be using the call_usermodehelper() to call up to rpc.gssd 
>>> to get the context, which means we could put this upcall noise 
>>> to bed... forever! :-)
>> 
>> Ask Al Viro for his comments on whether the kernel should start 
>> gssd (either a daemon or a script).  Hint: wear your kevlar underpants.
> I was thinking gssd would become a the gssd-cmd command... Al does not
> like the call_usermodehelper() interface?

He doesn't have a problem with call_usermodehelper() in general.  However, the kernel cannot guarantee security if it has to run a fixed command line.  Go ask him to explain.


> 
>> 
>> Have you tried Trond's approach yet?
> Looking into it... But nothing is trivial in that code... 
> 
>> 
>>> I realize this is not going happen overnight, so I would still
>>> like to propose my  nfs4_secure_mounts bool patch as bridge
>>> to the new call_usermodehelper()  since its the cleanest 
>>> solution so far... 
>>> 
>>> Thoughts?
>> 
>> We have workarounds already that work on every kernel since 3.8.
>> 
> The one that logs 5 to 20 lines (depending on thins are setup or not)
> per mount? That does work in some environments but no all. ;-)

When does running rpc.gssd not work?

> Or am I missing one? Please tell me I am!!! :-) 

OK: You're missing one.

Client configurations that have auth_rpcgss.ko loaded but do not run rpc.gssd are, quite simply, broken.  The gss upcall will not work in that configuration.  There is no reason to load auth_rpcgss.ko if user space does not have rpc.gssd enabled and running.

This has been a problem for a very long time, but use cases where the 15 second upcall timeout is encountered have until recently been infrequent, and only occur in situations where the mount options don't work anyway, so no one has bothered to address it.

This broken configuration is due to incorrect system initialization scripts.

If an administrator chooses not to run rpc.gssd, then auth_rpcgss.ko should not be loaded.  The kernel deals quite correctly when auth_rpcgss.ko is not loaded -- GSS flavors are simply not supported, and the kernel uses AUTH_SYS by default for everything.  (Right there is your magical administrative interface for controlling what security flavors are used and supported).

But the current init scripts load auth_rpcgss.ko unconditionally.  Thus any gss upcall will fail until rpc.gssd is started.

With upstream kernel commit 4edaa308 (and following) I added a use case that exposes the upcall timeout much more often.  It's a latent bug, but we now hit it during the first mount after every client reboot, so it is noticeable to anyone who leaves nfs-secure.service disabled.

Therefore the scenario we want to avoid is where auth_rpcgss.ko is loaded, but rpc.gssd is not running.  There are two obvious ways to avoid this scenario:

  A.  If auth_rpcgss.ko is loaded unconditionally, make sure rpc.gssd is running unconditionally (and cull the warnings)

  B.  If you do not want to run rpc.gssd, make sure auth_rpcgss.ko is not loaded

Both of these workarounds are configuration changes, not code changes.  B. is accomplished simply by blacklisting auth_rpcgss.ko.

We could go a step further and remove the module alias added by upstream kernel commit 71afa85e to prevent the kernel from loading auth_rpcgss.ko automatically, and then make sure the nfs-secure.service script (and the server-side equivalent) loads auth_rpcgss.ko before starting rpc.gssd.

Since you are opposed to running rpc.gssd, blacklisting auth_rpcgss.ko is the easy choice.  Adding auth_rpcgss.ko to the module blacklist is no more difficult than setting a kernel module parameter or toggling nfs-secure.service.

However, IMO, in the long run Linux should be installed with rpc.gssd running unconditionally, or dynamically start-able by mount.nfs (like statd works today).  We cannot guess a priori whether a user or administrator will want NFS support for GSS flavors, just as we cannot guess a priori whether the user wants support for NFSv3.

Yet we always have NFSv3 support available.  Likewise, support for GSS should always be available, and there really is no good reason any more not to leave it running all the time.

As Trond points out, NFSv4 implementations are required to implement GSS security.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




