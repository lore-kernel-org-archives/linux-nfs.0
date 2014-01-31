Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932355AbaAaPTz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Jan 2014 10:19:55 -0500
Message-ID: <52EBBF17.3050405@RedHat.com>
Date: Fri, 31 Jan 2014 10:19:51 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
References: <20140130172451.7a354ce4@notabene.brown>	<52EAB0CA.2090204@RedHat.com> <20140131091455.550e59a8@notabene.brown>
In-Reply-To: <20140131091455.550e59a8@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/30/2014 05:14 PM, NeilBrown wrote:

[snipped]

>> Do we really need all of these targets? Could we cut it down to
>> two. nfs.target and nfs-secure.target?
>>
> 
> Excellent question.
> My thought was to err on the side of providing too many rather than too few.
> If a distro wants to remove a particular choice it can use the "presets"
> feature off systemd to make sure that target is always enabled.
> 
> But I think you might be questioning specific targets rather than the general
> number of targets - I respond to that below.
On things that be came very apparent when we moved to
systemd was we needed to keep the "service" interface
intact (aka service [start|stop|...] nfs) because 
it broke a ton of existing scripts (esp in our QE dept ;-) )
This was the reason for the nfs.target. 

This might be a areas where distros need to do their own
tweaking to keep these legacy interfaces alive... 
 
[snipped]

>>
>>> diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
>>> new file mode 100644
>>> index 000000000000..7319a88661cc
>>> --- /dev/null
>>> +++ b/systemd/nfs-blkmap.service
>>> @@ -0,0 +1,11 @@
>>> +[Unit]
>>> +Description=pNFS block layout mapping daemon
>>> +After=var-lib-nfs-rpc_pipefs.mount
>>> +Requires=var-lib-nfs-rpc_pipefs.mount
>>> +
>>> +Requisite=nfs-blkmap.target
>>> +After=nfs-blkmap.target
>>> +
>>> +[Service]
>>> +Type=forking
>>> +ExecStart=/usr/sbin/blkmapd
>> Is this even supported anymore? Maybe we can just drop it???
> 
> No idea.  I found it as I was looking around and assumed it should be started.
> If it is no longer supported, how does NFS now find the block devices for
> direct pnfs access?
Can someone point me to a pNFS server that supports block Layouts?? 
Will it be at next month's Connectathon?? If the answer is no, then I
say we drop it...

> 
> 
>>
>>
>>> diff --git a/systemd/nfs-blkmap.target b/systemd/nfs-blkmap.target
>>> new file mode 100644
>>> index 000000000000..fbcc111152ee
>>> --- /dev/null
>>> +++ b/systemd/nfs-blkmap.target
>>> @@ -0,0 +1,8 @@
>>> +[Unit]
>>> +Description= PNFS blkmaping enablement.
>>> +# If this target is enabled, then blkmapd will be started
>>> +# as required.  If it is not enabled it won't.
>>> +
>>> +[Install]
>>> +WantedBy=remote-fs.target
>>> +WantedBy=multi-user.target
>>> \ No newline at end of file
>>
>> Again, why is a client target needed? Now that idmappings are
>> stored in the key ring what needs to be started on the client?
> 
> rpc.gssd?
shouldn't this be taken care of in the nfs-secure.target? 

> 
> Also sm-notify needs to be run on a machine this is used as an NFS client.
> This should happen even if no NFS filesystems are mounted at boot.
> An 'nfs-client' target seems the natural place to put that requirement.
I believe this is all done in the nfs-lock.service today. But I guess
it could make sense to move it into a more generic target.
 
> 
>>
>>> diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
>>> new file mode 100644
>>> index 000000000000..fa591354abf3
>>> --- /dev/null
>>> +++ b/systemd/nfs-client.target
>>> @@ -0,0 +1,13 @@
>>> +[Unit]
>>> +Description=NFS client services
>>> +Before=remote-fs-pre.target
>>> +Wants=remote-fs-pre.target
>>> +
>>> +# Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
>>> +# start that on demand if needed.
>>> +Wants=rpc-gssd.service nfs-blkmap.service rpc-statd-notify.service
>>> +Before=rpc-gssd.service nfs-blkmap.service
Just to be clear. These two line will *not* start the rpc.gssd service 
unless the nfs-secure.target was enabled?

