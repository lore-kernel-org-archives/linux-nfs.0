Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbaBDS0p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 13:26:45 -0500
Message-ID: <52F130E2.6090308@RedHat.com>
Date: Tue, 04 Feb 2014 13:26:42 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
References: <20140130172451.7a354ce4@notabene.brown>	<52F003A1.3060908@RedHat.com> <20140204093452.7b6d7c7d@notabene.brown>
In-Reply-To: <20140204093452.7b6d7c7d@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/03/2014 05:34 PM, NeilBrown wrote:
> On Mon, 03 Feb 2014 16:01:21 -0500 Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 01/30/2014 01:24 AM, NeilBrown wrote:
>>>
>>>  So:
>>>   1/ Do you agree that a collection of systemd unit files belongs in
>>>      nfs-utils?
>> I think having a single way to start NFS across all distors would be
>> a very good thing... 
>>
>>>   2/ Do you think it reasonable to expect most (systemd using) distros to
>>>      use the one set?  I will certainly try to ensure openSUSE does if
>>>      upstream accepts them.
>> I think I'll already agreed to this as well... 
>>
>>>   3/ Do you have any comments/question about those below?
>> I took a little closer look at these and actual tried to 
>> get them to work in a Fedora environment. Here is what I found..
>>
>>
>>> diff --git a/systemd/README b/systemd/README
>>> new file mode 100644
>>> index 000000000000..f0fb68825499
>>> --- /dev/null
>>> +++ b/systemd/README
>>> @@ -0,0 +1,50 @@
>>> +
>>> +Notes about systemd unit files for nfs-utils.
>>> +
>>> +The unit files provided here should be sufficient for systemd
>>> +to manage all daemons and related services provides by nfs-utils.
>>> +
>>> +They do *not* include any unit files for separate services such as
>>> +rpc.rquotad (in the 'quota' package) or rpcbind.
>>> +
>>> +There are 4 units that can be 'enabled' or 'disabled' by systemctl, or
>>> +by a suitable 'preset' setting:
>>> +
>>> + nfs-server.target
>>> +    If enabled, nfs service is started together with dependencies
>>> +    such as mountd, statd, rpc.idmapd
>> This changes the current API... Today to enable/start this service 
>> today one does:
>>
>>   systemctl enable nfs-server
>>   systemctl start nfs-server
>>
>> which would change to:
>>
>>   systemctl enable nfs-server.target
>>   systemctl start nfs-server
> 
> I think this would need to be "systemctl start nfs-server.target".
> 
>>
>> with the same daemons being started.
>> This changed will cause existing scripts to fail... 
>> I guess I don't see the point of having a .target file. 
> 
> It's frustrating that "foo" is treated as "foo.service" rather than
> "foo.target" but I guess we have to live with it.
> 
> According to the documentation a .service file "encodes
> information about a process controlled and supervised by systemd."
> 
> nfs-server isn't "a process", it is a collection of processes.
> 
> A .target is "used for grouping units" so it makes sense to me to group all
> the nfs-server units in an "nfs-server.target".
I see this logic.

> 
> So the structure makes sense based on the documentation and apparent design
> of systemd.  Unfortunately it leads to this clumsy API of having to give the
> ".target" suffix.
In the beginning the .service suffix was not appended either. I actually
opened a bug asking for the .service to be appended, which got
soundly closed as NOTABUG! But I guess enough people bitched about
so one day that "feature" just appeared. ;-)
 
> 
> I guess it makes sense to merge nfs-server.service and nfs-server.target as,
> after all, nfs-server.service doesn't describe a process controlled by
> systemd anyway - it is a 'oneshot'....
> I'll send a patch to do that.
Thanks! That will make our transition much easier....

> 
> 
>>
>> How is rpc.svcgssd enabled? Since the .service file does
>> not have a [Install] section the systemctl enable rpc.svcgssd
>> fails.
> 
> The "README" touches on this.  If you
>    systemctl enable nfs-secure.target
> then rpc.svcgssd will be run whenever nfs-server.target is started.
I was thinking nfs-server would only start rpc.svcgssd when its
enabled... not every time... 

