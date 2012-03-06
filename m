Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:34452 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758189Ab2CFHqi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 02:46:38 -0500
Message-ID: <4F55C0C1.9020108@steve-ss.com>
Date: Tue, 06 Mar 2012 08:46:09 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs3 lockd: cannot monitor errors
References: <4F520CB4.1030203@steve-ss.com> <4F554954.9050901@steve-ss.com> <52BCED70-81F8-454E-BD01-3261B1E76931@oracle.com>
In-Reply-To: <52BCED70-81F8-454E-BD01-3261B1E76931@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/03/12 00:23, Chuck Lever wrote:
>
> On Mar 5, 2012, at 6:16 PM, steve wrote:
>
>> On 03/03/12 13:21, steve wrote:
>>> Hi
>>> We recently switched to nfs3 from nfs4 and now we're getting lots of
>>> lockd errors. We can remove the error by mounting with:
>>> -o local_lock=posix
>>>
>>> We had to switch to be able to use the posix acl we had set on the share.
>>>
>>> What problems may we face by setting the local_lock?
>>> Thanks,
>>> Steve
>>>
>>
>> Hi
>> Sorry to bump
>> This is openSUSE 12.1. All the references to lockd probs seem to come from 10 or so years ago.
>>
>> Could anyone give me a one liner as to where to start looking? I've gone through all the usual channels.
>>
>> Cheers,
>> Steve
>>
>> Server:
>> Mar  5 16:24:46 hh3 kernel: [16760.656609] lockd: cannot monitor hh6
>
> This error message means "hh3" cannot monitor "hh6".  Usually that's a sign that rpc.statd on hh3 is having trouble getting a clean DNS lookup of hh6.  Maybe enabling debugging on statd would produce a little more diagnostic information.
>

Hi Chuck
Thanks for the reply. You've got me on the right track. Running at both 
ends in the foreground is rock solid and instantaneous:

server: hh3, 192.168.1.3
hh3:/home/steve # rpc.statd -Fd
rpc.statd: Version 1.2.5 starting
rpc.statd: Flags: No-Daemon Log-STDERR TI-RPC
sm-notify: Version 1.2.5 starting
sm-notify: Already notifying clients; Exiting!
rpc.statd: Local NSM state number: 459
rpc.statd: Effective UID, GID: 103, 65534
rpc.statd: Waiting for client connections
rpc.statd: from_local: updating local if addr list
rpc.statd: from_local: checked 5 local if addrs; incoming address not found
rpc.statd: check_default: access by 192.168.1.12 ALLOWED
rpc.statd: Received SM_NOTIFY from hh6, state: 59
rpc.statd: SM_NOTIFY from hh6 while not monitoring any hosts
rpc.statd: Waiting for client connections
rpc.statd: from_local: updating local if addr list
rpc.statd: from_local: incoming address matches local interface address
rpc.statd: check_default: access by 127.0.0.1 ALLOWED
rpc.statd: Received SM_MON for 192.168.1.12 from hh3
rpc.statd: get_nameinfo: failed to resolve address: Name or service not 
known

client: hh6, 192.168.1.12
rpc.statd: MONITORING 192.168.1.12 for hh3
rpc.statd: Waiting for client connections
rpc.statd -Fd
rpc.statd: Version 1.2.5 starting
rpc.statd: Flags: No-Daemon Log-STDERR TI-RPC
sm-notify: Version 1.2.5 starting
sm-notify: Already notifying clients; Exiting!
rpc.statd: Adding record for hh3.hh3.site to the monitor list...
rpc.statd: Loaded 1 previously monitored hosts
rpc.statd: Local NSM state number: 59
rpc.statd: Effective UID, GID: 103, 65534
rpc.statd: Waiting for client connections

Dropping to daemon makes the errors reappear with slow file transfer.

I've also nailed the Thunar file manager under XFCE which seems to be 
making calls to cifs via Kerberos each time we request a file ??. With 
Nautilus it's fine. The nfs/server principal is called once at the start 
of the session with no cifs requests.

Just one quick question, does the client server statd output look OK?
Thanks,
Steve

