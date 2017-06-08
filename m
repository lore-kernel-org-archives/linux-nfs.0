Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41650 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751448AbdFHUYI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 16:24:08 -0400
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and
 systemd.
To: NeilBrown <neilb@suse.com>,
        Lennart Poettering <mzxreary@0pointer.de>
Cc: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
 <87lgp4dbx7.fsf@notabene.neil.brown.name>
 <2a7fd6d4-a965-02e0-3b7b-97c5743d7083@RedHat.com>
 <20170607120221.GJ27006@gardel-login>
 <ce5c37b4-a81b-4eaf-c1ac-7f36488bdaa9@RedHat.com>
 <87mv9jawjf.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <db98d408-ae65-f9ac-5ca1-84a278c88491@RedHat.com>
Date: Thu, 8 Jun 2017 16:24:06 -0400
MIME-Version: 1.0
In-Reply-To: <87mv9jawjf.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/08/2017 01:16 AM, NeilBrown wrote:
> On Wed, Jun 07 2017, Steve Dickson wrote:
> 
>> On 06/07/2017 08:02 AM, Lennart Poettering wrote:
>>> On Wed, 07.06.17 06:08, Steve Dickson (SteveD@RedHat.com) wrote:
>>>
>>>>
>>>>
>>>> On 06/06/2017 05:49 PM, NeilBrown wrote:
>>>>> On Tue, Jun 06 2017, Steve Dickson wrote:
>>>>>
>>>>>> Hello,
>>>>>>
>>>>>> On 05/29/2017 06:19 PM, NeilBrown wrote:
>>>>>>>
>>>>>>> Systemd does not, and will not, support "bg" correctly.
>>>>>>> It has other, better, ways to handle "background" mounting.
>>>>>> The only problem with this is bg mounts still work at least
>>>>>> up to 4.11 kernel... 
>>>>>
>>>>> I don't think this is correct.
>>>>> In the default configuration, "mount -t nfs -o bg ...."
>>>>> runs for longer than 90 seconds, so systemd kill it.
>>>> I must be missing something... it seems to be working for me
>>>>
>>>> # mount -vvv -o bg rhel7srv:/home/tmp /mnt/tmp
>>>> mount.nfs: trying text-based options 'bg,vers=4.1,addr=172.31.1.60,clientaddr=172.31.1.58'
>>>> mount.nfs: mount(2): Connection refused
>>>> mount.nfs: trying text-based options 'bg,addr=172.31.1.60'
>>>> mount.nfs: prog 100003, trying vers=3, prot=6
>>>> mount.nfs: trying 172.31.1.60 prog 100003 vers 3 prot TCP port 2049
>>>> mount.nfs: portmap query failed: RPC: Remote system error - Connection refused
>>>> mount.nfs: backgrounding "rhel7srv:/home/tmp"
>>>> mount.nfs: mount options: "rw,bg"
>>>
>>> We are talking about mounts done through /etc/fstab, i.e. the ones
>>> systemd actually manages.
>> I guess I was not clear... After adding a bg mount to fstab and
>> reboot, mounting a server that is not up, there is a mount in
>> background that looks like 
>>
>> # ps ax | grep mount
>>  1104 ?        Ss     0:00 /sbin/mount.nfs nfssrv:/home/tmp /mnt/tmp -o rw,bg
>>
>> Looking at the remote-fs.target status:
>>
>> # systemctl status remote-fs.target 
>> * remote-fs.target - Remote File Systems
>>    Loaded: loaded (/usr/lib/systemd/system/remote-fs.target; enabled; vendor preset: enabled)
>>    Active: active since Tue 2017-06-06 12:36:51 EDT; 12min ago
>>      Docs: man:systemd.special(7)
>>
>> Jun 06 12:36:51 f26.boston.devel.redhat.com systemd[1]: Reached target Remote File Systems.
>>
>> It appears to be successful 
> 
> Strange ... not for me.
> 
> I have a recent compiled-from-source upstream systemd and a very recent
> upstream kernel.
> 
> I add a line to /etc/fstab
> 
>  192.168.1.111:/nowhere /mnt nfs bg 0 0
> 
> and reboot (192.168.1.111 is on a different subnet to the VM I am
> testing in, but no host responds to the address).
> 
> There is a 1m30s wait while trying to mount /mnt, then boot completes
> (I was wrong when I said that it didn't).
> 
> ● mnt.mount - /mnt
>    Loaded: loaded (/etc/fstab; generated; vendor preset: enabled)
>    Active: failed (Result: timeout) since Thu 2017-06-08 11:13:52 AEST; 1min 24s ago
>     Where: /mnt
>      What: 192.168.1.111:/nowhere
>      Docs: man:fstab(5)
>            man:systemd-fstab-generator(8)
>   Process: 333 ExecMount=/bin/mount 192.168.1.111:/nowhere /mnt -t nfs -o bg (code=killed, signal=TERM)
> 
> Jun 08 11:12:22 debian systemd[1]: Mounting /mnt...
> Jun 08 11:13:52 debian systemd[1]: mnt.mount: Mounting timed out. Stopping.
> Jun 08 11:13:52 debian systemd[1]: mnt.mount: Mount process exited, code=killed status=15
> Jun 08 11:13:52 debian systemd[1]: Failed to mount /mnt.
> Jun 08 11:13:52 debian systemd[1]: mnt.mount: Unit entered failed state.
> 
> 
> The /bin/mount process has been killed (SIGTERM) after the 90 second
> timeout
> 
> ● remote-fs.target - Remote File Systems
>    Loaded: loaded (/lib/systemd/system/remote-fs.target; enabled; vendor preset: enabled)
>   Drop-In: /run/systemd/generator/remote-fs.target.d
>            └─50-insserv.conf.conf
>    Active: inactive (dead)
>      Docs: man:systemd.special(7)
> 
> Jun 08 11:13:52 debian systemd[1]: Dependency failed for Remote File Systems.
> Jun 08 11:13:52 debian systemd[1]: remote-fs.target: Job remote-fs.target/start failed with result 'dependency'.
> 
> 
> remote-fs.target has not been reached.
I'm seeing this now... the server has to be up to cause this hang.

> 
> Because remote-fs.target is WantedBy multi-user.target, but need
> RequiredBy it, boot completes.
> But if anything did Require remote-fs.target, it would fail if "bg"
> mounts were not mounted within 90 seconds.
> 
> 
> Looking back over your log messages:
> 
>>>> mount.nfs: portmap query failed: RPC: Remote system error - Connection refused
>>>> mount.nfs: backgrounding "rhel7srv:/home/tmp"
> 
> it appears that the fg mount attempt failed quickly (ECONNREFUSED), so it
> background the process immediately.  Systemd sees that as success
> (despite the fact that the filesystem isn't actually mounted) and
> doesn't clean up the background processes (which is arguably a bug).
No... Systemd is doing the right thing in this case... Letting
bg mounts work... 

> 
> If you try to mount from a server which doesn't even return ECONNREFUSED or
> EHOSTUNREACH, such that the first mount attempt takes longer than 90
> seconds, then you should get the same results as me.
This is clearly a bug in systemd! The 'bg' mounts work with the server
down but hangs when the server is up. How can't this be a bug in systemd?? 

Why is systemd even looking at or interpreting the mount options??? 
This clear an overreach of systemd, IMHO. Then just to blindly rip
them out... WOW!

I'm only assuming... but it appears, do to this overreach, that systemd
actually think it know how to mount a file system better than the 
actual mount command tailor for particular that file system and
if it doesn't like an mount option it just going to rip it
out! Again, I hope this is not the case because if its... 
that's just crazy!!! 

> 
> Your results go some way to explaining why Lennart hasn't received many
> complaints, but I'm convinced that the current situation is not ideal
> (because SUSE has received some complaints).
It just proves bg mounts are being used.

> 
> I've been pondering the possibility of making "bg" work properly with
> systemd and I think I've found a promising approach.  It involves having
> systemd take responsibility for the "run in the background" part.
> 
> If we get systemd-fstab-generator to translate "bg" to "retry=10000",
> then "mount.nfs" will behave like the background version of
> "mount.nfs -o bg".  i.e. it will retry for one month (nearly).   If there is
> already a 'retry=' option, we just strip the "bg".
> 
> For this to work, we would need to add
>    TimeoutSec=infinity
> to the .mount unit file so that systemd doesn't kill the mount.
> We would also need to add (the effect of) "nofail", so that systemd
> doesn't wait for the mount to complete...
> Except that the current implementation of "nofail" is faulty.
> It removes the default "Before=remote-fs.mount", which has the unwanted
> consequence of unmounting the filesystem too early at shutdown.
> 
> I have a solution for that too (which I'll submit a push request for
> shortly).
> My solution to "nofail" is to treat it much like "automount", but
> instead of using an automount unit to trigger the mount, we use
> a timer unit (with OnActiveSec=0).
> By triggering the mount unit with a timer instead of Wanting it
> directly, it gets run in a separate transaction.  This means that the
> "Before=remote-fs.target" doesn't have the effect of delaying
> remote-fs.target.  Before/After only order jobs within the one
> transaction.
> When it comes time to shutdown, remote-fs.target and the foo.mount will
> be in the same transaction, so the Before= will ensure foo.mount
> isn't unmounted until after remote-fs.target has been allows to finish,
> which is after any services that might be using the filesystem.
> 
> So I think I've found a solution for systemd to handle "bg" nfs mounts
> correctly.   I'll submit some pull requests for consideration.
Neil, your an excellent engineer so I'm sure you will craft 
something very cool...  but I truly feel you are breaking one 
of the NFS communities long standing golden rule... We never add 
fix to client that fixes a bug in the server... Fix the server... 

That is the case here, IMHO...  There is a bug in systemd that is not
letting a mount command succeed... It's clearly their bug, 
let them fix it... Again, why systemd looking at mount options
is just mind boggling... 

steved.
 
