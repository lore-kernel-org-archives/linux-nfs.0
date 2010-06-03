From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Bug#583435: rpcbind: Insecure handling of state files
Date: Thu, 03 Jun 2010 17:11:10 -0400
Message-ID: <4C081A6E.5020406@oracle.com>
References: <20100527170908.GA14298@gaara.hadrons.org> <20100601120907.GA23357@gaara.hadrons.org> <20100602112520.GA22639@master.debian.org> <4C080B96.1030707@oracle.com> <20100603202743.GA6643@gaara.hadrons.org> <4C0811B9.3060809@oracle.com> <20100603210707.GA7377@gaara.hadrons.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Cc: linux-nfs@vger.kernel.org, 583435@bugs.debian.org
To: Guillem Jover <guillem@debian.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43399 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655Ab0FCVLg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jun 2010 17:11:36 -0400
In-Reply-To: <20100603210707.GA7377-v62vTE6/wQGgM1MOaoewpti2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/ 3/10 05:07 PM, Guillem Jover wrote:
> On Thu, 2010-06-03 at 16:34:01 -0400, Chuck Lever wrote:
>> On 06/ 3/10 04:27 PM, Guillem Jover wrote:
>>> The second problem is that those files get created by the daemon on
>>> shutdown, and they *do* follow symlinks. So a user can drop two
>>> symlinks
>>> there while the daemon is running and overwrite any file on the fil=
e
>>> system on shutdown.
>>>
>>> The fix would consist of passing to configure something like
>>> =E2=80=9C--with-statedir=3D/var/cache/rpcbind=E2=80=9D, and make su=
re the daemon creates
>>> such directory if missing on exit in src/warmstart.c:write_struct()=
,
>>> which it does not seem to be doing currently.
>>>
>>> In addition it would be wise to notify upstream to change the defau=
lt
>>> statedir to something else than /tmp.
>>
>> Agree changing the upstream default is a good idea.
>>
>> Generally, that kind of directory is created as part of installation
>> (like, by rpm --install) rather than by the daemon itself.
>
> At least for /var/run I think it's common for systems to mount it
> as tmpfs, so the directories might not be there on boot. But those ca=
n
> always be created by the init script (or equivalent), it might be a
> problem if run from inetd though.

Sure, that makes sense.  Having the daemon create the directory also=20
means there are fewer ways distributors can get this wrong.

>>>> Would /var/run (or a subdirectory of it) be a better choice than /=
tmp ?
>>>
>>> /var/run might not be preserved across reboots, but regardless of t=
hat I
>>> think /var/cache is a better fit, it's internal state, but it's use=
d
>>> to speed up start up time, and can be removed w/o ill effects.
>>
>> No, it's not intended to speed start up.
>>
>> The cache files aren't really supposed to be retained over a reboot.
>> After a system restart, all of the RPC services will restart and
>> register themselves again.  If just rpcbind restarts, all that
>> registration state is lost, so that's the point of saving it in a
>> file.
>
> Ah, yeah that makes more sense! More so given the configure option, I
> should have written "AFAIS" or something like that. :)
>
>> I don't have a preference wrt /var/run or /var/cache.
>
> So given that this is actually run time state, /var/run seems more
> appropriate, indeed.