>>> +
>>> +[Install]
>>> +WantedBy=multi-user.target
>>> +WantedBy=remote-fs.target
>>
>>
>>> diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
>>> new file mode 100644
>>> index 000000000000..6c2e1537f064
>>> --- /dev/null
>>> +++ b/systemd/nfs-idmapd.service
>>> @@ -0,0 +1,9 @@
>>> +[Unit]
>>> +Description=NFSv4 ID-name mapping service
>> Fedora has in the [Unit]:
>> BindTo=nfs-server.service
>> After=nfs-server.service
>> I guess I thought they were needed at the time..
> 
> Yes, I saw that.  So I looked into it.
> Apart from being a typo ("BindsTo" with an 's' is correct),
> BindsTo has an extra effect if the target unit - nfs-server.service in this
> case - disappears unexpectedly.  e.g. if the process dies.
> However nfs-server.service doesn't have a process which can die.  Rather it
> starts some kernel threads.  I'm pretty sure systemd won't be able to link
> those threads with nfs-server.service.
> So nfs-server.service can never "die", so "BindsTo" add nothing useful.
Fair enough... 

> 
> "After" just seems wrong.  The moment nfsd is started a request could come in
> which could require an idmap lookup, so nfs-idmapd should already be there.
In our testing we did find race conditions like this... 

> 
>>
>>> +
>>> +[Service]
>>> +EnvironmentFile=-/run/sysconfig/nfs-utils
>>> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
>>> +
>>> +Type=forking
>>> +ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
>>
>>
>>> diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
>>> new file mode 100644
>>> index 000000000000..92e05ca309ee
>>> --- /dev/null
>>> +++ b/systemd/nfs-mountd.service
>>> @@ -0,0 +1,13 @@
>>> +[Unit]
>>> +Description=NFS Mount Daemon
>>> +Requires=proc-fs-nfsd.mount
>>> +After=proc-fs-nfsd.mount
>>> +After=network.target
>>> +PartOf=nfs-server.service
>>> +
>>> +[Service]
>>> +EnvironmentFile=-/run/sysconfig/nfs-utils
>>> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
>> How does this script know who is calling it and what it
>> has to do? 
> 
> Its task is to read some config file like /etc/sysconfig/nfs and determine
> what the command line arguments for each nfs program should be and write out
>  FOO_ARGS=
> lines to /run/sysconfig/nfs-utils for each FOO which is an nfs program.
Well the the systemd people have argued that each FOO should read from 
a config file instead the systemd scripts... Being as that it may....

> I have since thought this would work better as a separate unit which creates
> the nfs-utils env file once, and have all the other units have Wants/After
> dependencies.
The reason I broken them out was I could not figure out how the single
env script could tell which service it was being called from. Meaning what tells
the script it's being call from the nfs-mountd.service verses the
rpc-gssd.service? Does systemd set some type of environment variable?
Because you can't set one from the service file. 

> 
> 
>>
>>> +
>>> +Type=forking
>>> +ExecStart=/usr/sbin/rpc.mountd $RPCMOUNTDARGS
>>
>>
>>> diff --git a/systemd/nfs-secure.target b/systemd/nfs-secure.target
>>> new file mode 100644
>>> index 000000000000..0127fdb07dbd
>>> --- /dev/null
>>> +++ b/systemd/nfs-secure.target
>>> @@ -0,0 +1,8 @@
>>> +[Unit]
>>> +Description=Secure NFS client/server services
>>> +# If this target is enabled, then rpc.gssd and rpc.svcgssd will be started
>>> +# as required.  If it is not enabled they won't.
>> So the "Requisite=nfs-secure.target" in rpc-gssd.service cause the 
>> daemon to started?
> 
> This is a bit subtle.
> The "Requisite=nfs-secure.target" in rpc-gssd.service means that service is
> only allowed to start if this unit (nfs-secure.target) is already started.
> So if nfs-secure.target is enabled, then rpc-gssd.service will start when
> anything Wants it.  If nfs-secure.target is not enabled, then
> rpc-gssd.service will not start, even if something Wants it.
> 
> So enabling nfs-secure.target doesn't start anything, just allows a couple of
> things to start if they are Wanted.
Got it... and that should work... 


