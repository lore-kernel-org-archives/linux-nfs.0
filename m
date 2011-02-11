Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:37040 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757203Ab1BKRfy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Feb 2011 12:35:54 -0500
Received: by yib18 with SMTP id 18so1171711yib.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 09:35:54 -0800 (PST)
In-Reply-To: <665D28F4-A8C9-47E8-AE27-E1D960A1830B@oracle.com>
References: <AANLkTik_Y4_UpBx-OMaedXz34qc+zuVzN1B5A5qnzW5y@mail.gmail.com>
	<665D28F4-A8C9-47E8-AE27-E1D960A1830B@oracle.com>
Date: Fri, 11 Feb 2011 13:35:53 -0400
Message-ID: <AANLkTi=dgyOmf+to8waRi+piomovMM-H7_7GdzyhYuEo@mail.gmail.com>
Subject: Re: NFS only mount with -o udp option
From: Edgar Almonte <samudhio@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

i get this without udp option:

mount: no type was given - I'll assume nfs because of the colon
mount.nfs: timeout set for Fri Feb 11 13:27:33 2011
mount.nfs: trying text-based options
'vers=4,addr=192.168.1.102,clientaddr=192.168.1.103'
mount.nfs: mount(2): No such file or directory
mount.nfs: trying text-based options
'vers=4,addr=fe80::224:21ff:fe57:368d,clientaddr=::'
mount.nfs: mount(2): Input/output error
mount.nfs: mount system call failed


and with udp option:

ount: no type was given - I'll assume nfs because of the colon
mount.nfs: timeout set for Fri Feb 11 13:28:29 2011
mount.nfs: trying text-based options
'udp,vers=4,addr=192.168.1.102,clientaddr=192.168.1.103'
mount.nfs: mount(2): No such file or directory
mount.nfs: trying text-based options 'udp,addr=192.168.1.102'
mount.nfs: prog 100003, trying vers=3, prot=17
mount.nfs: trying 192.168.1.102 prog 100003 vers 3 prot UDP port 2049
mount.nfs: prog 100005, trying vers=3, prot=17
mount.nfs: trying 192.168.1.102 prog 100005 vers 3 prot UDP port 41044
heaven.local:/STORAGE on /nfs/STORAGE type nfs (rw,udp)


for other distro ( debian laptop ) without the udp option:

mount: no type was given - I'll assume nfs because of the colon
mount.nfs: timeout set for Fri Feb 11 13:31:37 2011
mount.nfs: trying text-based options
'vers=4,addr=192.168.1.102,clientaddr=192.168.1.107'
mount.nfs: mount(2): No such file or directory
mount.nfs: trying text-based options 'addr=192.168.1.102'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: trying 192.168.1.102 prog 100003 vers 3 prot TCP port 2049
mount.nfs: prog 100005, trying vers=3, prot=17
mount.nfs: trying 192.168.1.102 prog 100005 vers 3 prot UDP port 41044
heaven.local:/STORAGE on /srv/nfs type nfs (rw)


and look like is some ipv6 issues


On Thu, Feb 10, 2011 at 11:50 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Feb 9, 2011, at 7:59 PM, Edgar Almonte wrote:
>
>> hello list
>>
>> like the subject say after some upgrade of my distro ( i have 2
>> machine with the same distro and only in one happne the problem ) i
>> can only mount nfs share using the option -o udp , without it i get
>> this error
>> mount.nfs: mount system call failed
>
> What does
>
>  sudo mount.nfs heaven.local:/STORAGE /nfs/STORAGE -v
>
> say?  It should tell you how the mount command is negotiating with the server.
>
>> i am using avahi-dns ( mdns ) for hostname resolve
>>
>> command used:
>> mount heaven.local:/STORAGE /nfs/STORAGE/
>> check dns is work right :
>>
>> ping heaven.local
>> PING heaven.local (192.168.1.102) 56(84) bytes of data.
>> 64 bytes from heaven.local (192.168.1.102): icmp_seq=1 ttl=64 time=0.153 ms
>> 64 bytes from heaven.local (192.168.1.102): icmp_seq=2 ttl=64 time=0.160 ms
>> ^C
>> --- heaven.local ping statistics ---
>> 2 packets transmitted, 2 received, 0% packet loss, time 1001ms
>> rtt min/avg/max/mdev = 0.153/0.156/0.160/0.013 ms
>>
>>
>> anyidea what i need check for solve this issue ?
>>
>> thanks
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
>