> Also rpc.gssd will be run whenever nfs-server.target or nfs-client.target is
> started.
Why is rpc.gssd started when the nfs server is started? Possibly for secure 
loopback mounts??

> 
>>
>> Also how does gss-proxy come to play in all this? Maybe we 
>> just use  gss-proxy by default and retire rpc.svcgssd.
> 
> I haven't really be following and so am only dimly aware of gss-proxy.
> It's a replacement for rpc.svcgssd - right?
> So we should get it to start in the same circumstances as rpc.svcgssd?
> 
> Is there some easy test - eg something existing in the filesystem - that we
> could use to see if the kernel supports gss-proxy ?
In Fedora, you set the GSS_USE_PROXY="yes" in /etc/sysconfig/nfs.
I've done a little testing with it but not enough... 

> 
> Also, I've been wondering if we could avoid the need to explicitly enable
> the gss stuff by gating it on the existence of /etc/krb5.keytab.
> Do you think that would be reasonable?
Personally I think the gssd daemons should just check for the
existence of /etc/krb5.keytab. If it does not exist it either
immediately errors out the upcall or dies... 
 
> 
>>
>>> +
>>> + nfs-client.target
>>> +    If enabled, daemons needs for an nfs client are enabled.
>>> +    This does *not* include rpc.statd.  the rpc-statd.service unit
>>> +    is started by /usr/sbin/start-statd which mount.nfs will run
>>> +    if statd is needed.
>> I am coming around to liking this one... but I think it should start
>> statd and configure lockd. Why not just roll the current nfs-lock 
>> service under this umbrella? A simple systemctl restart nfs-client
>> would configure and start all of the needed daemons. 
> 
> I just feels like the wrong place to be setting sysctl values... But maybe.
> And why start statd if it isn't needed.
I can live with this... :-) 

> 
>>
>> How would these daemons be restart and shutdown? Since this is a 
>> target, systemctl restart and system stop don't do anything.
> 
> This is something I haven't completely figured out yet.
> 
> Part of the solution might be the "PartOf" directive.
> If each service claims to be "PartOf" the main one, then stopping or
> restarting the main service will propagate to stopping and restarting the
> individual services.
> Unfortunately in nfs we have some shared services.  rpc.statd and rpc.gssd
> are needed by both server and client.  That isn't a big problem for 'restart',
> but if you 'systemctl stop nfs-client' and find that the server isn't
> properly working any more, that would be awkward
> If could possibly work around that by setting "StopWhenUnneeded" for those
> shared services.  Then e.g. rpc.statd would stop when both client and server
> are stopped, but not if either one of them is stopped.
> However I don't know how that interacts with restart.  I suspect that the
> StopWhenUnneeded services are *not* stopped and restarted when the main
> service is stopped.  So it would  be  hard to restart all nfs services on an
> upgrade.
> 
> Further research seems needed here.
Fine... I'll try to digest what you are saying here, but
would it make it easier if everything was in a service file?

> 
> 
>>
>>> +
>>> + nfs-secure.target
>>> +    If enabled, then rpc.gssd will be run when either -client or
>>> +    -server is started, and rpc.svcgssd will be run when -server
>>> +    is started
>> I like that fact that rpc.gssd is started by nfs-client but 
>> I don't like that API change. systemctl restart nfs-secure breaks 
> 
> Why would you want to "restart nfs-secure".  I can understanding wanting to
> restart individual processed, or the whole collection, but why that subset?
Well in Fedora nfs-secure is one process ;-) 

> 
> I'm fairly sure we can keep that API working if you really need it, but
> maybe as a fedora-specific hack?
Yup! At the time I didn't know how to handle the security daemons
that why there is a nfs-secure service and an nfs-server-secure
service. 

The path we are head is much better... 

steved.
  
>>  
>>> +
>>> + nfs-blkmap.target
>>> +    If enabled, then blkmapd will be run when nfs-client.target is
>>> +    started.
>> Unless someone steps up and says why this is needed or if it will 
>> ever be needed... I'm seriously thinking about dropping it from Fedora.
>>
>> I think overall its workable but I just don't see the advantage 
>> of using .targets over .service files... 
>>
>> steved.
> 
> Thanks for your very thorough review.
> 
> NeilBrown
> 
