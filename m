Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56332 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751762AbcICAiZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Sep 2016 20:38:25 -0400
Subject: Re: nfs-server (v4.x only) takes extra 6 minutes to start without
 rpcbind
To: james harvey <jamespharvey20@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <CA+X5Wn7oiaPyO+dN4ARb+Y4JuOqR90283par7-2NQvOtO_HOiQ@mail.gmail.com>
 <CA+X5Wn48mD-2hVwFsBSWhExmaMxL1HUAcB8MhXtnoVuFSWBBgQ@mail.gmail.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <74a1f425-5ed2-2558-3233-558458fa69f2@RedHat.com>
Date: Fri, 2 Sep 2016 20:38:23 -0400
MIME-Version: 1.0
In-Reply-To: <CA+X5Wn48mD-2hVwFsBSWhExmaMxL1HUAcB8MhXtnoVuFSWBBgQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 09/01/2016 08:50 PM, james harvey wrote:
> On Thu, Sep 1, 2016 at 7:22 AM, james harvey <jamespharvey20@gmail.com> wrote:
>> Up to date Arch.  Kernel 4.7.2 (-1 Arch).  nfs-utils 1.3.4 (-1 Arch).
>> No firewall running on this system.
>>
>> I started writing that an nfs-server configured for v4.x only would
>> never start if there was no rpcbind, BUT wound up finding out it does
>> start, it just takes ~ 6 minutes when with rpcbind it's "instant" /
>> less than 1 second.
> 
> Replicated on Fedora 24, kernel 4.6.7 (-300.fc24.x86_64), nfs-utils
> 1.3.4 (-1.rc2.fc24), and rpcbind 0.2.3 (-11.rc1.fc24).
> 
> {{{ fresh network iso install, using minimal install selection in
> install GUI }}}
> # yum install nfs-utils
> # systemctl enable nfs-server
> # vi /etc/sysconfig/nfs
> {{{ RPCNFSDARGS="-N 2 -N 3" \ RPCMOUNTDOPTS="-N 2 -N 3" }}}
> {{{ I've tried -N options with and without spaces, as I've seen it both ways }}}
> # systemctl reboot
> 
> Well, Fedora (as Arch does) starts nfs-server for v4.x just fine with
> rpcbind.  Fedora fails to start nfs-idmapd with "/usr/sbin/rpc.idmapd:
> symbol lookup error: /lib64/libnfsidmap.so.0: undefined symbol:
> __dn_expand".  nfs-idmapd starts fine on Arch.
This has been fixed by https://bodhi.fedoraproject.org/updates/FEDORA-2016-625bd99661

> 
> Starting to started is "instant" (less than 1 second.)
> 
> 
> But, moving on:
> # systemctl mask rpcbind.service rpcbind.socket
> # systemctl reboot
There has been problems with systemd starting the listening 
socket... I wonder if this is yea another one... 

> 
> # systemctl status nfs-server
> Sep 01 20:29:00 fedora systemd[1]: Starting NFS server and services...
> Sep 01 20:35:22 fedora systemd[1]: Started NFS server and services
> 
> 
> Then to strace:
> # systemctl disable nfs-server
> # systemctl reboot
> # systemctl start nfs-config.service
> {{{ proc-fs-nfsd.mount and var-lib-nfsd-rpc_pipefs.mount are already active }}}
> # systemctl start nfs-idmapd
> {{{ still fails with undefined symbol __dn_expand }}}
Again this has been fixed... 

> 
> # rpc.mountd --foreground -N 2 -N 3
> 
> {{{ another tty }}}
> # strace rpc.nfsd --debug -N 2 -N 3 8
> 
> Gives the attached strace output, which shows the same two really long
> delays when reading or writing /proc/fs/nfsd/portlist.
> 
I don't see the attachment... 

steved.
