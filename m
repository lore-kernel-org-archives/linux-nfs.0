Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38406 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751432AbdFGKIV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Jun 2017 06:08:21 -0400
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and
 systemd.
To: NeilBrown <neilb@suse.com>
Cc: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org,
        Lennart Poettering <lennart@poettering.net>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
 <87lgp4dbx7.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <2a7fd6d4-a965-02e0-3b7b-97c5743d7083@RedHat.com>
Date: Wed, 7 Jun 2017 06:08:18 -0400
MIME-Version: 1.0
In-Reply-To: <87lgp4dbx7.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/06/2017 05:49 PM, NeilBrown wrote:
> On Tue, Jun 06 2017, Steve Dickson wrote:
> 
>> Hello,
>>
>> On 05/29/2017 06:19 PM, NeilBrown wrote:
>>>
>>> Systemd does not, and will not, support "bg" correctly.
>>> It has other, better, ways to handle "background" mounting.
>> The only problem with this is bg mounts still work at least
>> up to 4.11 kernel... 
> 
> I don't think this is correct.
> In the default configuration, "mount -t nfs -o bg ...."
> runs for longer than 90 seconds, so systemd kill it.
I must be missing something... it seems to be working for me

# mount -vvv -o bg rhel7srv:/home/tmp /mnt/tmp
mount.nfs: trying text-based options 'bg,vers=4.1,addr=172.31.1.60,clientaddr=172.31.1.58'
mount.nfs: mount(2): Connection refused
mount.nfs: trying text-based options 'bg,addr=172.31.1.60'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: trying 172.31.1.60 prog 100003 vers 3 prot TCP port 2049
mount.nfs: portmap query failed: RPC: Remote system error - Connection refused
mount.nfs: backgrounding "rhel7srv:/home/tmp"
mount.nfs: mount options: "rw,bg"

# ps ax | grep mount.nfs
 2270 ?        Ss     0:00 /sbin/mount.nfs rhel7srv:/home/tmp /mnt/tmp -v -o rw,bg

> 
> A working "bg" mount would successfully mount the filesystem is the
> server came back after 5 minutes. If you use current systemd in the
> default configuration, it won't.
When I add a bg mount to fstab again... it works just fine. This
is with the latest upstream nfs-utils. 

> 
> bg mounts do work sometimes, but I don't think they are reliable, and
> there seems to be no interest in changing this.
> Maybe the text should say "Systemd does not, and will not, reliably
> support "bg" mounts...".
not reliable maybe... I'm just doing very simple testing... 
> 
> 
>>
>> It appears there is a problem with a 4.12 kernel. The mount no 
>> longer errors out with ECONNREFUSED it just hangs in the 
>> kernel trying forever... It sounds like a bug to me but 
>> maybe that change was intentional.. Anna?? Trond???
> 
> Might be related to my patch
>   [PATCH] SUNRPC: ensure correct error is reported by xs_tcp_setup_socket()
> 
> sent 25th May.
I'll take a look.. thanks!

> 
>>
>> So I'm a bit hesitant to commit this since not accurate, yet.
>>
>> Finally, the whole idea of systemd randomly/silently 
>> strip off mount options is crazy... IMHO... 
> 
> It isn't exactly systemd, it is systemd-fstab-generator.
> The options lists in /etc/fstab are not all equal.  Some
> are relevant to /bin/mount, some to mount.nfs, some to the kernel.
> I think /bin/mount processes the option lists before passing it
> to mount.nfs.  There is no intrinsic reason that systemd-fstab-generator
> shouldn't do the same thing.
OK. 
> 
>>
>> Just because a concept that has been around for years
>> does not fix well in the systemd world it gets
>> rip out??? IDK... but I think we can do better than that.
> 
> I could suggest that automount is uniformly better than bg.  Give how
> long automount has been around, and how easy it is to use with systemd,
> it might be time to start encouraging people to stop using the inferior
> technology.
Yes... bg mounts are a poor man's automount... 
> 
> I could say that, but I'm not 100% sure.  The difference between
> automount and bg is that with bg it is easy to see if the mount has
> succeeded yet - just look for an empty directory.  With automount,
> you'll typically get a delay at that point.  We could possibly wind down
> that delay...
> 
>>
>> Note, the 'bg' is used by clients that do want their
>> booting to hang by servers that are down so if the 
>> option is rip out, boots will start hang. This
>> will make it very difficult to debug since the bg
>> will still exist in fstab.
> 
> Not exactly.
> Current default behaviour is that systemd will wait 90 seconds, then
> kill the mount program and fail the boot.  If we strip out "bg", the
> same thing will happen.
Again.. I'm not seeing this 90 sec delay when I add a bg mount
to /etc/fstab.

> 
> I'm OK with the patch not being applied just yet.  I think we need to
> resolve this issue, but it isn't 100% clear to me what the best
> resolution would be.  So I'm happy to see a conversation happening and
> opinions being shared.
> I'd be particularly pleased if you could double check how "bg" is
> currently handled on some systemd-enabled system that you use.
> Does the mount program get killed like I see?  
No. after adding a bg mount to fstab and rebooting (with the server
down) I see the following mount in backgroup 
   1104 ?        Ss     0:00 /sbin/mount.nfs nfssrv:/home/tmp /mnt/tmp -o rw,bg

> Does boot succeed if there is a bg mount from an unresponsive server?
Yes. Then when I bring up the server the mount succeeds

steved.

P.S. I'm taking some PTO today so I will not be back in the office
until later today or tomorrow... 

steved.
 
> 
> Thanks,
> NeilBrown
> 
> 
>>
>> Again, the whole concept of systemd messing with mounts options
>> is just not a good one... IMHO.. 
>>
>> steved.
>>
>>>
>>> Explain this.
>>>
>>> See also https://github.com/systemd/systemd/issues/6046
>>>
>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>> ---
>>>  utils/mount/nfs.man | 18 +++++++++++++++++-
>>>  1 file changed, 17 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>>> index cc6e992ed807..7e76492d454f 100644
>>> --- a/utils/mount/nfs.man
>>> +++ b/utils/mount/nfs.man
>>> @@ -372,6 +372,21 @@ Alternatively these issues can be addressed
>>>  using an automounter (refer to
>>>  .BR automount (8)
>>>  for details).
>>> +.IP
>>> +When
>>> +.B systemd
>>> +is used to mount the filesystems listed in
>>> +.IR /etc/fstab ,
>>> +the
>>> +.B bg
>>> +option is not supported, and may be stripped from the option list.
>>> +Similar functionality can be achieved by providing the
>>> +.B x-system.automount
>>> +option.  This will cause
>>> +.B systemd
>>> +to attempt to mount the filesystem when the mountpoint is first
>>> +accessed, rather than during system boot.  The mount still happens in
>>> +the "background", though in a different way.
>>>  .TP 1.5i
>>>  .BR rdirplus " / " nordirplus
>>>  Selects whether to use NFS v3 or v4 READDIRPLUS requests.
>>> @@ -1810,7 +1825,8 @@ such as security negotiation, server referrals, and named attributes.
>>>  .BR rpc.idmapd (8),
>>>  .BR rpc.gssd (8),
>>>  .BR rpc.svcgssd (8),
>>> -.BR kerberos (1)
>>> +.BR kerberos (1),
>>> +.BR systemd.mount (5) .
>>>  .sp
>>>  RFC 768 for the UDP specification.
>>>  .br
>>>