>>> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
>>> new file mode 100644
>>> index 000000000000..9812866c66aa
>>> --- /dev/null
>>> +++ b/systemd/nfs-server.service
>>> @@ -0,0 +1,24 @@
>>> +[Unit]
>>> +Description=NFS server
>>> +DefaultDependencies=no
>>> +Requires= network.target proc-fs-nfsd.mount rpcbind.target
>>> +PartOf=nfs-server.target
>>> +
>>> +After= network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.service
>>> +After= nfs-idmapd.service rpc-statd.service
>>> +After= rpc-gssd.service rpc-svcgssd.service
>>> +Before= rpc-statd-notify.service
>>> +
>>> +[Service]
>>> +EnvironmentFile=-/run/sysconfig/nfs-utils
>>> +ExecStartPre=-/usr/lib/systemd/scritps/nfs-utils_env.sh
>>> +
>>> +Type=oneshot
>>> +RemainAfterExit=yes
>>> +ExecStartPre=/usr/sbin/exportfs -r
>>> +ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS
>> Having ExecStartPre and ExecStartPost scripts gives
>> us a place to do some pre and post server configuration.
>>
>> Granted it has not been needed in a while but I'm thinking
>> it could come in handing... 
> 
> systemd supports so-called "dropins".  If a distro wants to add an
> ExecStartPre for some distro-specific reason they can put it in
> 
>  /etc/systemd/system/nfs-server.service.d/04-Fedora-hacks.conf
> 
> and it will be understood by systemd to be part of this service.
> Of course if they were not distro-specific reasons we would include them in
> the upstream package :-)
Right... Keeping things non-distro-specific would be the goal...

> 
> I note that the Fedora nfs-server.service has a preconfig
>  echo "$NFSD_V4_GRACE" > /proc/fs/nfsd/nfsv4gracetime
> 
> and a postconfig
>         /sbin/modprobe svcrdma
>         echo "rdma $RDMA_PORT" > /proc/fs/nfsd/portlist
> 
> These seem reasonably general, though I'm wondering why the RDMA port is set
> in postconfig rather than preconfig.
> Do you know why that is?
Because the nfs server need be up and running before the listing 
port is created. Just the way it was designed... I guess...

But at the end of the day, all the rdma stuff could go
into is own nfs-server-rdma service file too...

[snipped]

>>
>>
>>> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
>>> new file mode 100644
>>> index 000000000000..f024d40a8f41
>>> --- /dev/null
>>> +++ b/systemd/rpc-svcgssd.service
FYI... when gss-proxy is enabled this does not need to be started... 

[snipped]

>>
>>
>>> diff --git a/utils/statd/start-statd b/utils/statd/start-statd
>>> index 1b345a547932..cde3583238e3 100644
>>> --- a/utils/statd/start-statd
>>> +++ b/utils/statd/start-statd
>>> @@ -5,5 +5,8 @@
>>>  # It should run statd with whatever flags are apropriate for this
>>>  # site.
>>>  PATH=/sbin:/usr/sbin
>>> -exec rpc.statd --no-notify
>>> -
>>> +if systemctl start statd.service
>>> +then :
>>> +else
>>> +    exec rpc.statd --no-notify
>>> +fi
>>>
>>
>> How does lockd get started and configured?
> 
> Lockd is automatically started by the kernel (nfs and nfsd) when needed.
> I noticed that Fedora had some scripts to optionally set the port numbers
> that lockd would use.  I left that out because I hoped we could find a better
> way.
> 
> If lockd is compiled in to the kernel, then I think fs.nfs.nlm_XXXport should
> be set via /etc/sysctl.conf.
> If it is a module, then the module parameters should be configured via
> an /etc/modprobe.d/lockd.conf file.
> I wish this was unified somehow (should modprobe call sysctl??) but it isn't.
> 
> I appreciate that in neither case is it easy to get values out of a
> 'sysconfig' file in to the right place.
Yes... it is messy...

> 
> I cannot really think of a better solution than an 'nfs-lock' service which
> sets these values,  so I'll probably add it.
Well it could be part the the nfs-client.target... 

>>
>> Overall it looks reasonable... But this is a change
>> of ABI... so it will be painful... :-(
> 
> What exactly is changing that will be painful?  I would certainly like to
> arrange the unit files to minimise your pain as much as possible, as long as
> it doesn't compromise effectiveness.
As I've already alluded to, people have built scripts around the
old sysv scripts... when all that changes... all those scripts break.
Which is the reason why I think we should maintain the old service
interface... at least for a while...

Question: Do all the distro's install the systemd scripts in the 
same place? /usr/lib/systemd/system?? 

Do even need to install them? Maybe just let the distro deal with them? 

steved.
