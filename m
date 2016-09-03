Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:34617 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752924AbcICCzV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Sep 2016 22:55:21 -0400
Received: by mail-ua0-f172.google.com with SMTP id q42so134656644uaq.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Sep 2016 19:55:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <74a1f425-5ed2-2558-3233-558458fa69f2@RedHat.com>
References: <CA+X5Wn7oiaPyO+dN4ARb+Y4JuOqR90283par7-2NQvOtO_HOiQ@mail.gmail.com>
 <CA+X5Wn48mD-2hVwFsBSWhExmaMxL1HUAcB8MhXtnoVuFSWBBgQ@mail.gmail.com> <74a1f425-5ed2-2558-3233-558458fa69f2@RedHat.com>
From: james harvey <jamespharvey20@gmail.com>
Date: Fri, 2 Sep 2016 22:55:19 -0400
Message-ID: <CA+X5Wn7CFa9uCZPQZbB0aNs+gXf-CHaaEg5pNpTxWv=iVS+QkQ@mail.gmail.com>
Subject: Re: nfs-server (v4.x only) takes extra 6 minutes to start without rpcbind
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 2, 2016 at 8:38 PM, Steve Dickson <SteveD@redhat.com> wrote:
> On 09/01/2016 08:50 PM, james harvey wrote:
>> On Thu, Sep 1, 2016 at 7:22 AM, james harvey <jamespharvey20@gmail.com> wrote:
>>> Up to date Arch.  Kernel 4.7.2 (-1 Arch).  nfs-utils 1.3.4 (-1 Arch).
>>> No firewall running on this system.
>>>
>>> I started writing that an nfs-server configured for v4.x only would
>>> never start if there was no rpcbind, BUT wound up finding out it does
>>> start, it just takes ~ 6 minutes when with rpcbind it's "instant" /
>>> less than 1 second.
>>
>> Replicated on Fedora 24, kernel 4.6.7 (-300.fc24.x86_64), nfs-utils
>> 1.3.4 (-1.rc2.fc24), and rpcbind 0.2.3 (-11.rc1.fc24).
>>
>> {{{ fresh network iso install, using minimal install selection in
>> install GUI }}}
>> # yum install nfs-utils
>> # systemctl enable nfs-server
>> # vi /etc/sysconfig/nfs
>> {{{ RPCNFSDARGS="-N 2 -N 3" \ RPCMOUNTDOPTS="-N 2 -N 3" }}}
>> {{{ I've tried -N options with and without spaces, as I've seen it both ways }}}
>> # systemctl reboot
>>
>> Well, Fedora (as Arch does) starts nfs-server for v4.x just fine with
>> rpcbind.  Fedora fails to start nfs-idmapd with "/usr/sbin/rpc.idmapd:
>> symbol lookup error: /lib64/libnfsidmap.so.0: undefined symbol:
>> __dn_expand".  nfs-idmapd starts fine on Arch.
> This has been fixed by https://bodhi.fedoraproject.org/updates/FEDORA-2016-625bd99661
>
>>
>> Starting to started is "instant" (less than 1 second.)
>>
>>
>> But, moving on:
>> # systemctl mask rpcbind.service rpcbind.socket
>> # systemctl reboot
> There has been problems with systemd starting the listening
> socket... I wonder if this is yea another one...

FWIW, after nfs-server eventually starts, systemctl still shows
rpcbind.socket (and rpcbind.service) as masked, inactive, and dead.

Also /var/run/rpcbind.sock doesn't exist.

I disabled all related services, and rebooted with systemd debugging.
(Disabled them so they could be manually started with boot noise off
on its own.)

dmesg (with all the systemd debugging output) only mentions rpcbind
along with saying "Cannot add dependency job, ignoring: Unit
rpcbind.socket is masked."  Not looking to me like it's trying to
start it.

I'm not familiar with how the proc fs is handled internally.  IF this
were in the sys fs, which I am more familiar with, I would be thinking
whichever kernel module provided the show and store functions for
.../nfsd/portlist is taking a really long time to execute when it
can't connect to rpcbind.

This didn't wind up helping here, but turning on systemd debugging
showed me rpc-statd.service was trying to be started (as
nfs-server.service Wants it.)  Although masking rpc-statd.service
certainly prevents it from starting, it doesn't eliminate the long
delay.

The relevant part of the 6MB dmesg is:

==========
[   98.158892] systemd[1]: Mounted NFSD configuration filesystem.
[   98.161917] systemd[1]: Mounted RPC Pipe File System.
[   98.172261] systemd[1]: Starting Preprocess NFS configuration...
[   98.184153] systemd[1]: Started Preprocess NFS configuration.
[   98.185463] systemd[1]: Started NFS Mount Daemon.
[   98.187190] systemd[1]: Starting NFSv4 ID-name mapping service...
[   98.190856] systemd[1]: nfs-idmapd.service: Control process exited,
code=exited status=127
[   98.191561] systemd[1]: Failed to start NFSv4 ID-name mapping service.
[   98.192050] systemd[1]: nfs-idmapd.service: Unit entered failed state.
[   98.192813] systemd[1]: nfs-idmapd.service: Failed with result 'exit-code'.
[  393.992248] NFSD: starting 90-second grace period (net ffffffff81cfb7c0)
[  393.996640] systemd[1]: Received SIGCHLD from PID 788 (rpc.nfsd).
[  393.997043] systemd[1]: Child 788 (rpc.nfsd) died (code=exited,
status=0/SUCCESS)
[  393.997095] systemd[1]: nfs-server.service: Child 788 belongs to
nfs-server.service
[  393.997110] systemd[1]: nfs-server.service: Main process exited,
code=exited, status=0/SUCCESS
[  393.997444] systemd[1]: nfs-server.service: Changed start -> exited
[  393.997454] systemd[1]: nfs-server.service: Job
nfs-server.service/start finished, result=done
[  393.997466] systemd[1]: Started NFS server and services.
[  394.009311] systemd[1]: Starting Notify NFS peers of a restart...
[  394.031645] systemd[1]: Started Notify NFS peers of a restart.
==========



>> # systemctl status nfs-server
>> Sep 01 20:29:00 fedora systemd[1]: Starting NFS server and services...
>> Sep 01 20:35:22 fedora systemd[1]: Started NFS server and services
>>
>>
>> Then to strace:
>> # systemctl disable nfs-server
>> # systemctl reboot
>> # systemctl start nfs-config.service
>> {{{ proc-fs-nfsd.mount and var-lib-nfsd-rpc_pipefs.mount are already active }}}
>> # systemctl start nfs-idmapd
>> {{{ still fails with undefined symbol __dn_expand }}}
> Again this has been fixed...
>
>>
>> # rpc.mountd --foreground -N 2 -N 3
>>
>> {{{ another tty }}}
>> # strace rpc.nfsd --debug -N 2 -N 3 8
>>
>> Gives the attached strace output, which shows the same two really long
>> delays when reading or writing /proc/fs/nfsd/portlist.
>>
> I don't see the attachment...
>
> steved.

Strange, wonder if the list removed it - I do see it on my sent message.

Anyways, I just uploaded it here: http://pastebin.ca/3709748

The delays happen at lines 145-149, which print as one line, I just
broke it apart showing the characters that show on the line before and
after the delay.

Same at lines 166-170.
