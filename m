Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467AbbALM1U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2015 07:27:20 -0500
Message-ID: <54B3BDA3.2010009@RedHat.com>
Date: Mon, 12 Jan 2015 07:27:15 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: A couple systemd questions
References: <54B295B7.9070509@RedHat.com> <20150112085144.6460dc27@notabene.brown>
In-Reply-To: <20150112085144.6460dc27@notabene.brown>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/11/2015 02:51 PM, NeilBrown wrote:
> On Sun, 11 Jan 2015 10:24:39 -0500 Steve Dickson <SteveD@redhat.com> wrote:
> 
>> Hey Neil,
>>
>> You being the architect of the systemd scribes ;-)  I have a 
>> couple questions. 
>>
>> The nfs-server service brings both the rpc.mountd and rpc.idmapd 
>> daemons up when the service is started, but only 
>> brings rpc.mountd down when the service is stopped. 
>>
>> I'm assuming that was done because the client was 
>> using  rpc.idmapd to do its id mapping, but that is no 
>> longer the case with some clients. They use the 
>> key rings via nfsidmap command to do the id mapping
> 
> Your assumption is correct.
> Having nfs-client only require nfs-idmap on some configs is not easy to do
> with systemd... at least I don't know an easy way.
> We probably need to distribute two versions of some config file(s), one where
> the dependency exists, one where it doesn't.
> 
> How does one tell whether idmapd is needed or not?
The existence of /etc/request-key.d/id_resolver.conf and /usr/sbin/nfsidmap?

The kernel is hard coded to do an keyring upcall first then if that fails
it will try an upcall to rpc.idmapd. So at this point it 
makes sense to use the keyring upcalls... 

> 
> 
>>
>> So I'm thinking the nfs-server service should bring 
>> both daemons up and down when the server is started 
>> and stopped since the server is the only service using 
>> the rpc.idmapd.
>>
>> My attempted at doing this is to change the 
>> nfs-idmap service to do the following:
>>
>> [Unit]
>> Description=NFSv4 ID-name mapping service
>> Requires=var-lib-nfs-rpc_pipefs.mount
>> After=var-lib-nfs-rpc_pipefs.mount
>> After=network.target
>> PartOf=nfs-server.service
>> PartOf=nfs-utils.service
>>
>> Wants=nfs-config.service
>> After=nfs-config.service
>>
>> [Service]
>> EnvironmentFile=-/run/sysconfig/nfs-utils
>> Type=forking
>> ExecStart=/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
>>
>> Almost exactly what the  rpc-mountd service does. 
>>
>> Now I thought the "PartOf=nfs-server.service" would cause
>> rpc.idmapd to come down when the server came down, but that 
>> does not seem to be the case... The only way I can get 
>> nfs-idmap service to come down is to explicitly stop it... 
>> What am I missing?
> 
> You are missing the same thing that I am missing.
> I wonder if systemd gets confused by multiple PartOf directives.
> 
> The man page says:
> 
>   When systemd stops or restarts the units listed here, the action
>   is propagated to this unit.
> 
> So if systemd is told to stop nfs-server.service, it should also stop
> nfs-idmap.service...
That's how I interpreted it as well... I'll talk with the systemd guys 
to see what they say

> Maybe try with only one PartOf?  Or with
>   PartOf=nfs-server.service nfs-utils.service
I did try this and it didn't seem to matter... 

> 
> 
>>
>> Secondly, in all of the services where rpcbind is needed you 
>> reference the rpcbind.target instead of the rpcbind.service. 
>> Why is that?
> 
> Because rpcbind.target is a public name (even mentioned in doco).  I had this
> idea that when systemd unit files from one package need to interact with
> those from another package, they should be careful to only use "public"
> interfaces in case one package changes.
> And I thought "rpcbind.target" was like a public interface.
> 
> I no longer think that.  The ".target" concept doesn't seem to be nearly as
> useful as I thought it would be.
> 
> I would not object to changing nfs-utils to use "rpcbind.service" if that
> would help anyone at all.
I've got this bug 
   https://bugzilla.redhat.com/show_bug.cgi?id=1171603
talking about how the nfs-server service should be using rpcbind.service
instead of rpcbind.target. The reasoning in the bz might be a 
bit off... but it did get me thinking about it... 

> 
>>
>> The reason I'm ask is,  I'm seeing a problem  where rpc.statd fails 
>> to start because nfs_svc_create() fails. Meaning it was unable to
>> either create UPD/TCP sockets or the registrations to rpcbind fails.
>>
>> I'm thinking its the later due a race between rpcbind and statd 
>> starting. I've seen races like before in with systemd services... 
> 
> but but but, the whole point of before/after is to avoid races...
Understood... Maybe targets are handled differently that services??? 

> 
>>
>> So I'm thinking that race would not exist if the rpc-statd service
>> would use rpcbind.service in the "Requires=" and "After=" 
>> statements instead of rpcbind.target. Right?? 
> 
> Don't know.  Try it and see.  If it works, use it.
Here is the race I'm seeing:
   https://bugzilla.redhat.com/show_bug.cgi?id=1175005#c4
Its not very reproducible, but I have seen a couple other times
since we moved to the new systemd scripts... 

Thanks for the time!! 
 
steved.
