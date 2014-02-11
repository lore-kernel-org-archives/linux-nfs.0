Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750812AbaBKM4f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Feb 2014 07:56:35 -0500
Message-ID: <52FA1E00.8000801@RedHat.com>
Date: Tue, 11 Feb 2014 07:56:32 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
References: <20140130172451.7a354ce4@notabene.brown>	<52F003A1.3060908@RedHat.com>	<20140204093452.7b6d7c7d@notabene.brown>	<52F130E2.6090308@RedHat.com> <20140205145514.2c44b575@notabene.brown>
In-Reply-To: <20140205145514.2c44b575@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Sorry for the delayed response... I got suck into another world... ;-(
 
On 02/04/2014 10:55 PM, NeilBrown wrote:
> On Tue, 04 Feb 2014 13:26:42 -0500 Steve Dickson <SteveD@redhat.com> wrote:
>>>>
>>>> How is rpc.svcgssd enabled? Since the .service file does
>>>> not have a [Install] section the systemctl enable rpc.svcgssd
>>>> fails.
>>>
>>> The "README" touches on this.  If you
>>>    systemctl enable nfs-secure.target
>>> then rpc.svcgssd will be run whenever nfs-server.target is started.
>> I was thinking nfs-server would only start rpc.svcgssd when its
>> enabled... not every time... 
> 
> I don't follow what you are saying ... not that it really matters as we both
> seem to be agreed to take a different approach with the gss daemons.
> 
> In my original plan:
>  if nfs-secure is enabled, then whenever nfs-server is started, it makes sure
>  that rpc.svcgssd is running.
>  if nfs-secure is not enabled, then rpc.svcgssd will refuse to start.
Understood... and that's good... 

> 
> 
>>
>>> Also rpc.gssd will be run whenever nfs-server.target or nfs-client.target is
>>> started.
>> Why is rpc.gssd started when the nfs server is started? Possibly for secure 
>> loopback mounts??
> 
> Call-backs from NFSv4.0 server, as has been mentioned elsewhere.
But kerberos has to be configure... but I think we are talking
about that in a another thread...

> 
>>
>>>
>>>>
>>>> How would these daemons be restart and shutdown? Since this is a 
>>>> target, systemctl restart and system stop don't do anything.
>>>
>>> This is something I haven't completely figured out yet.
>>>
>>> Part of the solution might be the "PartOf" directive.
>>> If each service claims to be "PartOf" the main one, then stopping or
>>> restarting the main service will propagate to stopping and restarting the
>>> individual services.
>>> Unfortunately in nfs we have some shared services.  rpc.statd and rpc.gssd
>>> are needed by both server and client.  That isn't a big problem for 'restart',
>>> but if you 'systemctl stop nfs-client' and find that the server isn't
>>> properly working any more, that would be awkward
>>> If could possibly work around that by setting "StopWhenUnneeded" for those
>>> shared services.  Then e.g. rpc.statd would stop when both client and server
>>> are stopped, but not if either one of them is stopped.
>>> However I don't know how that interacts with restart.  I suspect that the
>>> StopWhenUnneeded services are *not* stopped and restarted when the main
>>> service is stopped.  So it would  be  hard to restart all nfs services on an
>>> upgrade.
>>>
>>> Further research seems needed here.
>> Fine... I'll try to digest what you are saying here, but
>> would it make it easier if everything was in a service file?
> 
> No, the only way the .target files are more awkward is that you have to type
> ".target".
> 
> In fact a .target can be turned into an .service by adding:
> 
> [Service]
> Type=oneshot
> RemainAfterExit=yes
> ExecStart=/bin/true
> 
> at the end.  You might even get away with less than that.
> Given this and that ".target" is extra typing, there seems little reason to
> use .target unit files.
So are you saying are not going use .target units? They will all be .service units?

> 
>>
>>>
>>>
>>>>
>>>>> +
>>>>> + nfs-secure.target
>>>>> +    If enabled, then rpc.gssd will be run when either -client or
>>>>> +    -server is started, and rpc.svcgssd will be run when -server
>>>>> +    is started
>>>> I like that fact that rpc.gssd is started by nfs-client but 
>>>> I don't like that API change. systemctl restart nfs-secure breaks 
>>>
>>> Why would you want to "restart nfs-secure".  I can understanding wanting to
>>> restart individual processed, or the whole collection, but why that subset?
>> Well in Fedora nfs-secure is one process ;-) 
> 
> Oh yes, "nfs-secure" means "run rpc.gssd".
> If you wanted to preserve that I think you could create a drop-in file
> for rpc-gssd.service containing
>    [Install]
>    Alias=nfs-secure.service
> though that would require "systemctl enable rpc-gssd" so maybe it isn't the
> best approach.
If I'm understanding this and above...  systemctl enable nfs-secure would
be controlling the starting up of both rpc.gssd and rpc.svcgssd/gss-proxy? 

steved.
