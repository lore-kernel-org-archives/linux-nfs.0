From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Bug#583435: rpcbind: Insecure handling of state files
Date: Thu, 03 Jun 2010 16:34:01 -0400
Message-ID: <4C0811B9.3060809@oracle.com>
References: <20100527170908.GA14298@gaara.hadrons.org> <20100601120907.GA23357@gaara.hadrons.org> <20100602112520.GA22639@master.debian.org> <4C080B96.1030707@oracle.com> <20100603202743.GA6643@gaara.hadrons.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Cc: linux-nfs@vger.kernel.org, 583435@bugs.debian.org
To: Guillem Jover <guillem@debian.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:29679 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424Ab0FCUey (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jun 2010 16:34:54 -0400
In-Reply-To: <20100603202743.GA6643-v62vTE6/wQGgM1MOaoewpti2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/ 3/10 04:27 PM, Guillem Jover wrote:
> Hi!
>
> On Thu, 2010-06-03 at 16:07:50 -0400, Chuck Lever wrote:
>> On 06/ 2/10 07:25 AM, An=C3=ADbal Monsalve Salazar wrote:
>>> On Tue, Jun 01, 2010 at 02:09:07PM +0200, Guillem Jover wrote:
>>>> On Thu, 2010-05-27 at 19:09:08 +0200, Guillem Jover wrote:
>>>>> Package: rpcbind
>>>>> Version: 0.2.0-4
>>>>> Severity: serious
>>>>> Tags: security
>>>>
>>>>> The rpcbind daemon, which runs as root, uses /tmp/portmap.xdr and
>>>>> /tmp/rpcbind.xdr for doing warm starts as what seems to be a way =
to
>>>>> preserve state between invokations. It parses (through libtirpc) =
and
>>>>> removes them on start. It creates them before exiting.
>>>>>
>>>>> So first off, *any* user can craft those two files before the dae=
mon
>>>>> has started for the first time, which the daemon will parse. This
>>>>> might be ok, depending on the checks done on parse, I'd still be =
very
>>>>> wary of letting a user be able to craft such files at will.
>>>>
>>>> It seems to be doing no checks whatsoever. A simple test I perform=
ed at
>>>> the time of filing this report, but didn't seem to have any obviou=
s
>>>> consequence, shows this which I noticed later on:
>
>>> The original bug report is at http://bugs.debian.org/583435
>
> I'm adding here part of the initial mail that I trimmed when replying
> to myself:
>
> ,---
> The second problem is that those files get created by the daemon on
> shutdown, and they *do* follow symlinks. So a user can drop two
> symlinks
> there while the daemon is running and overwrite any file on the file
> system on shutdown.
>
> The fix would consist of passing to configure something like
> =E2=80=9C--with-statedir=3D/var/cache/rpcbind=E2=80=9D, and make sure=
 the daemon creates
> such directory if missing on exit in src/warmstart.c:write_struct(),
> which it does not seem to be doing currently.
>
> In addition it would be wise to notify upstream to change the default
> statedir to something else than /tmp.
> `---

Agree changing the upstream default is a good idea.

Generally, that kind of directory is created as part of installation=20
(like, by rpm --install) rather than by the daemon itself.

>> Would /var/run (or a subdirectory of it) be a better choice than /tm=
p ?
>
> /var/run might not be preserved across reboots, but regardless of tha=
t I
> think /var/cache is a better fit, it's internal state, but it's used
> to speed up start up time, and can be removed w/o ill effects.

No, it's not intended to speed start up.

The cache files aren't really supposed to be retained over a reboot.=20
After a system restart, all of the RPC services will restart and=20
register themselves again.  If just rpcbind restarts, all that=20
registration state is lost, so that's the point of saving it in a file.

I don't have a preference wrt /var/run or /var/cache.
