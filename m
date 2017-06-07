Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19469 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751805AbdFGTsG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Jun 2017 15:48:06 -0400
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and
 systemd.
To: Lennart Poettering <mzxreary@0pointer.de>
Cc: NeilBrown <neilb@suse.com>, systemd-devel@freedesktop.org,
        linux-nfs@vger.kernel.org
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
 <87lgp4dbx7.fsf@notabene.neil.brown.name>
 <2a7fd6d4-a965-02e0-3b7b-97c5743d7083@RedHat.com>
 <20170607120221.GJ27006@gardel-login>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <ce5c37b4-a81b-4eaf-c1ac-7f36488bdaa9@RedHat.com>
Date: Wed, 7 Jun 2017 15:48:04 -0400
MIME-Version: 1.0
In-Reply-To: <20170607120221.GJ27006@gardel-login>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/07/2017 08:02 AM, Lennart Poettering wrote:
> On Wed, 07.06.17 06:08, Steve Dickson (SteveD@RedHat.com) wrote:
> 
>>
>>
>> On 06/06/2017 05:49 PM, NeilBrown wrote:
>>> On Tue, Jun 06 2017, Steve Dickson wrote:
>>>
>>>> Hello,
>>>>
>>>> On 05/29/2017 06:19 PM, NeilBrown wrote:
>>>>>
>>>>> Systemd does not, and will not, support "bg" correctly.
>>>>> It has other, better, ways to handle "background" mounting.
>>>> The only problem with this is bg mounts still work at least
>>>> up to 4.11 kernel... 
>>>
>>> I don't think this is correct.
>>> In the default configuration, "mount -t nfs -o bg ...."
>>> runs for longer than 90 seconds, so systemd kill it.
>> I must be missing something... it seems to be working for me
>>
>> # mount -vvv -o bg rhel7srv:/home/tmp /mnt/tmp
>> mount.nfs: trying text-based options 'bg,vers=4.1,addr=172.31.1.60,clientaddr=172.31.1.58'
>> mount.nfs: mount(2): Connection refused
>> mount.nfs: trying text-based options 'bg,addr=172.31.1.60'
>> mount.nfs: prog 100003, trying vers=3, prot=6
>> mount.nfs: trying 172.31.1.60 prog 100003 vers 3 prot TCP port 2049
>> mount.nfs: portmap query failed: RPC: Remote system error - Connection refused
>> mount.nfs: backgrounding "rhel7srv:/home/tmp"
>> mount.nfs: mount options: "rw,bg"
> 
> We are talking about mounts done through /etc/fstab, i.e. the ones
> systemd actually manages.
I guess I was not clear... After adding a bg mount to fstab and
reboot, mounting a server that is not up, there is a mount in
background that looks like 

# ps ax | grep mount
 1104 ?        Ss     0:00 /sbin/mount.nfs nfssrv:/home/tmp /mnt/tmp -o rw,bg

Looking at the remote-fs.target status:

# systemctl status remote-fs.target 
* remote-fs.target - Remote File Systems
   Loaded: loaded (/usr/lib/systemd/system/remote-fs.target; enabled; vendor preset: enabled)
   Active: active since Tue 2017-06-06 12:36:51 EDT; 12min ago
     Docs: man:systemd.special(7)

Jun 06 12:36:51 f26.boston.devel.redhat.com systemd[1]: Reached target Remote File Systems.

It appears to be successful 

steved.
