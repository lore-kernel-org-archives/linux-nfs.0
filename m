Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752644Ab3KKVM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Nov 2013 16:12:28 -0500
Message-ID: <52814876.7080604@RedHat.com>
Date: Mon, 11 Nov 2013 16:13:26 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
References: <1384037221-7224-1-git-send-email-steved@redhat.com> <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com> <52811CBB.3070204@RedHat.com> <E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com> <5281290B.6000201@RedHat.com> <E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
In-Reply-To: <E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/11/13 15:33, Chuck Lever wrote:
>>>
>>> We have workarounds already that work on every kernel since 3.8.
>>>
>> The one that logs 5 to 20 lines (depending on thins are setup or not)
>> per mount? That does work in some environments but no all. ;-)
> 
> When does running rpc.gssd not work?
Define "work"... ;-) Logging 20 error messages on every mount
when the keytab does not exist is not working or not very well.... IMHO..
> 
>> Or am I missing one? Please tell me I am!!! :-) 
> 
> OK: You're missing one.
Thank you... 

> 
> Client configurations that have auth_rpcgss.ko loaded but do not run rpc.gssd are, quite simply, broken.  The gss upcall will not work in that configuration.  There is no reason to load auth_rpcgss.ko if user space does not have rpc.gssd enabled and running.
> 
> This has been a problem for a very long time, but use cases where the 15 second upcall timeout is encountered have until recently been infrequent, and only occur in situations where the mount options don't work anyway, so no one has bothered to address it.
> 
> This broken configuration is due to incorrect system initialization scripts.
Which initialization scripts are you referring to?

> 
> If an administrator chooses not to run rpc.gssd, then auth_rpcgss.ko should not be loaded.  The kernel deals quite correctly when auth_rpcgss.ko is not loaded -- GSS flavors are simply not supported, and the kernel uses AUTH_SYS by default for everything.  (Right there is your magical administrative interface for controlling what security flavors are used and supported).
> 
> But the current init scripts load auth_rpcgss.ko unconditionally.  Thus any gss upcall will fail until rpc.gssd is started.
> 
> With upstream kernel commit 4edaa308 (and following) I added a use case that exposes the upcall timeout much more often.  It's a latent bug, but we now hit it during the first mount after every client reboot, so it is noticeable to anyone who leaves nfs-secure.service disabled.
> 
> Therefore the scenario we want to avoid is where auth_rpcgss.ko is loaded, but rpc.gssd is not running.  There are two obvious ways to avoid this scenario:
> 
>   A.  If auth_rpcgss.ko is loaded unconditionally, make sure rpc.gssd is running unconditionally (and cull the warnings)
> 
>   B.  If you do not want to run rpc.gssd, make sure auth_rpcgss.ko is not loaded
Isn't the case that nfsd will also loads auth_rpcgss. So if server was started we
would be right back to the 15 sec delay?

steved.

> 
> Both of these workarounds are configuration changes, not code changes.  B. is accomplished simply by blacklisting auth_rpcgss.ko.
> 
> We could go a step further and remove the module alias added by upstream kernel commit 71afa85e to prevent the kernel from loading auth_rpcgss.ko automatically, and then make sure the nfs-secure.service script (and the server-side equivalent) loads auth_rpcgss.ko before starting rpc.gssd.
> 
> Since you are opposed to running rpc.gssd, blacklisting auth_rpcgss.ko is the easy choice.  Adding auth_rpcgss.ko to the module blacklist is no more difficult than setting a kernel module parameter or toggling nfs-secure.service.
> 
> However, IMO, in the long run Linux should be installed with rpc.gssd running unconditionally, or dynamically start-able by mount.nfs (like statd works today).  We cannot guess a priori whether a user or administrator will want NFS support for GSS flavors, just as we cannot guess a priori whether the user wants support for NFSv3.
> 
> Yet we always have NFSv3 support available.  Likewise, support for GSS should always be available, and there really is no good reason any more not to leave it running all the time.
> 
> As Trond points out, NFSv4 implementations are required to implement GSS security.
> 
